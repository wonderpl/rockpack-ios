//
//  SYNHomeTopTabViewController.m
//  rockpack
//
//  Created by Nick Banks on 07/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "NSDate-Utilities.h"
#import "SYNAppDelegate.h"
#import "SYNFeedRootViewController.h"
#import "SYNHomeSectionHeaderView.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNVideoThumbnailWideCell.h"
#import "Video.h"
#import "VideoInstance.h"
#import "SYNDeviceManager.h"
#import "UIImageView+WebCache.h"
#import "SYNRefreshButton.h"

@interface SYNFeedRootViewController ()

@property (nonatomic, assign) BOOL refreshing;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) SYNHomeSectionHeaderView *supplementaryViewWithRefreshButton;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) SYNRefreshButton* refreshButton;

@end



@implementation SYNFeedRootViewController

#pragma mark - View Lifecycle

- (id) initWithViewId: (NSString *) vid
{
    if ((self = [super initWithViewId: vid]))
    {
        self.title = kFeedTitle;
    }
    
    return self;
}


- (void) loadView
{
    BOOL isIPhone = [[SYNDeviceManager sharedInstance] isIPhone];
    UIEdgeInsets insets;
    if(isIPhone)
    {
        insets = UIEdgeInsetsMake(10.0f, 10.0f, 15.0f, 10.0f);
    }
    else
    {
        insets = UIEdgeInsetsMake(10.0f, 10.0f, 15.0f, 10.0f);
    }
    
    
    SYNIntegralCollectionViewFlowLayout *standardFlowLayout;
    if(isIPhone)
    {
        standardFlowLayout = [SYNIntegralCollectionViewFlowLayout
                              layoutWithItemSize:CGSizeMake(497.0f , 141.0f)
                              minimumInterItemSpacing:0.0f
                              minimumLineSpacing:10.0f
                              scrollDirection:UICollectionViewScrollDirectionVertical
                              sectionInset:insets];
    }
    else
    {
        standardFlowLayout = [SYNIntegralCollectionViewFlowLayout
                              layoutWithItemSize:CGSizeMake(497.0f , 141.0f)
                              minimumInterItemSpacing:0.0f
                              minimumLineSpacing:30.0f
                              scrollDirection:UICollectionViewScrollDirectionVertical
                              sectionInset:insets];
    }
    
    CGRect videoCollectionViewFrame, selfFrame;
    if(isIPhone)
    {
        CGSize screenSize= CGSizeMake([[SYNDeviceManager sharedInstance]currentScreenWidth],[[SYNDeviceManager sharedInstance]currentScreenHeight]);
        videoCollectionViewFrame = CGRectMake(0.0, kStandardCollectionViewOffsetYiPhone, screenSize.width, screenSize.height - 20.0f - kStandardCollectionViewOffsetYiPhone);
        selfFrame = CGRectMake(0.0, 0.0, screenSize.width, screenSize.height - 20.0f);
    }
    else
    {
        videoCollectionViewFrame = CGRectMake(0.0, kStandardCollectionViewOffsetY, kFullScreenWidthLandscape, kFullScreenHeightLandscapeMinusStatusBar - kStandardCollectionViewOffsetY);
        selfFrame = CGRectMake(0.0, 0.0, kFullScreenWidthLandscape, kFullScreenHeightLandscapeMinusStatusBar);
    }
    self.videoThumbnailCollectionView = [[UICollectionView alloc] initWithFrame:videoCollectionViewFrame collectionViewLayout:standardFlowLayout];
    self.videoThumbnailCollectionView.delegate = self;
    self.videoThumbnailCollectionView.dataSource = self;
    self.videoThumbnailCollectionView.backgroundColor = [UIColor clearColor];

    self.view = [[UIView alloc] initWithFrame:selfFrame];
    
    [self.view addSubview:self.videoThumbnailCollectionView];
    self.view.backgroundColor = [UIColor clearColor];
    self.videoThumbnailCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight;
    
    // We should only setup our date formatter once
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss Z";
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Google Analytics support
    self.trackedViewName = @"Feed";
    
    // == Refresh button == //
    
    
    self.refreshButton = [SYNRefreshButton refreshButton];
    [self.refreshButton addTarget:self
                           action:@selector(refreshButtonPressed)
                 forControlEvents:UIControlEventTouchUpInside];
    
    CGRect refreshButtonFrame = self.refreshButton.frame;
    refreshButtonFrame.origin.x = [[SYNDeviceManager sharedInstance] isIPad]? 10.0  : 63.0;
    refreshButtonFrame.origin.y = [[SYNDeviceManager sharedInstance] isIPad]? 40.0 : 10.0;
    self.refreshButton.frame = refreshButtonFrame;
    
    [self.view addSubview:self.refreshButton];
    
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame: CGRectMake(0, -44, 320, 44)];
    
    [self.refreshControl addTarget: self
                            action: @selector(refreshVideoThumbnails)
                  forControlEvents: UIControlEventValueChanged];
    
    
    [self.videoThumbnailCollectionView addSubview: self.refreshControl];

    // Init collection view
    UINib *videoThumbnailCellNib = [UINib nibWithNibName: @"SYNVideoThumbnailWideCell"
                                                  bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: videoThumbnailCellNib
                        forCellWithReuseIdentifier: @"SYNVideoThumbnailWideCell"];
    
    // Register collection view header view
    UINib *headerViewNib = [UINib nibWithNibName: @"SYNHomeSectionHeaderView"
                                          bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: headerViewNib
                        forSupplementaryViewOfKind: UICollectionElementKindSectionHeader
                               withReuseIdentifier: @"SYNHomeSectionHeaderView"];
    
    [self refreshVideoThumbnails];
}

-(void)refreshButtonPressed
{
    [self.refreshButton startRefreshCycle];
    [self refreshVideoThumbnails];
}

- (void) refreshCycleComplete
{
    [self.refreshButton endRefreshCycle];
}

-(void)viewCameToScrollFront
{
    [self refreshButtonPressed];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear:animated];
    
    [self.videoThumbnailCollectionView reloadData];
}


- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                 duration: (NSTimeInterval) duration
{
    [super willRotateToInterfaceOrientation: toInterfaceOrientation
                                   duration: duration];
    [self reloadCollectionViews];
}


- (void) reloadCollectionViews
{
    [self.videoThumbnailCollectionView reloadData];
}


- (void) refreshVideoThumbnails
{
    [appDelegate.oAuthNetworkEngine subscriptionsUpdatesForUserId:  appDelegate.currentOAuth2Credentials.userId
                                                            start: 0
                                                             size: 0
                                                completionHandler: ^(NSDictionary *responseDictionary) {
                                                    [self handleRefreshComplete];
                                                    DebugLog(@"Refresh subscription updates successful");
                                                } errorHandler: ^(NSDictionary* errorDictionary) {
                                                    [self handleRefreshComplete];
                                                    DebugLog(@"Refresh subscription updates failed");
                                                }];
}

- (void) handleRefreshComplete
{
    self.refreshing = FALSE;
    [self.refreshControl endRefreshing];
    [[NSNotificationCenter defaultCenter] postNotificationName: kRefreshComplete
                                                        object: self];
}


#pragma mark - Fetched results

- (NSFetchedResultsController *) fetchedResultsController
{
    if (fetchedResultsController)
        return fetchedResultsController;
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    fetchRequest.entity = [NSEntityDescription entityForName: @"VideoInstance"
                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"viewId == \"%@\"", viewId]];
    
    fetchRequest.sortDescriptors = @[
                                     [[NSSortDescriptor alloc] initWithKey: @"dateAdded" ascending: NO]
                                     ];
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                        managedObjectContext: appDelegate.mainManagedObjectContext
                                                                          sectionNameKeyPath: @"dateAddedIgnoringTime"
                                                                                   cacheName: nil];
    fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    ZAssert([fetchedResultsController performFetch: &error], @"videoInstanceFetchedResultsController:performFetch failed: %@\n%@", [error localizedDescription], [error userInfo]);
    
    return fetchedResultsController;
}


#pragma mark - UICollectionView Delegate

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    if (collectionView == self.videoThumbnailCollectionView)
    {
        return self.fetchedResultsController.sections.count;
    }
    else
    {
        return 1;
    }
}


- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger) section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return sectionInfo.numberOfObjects;
    
}


- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout*) collectionViewLayout
   sizeForItemAtIndexPath: (NSIndexPath *) indexPath
{
    if([[SYNDeviceManager sharedInstance] isIPhone])
    {
        return CGSizeMake(310,221);
    }
    else if([[SYNDeviceManager sharedInstance] isLandscape])
    {
        return CGSizeMake(497, 140);
    }
    else
    {
        return CGSizeMake(370, 140);
    }
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    UICollectionViewCell *cell = nil;
    
    VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    SYNVideoThumbnailWideCell *videoThumbnailCell = [cv dequeueReusableCellWithReuseIdentifier: @"SYNVideoThumbnailWideCell"
                                                                                  forIndexPath: indexPath];

    [videoThumbnailCell.videoImageView setImageWithURL: [NSURL URLWithString: videoInstance.video.thumbnailURL]
                                      placeholderImage: [UIImage imageNamed: @"PlaceholderVideoThumbnailWide.png"]
                                               options: SDWebImageRetryFailed];
    
    [videoThumbnailCell.channelImageView setImageWithURL: [NSURL URLWithString: videoInstance.channel.coverThumbnailSmallURL]
                                        placeholderImage: [UIImage imageNamed: @"PlaceholderChannelThumbnail.png"]
                                                 options: SDWebImageRetryFailed];
    
    videoThumbnailCell.channelImageView.hidden = [[SYNDeviceManager sharedInstance] isPortrait]
                                                 && [[SYNDeviceManager sharedInstance] isIPad];
    
    videoThumbnailCell.channelShadowView.hidden = [[SYNDeviceManager sharedInstance] isPortrait]
                                                  && [[SYNDeviceManager sharedInstance] isIPad];
    
    videoThumbnailCell.videoTitle.text = videoInstance.title;
    videoThumbnailCell.channelNameText = videoInstance.channel.title;
    videoThumbnailCell.usernameText = [NSString stringWithFormat: @"%@", videoInstance.channel.channelOwner.displayName];
    videoThumbnailCell.addItButton.highlighted = NO;
    videoThumbnailCell.addItButton.selected = [appDelegate.videoQueue videoInstanceIsAddedToChannel:videoInstance];
    
    
    videoThumbnailCell.viewControllerDelegate = self;
    
    cell = videoThumbnailCell;
    
    return cell;
}


- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout*) collectionViewLayout
                   referenceSizeForHeaderInSection: (NSInteger) section
{
    if (collectionView == self.videoThumbnailCollectionView)
    {
        if([[SYNDeviceManager sharedInstance] isIPad])
        {
            return CGSizeMake(1024, 65);   
        }
        return CGSizeMake(320, 34);
    }
    else
    {
        return CGSizeMake(0, 0);
    }
}


// Used for the collection view header
- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
    
    UICollectionReusableView *sectionSupplementaryView = nil;
    
    if (collectionView == self.videoThumbnailCollectionView)
    {
        // Work out the day
        id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex: indexPath.section];
        
        // In the 'name' attribut of the sectionInfo we have actually the keypath data (i.e in this case Date without time)
        
        // TODO: We might want to optimise this instead of creating a new date formatter each time

        
        NSDate *date = [self.dateFormatter dateFromString: sectionInfo.name];
        
        SYNHomeSectionHeaderView *headerSupplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind: kind
                                                                                               withReuseIdentifier: @"SYNHomeSectionHeaderView"
                                                                                                      forIndexPath: indexPath];
        NSString *sectionText;
        BOOL focus = FALSE;
        
        if (indexPath.section == 0)
        {
            // When highlighting is required again, then set to TRUE
            focus = FALSE;
            
            // We need to store this away, so can control animations (but must nil when goes out of scope)
            self.supplementaryViewWithRefreshButton = headerSupplementaryView;
        }
        
        // Unavoidably long if-then-else
        if ([date isToday])
        {
            sectionText = @"TODAY";
        }
        else if ([date isYesterday])
        {
            sectionText = @"YESTERDAY";
        }
        else if ([date isLast7Days])
        {
            sectionText = date.weekdayString;
        }
        else if ([date isThisYear])
        {
            sectionText = date.shortDateWithOrdinalString;
        }
        else
        {
            sectionText = date.shortDateWithOrdinalStringAndYear;
        }
        
        // Special case, remember the first section view
        headerSupplementaryView.viewControllerDelegate = self;
        headerSupplementaryView.focus = focus;
        headerSupplementaryView.sectionTitleLabel.text = sectionText.uppercaseString;
        if ([[SYNDeviceManager sharedInstance] isLandscape])
        {
            headerSupplementaryView.sectionView.image = [UIImage imageNamed:@"PanelDay"];
        }
        else
        {
            headerSupplementaryView.sectionView.image = [UIImage imageNamed:@"PanelDayPortrait"];
        }
        
        sectionSupplementaryView = headerSupplementaryView;
    }

    return sectionSupplementaryView;
}

- (void) collectionView: (UICollectionView *) collectionView
       didEndDisplayingSupplementaryView: (UICollectionReusableView *) view
       forElementOfKind: (NSString *) elementKind
            atIndexPath: (NSIndexPath *) indexPath
{
    if (collectionView == self.videoThumbnailCollectionView)
    {
        if (indexPath.section == 0)
        {
            // If out first section header leave the screen, then we need to ensure that we don't try and manipulate it
            //  in future (as it will no longer exist)
            self.supplementaryViewWithRefreshButton = nil;
        }
    }
    else
    {
        // We should not be expecting any other supplementary views
        AssertOrLog(@"No valid collection view found");
    }
}


- (BOOL) needsAddButton
{
    return YES;
}


#pragma mark - UI Actions

- (void) refresh
{
    [self refreshVideoThumbnails];
}

- (IBAction) touchVideoAddItButton: (UIButton *) addItButton
{
    DebugLog (@"No implementation yet");
}





@end
