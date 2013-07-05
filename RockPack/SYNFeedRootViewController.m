    //
//  SYNHomeTopTabViewController.m
//  rockpack
//
//  Created by Nick Banks on 07/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "Channel.h"
#import "ChannelCover.h"
#import "ChannelOwner.h"
#import "GAI.h"
#import "NSDate-Utilities.h"
#import "SYNAppDelegate.h"
#import "SYNDeviceManager.h"
#import "SYNFeedMessagesView.h"
#import "SYNFeedRootViewController.h"
#import "SYNHomeSectionHeaderView.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNVideoThumbnailWideCell.h"
#import "UIImageView+WebCache.h"
#import "Video.h"
#import "VideoInstance.h"

@interface SYNFeedRootViewController ()

@property (nonatomic, assign) BOOL refreshing;
@property (nonatomic, assign) BOOL shouldReloadCollectionView;
@property (nonatomic, strong) NSBlockOperation *blockOperation;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) SYNFeedMessagesView* emptyGenreMessageView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, weak) SYNVideoThumbnailWideCell* selectedCell; 

@end


@implementation SYNFeedRootViewController

#pragma mark - Object lifecycle

- (void) dealloc
{
    // No harm in removing all notifications, as we are being de-alloced after all..
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    // Defensive programming
    self.videoThumbnailCollectionView.delegate = nil;
}


#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    SYNIntegralCollectionViewFlowLayout *standardFlowLayout;
    UIEdgeInsets sectionInset, contentInset;
    CGRect videoCollectionViewFrame, calculatedViewFrame;
    CGSize screenSize;
    CGFloat minimumLineSpacing;
    
    // Setup device dependent parametes/dimensions
    BOOL isIPhone = [SYNDeviceManager.sharedInstance isIPhone];
    
    if (isIPhone)
    {
        // Calculate frame size
        screenSize = CGSizeMake([SYNDeviceManager.sharedInstance currentScreenWidth], [SYNDeviceManager.sharedInstance currentScreenHeight]);
        
        calculatedViewFrame = CGRectMake(0.0, 0.0, screenSize.width, screenSize.height - 20.0f);
        
        videoCollectionViewFrame = CGRectMake(0.0, kStandardCollectionViewOffsetYiPhone, screenSize.width, screenSize.height - 20.0f - kStandardCollectionViewOffsetYiPhone);
        
        // Collection view parameters
        contentInset = UIEdgeInsetsMake(4, 0, 0, 0);
        sectionInset = UIEdgeInsetsMake(10.0f, 10.0f, 15.0f, 10.0f);
        minimumLineSpacing = 10.0f;
        
    }
    else
    {
        calculatedViewFrame = CGRectMake(0.0, 0.0, kFullScreenWidthLandscape, kFullScreenHeightLandscapeMinusStatusBar);
        
        videoCollectionViewFrame = CGRectMake(0.0, kStandardCollectionViewOffsetY, kFullScreenWidthLandscape, kFullScreenHeightLandscapeMinusStatusBar - kStandardCollectionViewOffsetY);
        
        // Collection view parameters
        contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        sectionInset = UIEdgeInsetsMake(10.0f, 10.0f, 15.0f, 10.0f);
        minimumLineSpacing = 30.0f;
    }
    
    // Set our view frame and attributes
    self.view.frame = calculatedViewFrame;
    self.view.backgroundColor = [UIColor clearColor];
    
    [self removeEmptyGenreMessage];
    
    // Setup out collection view layout
    standardFlowLayout = [SYNIntegralCollectionViewFlowLayout layoutWithItemSize: CGSizeMake(497.0f , 141.0f)
                                                         minimumInterItemSpacing: 0.0f
                                                              minimumLineSpacing: minimumLineSpacing
                                                                 scrollDirection: UICollectionViewScrollDirectionVertical
                                                                    sectionInset: sectionInset];
    standardFlowLayout.footerReferenceSize = [self footerSize];
    
    // Setup the collection view itself
    self.videoThumbnailCollectionView = [[UICollectionView alloc] initWithFrame: videoCollectionViewFrame
                                                           collectionViewLayout: standardFlowLayout];
    
    self.videoThumbnailCollectionView.delegate = self;
    self.videoThumbnailCollectionView.dataSource = self;
    self.videoThumbnailCollectionView.backgroundColor = [UIColor clearColor];
    self.videoThumbnailCollectionView.scrollsToTop = NO;
    self.videoThumbnailCollectionView.contentInset = contentInset;
    [self.view addSubview:self.videoThumbnailCollectionView];

    self.videoThumbnailCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight;
    
    [self.videoThumbnailCollectionView addSubview: self.refreshControl];

    // Register collection view cells
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
    
    // Refresh control
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame: CGRectMake(0, -44, 320, 44)];
    
    self.refreshControl.tintColor = [UIColor colorWithRed: (11.0/255.0)
                                                    green: (166.0/255.0)
                                                     blue: (171.0/255.0)
                                                    alpha: (1.0)];
    
    [self.refreshControl addTarget: self
                            action: @selector(loadAndUpdateOriginalFeedData)
                  forControlEvents: UIControlEventValueChanged];
    
    // We should only setup our date formatter once
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss Z";
    
    // Log
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(videoQueueCleared)
                                                 name: kVideoQueueClear
                                               object: nil];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    // Google analytics support
    [self updateAnalytics];
}


- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    [self displayEmptyGenreMessage: NSLocalizedString(@"feed_screen_loading_message", nil)
                         andLoader: YES];
    
    [self loadAndUpdateFeedData];
}


- (void) videoQueueCleared
{
    // this will remove the '+' from the videos that where selected
    [self.videoThumbnailCollectionView reloadData];
}

#pragma mark - Container Scrol Delegates

- (void) viewDidScrollToFront
{
    [self updateAnalytics];
    
    self.videoThumbnailCollectionView.scrollsToTop = YES;
    
    // if the user has not pressed load more
    if(self.dataRequestRange.location == 0)
    {
        [self resetDataRequestRange]; // just in case the length is less than standard
        [self.refreshButton startRefreshCycle];
        [self loadAndUpdateFeedData];
       
    }
}


- (void) viewDidScrollToBack
{
    self.videoThumbnailCollectionView.scrollsToTop = NO;
}


- (void) updateAnalytics
{
    // Google analytics support
    [GAI.sharedInstance.defaultTracker sendView: @"Feed"];
}


- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                 duration: (NSTimeInterval) duration
{
    [super willRotateToInterfaceOrientation: toInterfaceOrientation
                                   duration: duration];
    
    [self.videoThumbnailCollectionView reloadData];
}


-(void) loadAndUpdateOriginalFeedData
{
    [self resetDataRequestRange];
    [self loadAndUpdateFeedData];
    
}


- (void) loadAndUpdateFeedData
{
    self.loadingMoreContent = YES;
    
    NSLog (@"Loc %d, Len %d", self.dataRequestRange.location, self.dataRequestRange.length);
    
    if(!appDelegate.currentOAuth2Credentials.userId)
        return;

    [self.refreshButton startRefreshCycle];
    
    [appDelegate.oAuthNetworkEngine subscriptionsUpdatesForUserId: appDelegate.currentOAuth2Credentials.userId
                                                            start: self.dataRequestRange.location
                                                             size: self.dataRequestRange.length
                                                completionHandler: ^(NSDictionary *responseDictionary) {
                                                    
                                                    BOOL toAppend = (self.dataRequestRange.location > 0);
                                                    
                                                    BOOL registryResultOk = [appDelegate.mainRegistry registerDataForFeedFromDictionary: responseDictionary
                                                                                                                            byAppending: toAppend];
                                                    
                                                    NSNumber* totalNumber = responseDictionary[@"videos"][@"total"];
                                                    if(totalNumber && ![totalNumber isKindOfClass:[NSNull class]])
                                                        self.dataItemsAvailable = [totalNumber integerValue];
                                                    else
                                                        self.dataItemsAvailable = self.dataRequestRange.length; // heuristic 
                                                    
                                                    if (!registryResultOk)
                                                    {
                                                        DebugLog(@"Refresh subscription updates failed");
                                                        
                                                        return;
                                                    }
                                                    
                                                    [self removeEmptyGenreMessage];
                                                    
                                                    if(self.fetchedResultsController.fetchedObjects.count == 0)
                                                        [self displayEmptyGenreMessage:NSLocalizedString(@"feed_screen_empty_message", nil) andLoader:NO];
                                                    
                                                    self.loadingMoreContent = NO;
                                                    
                                                    [self handleRefreshComplete];
                                                    
                                                } errorHandler: ^(NSDictionary* errorDictionary) {
                                                    
                                                    [self handleRefreshComplete];
                                                    
                                                    [self removeEmptyGenreMessage];
                                                    
                                                    [self displayEmptyGenreMessage:NSLocalizedString(@"feed_screen_loading_error", nil) andLoader:NO];
                                                    
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
    [self.videoThumbnailCollectionView reloadData];
    
    [self loadAndUpdateFeedData];
    
}

#pragma mark - Empty genre message handling

- (void) removeEmptyGenreMessage
{
    if (!self.emptyGenreMessageView)
        return;
    
    [self.emptyGenreMessageView removeFromSuperview];
}


- (void) displayEmptyGenreMessage: (NSString*) messageKey
                        andLoader: (BOOL) isLoader
{
    
    if (self.emptyGenreMessageView)
    {
        [self.emptyGenreMessageView removeFromSuperview];
        self.emptyGenreMessageView = nil;
    }
    
    self.emptyGenreMessageView = [SYNFeedMessagesView withMessage:NSLocalizedString(messageKey ,nil) andLoader:isLoader];
    
    CGRect messageFrame = self.emptyGenreMessageView.frame;
    messageFrame.origin.y = ([[SYNDeviceManager sharedInstance] currentScreenHeight] * 0.5) - (messageFrame.size.height * 0.5);
    messageFrame.origin.x = ([[SYNDeviceManager sharedInstance] currentScreenWidth] * 0.5) - (messageFrame.size.width * 0.5);
    
    messageFrame = CGRectIntegral(messageFrame);
    self.emptyGenreMessageView.frame = messageFrame;
    self.emptyGenreMessageView.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    [self.view addSubview: self.emptyGenreMessageView];
}


#pragma mark - Fetched results controller

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

    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"dateAdded" ascending: NO],[[NSSortDescriptor alloc] initWithKey: @"position" ascending: YES]];
    
    
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
    

- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{
    
    [self.videoThumbnailCollectionView reloadData];
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

- (void) videoOverlayDidDissapear
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasShownSubscribeOnBoarding = [defaults boolForKey:kUserDefaultsAddVideo];
    if(!hasShownSubscribeOnBoarding)
    {
        
        NSString* message = NSLocalizedString(@"onboarding_video", nil);
        
        CGFloat fontSize = [[SYNDeviceManager sharedInstance] isIPad] ? 19.0 : 15.0 ;
        CGSize size = [[SYNDeviceManager sharedInstance] isIPad] ? CGSizeMake(340.0, 164.0) : CGSizeMake(260.0, 144.0);
        CGRect rectToPointTo = CGRectZero;
        PointingDirection directionToPointTo = PointingDirectionDown;
        if(self.selectedCell)
        {
            rectToPointTo = [self.view convertRect:self.selectedCell.addItButton.frame fromView:self.selectedCell];
            if(rectToPointTo.origin.y < [[SYNDeviceManager sharedInstance] currentScreenHeight] * 0.5)
                directionToPointTo = PointingDirectionUp;
            
            //NSLog(@"%f %f", rectToPointTo.origin.x, rectToPointTo.origin.y);
        }
        SYNOnBoardingPopoverView* addToChannelPopover = [SYNOnBoardingPopoverView withMessage:message
                                                                                  withSize:size
                                                                               andFontSize:fontSize
                                                                                pointingTo:rectToPointTo
                                                                             withDirection:directionToPointTo];
        
        
        __weak SYNFeedRootViewController* wself = self;
        addToChannelPopover.action = ^{
            [wself videoAddButtonTapped:wself.selectedCell.addItButton];
        };
        [appDelegate.onBoardingQueue addPopover:addToChannelPopover];
        
        [defaults setBool:YES forKey:kUserDefaultsAddVideo];
        
        [appDelegate.onBoardingQueue present];
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

    [videoThumbnailCell.channelImageView setImageWithURL: [NSURL URLWithString: videoInstance.channel.channelOwner.thumbnailLargeUrl]
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
    id<NSFetchedResultsSectionInfo> sectionInfo = (self.fetchedResultsController.sections)[indexPath.section];
    
    // In the 'name' attribut of the sectionInfo we have actually the keypath data (i.e in this case Date without time)
    
    // TODO: We might want to optimise this instead of creating a new date formatter each time
    
    if (kind == UICollectionElementKindSectionHeader)
    {
        NSDate *date = [self.dateFormatter dateFromString: sectionInfo.name];
        
        SYNHomeSectionHeaderView *headerSupplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind: kind
                                                                                               withReuseIdentifier: @"SYNHomeSectionHeaderView"
                                                                                                      forIndexPath: indexPath];
        NSString *sectionText;
        
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
        
        self.footerView.showsLoading = self.isLoadingMoreContent;
        supplementaryView = self.footerView;
    }

    return supplementaryView;
}


- (void) displayVideoViewerFromView: (UIButton *) videoViewButton
{
    
    
    NSIndexPath *indexPath = [self indexPathFromVideoInstanceButton: videoViewButton];
    self.selectedCell = (SYNVideoThumbnailWideCell*)[self.videoThumbnailCollectionView cellForItemAtIndexPath:indexPath];
    
    
    [super displayVideoViewerFromView: videoViewButton];
    
}

#pragma mark - Load More Footer

- (void) loadMoreVideos: (UIButton*) sender
{
    [self incrementRangeForNextRequest];
    
    [self loadAndUpdateFeedData];
}




- (void) headerTapped
{
    [self.videoThumbnailCollectionView setContentOffset:CGPointZero animated:YES];
}


- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height - kLoadMoreFooterViewHeight
        && self.isLoadingMoreContent == NO)
    {
        DebugLog (@"Scrolling more");
        [self loadMoreVideos: nil];
    }
}


- (void) applicationWillEnterForeground: (UIApplication *) application
{
    // set the data request range back to 0, 48 and refresh
    [super applicationWillEnterForeground: application];
    
    [self loadAndUpdateFeedData];
}


@end
