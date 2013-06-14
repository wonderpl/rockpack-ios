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
@property (nonatomic, strong) NSBlockOperation *blockOperation;
@property (nonatomic, assign) BOOL shouldReloadCollectionView;
@property (nonatomic, weak) SYNVideoThumbnailWideCell* selectedCell;

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
    
    self.refreshControl.tintColor = [UIColor colorWithRed:(11.0/255.0) green:(166.0/255.0) blue:(171.0/255.0) alpha:(1.0)];
    
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
    
    
    self.dataRequestRange = NSMakeRange(0, STANDARD_REQUEST_LENGTH);
    
    [self displayEmptyGenreMessage:NSLocalizedString(@"feed_screen_loading_message", nil) andLoader:YES];
    
    [self loadAndUpdateFeedData];
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
    
}

-(void)videoQueueCleared
{
    // this will remove the '+' from the videos that where selected
    [self.videoThumbnailCollectionView reloadData];
}
- (void) viewDidScrollToFront
{
    [self updateAnalytics];
    if(self.dataRequestRange.location == 0)
    {
        [self refreshData];
    }
}


- (void) updateAnalytics
{
    // Google analytics support
    [GAI.sharedInstance.defaultTracker sendView: @"Feed"];
}



-(void)refreshData
{
    [self.refreshButton startRefreshCycle];
    self.dataRequestRange = NSMakeRange(0, STANDARD_REQUEST_LENGTH);
    [self loadAndUpdateFeedData];
}


- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                 duration: (NSTimeInterval) duration
{
    [super willRotateToInterfaceOrientation: toInterfaceOrientation
                                   duration: duration];
    
    [self.videoThumbnailCollectionView reloadData];
}


#ifdef SMART_RELOAD

- (void) controllerWillChangeContent: (NSFetchedResultsController *) controller
{
    self.shouldReloadCollectionView = NO;
    self.blockOperation = [NSBlockOperation new];
}

// We need to serialise all of the updates, and we could either use performBatchUpdates or put then on 

// Add all our section changes to our block queue
- (void) controller: (NSFetchedResultsController *) controller
   didChangeSection: (id<NSFetchedResultsSectionInfo>) sectionInfo
            atIndex: (NSUInteger) sectionIndex
      forChangeType: (NSFetchedResultsChangeType) type
{
    __weak UICollectionView *collectionView = self.videoThumbnailCollectionView;
    
    switch (type)
    {
        case NSFetchedResultsChangeInsert:
        {
            [self.blockOperation addExecutionBlock: ^{
                [collectionView insertSections: [NSIndexSet indexSetWithIndex: sectionIndex]];
            }];
            break;
        }
            
        case NSFetchedResultsChangeDelete:
        {
            [self.blockOperation addExecutionBlock: ^{
                [collectionView deleteSections: [NSIndexSet indexSetWithIndex: sectionIndex]];
            }];
            break;
        }
            
        case NSFetchedResultsChangeUpdate:
        {
            [self.blockOperation addExecutionBlock: ^{
                [collectionView reloadSections: [NSIndexSet indexSetWithIndex: sectionIndex]];
            }];
            break;
        }
            
        default:
            break;
    }
}


//  Add all the object changes to our block queue
- (void) controller: (NSFetchedResultsController *) controller
    didChangeObject: (id) changeObject
        atIndexPath: (NSIndexPath *) indexPath
      forChangeType: (NSFetchedResultsChangeType) type
       newIndexPath: (NSIndexPath *) newIndexPath
{
    __weak UICollectionView *collectionView = self.videoThumbnailCollectionView;
    
    switch (type)
    {
        case NSFetchedResultsChangeInsert:
        {
            if ([self.videoThumbnailCollectionView numberOfSections] > 0)
            {
                if ([self.videoThumbnailCollectionView numberOfItemsInSection: indexPath.section] == 0)
                {
                    self.shouldReloadCollectionView = YES;
                }
                else
                {
                    [self.blockOperation addExecutionBlock: ^{
                        [collectionView insertItemsAtIndexPaths: @[newIndexPath]];
                    }];
                }
            }
            else
            {
                self.shouldReloadCollectionView = YES;
            }
            break;
        }
            
        case NSFetchedResultsChangeDelete:
        {
            if ([self.videoThumbnailCollectionView numberOfItemsInSection: indexPath.section] == 1)
            {
                self.shouldReloadCollectionView = YES;
            }
            else
            {
                [self.blockOperation addExecutionBlock: ^{
                    [collectionView deleteItemsAtIndexPaths:@[indexPath]];
                }];
            }
            break;
        }
            
        case NSFetchedResultsChangeUpdate:
        {
            [self.blockOperation addExecutionBlock: ^{
                [collectionView reloadItemsAtIndexPaths: @[indexPath]];
            }];
            break;
        }
            
        case NSFetchedResultsChangeMove:
        {
            [self.blockOperation addExecutionBlock: ^{
                [collectionView moveItemAtIndexPath: indexPath
                                        toIndexPath: newIndexPath];
            }];
            break;
        }
            
        default:
            break;
    }
}


// Nasty hack to work around know problems with UICollectionView (http://openradar.appspot.com/12954582)
- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{
    if (self.shouldReloadCollectionView)
    {
        // Oh dear, we need to work around the bug, so just reload the collection view
        [self.videoThumbnailCollectionView reloadData];
    }
    else
    {
        // Luckily we can use the nice UICollectionView animations, (within our batch update)
        [self.videoThumbnailCollectionView performBatchUpdates: ^{
            [self.blockOperation start];
        } completion: nil];
    }
}

#else


- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{
    
    [self.videoThumbnailCollectionView reloadData];
}

#endif


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
                                                    
                                                    
                                                    [self removeEmptyGenreMessage];
                                                    
                                                    if(self.fetchedResultsController.fetchedObjects.count == 0)
                                                    {
                                                        [self displayEmptyGenreMessage:NSLocalizedString(@"feed_screen_empty_message", nil) andLoader:NO];
                                                    }  
                                                    
                                                    DebugLog(@"new fetched count : %i", self.fetchedResultsController.fetchedObjects.count);
                                                    
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
    [self.videoThumbnailCollectionView reloadData];
    
    [self loadAndUpdateFeedData];
    
}

-(void)removeEmptyGenreMessage
{
    if(!self.emptyGenreMessageView)
        return;
    
    [self.emptyGenreMessageView removeFromSuperview];
}

- (void) displayEmptyGenreMessage:(NSString*)messageKey andLoader:(BOOL)isLoader
{
    
    if (self.emptyGenreMessageView)
    {
        [self.emptyGenreMessageView removeFromSuperview];
        self.emptyGenreMessageView = nil;
    }
    
    self.emptyGenreMessageView = [SYNFeedMessagesView withMessage:NSLocalizedString(messageKey ,nil) andLoader:isLoader];
    
    CGRect messageFrame = self.emptyGenreMessageView.frame;
    messageFrame.origin.y = [[SYNDeviceManager sharedInstance] currentScreenHeight] * 0.5 - messageFrame.size.height * 0.5;
    messageFrame.origin.x = [[SYNDeviceManager sharedInstance] currentScreenWidth] * 0.5 - messageFrame.size.width * 0.5;
    messageFrame= CGRectIntegral(messageFrame);
    self.emptyGenreMessageView.frame = messageFrame;
    self.emptyGenreMessageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    
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
        SYNOnBoardingPopoverQueueController* onBoardingQueue = [[SYNOnBoardingPopoverQueueController alloc] init];
        
        NSString* message = @"Whenever you see a video you like tap the + button to add it to one of your channels.";
        
        CGFloat fontSize = [[SYNDeviceManager sharedInstance] isIPad] ? 19.0 : 15.0 ;
        CGSize size = [[SYNDeviceManager sharedInstance] isIPad] ? CGSizeMake(340.0, 144.0) : CGSizeMake(260.0, 144.0);
        CGRect rectToPointTo = CGRectZero;
        PointingDirection directionToPointTo = PointingDirectionDown;
        if(self.selectedCell)
        {
            rectToPointTo = [self.view convertRect:self.selectedCell.addItButton.frame fromView:self.selectedCell];
            if(rectToPointTo.origin.y < [[SYNDeviceManager sharedInstance] currentScreenHeight] * 0.5)
                directionToPointTo = PointingDirectionUp;
            
            //NSLog(@"%f %f", rectToPointTo.origin.x, rectToPointTo.origin.y);
        }
        SYNOnBoardingPopoverView* subscribePopover = [SYNOnBoardingPopoverView withMessage:message
                                                                                  withSize:size
                                                                               andFontSize:fontSize
                                                                                pointingTo:rectToPointTo
                                                                             withDirection:directionToPointTo];
        
        
        [onBoardingQueue addPopover:subscribePopover];
        
        [defaults setBool:YES forKey:kUserDefaultsAddVideo];
        
        [self.view addSubview:onBoardingQueue.view];
        [self addChildViewController:onBoardingQueue];
        [onBoardingQueue present];
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

- (BOOL) needsAddButton
{
    return NO;
}



-(void)headerTapped
{
    [self.videoThumbnailCollectionView setContentOffset:CGPointZero animated:YES];
}



@end
