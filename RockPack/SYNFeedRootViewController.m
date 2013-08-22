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
#import "SYNAggregateChannelCell.h"
#import "UIImageView+WebCache.h"
#import "SYNAggregateCell.h"
#import "UIImageView+WebCache.h"
#import "SYNAggregateVideoCell.h"
#import "Video.h"
#import "FeedItem.h"
#import "SYNMasterViewController.h"
#import "VideoInstance.h"
#import "Appirater.h"

typedef void(^FeedDataErrorBlock)(void);

@interface SYNFeedRootViewController () <SYNAggregateCellDelegate>

@property (nonatomic, assign) BOOL refreshing;
@property (nonatomic, assign) BOOL shouldReloadCollectionView;
@property (nonatomic, strong) NSBlockOperation *blockOperation;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) SYNFeedMessagesView* emptyGenreMessageView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, weak)   SYNAggregateVideoCell* selectedVideoCell;
@property (nonatomic, strong) NSArray* feedItemsData;
@property (nonatomic, strong) NSDictionary* feedVideosById;
@property (nonatomic, strong) NSDictionary* feedChannelsById;
@property (nonatomic, strong) NSDictionary* feedItemByPosition;
@property (nonatomic, strong) UICollectionView* feedCollectionView;
@property (nonatomic, strong) NSArray* videosInOrderArray;
@property (nonatomic) BOOL togglingInProgress;

@end


@implementation SYNFeedRootViewController

#pragma mark - Object lifecycle

- (void) dealloc
{
    // No harm in removing all notifications, as we are being de-alloced after all..
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    // Defensive programming
    self.feedCollectionView.delegate = nil;
    self.feedCollectionView.dataSource = nil;
}


#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.feedItemsData = [NSArray array];
    
    self.videosInOrderArray = [NSArray array];
    
    SYNIntegralCollectionViewFlowLayout *standardFlowLayout;
    UIEdgeInsets sectionInset, contentInset;
    CGRect videoCollectionViewFrame, calculatedViewFrame;
    CGSize screenSize;
    CGFloat minimumLineSpacing;
    
    // Setup device dependent parametes/dimensions
    
    if (IS_IPHONE)
    {
        // Calculate frame size
        screenSize = CGSizeMake([SYNDeviceManager.sharedInstance currentScreenWidth], [SYNDeviceManager.sharedInstance currentScreenHeight]);
        
        calculatedViewFrame = CGRectMake(0.0, 0.0, screenSize.width, screenSize.height - 20.0f);
        
        videoCollectionViewFrame = CGRectMake(0.0, kStandardCollectionViewOffsetYiPhone, screenSize.width, screenSize.height - 20.0f - kStandardCollectionViewOffsetYiPhone);
        
        // Collection view parameters
        contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        minimumLineSpacing = 12.0f;
        
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
    
    CGSize itemSize;
    if (IS_IPHONE)
    {
        itemSize = CGSizeMake(310.0f , 261.0f);
    }
    else if ([SYNDeviceManager.sharedInstance isLandscape])
    {
        itemSize = CGSizeMake(616, 168);
    }
    else
    {
        itemSize = CGSizeMake(616, 168);
    }
    
    standardFlowLayout = [SYNIntegralCollectionViewFlowLayout layoutWithItemSize: itemSize
                                                         minimumInterItemSpacing: 0.0f
                                                              minimumLineSpacing: minimumLineSpacing
                                                                 scrollDirection: UICollectionViewScrollDirectionVertical
                                                                    sectionInset: sectionInset];
    
    // standardFlowLayout.footerReferenceSize = [self footerSize];
    
    // Setup the collection view itself
    self.feedCollectionView = [[UICollectionView alloc] initWithFrame: videoCollectionViewFrame
                                                 collectionViewLayout: standardFlowLayout];
    
    self.feedCollectionView.delegate = self;
    self.feedCollectionView.dataSource = self;
    self.feedCollectionView.backgroundColor = [UIColor clearColor];
    self.feedCollectionView.scrollsToTop = NO;
    self.feedCollectionView.contentInset = contentInset;
    self.feedCollectionView.showsVerticalScrollIndicator = NO;
    self.feedCollectionView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.feedCollectionView];

    self.feedCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight;

    
    [self.feedCollectionView registerNib: [UINib nibWithNibName: @"SYNAggregateVideoCell" bundle: nil]
                        forCellWithReuseIdentifier: @"SYNAggregateVideoCell"];
    
    [self.feedCollectionView registerNib: [UINib nibWithNibName: @"SYNAggregateChannelCell" bundle: nil]
              forCellWithReuseIdentifier: @"SYNAggregateChannelCell"];
    
    
    [self.feedCollectionView registerNib: [UINib nibWithNibName: @"SYNHomeSectionHeaderView" bundle: nil]
                        forSupplementaryViewOfKind: UICollectionElementKindSectionHeader
                               withReuseIdentifier: @"SYNHomeSectionHeaderView"];
    
    // Register Footer
    UINib *footerViewNib = [UINib nibWithNibName: @"SYNChannelFooterMoreView"
                                          bundle: nil];
    
    [self.feedCollectionView registerNib: footerViewNib
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
    
    [self.feedCollectionView addSubview: self.refreshControl];
    
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
    if([self class] == [SYNFeedRootViewController class])
    {
        [self loadAndUpdateFeedData];
    }
}


- (void) videoQueueCleared
{
    // this will remove the '+' from the videos that where selected
    [self.feedCollectionView reloadData];
}

#pragma mark - Container Scrol Delegates

- (void) viewDidScrollToFront
{
    [self updateAnalytics];
    
    self.feedCollectionView.scrollsToTop = YES;
    
    self.togglingInProgress = NO;
    
    // if the user has not pressed load more
    if (self.dataRequestRange.location == 0)
    {
        [self resetDataRequestRange]; // just in case the length is less than standard
        [self.refreshButton startRefreshCycle];
        [self loadAndUpdateFeedData];
       
    }

    [self checkForOnBoarding];

}

-(void)checkForOnBoarding
{
    
    if(self.feedItemsData.count > 0)
        return;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasShownFeedOnBoarding = [defaults boolForKey:kUserDefaultsFeed];
    if(!hasShownFeedOnBoarding)
    {
        NSString* message = IS_IPAD ? NSLocalizedString(@"onboarding_feed", nil) : NSLocalizedString(@"onboarding_feed_iphone", nil);
        
        CGFloat fontSize = IS_IPAD ? 16.0 : 14.0 ;
        CGSize size = IS_IPAD ? CGSizeMake(340.0, 84.0) : CGSizeMake(260.0, 80.0);
        SYNOnBoardingPopoverView* subscribePopover = [SYNOnBoardingPopoverView withMessage:message
                                                                                  withSize:size
                                                                               andFontSize:fontSize
                                                                                pointingTo:CGRectZero
                                                                             withDirection:PointingDirectionNone];
        
        
        [appDelegate.onBoardingQueue addPopover:subscribePopover];
        
        [defaults setBool:YES forKey:kUserDefaultsFeed];
        
        [appDelegate.onBoardingQueue present];
    }
    
    
}

- (void) viewDidScrollToBack
{
    self.feedCollectionView.scrollsToTop = NO;
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
    
    [self.feedCollectionView reloadData];
}


-(void) loadAndUpdateOriginalFeedData
{
    [self resetDataRequestRange];
    [self loadAndUpdateFeedData];
    
}


- (void) loadAndUpdateFeedData
{
    self.loadingMoreContent = YES;
    
    if (!appDelegate.currentOAuth2Credentials.userId)
        return;

    [self.refreshButton startRefreshCycle];
    
    __weak SYNFeedRootViewController* wself = self;
    FeedDataErrorBlock errorBlock = ^{
        
        [wself handleRefreshComplete];
        
        [wself removeEmptyGenreMessage];
        
        if(wself.feedItemsData.count == 0)
        {
            [wself displayEmptyGenreMessage:NSLocalizedString(@"feed_screen_loading_error", nil) andLoader:NO]; 
        }
            
        else
        {
            [wself displayEmptyGenreMessage:NSLocalizedString(@"feed_screen_updating_error", nil) andLoader:NO];
            [NSTimer scheduledTimerWithTimeInterval:3.0f
                                             target:self
                                           selector:@selector(removeEmptyGenreMessage)
                                           userInfo:nil
                                            repeats:NO];
        }
            
        
        self.loadingMoreContent = NO;
        
        DebugLog(@"Refresh subscription updates failed");
    };
    
    [appDelegate.oAuthNetworkEngine feedUpdatesForUserId: appDelegate.currentOAuth2Credentials.userId
                                                   start: self.dataRequestRange.location
                                                    size: self.dataRequestRange.length
                                       completionHandler: ^(NSDictionary *responseDictionary) {
                                                    
                                           
                                           BOOL toAppend = (self.dataRequestRange.location > 0);
                                                    
                                           
                                           NSDictionary *contentItem = responseDictionary[@"content"];
                                           
                                           if (!contentItem || ![contentItem isKindOfClass: [NSDictionary class]]) {
                                               
                                               errorBlock();
                                               
                                               return;
                                               
                                           }
                                                        
                                           
                                           NSNumber* totalNumber = [contentItem[@"total"] isKindOfClass:[NSNumber class]] ? contentItem[@"total"] : @0 ;
                                           wself.dataItemsAvailable = [totalNumber integerValue];
                                           
                                           // NSLog(@"%i from %i", ((NSArray*)contentItem[@"items"]).count, wself.dataItemsAvailable);
                                           
                                           
                                           [wself removeEmptyGenreMessage];
                                               
                                           
                                           if(![appDelegate.mainRegistry registerDataForSocialFeedFromItemsDictionary:contentItem
                                                                                                          byAppending:toAppend])
                                               
                                           {
                                               
                                               errorBlock();
                                               
                                               return;
                                               
                                           }
                                           
                                           
                                           [wself fetchAndDisplayFeedItems];
                                           
                                           
                                           wself.loadingMoreContent = NO;
                                                    
                                           
                                           [wself handleRefreshComplete];
                                           
                                           if(wself.dataItemsAvailable == 0) {
                                               
                                               [wself displayEmptyGenreMessage:NSLocalizedString(@"feed_screen_empty_message", nil) andLoader:NO];
                                               
                                               
                                           }
                                                    
                                           
                                       } errorHandler: ^(NSDictionary* errorDictionary) {
                                                    
                                           
                                           errorBlock();
                                                    
                                           
                                       }];
}


- (void) handleRefreshComplete
{
    self.refreshing = NO;
    [self.refreshControl endRefreshing];
    [self.refreshButton endRefreshCycle];
}


- (void) clearedLocationBoundData
{
    // to clear
    
    [self fetchAndDisplayFeedItems];
    
    [self.feedCollectionView reloadData];
    
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


#pragma mark - Fetch Feed Data

- (void) fetchAndDisplayFeedItems
{
    
    [self fetchVideoItems];
    
    [self fetchChannelItems];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    fetchRequest.entity = [NSEntityDescription entityForName: kFeedItem
                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    // if the aggregate has a parent FeedItem then it should NOT be displayed since it is going to be part of an aggregate...
    NSPredicate* predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"viewId == \"%@\" AND aggregate == nil", self.viewId]]; // kFeedViewId
 
    fetchRequest.predicate = predicate;

    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"dateAdded" ascending: NO],
                                     [[NSSortDescriptor alloc] initWithKey: @"position" ascending: NO]];
    
    NSError* error;
    
    NSArray *resultsArray = [appDelegate.mainManagedObjectContext executeFetchRequest: fetchRequest error: &error];
    if (!resultsArray)
        return;
    
    // sort results in categories
    
    if(resultsArray.count == 0)
    {
        self.feedItemsData = [NSArray array];
        [self.feedCollectionView reloadData];
        return;
    }
    
    
    NSMutableDictionary* buckets = [NSMutableDictionary dictionary];
    NSDate* dateNoTime;
    
    for (FeedItem* feedItem in resultsArray)
    {
        dateNoTime = [feedItem.dateAdded dateIgnoringTime];
        
        NSMutableArray* bucket = [buckets objectForKey:dateNoTime];
        if(!bucket) { // if the bucket has not been created already, create it
            bucket = [NSMutableArray array];
            [buckets setObject:bucket forKey:dateNoTime];
        }
            
        [bucket addObject:feedItem];
        
    }
    
    NSArray* sortedDateKeys = [[buckets allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSDate* date1, NSDate* date2) {
        
        return [date2 compare:date1];
        
    }];
    
    NSMutableArray* sortedItemsArray = [NSMutableArray array];
    for (NSDate* dateKey in sortedDateKeys)
    {
        [sortedItemsArray addObject:[buckets objectForKey:dateKey]];
        
    }
    self.feedItemsData = sortedItemsArray;
    
    
    [self.feedCollectionView reloadData];
    
    // put the videos in order
    
    self.videosInOrderArray = [NSArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self sortVideosForPlaylist];
    });
    
}

- (void) fetchVideoItems
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    fetchRequest.entity = [NSEntityDescription entityForName: kVideoInstance
                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"viewId == \"%@\"", self.viewId]]; // kFeedViewId
    
    fetchRequest.predicate = predicate;
    
    
    NSError* error;
    
    NSArray *resultsArray = [appDelegate.mainManagedObjectContext executeFetchRequest: fetchRequest error: &error];
    if (!resultsArray)
        return;
    
    NSMutableDictionary* mutDictionary = [[NSMutableDictionary alloc] initWithCapacity:resultsArray.count];
    for (VideoInstance* vi in resultsArray) {
        [mutDictionary setObject:vi forKey:vi.uniqueId];
    }
    
    self.feedVideosById = [NSDictionary dictionaryWithDictionary:mutDictionary];
}

- (void) fetchChannelItems
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    fetchRequest.entity = [NSEntityDescription entityForName: kChannel
                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"viewId == \"%@\"", self.viewId]]; // kFeedViewId
    
    fetchRequest.predicate = predicate;
    
    
    NSError* error;
    
    NSArray *resultsArray = [appDelegate.mainManagedObjectContext executeFetchRequest: fetchRequest error: &error];
    if (!resultsArray)
        return;
    
    NSMutableDictionary* mutDictionary = [[NSMutableDictionary alloc] initWithCapacity:resultsArray.count];
    for (Channel* ch in resultsArray) {
        [mutDictionary setObject:ch forKey:ch.uniqueId];
    }
    
    self.feedChannelsById = [NSDictionary dictionaryWithDictionary:mutDictionary];
}



#pragma mark - UICollectionView Delegate

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return self.feedItemsData.count; // the number of arrays included
}

- (UIEdgeInsets)collectionView: (UICollectionView *)collectionView
                        layout: (UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex: (NSInteger)section
{
    
    return UIEdgeInsetsMake(10.0, 0.0, 40.0, 0.0);
}

- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger) section
{
    NSArray* sectionInfo = self.feedItemsData[section];
    return sectionInfo.count;
    
}


- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout*) collectionViewLayout
   sizeForItemAtIndexPath: (NSIndexPath *) indexPath
{
    FeedItem* feedItem = [self feedItemAtIndexPath:indexPath];
    CGFloat cellWidth = 0.0;
    if(IS_IPHONE)
    {
        cellWidth = 310.0f;
    }
    else
    {
        cellWidth = 616.0f;
    }
    
    if(feedItem.resourceTypeValue == FeedItemResourceTypeVideo)
    {
        return CGSizeMake(cellWidth, IS_IPHONE ? 280.0f : 168.0f);
    }
    else // Channel
    {
        if(feedItem.itemTypeValue == FeedItemTypeAggregate)
        {
           
            if(feedItem.itemCountValue == 2 || feedItem.itemCountValue == 3)
                return CGSizeMake(cellWidth, IS_IPHONE ? 182.0f : 149.0f);
        }
        return CGSizeMake(cellWidth, IS_IPHONE ? 363.0f : 298.0f);
    }
}

- (void) videoOverlayDidDissapear
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasShownSubscribeOnBoarding = [defaults boolForKey:kUserDefaultsAddVideo];
    if (!hasShownSubscribeOnBoarding)
    {
        
        NSString* message = NSLocalizedString(@"onboarding_video", nil);
        
        CGFloat fontSize = IS_IPAD ? 16.0 : 14.0 ;
        CGSize size = IS_IPAD ? CGSizeMake(240.0, 86.0) : CGSizeMake(200.0, 82.0);
        CGRect rectToPointTo = CGRectZero;
        PointingDirection directionToPointTo = PointingDirectionDown;
        if (self.selectedVideoCell)
        {
           
            rectToPointTo = [self.view convertRect:self.selectedVideoCell.frame fromView:self.selectedVideoCell];
            if (rectToPointTo.origin.y < [[SYNDeviceManager sharedInstance] currentScreenHeight] * 0.5)
                directionToPointTo = PointingDirectionUp;
            
        }
        SYNOnBoardingPopoverView* addToChannelPopover = [SYNOnBoardingPopoverView withMessage:message
                                                                                  withSize:size
                                                                               andFontSize:fontSize
                                                                                pointingTo:rectToPointTo
                                                                             withDirection:directionToPointTo];
        
        
        //__weak SYNFeedRootViewController* wself = self;
        addToChannelPopover.action = ^(id obj){
           // [wself videoAddButtonTapped:wself.selectedVideoCell.addButton];
        };
        [appDelegate.onBoardingQueue addPopover:addToChannelPopover];
        
        [defaults setBool:YES forKey:kUserDefaultsAddVideo];
        
        [appDelegate.onBoardingQueue present];
    }
}

-(FeedItem*)feedItemAtIndexPath:(NSIndexPath*)indexPath
{
    NSArray* sectionArray = self.feedItemsData[indexPath.section];
    FeedItem* feedItem = sectionArray[indexPath.row];
    return feedItem;
}

- (Channel *) channelInstanceForIndexPath: (NSIndexPath *) indexPath
                        andComponentIndex: (NSInteger) componentIndex
{
    if (!indexPath)
        DebugLog(@"Nil index path");
    DebugLog (@"indexPath %@", indexPath);
    Channel *channel;
    
    FeedItem *feedItem = [self feedItemAtIndexPath: indexPath];
    
    if (componentIndex == kArcMenuInvalidComponentIndex)
    {
        channel = [self channelAtCoverOfFeedItem: feedItem];
    }
    else
    {
        // Aggregate cell with multiple indices
        channel = [self.feedChannelsById objectForKey: feedItem.coverIndexArray[componentIndex]];
    }

    return channel;
}




- (NSIndexPath *) indexPathForChannelCell: (UICollectionViewCell *) cell
{
    // Same mechanism as for video cell
    return  [self indexPathForVideoCell: cell];
}


- (NSIndexPath *) indexPathForVideoCell: (UICollectionViewCell *) cell
{
    NSIndexPath *indexPath = [self.feedCollectionView indexPathForItemAtPoint: cell.center];
    return indexPath;
}


- (void) arcMenuUpdateState: (UIGestureRecognizer *) recognizer
                    forCell: (UICollectionViewCell *) cell
{
    [super arcMenuUpdateState: recognizer
                      forCell: cell];
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        // Need to set the component index if aggregate celll
        NSIndexPath *indexPath = [self.feedCollectionView indexPathForItemAtPoint: cell.center];
        FeedItem *feedItem = [self feedItemAtIndexPath: indexPath];
        NSInteger indexOfButton;
        
        if (feedItem.resourceTypeValue == FeedItemResourceTypeChannel && feedItem.itemTypeValue == FeedItemTypeAggregate)
        {
            UIImageView *simulatedButton = (UIImageView *) recognizer.view;
            indexOfButton = [(SYNAggregateChannelCell *) cell indexForSimulatedButtonPressed: simulatedButton];
        }
        else
        {
            indexOfButton = kArcMenuInvalidComponentIndex;
        }
        
        Channel *channel = [self channelInstanceForIndexPath: indexPath
                                           andComponentIndex: indexOfButton];
        
        [self requestShareLinkWithObjectType: @"channel"
                                    objectId: channel.uniqueId];
        
        self.arcMenu.componentIndex = indexOfButton;
        DebugLog(@"Set componentIndex to %d", indexOfButton);
    }
}


- (void) arcMenu: (SYNArcMenuView *) menu
         didSelectMenuName: (NSString *) menuName
         forCellAtIndex: (NSIndexPath *) cellIndexPath
         andComponentIndex: (NSInteger) componentIndex
{
    if ([menuName isEqualToString: kActionShareVideo])
    {
        [self shareVideoAtIndexPath: cellIndexPath];
    }
    else if ([menuName isEqualToString: kActionShareChannel])
    {
        [self shareChannelAtIndexPath: cellIndexPath
                    andComponentIndex: componentIndex];
    }
    else
    {
        AssertOrLog(@"Invalid Arc Menu index selected");
    }
}


- (UIView *) arcMenuViewToShade
{
    return self.feedCollectionView;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNAggregateCell *cell = nil;
    FeedItem* feedItem = [self feedItemAtIndexPath:indexPath];
    ChannelOwner* channelOwner;
    
    NSInteger feedItemsAggregated = feedItem.itemTypeValue == FeedItemTypeAggregate ? feedItem.feedItems.count : 1;
    
    if (feedItem.resourceTypeValue == FeedItemResourceTypeVideo)
    {
        cell = [cv dequeueReusableCellWithReuseIdentifier: @"SYNAggregateVideoCell"
                                             forIndexPath: indexPath];
        
        VideoInstance* videoInstance;
        
        videoInstance = (VideoInstance*)[self.feedVideosById objectForKey:feedItem.coverIndexArray[0]]; // there should be only one
        
        
        cell.mainTitleLabel.text = videoInstance.title;
        
        
        if(!feedItem.title) // it should usually be nil
        {
         
            [cell setTitleMessageWithDictionary:@{  @"display_name" : videoInstance.channel.channelOwner ? videoInstance.channel.channelOwner.displayName : @"",
                                                    @"item_count" : @(feedItemsAggregated),
             @"channel_name" : videoInstance.channel ? videoInstance.channel.title : @"" }];
            
        }
        else
            cell.messageLabel.text = feedItem.title;
        
//        NSLog(@"videoInstance: \n\n============== \n\n%@ \n\n============== \n\n%@ \n\n============== \n\n%@ \n\n=============", videoInstance, videoInstance.video.starCount, videoInstance.starrers);
        [cell setSupplementaryMessageWithDictionary:@{  @"star_count": videoInstance.video ? videoInstance.video.starCount : @0,
         @"starrers": videoInstance ? [videoInstance.starrers array] : [NSArray array] }];
        
        [cell setCoverImagesAndTitlesWithArray:@[@{     @"image": videoInstance.video ? videoInstance.video.thumbnailURL : @"",
         @"title" : videoInstance ? videoInstance.title : @"" }]];
        
        channelOwner = videoInstance.channel.channelOwner; // heuristic, get the last video instance, all should have the same channelOwner however
        
    }
    else if(feedItem.resourceTypeValue == FeedItemResourceTypeChannel)
    {
        cell = [cv dequeueReusableCellWithReuseIdentifier: @"SYNAggregateChannelCell"
                                             forIndexPath: indexPath];
        
        Channel* channel;
        
        if (feedItem.itemTypeValue == FeedItemTypeAggregate)
        {
            NSArray* coverIndexIds = [feedItem.coverIndexes componentsSeparatedByString:@":"];
            
            NSMutableArray* coverImagesAndTitles = [NSMutableArray arrayWithCapacity:coverIndexIds.count];
            
            
            for (NSString* resourceId in coverIndexIds)
            {
                channel = (Channel*)[self.feedChannelsById objectForKey:resourceId];
                [coverImagesAndTitles addObject:@{  @"image": channel.channelCover ? channel.channelCover.imageUrl : @"",
                                                    @"title" : channel.title    }];
            }
            
            [cell setCoverImagesAndTitlesWithArray:coverImagesAndTitles];
        }
        else
        {
            channel = (Channel*)[self.feedChannelsById objectForKey:feedItem.resourceId];
            
            [cell setCoverImagesAndTitlesWithArray:@[@{ @"image": channel.channelCover ? channel.channelCover.imageLargeUrl : @"",
                                                        @"title" : channel.title    }]]; 
        }
        
        channelOwner = channel.channelOwner;
        
        if(!feedItem.title)
        {
            [cell setTitleMessageWithDictionary:@{  @"display_name" : channel.channelOwner ? channel.channelOwner.displayName : @"",
                                                    @"item_count" : @(feedItemsAggregated)}];
        }
        else
            cell.messageLabel.text = feedItem.title; 
    }
    
    cell.viewControllerDelegate = self;
    
    [cell.userThumbnailImageView setImageWithURL: [NSURL URLWithString: channelOwner.thumbnailURL]
                                placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                                         options: SDWebImageRetryFailed];
    
    // add common properties
    
    return cell;
}



- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout*) collectionViewLayout
                   referenceSizeForHeaderInSection: (NSInteger) section
{
    if (IS_IPAD)
        return CGSizeMake(1024, 65);
    
    return CGSizeMake(320, 34);
}


- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout*) collectionViewLayout
                   referenceSizeForFooterInSection: (NSInteger) section
{
    CGSize footerSize = CGSizeZero;
    
    
    if  (section == (self.feedItemsData.count - 1) && // only the last section can have a loader
        (self.dataRequestRange.location + self.dataRequestRange.length < self.dataItemsAvailable)) 
    {
        
        footerSize = [self footerSize];
        
       
    }
    
    return footerSize;
    
}


// Used for the collection view header
- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
    
    UICollectionReusableView *supplementaryView = nil;
    
    // Work out the day
    FeedItem* heuristicFeedItem = [self feedItemAtIndexPath:indexPath];
    
    // In the 'name' attribut of the sectionInfo we have actually the keypath data (i.e in this case Date without time)
    
    // TODO: We might want to optimise this instead of creating a new date formatter each time
    
    if (kind == UICollectionElementKindSectionHeader)
    {
        NSDate* date = heuristicFeedItem.dateAdded;
        
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
        self.footerView = [collectionView dequeueReusableSupplementaryViewOfKind: kind
                                                             withReuseIdentifier: @"SYNChannelFooterMoreView"
                                                                    forIndexPath: indexPath];
        supplementaryView = self.footerView;
        
        // Show loading spinner if we have more datasection == )
        if ((indexPath.section == (self.feedItemsData.count - 1)) && // last item
            (self.dataRequestRange.location + self.dataRequestRange.length) < self.dataItemsAvailable)
        {
            self.footerView.showsLoading = self.isLoadingMoreContent;
        }
    }

    return supplementaryView;
}

#pragma mark - Click Cell Delegates

- (VideoInstance *) videoInstanceForIndexPath: (NSIndexPath *) indexPath
{
    FeedItem* feedItem = [self feedItemAtIndexPath:indexPath];
    
    VideoInstance* videoInstance = [self videoInstanceAtCoverOfFeedItem: feedItem];
    
    return videoInstance;
}


-(VideoInstance*)videoInstanceAtCoverOfFeedItem:(FeedItem*)feedItem
{
    if(!feedItem || (feedItem.resourceTypeValue != FeedItemResourceTypeVideo))
        return nil;
    
    VideoInstance* videoInstance;
    
    if(feedItem.itemTypeValue == FeedItemTypeLeaf)
        videoInstance = [self.feedVideosById objectForKey:feedItem.resourceId];
    else
        videoInstance = [self.feedVideosById objectForKey:feedItem.coverIndexArray[0]];
    
    return videoInstance;
}


-(Channel*)channelAtCoverOfFeedItem:(FeedItem*)feedItem
{
    DebugLog(@"Feed Item: %@", feedItem);
    if(!feedItem || (feedItem.resourceTypeValue != FeedItemResourceTypeChannel))
        return nil;
    
    Channel* channel;
    
    if(feedItem.itemTypeValue == FeedItemTypeLeaf)
        channel = [self.feedChannelsById objectForKey:feedItem.resourceId];
    else
        channel = [self.feedChannelsById objectForKey:feedItem.coverIndexArray[0]];
    
    return channel;
}

-(void)sortVideosForPlaylist
{
    NSMutableArray* ma = [NSMutableArray array]; // max should be the existing videos
    
    for (NSArray* section in self.feedItemsData)
    {
        for (FeedItem* fi in section)
        {
            
            if(fi.resourceTypeValue != FeedItemResourceTypeVideo)
                continue;
                
            
            if(fi.itemTypeValue == FeedItemTypeLeaf)
            {
                [ma addObject:[self.feedVideosById objectForKey:fi.resourceId]];
            }
            else
            {
                for (FeedItem* cfi in fi.feedItems)
                {
                    // assumes that FeedItems are one level deep at the present moment (probably will not change for a while)
                    if(cfi.resourceTypeValue != FeedItemResourceTypeVideo || cfi.itemTypeValue != FeedItemTypeLeaf)
                        continue;
                    
                    [ma addObject:[self.feedVideosById objectForKey:cfi.resourceId]];
                    
                }
            }
            
        }
    }
    
    self.videosInOrderArray = [NSArray arrayWithArray:ma];
}


- (void) pressedAggregateCellCoverView: (UIView *) view
{
    SYNAggregateCell *aggregateCellSelected = [self aggregateCellFromView: view];
    NSIndexPath *indexPath = [self.feedCollectionView indexPathForItemAtPoint: aggregateCellSelected.center];
    FeedItem *selectedFeedItem = [self feedItemAtIndexPath: indexPath];
    
    if (selectedFeedItem.resourceTypeValue == FeedItemResourceTypeVideo)
    {
        if (self.videosInOrderArray.count == 0)
        {
            return;
        }
        
        NSLog(@"%@", self.videosInOrderArray);
        
        VideoInstance *videoInstance = [self videoInstanceAtCoverOfFeedItem: selectedFeedItem];
        
        SYNMasterViewController *masterViewController = (SYNMasterViewController *) appDelegate.masterViewController;
        
        __block NSInteger indexOfSelectedVideoInArray = 0;
        [self.videosInOrderArray enumerateObjectsUsingBlock: ^(VideoInstance *vi, NSUInteger idx, BOOL *stop) {
             indexOfSelectedVideoInArray++;
             
             if ([vi.uniqueId isEqualToString: videoInstance.uniqueId])
             {
                 *stop = YES;
             }
         }];
        
        indexOfSelectedVideoInArray--; // zero index
        
        [masterViewController addVideoOverlayToViewController: self
                                       withVideoInstanceArray: self.videosInOrderArray
                                             andSelectedIndex: indexOfSelectedVideoInArray
                                                   fromCenter: self.view.center];
    }
    else
    {
        Channel *channel;
        
        if (selectedFeedItem.itemTypeValue == FeedItemTypeLeaf)
        {
            channel = [self.feedChannelsById objectForKey: selectedFeedItem.resourceId];
        }
        else
        {
            SYNAggregateChannelCell *channelCellSelected = (SYNAggregateChannelCell *) aggregateCellSelected;
            
            NSInteger indexOfButton = [channelCellSelected indexForSimulatedButtonPressed: view];
            channel = [self.feedChannelsById objectForKey: selectedFeedItem.coverIndexArray[indexOfButton]];
        }
        
        if (channel)
        {
            [appDelegate.viewStackManager viewChannelDetails: channel];
        }
    }
}


- (SYNAggregateCell *) aggregateCellFromView: (UIView *) view
{
    UIView *candidateCell = view;
    
    while (![candidateCell isKindOfClass: [SYNAggregateCell class]])
    {
        candidateCell = candidateCell.superview;
    }
    
    return (SYNAggregateCell *) candidateCell;
}


- (NSIndexPath *) indexPathFromView: (UIView *) view
{
    SYNAggregateCell *aggregateCellSelected = [self aggregateCellFromView: view];
    NSIndexPath *indexPath = [self.feedCollectionView indexPathForItemAtPoint: aggregateCellSelected.center];
    
    return indexPath;
}


- (FeedItem *) feedItemFromView: (UIView *) view
{
    NSIndexPath *indexPath = [self indexPathFromView: view];
    FeedItem *selectedFeedItem = [self feedItemAtIndexPath: indexPath];
    
    return selectedFeedItem;
}

#pragma mark - Cell Actions Delegate

- (void) videoAddButtonTapped: (UIButton *) addButton
{
    FeedItem *selectedFeedItem = [self feedItemFromView: addButton];
    
    if (selectedFeedItem.resourceTypeValue == FeedItemResourceTypeVideo)
    {
        VideoInstance *videoInstance;
        
        if (selectedFeedItem.itemTypeValue == FeedItemTypeLeaf)
        {
            videoInstance = [self.feedVideosById objectForKey: selectedFeedItem.resourceId];
        }
        else
        {
            videoInstance = [self.feedVideosById objectForKey: selectedFeedItem.coverIndexArray[0]];
        }
        
        if (!videoInstance)
        {
            return;
        }
        
        id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
        
        [tracker sendEventWithCategory: @"uiAction"
                            withAction: @"videoPlusButtonClick"
                             withLabel: nil
                             withValue: nil];
        
        [appDelegate.oAuthNetworkEngine recordActivityForUserId: appDelegate.currentUser.uniqueId
                                                         action: @"select"
                                                videoInstanceId: videoInstance.uniqueId
                                              completionHandler: ^(id response) {
                                              } errorHandler: ^(id error) {
                                                  DebugLog(@"Could not record videoAddButtonTapped: activity");
                                              }];
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kVideoQueueAdd
                                                            object: self
                                                          userInfo: @{@"VideoInstance": videoInstance}];
        
        [self.videoThumbnailCollectionView reloadData];
    }
}


- (void) profileButtonTapped: (UIButton *) sender
{
    FeedItem *feedItem = [self feedItemFromView: sender];
    ChannelOwner *channelOwner;
    
    if ([self videoInstanceAtCoverOfFeedItem: feedItem])
    {
        channelOwner = [self videoInstanceAtCoverOfFeedItem: feedItem].channel.channelOwner;
    }
    else if ([self channelAtCoverOfFeedItem: feedItem])
    {
        channelOwner = [self channelAtCoverOfFeedItem: feedItem].channelOwner;
    }
    
    if (!channelOwner)
    {
        return;
    }
    
    [appDelegate.viewStackManager viewProfileDetails: channelOwner];
}


- (IBAction) toggleStarAtIndexPath: (NSIndexPath *) indexPath
{
    // Bit of a hack, but find the button in the cell
    SYNAggregateVideoCell *cell = (SYNAggregateVideoCell *)[self.feedCollectionView cellForItemAtIndexPath: indexPath];
    
    UIButton *heartButton = cell.heartButton;
    
    [self likeButtonPressed: heartButton];
}


- (void) likeButtonPressed: (UIButton *) button
{
    if (self.togglingInProgress)
    {
        return;
    }
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker sendEventWithCategory: @"uiAction"
                        withAction: @"videoStarButtonClick"
                         withLabel: @"feed"
                         withValue: nil];
    
    BOOL didStar = (button.selected == NO);
    
    button.enabled = NO;
    
    VideoInstance *videoInstance = [self videoInstanceAtCoverOfFeedItem: [self feedItemFromView: button]];
    
    if (!videoInstance)
    {
        return;
    }
    
    self.togglingInProgress = YES;
    
    // int starredIndex = self.currentSelectedIndex;
    [appDelegate.oAuthNetworkEngine recordActivityForUserId: appDelegate.currentUser.uniqueId
                                                     action: (didStar ? @"star" : @"unstar")
                                            videoInstanceId: videoInstance.uniqueId
                                          completionHandler: ^(id response) {
                                              self.togglingInProgress = NO;
                                              
                                              if (didStar)
                                              {
                                                  // Currently highlighted, so increment
                                                  videoInstance.video.starredByUserValue = YES;
                                                  videoInstance.video.starCountValue += 1;
                                                  
                                                  button.selected = YES;
                                                  
                                                  [videoInstance addStarrersObject: appDelegate.currentUser];
                                              }
                                              else
                                              {
                                                  // Currently highlighted, so decrement
                                                  videoInstance.video.starredByUserValue = NO;
                                                  videoInstance.video.starCountValue -= 1;
                                                  
                                                  button.selected = NO;
                                                  [videoInstance removeStarrersObject: appDelegate.currentUser];
                                              }
                                              
                                              [appDelegate saveContext: YES];
                                              
                                              if (videoInstance.starrers.count == 0)
                                              {
                                                  NSLog(@"No Starrers");
                                              }
                                              else
                                              {
                                                  for (ChannelOwner * co in videoInstance.starrers)
                                                  {
                                                      if ([co.uniqueId
                                                           isEqualToString: appDelegate.currentUser.uniqueId])
                                                      {
                                                          NSLog(@"Starrer: User*");
                                                      }
                                                      else
                                                      {
                                                          NSLog(@"Starrer: %@", co.displayName);
                                                      }
                                                  }
                                              }
                                              
                                              [self.feedCollectionView reloadData];
                                              
                                              button.enabled = YES;
                                          }
                                               errorHandler: ^(id error) {
                                                   self.togglingInProgress = NO;
                                                   
                                                   DebugLog(@"Could not star video");
                                                   
                                                   button.enabled = YES;
                                               }];
}

#pragma mark - Load More Footer

- (void) loadMoreVideos
{
    if (self.moreItemsToLoad == TRUE)
    {
        [self incrementRangeForNextRequest];
        [self loadAndUpdateFeedData];
    }
}


- (void) headerTapped
{
    [self.feedCollectionView setContentOffset:CGPointZero animated:YES];
}


- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height - kLoadMoreFooterViewHeight
        && self.isLoadingMoreContent == NO)
    {
        [self loadMoreVideos];
    }
}


- (void) applicationWillEnterForeground: (UIApplication *) application
{
    // set the data request range back to 0, 48 and refresh
    [super applicationWillEnterForeground: application];
    
    [self loadAndUpdateFeedData];
}


@end
