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
#import "ChannelCover.h"
#import "GAI.h"
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
#import "SYNFeedMessagesView.h"

@interface SYNFeedRootViewController ()

@property (nonatomic, assign) BOOL refreshing;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) SYNHomeSectionHeaderView *supplementaryViewWithRefreshButton;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) SYNFeedMessagesView* emptyGenreMessageView;


@end



@implementation SYNFeedRootViewController

#pragma mark - View Lifecyclea


- (void) loadView
{
    BOOL isIPhone = [SYNDeviceManager.sharedInstance isIPhone];
    UIEdgeInsets insets;
    
    if (isIPhone)
    {
        insets = UIEdgeInsetsMake(10.0f, 10.0f, 15.0f, 10.0f);
    }
    else
    {
        insets = UIEdgeInsetsMake(10.0f, 10.0f, 15.0f, 10.0f);
    }
    
    
    SYNIntegralCollectionViewFlowLayout *standardFlowLayout;
    if (isIPhone)
        standardFlowLayout = [SYNIntegralCollectionViewFlowLayout
                              layoutWithItemSize:CGSizeMake(497.0f , 141.0f)
                              minimumInterItemSpacing:0.0f
                              minimumLineSpacing:10.0f
                              scrollDirection:UICollectionViewScrollDirectionVertical
                              sectionInset:insets];
    
    else
        standardFlowLayout = [SYNIntegralCollectionViewFlowLayout
                              layoutWithItemSize:CGSizeMake(497.0f , 141.0f)
                              minimumInterItemSpacing:0.0f
                              minimumLineSpacing:30.0f
                              scrollDirection:UICollectionViewScrollDirectionVertical
                              sectionInset:insets];
    
    
    standardFlowLayout.footerReferenceSize = [self footerSize];
    
    CGRect videoCollectionViewFrame, selfFrame;
    
    if (isIPhone)
    {
        CGSize screenSize= CGSizeMake([SYNDeviceManager.sharedInstance currentScreenWidth],[SYNDeviceManager.sharedInstance currentScreenHeight]);
        videoCollectionViewFrame = CGRectMake(0.0, kStandardCollectionViewOffsetYiPhone, screenSize.width, screenSize.height - 20.0f - kStandardCollectionViewOffsetYiPhone);
        selfFrame = CGRectMake(0.0, 0.0, screenSize.width, screenSize.height - 20.0f);
    }
    else
    {
        videoCollectionViewFrame = CGRectMake(0.0, kStandardCollectionViewOffsetY, kFullScreenWidthLandscape, kFullScreenHeightLandscapeMinusStatusBar - kStandardCollectionViewOffsetY);
        selfFrame = CGRectMake(0.0, 0.0, kFullScreenWidthLandscape, kFullScreenHeightLandscapeMinusStatusBar);
    }
    
    self.videoThumbnailCollectionView = [[UICollectionView alloc] initWithFrame: videoCollectionViewFrame
                                                           collectionViewLayout:standardFlowLayout];
    self.videoThumbnailCollectionView.delegate = self;
    self.videoThumbnailCollectionView.dataSource = self;
    self.videoThumbnailCollectionView.backgroundColor = [UIColor clearColor];
    
    if (isIPhone)
    {
        self.videoThumbnailCollectionView.contentInset = UIEdgeInsetsMake(4, 0, 0, 0);
    }
    
    else
    {
        self.videoThumbnailCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }

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
    
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame: CGRectMake(0, -44, 320, 44)];
    
    [self.refreshControl addTarget: self
                            action: @selector(loadAndUpdateFeedData)
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
    
    // Register Footer
    UINib *footerViewNib = [UINib nibWithNibName: @"SYNChannelFooterMoreView"
                                          bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: footerViewNib
                          forSupplementaryViewOfKind: UICollectionElementKindSectionFooter
                                 withReuseIdentifier: @"SYNChannelFooterMoreView"];
    
    // == Refresh button == //
    self.refreshButton = [SYNRefreshButton refreshButton];
    
    [self.refreshButton addTarget: self
                           action: @selector(refreshButtonPressed)
                 forControlEvents: UIControlEventTouchUpInside];
    
    CGRect refreshButtonFrame = self.refreshButton.frame;
    refreshButtonFrame.origin.x = [SYNDeviceManager.sharedInstance isIPad]? 5.0f  : 5.0f;
    refreshButtonFrame.origin.y = [SYNDeviceManager.sharedInstance isIPad]? 7.0f : 5.0f;
    self.refreshButton.frame = refreshButtonFrame;
    [self.view addSubview: self.refreshButton];
    
    self.dataRequestRange = NSMakeRange(0, STANDARD_REQUEST_LENGTH);
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear:animated];
    
    // Google analytics support
    [self updateAnalytics];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoQueueCleared)
                                                 name:kVideoQueueClear
                                               object:nil];
    
    
    
    [self loadAndUpdateFeedData];
    
    
}

-(void)videoQueueCleared
{
    // this will remove the '+' from the videos that where selected
    [self.videoThumbnailCollectionView reloadData];
}
- (void) viewDidScrollToFront
{
    [self updateAnalytics];
    
    [self refreshButtonPressed];
}


- (void) updateAnalytics
{
    // Google analytics support
    [GAI.sharedInstance.defaultTracker sendView: viewId];
}


- (void) refreshButtonPressed
{
    [self.refreshButton startRefreshCycle];
    [self loadAndUpdateFeedData];
}


- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                 duration: (NSTimeInterval) duration
{
    [super willRotateToInterfaceOrientation: toInterfaceOrientation
                                   duration: duration];
    
    [self.videoThumbnailCollectionView reloadData];
}




- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{
  
    
}


- (void) loadAndUpdateFeedData
{
    
    [self.refreshButton startRefreshCycle];
    
    [appDelegate.oAuthNetworkEngine subscriptionsUpdatesForUserId:  appDelegate.currentOAuth2Credentials.userId
                                                            start: self.dataRequestRange.location
                                                             size: self.dataRequestRange.length
                                                completionHandler: ^(NSDictionary *responseDictionary) {
                                                    
                                                    BOOL toAppend = (self.dataRequestRange.location > 0);
                                                    
                                                    BOOL registryResultOk = [appDelegate.mainRegistry registerDataForFeedFromDictionary: responseDictionary
                                                                                                                            byAppending: toAppend];
                                                    
                                                    NSNumber* totalNumber = [[responseDictionary objectForKey:@"videos"] objectForKey:@"total"];
                                                    if(totalNumber && ![totalNumber isKindOfClass:[NSNull class]])
                                                        self.dataItemsAvailable = [totalNumber integerValue];
                                                    else
                                                        self.dataItemsAvailable = self.dataRequestRange.length;
                                                    
                                                    if (!registryResultOk)
                                                    {
                                                        DebugLog(@"Refresh subscription updates failed");
                                                        
                                                        return;
                                                    }
                                                    
                                                    
                                                    [self.videoThumbnailCollectionView reloadData];
                                                    
                                                    if(self.fetchedResultsController.fetchedObjects.count == 0)
                                                        [self displayEmptyGenreMessage];
                                                    else
                                                        [self removeEmptyGenreMessage];
                                                    
                                                    self.footerView.showsLoading = NO;
                                                    
                                                    [self handleRefreshComplete];
                                                    
                                                } errorHandler: ^(NSDictionary* errorDictionary) {
                                                    
                                                         [self handleRefreshComplete];
                                                         DebugLog(@"Refresh subscription updates failed");
                                                     }];
}


- (void) handleRefreshComplete
{
    self.refreshing = FALSE;
    [self.refreshControl endRefreshing];
    [self.refreshButton endRefreshCycle];
}


- (void) clearedLocationBoundData
{
    [self loadAndUpdateFeedData];
    
}

-(void)removeEmptyGenreMessage
{
    if(!self.emptyGenreMessageView)
        return;
    
    [self.emptyGenreMessageView removeFromSuperview];
}

- (void) displayEmptyGenreMessage
{
    
    if (self.emptyGenreMessageView)
        return;
    
    self.emptyGenreMessageView = [SYNFeedMessagesView withMessage:@"Your feed looks a little empty!"];
    
    self.emptyGenreMessageView.center = CGPointMake(self.view.center.x, 280.0);
    self.emptyGenreMessageView.frame = CGRectIntegral(self.emptyGenreMessageView.frame);
    
    [self.view addSubview:self.emptyGenreMessageView];
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
    
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"viewId == \"%@\" AND fresh == YES", kFeedViewId]];
 
    fetchRequest.predicate = predicate;

    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"dateAdded" ascending: NO]];
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                        managedObjectContext: appDelegate.mainManagedObjectContext
                                                                          sectionNameKeyPath: @"dateAddedIgnoringTime"
                                                                                   cacheName: nil];
    fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![fetchedResultsController performFetch: &error])
    {
        AssertOrLog(@"videoInstanceFetchedResultsController:performFetch failed: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    
    return fetchedResultsController;
}


#pragma mark - UICollectionView Delegate

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return self.fetchedResultsController.sections.count;
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
    if([SYNDeviceManager.sharedInstance isIPhone])
    {
        return CGSizeMake(310,221);
    }
    else if([SYNDeviceManager.sharedInstance isLandscape])
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
                                      placeholderImage: [UIImage imageNamed: @"PlaceholderVideoWide.png"]
                                               options: SDWebImageRetryFailed];

    [videoThumbnailCell.channelImageView setImageWithURL: [NSURL URLWithString: videoInstance.channel.channelCover.imageSmallUrl]
                                        placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                                                 options: SDWebImageRetryFailed];
    
    videoThumbnailCell.channelImageView.hidden = [SYNDeviceManager.sharedInstance isPortrait]
                                                 && [SYNDeviceManager.sharedInstance isIPad];
    
    videoThumbnailCell.channelShadowView.hidden = [SYNDeviceManager.sharedInstance isPortrait]
                                                  && [SYNDeviceManager.sharedInstance isIPad];
    
    videoThumbnailCell.videoTitle.text = videoInstance.title;
    
    videoThumbnailCell.channelNameText = videoInstance.channel.title;
    
    videoThumbnailCell.usernameText = [NSString stringWithFormat: @"%@", videoInstance.channel.channelOwner.displayName];
    
    videoThumbnailCell.addItButton.highlighted = NO;
    videoThumbnailCell.addItButton.selected = [appDelegate.videoQueue videoInstanceIsAddedToChannel:videoInstance];;
    
    
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
        if([SYNDeviceManager.sharedInstance isIPad])
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
    
    UICollectionReusableView *supplementaryView = nil;
    
    // Work out the day
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex: indexPath.section];
    
    // In the 'name' attribut of the sectionInfo we have actually the keypath data (i.e in this case Date without time)
    
    // TODO: We might want to optimise this instead of creating a new date formatter each time
    
    if (kind == UICollectionElementKindSectionHeader)
    {
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
            sectionText = NSLocalizedString(@"TODAY", nil);
        }
        else if ([date isYesterday])
        {
            sectionText = NSLocalizedString(@"YESTERDAY", nil);
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
        if ([SYNDeviceManager.sharedInstance isLandscape])
        {
            headerSupplementaryView.sectionView.image = [UIImage imageNamed:@"PanelDay"];
        }
        else
        {
            headerSupplementaryView.sectionView.image = [UIImage imageNamed:@"PanelDayPortrait"];
        }
        
        supplementaryView = headerSupplementaryView;
    }
    
    else if (kind == UICollectionElementKindSectionFooter)
    {
        if(indexPath.section < self.fetchedResultsController.sections.count - 1)
            return supplementaryView;
        
        if(self.fetchedResultsController.fetchedObjects.count == 0 ||
           (self.dataRequestRange.location + self.dataRequestRange.length) >= self.dataItemsAvailable)
        {
            return supplementaryView;
        }
        
        self.footerView = [self.videoThumbnailCollectionView dequeueReusableSupplementaryViewOfKind: kind
                                                                                withReuseIdentifier: @"SYNChannelFooterMoreView"
                                                                                       forIndexPath: indexPath];
        
        [self.footerView.loadMoreButton addTarget: self
                                           action: @selector(loadMoreVideos:)
                                 forControlEvents: UIControlEventTouchUpInside];
        
        //[self loadMoreChannels:self.footerView.loadMoreButton];
        
        supplementaryView = self.footerView;
    }

    return supplementaryView;
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

#pragma mark - Load More Footer



- (void) loadMoreVideos: (UIButton*) sender
{
    
    [self incrementRangeForNextRequest];
    
    [self loadAndUpdateFeedData];
    
    
}

- (BOOL) needsAddButton
{
    return YES;
}







@end
