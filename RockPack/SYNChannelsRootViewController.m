//
//  SYNChannelsTopTabViewController.m
//  rockpack
//
//  Created by Nick Banks on 01/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "Channel.h"
#import "Genre.h"
#import "ChannelOwner.h"
#import "SYNAppDelegate.h"
#import "ChannelCover.h"
#import "GAI.h"
#import "SYNChannelCategoryTableViewController.h"
#import "SYNChannelDetailViewController.h"
#import "SYNChannelThumbnailCell.h"
#import "SYNChannelsRootViewController.h"
#import "SYNDeviceManager.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNMainRegistry.h"
#import "SYNNetworkEngine.h"
#import "SubGenre.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import "SYNGenreItemView.h"
#import "Video.h"
#import "VideoInstance.h"
#import "SYNFeedMessagesView.h"


#define kChannelsCache @"ChannelsCache"

@interface SYNChannelsRootViewController () <UIScrollViewDelegate, SYNChannelCategoryTableViewDelegate>

#ifdef ALLOWS_PINCH_GESTURES

@property (nonatomic, assign) BOOL userPinchedOut;
@property (nonatomic, strong) NSIndexPath *pinchedIndexPath;
@property (nonatomic, strong) UIImageView *pinchedView;

#endif


@property (nonatomic, assign) BOOL ignoreRefresh;
@property (nonatomic, strong) NSString* currentCategoryId;
@property (nonatomic, strong) Genre* currentGenre;
@property (nonatomic, weak) SYNMainRegistry* mainRegistry;

@property (nonatomic, strong) SYNFeedMessagesView* emptyGenreMessageView;

@property (nonatomic, strong) SYNChannelCategoryTableViewController* categoryTableViewController;
@property (nonatomic, strong) UIButton* categorySelectButton;
@property (nonatomic, strong) UIControl* categorySelectDismissControl;
@property (nonatomic, strong) UILabel* categoryNameLabel;
@property (nonatomic, strong) UILabel* subCategoryNameLabel;
@property (nonatomic, strong) UIImageView* arrowImage;
@property (nonatomic, strong) NSMutableArray* channels;


@property (nonatomic, strong) Genre* allGenre;
@end

@implementation SYNChannelsRootViewController

@synthesize currentCategoryId;
@synthesize currentGenre;
@synthesize dataRequestRange;
@synthesize dataItemsAvailable;
@synthesize mainRegistry;
@synthesize isAnimating;
@synthesize channels;
@synthesize runningNetworkOperation = _runningNetworkOperation;

#pragma mark - View lifecycle


- (void) loadView
{
    BOOL isIPhone = [SYNDeviceManager.sharedInstance isIPhone];
    
    SYNIntegralCollectionViewFlowLayout* flowLayout;
    
    if (isIPhone)
        flowLayout = [SYNIntegralCollectionViewFlowLayout layoutWithItemSize: CGSizeMake(158.0f, 169.0f)
                                                     minimumInterItemSpacing: 0.0
                                                          minimumLineSpacing: 6.0
                                                             scrollDirection: UICollectionViewScrollDirectionVertical
                                                                sectionInset: UIEdgeInsetsMake(2.0, 2.0, 46.0, 2.0)];
    else
        flowLayout = [SYNIntegralCollectionViewFlowLayout layoutWithItemSize: [self itemSize]
                                                     minimumInterItemSpacing: 0.0
                                                          minimumLineSpacing: 2.0
                                                             scrollDirection: UICollectionViewScrollDirectionVertical
                                                                sectionInset: UIEdgeInsetsMake(6.0, 6.0, 5.0, 6.0)];
        
    
    
    flowLayout.footerReferenceSize = [self footerSize];
    
    // Work out how hight the inital tab bar is
    CGFloat topTabBarHeight = [UIImage imageNamed: @"CategoryBar"].size.height;
    
    CGRect channelCollectionViewFrame;
    if (isIPhone)
    {
        channelCollectionViewFrame = CGRectMake(0.0f, 103.0f, [SYNDeviceManager.sharedInstance currentScreenWidth], [SYNDeviceManager.sharedInstance currentScreenHeight] - 123.0f);
    }
    else
    {
        channelCollectionViewFrame = [SYNDeviceManager.sharedInstance isLandscape] ?
        CGRectMake(0.0, kStandardCollectionViewOffsetY + topTabBarHeight, kFullScreenWidthLandscape, kFullScreenHeightLandscapeMinusStatusBar - kStandardCollectionViewOffsetY - topTabBarHeight) :
        CGRectMake(0.0f, kStandardCollectionViewOffsetY + topTabBarHeight, kFullScreenWidthPortrait, kFullScreenHeightPortraitMinusStatusBar  - kStandardCollectionViewOffsetY - topTabBarHeight);
    }
    
    self.channelThumbnailCollectionView = [[UICollectionView alloc] initWithFrame: channelCollectionViewFrame
                                                             collectionViewLayout: flowLayout];
    self.channelThumbnailCollectionView.dataSource = self;
    self.channelThumbnailCollectionView.delegate = self;
    self.channelThumbnailCollectionView.backgroundColor = [UIColor clearColor];
    self.channelThumbnailCollectionView.showsVerticalScrollIndicator = NO;
    self.channelThumbnailCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    CGRect newFrame;
    if (isIPhone)
    {
        newFrame = CGRectMake(0.0f, 59.0f, [SYNDeviceManager.sharedInstance currentScreenWidth], [SYNDeviceManager.sharedInstance currentScreenHeight] - 20.0f);
    }
    else
    {
        newFrame = [SYNDeviceManager.sharedInstance isLandscape] ?
        CGRectMake(0.0, 0.0, kFullScreenWidthLandscape, kFullScreenHeightLandscapeMinusStatusBar) :
        CGRectMake(0.0f, 0.0f, kFullScreenWidthPortrait, kFullScreenHeightPortraitMinusStatusBar);
    }

    
    self.view = [[UIView alloc] initWithFrame:newFrame];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.channelThumbnailCollectionView];
    
    startAnimationDelay = 0.0;
    
    if (self.enableCategoryTable)
    {
        [self layoutChannelsCategoryTable];
    }
    
    self.channelThumbnailCollectionView.showsVerticalScrollIndicator = YES;
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.mainRegistry = appDelegate.mainRegistry;
    
    self.channels = [NSMutableArray array];
    
    // Register Cells
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNChannelThumbnailCell"
                                             bundle: nil];
    
    [self.channelThumbnailCollectionView registerNib: thumbnailCellNib
                          forCellWithReuseIdentifier: @"SYNChannelThumbnailCell"];
    
    // Register Footer
    UINib *footerViewNib = [UINib nibWithNibName: @"SYNChannelFooterMoreView"
                                          bundle: nil];
    
    [self.channelThumbnailCollectionView registerNib: footerViewNib
                          forSupplementaryViewOfKind: UICollectionElementKindSectionFooter
                                 withReuseIdentifier: @"SYNChannelFooterMoreView"];

#ifdef ALLOWS_PINCH_GESTURES
    UIPinchGestureRecognizer *pinchOnChannelView = [[UIPinchGestureRecognizer alloc] initWithTarget: self
                                                                                             action: @selector(handlePinchGesture:)];
    
    [self.view addGestureRecognizer: pinchOnChannelView];
#endif
    
    currentGenre = nil;
    
    [self displayChannelsForGenre:currentGenre];
    
    [self loadChannelsForGenre:currentGenre];
}



- (void) viewDidScrollToFront
{
    [self updateAnalytics];
    
    // On Boarding
    
    SYNOnBoardingPopoverQueueController* onBoardingQueue = [[SYNOnBoardingPopoverQueueController alloc] init];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasShownSubscribeOnBoarding = [defaults boolForKey:kUserDefaultsChannels];
    if(!hasShownSubscribeOnBoarding)
    {
        NSString* message = @"To start, browse channels created by other people. A channel is a collection of videos.";
        
        SYNOnBoardingPopoverView* subscribePopover = [SYNOnBoardingPopoverView withMessage:message
                                                                                pointingTo:CGRectZero // it is a struct and cannot pass nil
                                                                             withDirection:PointingDirectionNone];
        
        
        [onBoardingQueue addPopover:subscribePopover];
        
        [defaults setBool:YES forKey:kUserDefaultsChannels];
    }
    
    
    if(!hasShownSubscribeOnBoarding)
    {
        [self.view addSubview:onBoardingQueue.view];
        [self addChildViewController:onBoardingQueue];
        [onBoardingQueue present];
    }
    else
    {
        onBoardingQueue = nil;
    }
    
    // if the user has requested 'Load More' channels then dont refresh the page cause he is in the middle of a search
    if(self.dataRequestRange.location == 0)
        [self loadChannelsForGenre:currentGenre];
}


- (void) updateAnalytics
{
    // Google analytics support
    [GAI.sharedInstance.defaultTracker sendView: @"Channels - Root"];
}


- (void) animatedPushViewController: (UIViewController *) vc
{
    [super animatedPushViewController:vc];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteSearchBarRequestHide
                                                        object: self];
}


#pragma mark - Loading of Channels

- (void) loadChannelsForGenre: (Genre*) genre
{
    [self loadChannelsForGenre: genre
                   byAppending: NO];
}


- (void) loadChannelsForGenre: (Genre*) genre
                  byAppending: (BOOL) append
{
    
    DebugLog(@"Next request: %i - %i", self.dataRequestRange.location, self.dataRequestRange.length + self.dataRequestRange.location - 1);
    
    self.runningNetworkOperation = [appDelegate.networkEngine updateChannelsScreenForCategory: (genre ? genre.uniqueId : @"all")
                                                                                     forRange: self.dataRequestRange
                                                                                ignoringCache: NO
                                                                                 onCompletion: ^(NSDictionary* response) {
                                                      
                                                      NSDictionary *channelsDictionary = [response objectForKey: @"channels"];
                                                      if (!channelsDictionary || ![channelsDictionary isKindOfClass: [NSDictionary class]])
                                                          return;
                                                      
                                                      NSArray *itemArray = [channelsDictionary objectForKey: @"items"];
                                                      if (![itemArray isKindOfClass: [NSArray class]])
                                                          return;
                                                      
                                                      dataRequestRange.length = itemArray.count;
                                                      
                                                      
                                                      
                                                      NSNumber *totalNumber = [channelsDictionary objectForKey: @"total"];
                                                      if (![totalNumber isKindOfClass: [NSNumber class]])
                                                          return;
                                                      
                                                      self.dataItemsAvailable = [totalNumber integerValue];
                                                      
                                                      
                                                      BOOL registryResultOk = [appDelegate.mainRegistry registerChannelsFromDictionary: response
                                                                                                                              forGenre: genre
                                                                                                                           byAppending: append];
                                                      self.footerView.showsLoading = NO;
                                                      
                                                      if (!registryResultOk)
                                                      {
                                                          DebugLog(@"Registration of Channel Failed for: %@", currentCategoryId);
                                                          return;
                                                      }
                                                      
                                                      [self displayChannelsForGenre:genre];
                                                      
                                                      if (self.emptyGenreMessageView)
                                                      {
                                                          [self.emptyGenreMessageView removeFromSuperview];
                                                          self.emptyGenreMessageView = nil;
                                                      }
                                                      
                                                      if (self.channels.count == 0)
                                                      {
                                                          [self displayEmptyGenreMessage:@"NO CHANNELS FOUND"];
                                                      }
                                                      
                                                      
                                                      
                                                  } onError: ^(NSDictionary* errorInfo) {
                                                      DebugLog(@"Could not load channels: %@", errorInfo);
                                                      self.footerView.showsLoading = NO;
                                                  }];
}


- (void) loadMoreChannels: (UIButton*) sender
{
    

    [self incrementRangeForNextRequest];
    
    
    [self loadChannelsForGenre: currentGenre
                   byAppending: YES];
}


- (void) displayChannelsForGenre: (Genre*) genre
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName: @"Channel"
                                   inManagedObjectContext: appDelegate.mainManagedObjectContext]];
    
    NSPredicate* genrePredicate;
    
    if (!genre) // @"all" category
    {
        genrePredicate = [NSPredicate predicateWithFormat: @"popular == YES"];
    }
    else
    {
        if ([genre isMemberOfClass:[Genre class]]) // no isKindOfClass: which will always return true in this case
        {
            genrePredicate = [NSPredicate predicateWithFormat: @"categoryId IN %@", [genre getSubGenreIdArray]];
        }
        else
        {
            genrePredicate = [NSPredicate predicateWithFormat: @"categoryId == %@", genre.uniqueId];
        }
    }
    
    NSPredicate* viewIdPredicate = [NSPredicate predicateWithFormat: @"viewId == %@", kChannelsViewId];
    
    // only get the channels marked as fresh //
    
    NSPredicate* isFreshPredicate = [NSPredicate predicateWithFormat: @"fresh == YES"];
    
    
    
    NSPredicate* finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:
                                   @[genrePredicate, isFreshPredicate, viewIdPredicate]];

    [request setPredicate:finalPredicate];
    
    NSSortDescriptor *positionDescriptor = [[NSSortDescriptor alloc] initWithKey:@"position"  ascending:YES];
    
    [request setSortDescriptors:@[positionDescriptor]];
    
    NSError *error = nil;
    
    NSArray *resultsArray = [appDelegate.mainManagedObjectContext executeFetchRequest: request error: &error];
    if (!resultsArray)
        return;
    
    DebugLog(@"resultsArray: %i", resultsArray.count);
    
    self.channels = [NSMutableArray arrayWithArray:resultsArray];
    
    

    // We shouldn't wait until the animation is over, as this will result in crashes if the user is scrolling
    
    [self.channelThumbnailCollectionView reloadData];
}


- (void) displayEmptyGenreMessage:(NSString*)message
{
    
    if (self.emptyGenreMessageView) // add no more than one
        return;
    
    self.emptyGenreMessageView = [SYNFeedMessagesView withMessage:message];
    
    self.emptyGenreMessageView.center = CGPointMake(self.view.center.x, 280.0);
    self.emptyGenreMessageView.frame = CGRectIntegral(self.emptyGenreMessageView.frame);
   
    [self.view insertSubview:self.emptyGenreMessageView belowSubview:self.categoryTableViewController.view];
}


#pragma mark - Helper Methods


- (CGSize) itemSize
{
    return [SYNDeviceManager.sharedInstance isIPhone] ? CGSizeMake(152.0f, 152.0f) : CGSizeMake(251.0, 274.0);
}




#pragma mark - CollectionView Delegate

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}

- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    return self.channels.count;

}



- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    Channel *channel = self.channels[indexPath.row];
    
    SYNChannelThumbnailCell *channelThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelThumbnailCell"
                                                                                              forIndexPath: indexPath];
    
    
    channelThumbnailCell.imageUrlString = channel.channelCover.imageLargeUrl;
    
    [channelThumbnailCell setChannelTitle: channel.title];
    channelThumbnailCell.displayNameLabel.text = [NSString stringWithFormat: @"%@", channel.channelOwner.displayName];
    channelThumbnailCell.viewControllerDelegate = self;
    
    return channelThumbnailCell;
}

- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [((SYNChannelThumbnailCell*)cell).imageView cancelCurrentImageLoad];
    
}
- (void) displayNameButtonPressed: (UIButton*) button
{
    
    
    SYNChannelThumbnailCell* parent = (SYNChannelThumbnailCell*)[[button superview] superview];
    
    NSIndexPath* indexPath = [self.channelThumbnailCollectionView indexPathForCell: parent];
    
    Channel *channel = (Channel*)self.channels[indexPath.row];
    
    [self viewProfileDetails:channel.channelOwner];
    
}



- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
    if (collectionView != self.channelThumbnailCollectionView)
        return nil;
    
    
    
    UICollectionReusableView* supplementaryView;
    
    if (kind == UICollectionElementKindSectionHeader)
    {
        // nothing yet
    }
    
    if (kind == UICollectionElementKindSectionFooter)
    {
        if (self.channels.count == 0 || (self.dataRequestRange.location + self.dataRequestRange.length) >= dataItemsAvailable)
        {
            return supplementaryView;
        }
        
        self.footerView = [self.channelThumbnailCollectionView dequeueReusableSupplementaryViewOfKind: kind
                                                                                    withReuseIdentifier: @"SYNChannelFooterMoreView"
                                                                                           forIndexPath: indexPath];
        
        [self.footerView.loadMoreButton addTarget: self
                                           action: @selector(loadMoreChannels:)
                                 forControlEvents: UIControlEventTouchUpInside];
        
        //[self loadMoreChannels:self.footerView.loadMoreButton];
        
        supplementaryView = self.footerView;
    }
    
    return supplementaryView;
}


- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (self.isAnimating) // prevent double clicking
        return;
    
    Channel *channel = (Channel*)self.channels[indexPath.row];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kChannelDetailsRequested
                                                        object:self
                                                      userInfo:@{kChannel:channel}];
}


#ifdef ALLOWS_PINCH_GESTURES

- (void) handlePinchGesture: (UIPinchGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        
        
        // At this stage, we don't know whether the user is pinching in or out
        self.userPinchedOut = FALSE;
        
        DebugLog (@"UIGestureRecognizerStateBegan");
        // figure out which item in the table was selected
        NSIndexPath *indexPath = [self.channelThumbnailCollectionView indexPathForItemAtPoint: [sender locationInView: self.channelThumbnailCollectionView]];
        
        if (!indexPath)
        {
            return;
        }
        
        self.pinchedIndexPath = indexPath;
        
        Channel *channel = (Channel*)self.channels[indexPath.row];
        SYNChannelThumbnailCell *channelCell = (SYNChannelThumbnailCell *)[self.channelThumbnailCollectionView cellForItemAtIndexPath: indexPath];
        
        // Get the various frames we need to calculate the actual position
        CGRect imageViewFrame = channelCell.imageView.frame;
        CGRect viewFrame = channelCell.superview.frame;
        CGRect cellFrame = channelCell.frame;
        
        CGPoint offset = self.channelThumbnailCollectionView.contentOffset;
        
        // Now add them together to get the real pos in the top view
        imageViewFrame.origin.x += cellFrame.origin.x + viewFrame.origin.x - offset.x;
        imageViewFrame.origin.y += cellFrame.origin.y + viewFrame.origin.y - offset.y;
        
        
        self.pinchedView = [[UIImageView alloc] initWithFrame: imageViewFrame];
        self.pinchedView.alpha = 0.7f;
        
        [self.pinchedView setImageWithURL: [NSURL URLWithString: channel.coverThumbnailLargeURL]
                         placeholderImage: nil
                                  options: SDWebImageRetryFailed];
        
        // now add the item to the view
        [self.view addSubview: self.pinchedView];
    }
    else if (sender.state == UIGestureRecognizerStateChanged)
    {
        DebugLog (@"UIGestureRecognizerStateChanged");
        float scale = sender.scale;
        
        if (scale < 1.0)
        {
            return;
        }
        else
        {
            self.userPinchedOut = TRUE;
            
            // we zoomed it, so let's update the coordinates of the dragged view
            self.pinchedView.transform = CGAffineTransformMakeScale(scale, scale);
        }
    }
    else if (sender.state == UIGestureRecognizerStateEnded)
    {
        DebugLog (@"UIGestureRecognizerStateEnded");
        
        if (self.userPinchedOut == TRUE)
        {
            [self transitionToItemAtIndexPath: self.pinchedIndexPath];
        }
    }
    else if (sender.state == UIGestureRecognizerStateCancelled)
    {
        DebugLog (@"UIGestureRecognizerStateCancelled");
        [self.pinchedView removeFromSuperview];
    }
}


// Custom zoom out transition
- (void) transitionToItemAtIndexPath: (NSIndexPath *) indexPath
{
    Channel *channel = (Channel*)self.channels[indexPath.row];
    
    SYNChannelDetailViewController *channelVC = [[SYNChannelDetailViewController alloc] initWithChannel: channel
                                                                                              usingMode: kChannelDetailsModeDisplay];
    
    channelVC.view.alpha = 0.0f;
    
    [self.navigationController pushViewController: channelVC
                                         animated: NO];
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         // Contract thumbnail view
         self.view.alpha = 0.0f;
         channelVC.view.alpha = 1.0f;
         
         // TODO: Put the correct code to hide the top bar (was removed when the implementation started)
         
         self.pinchedView.alpha = 0.0f;
         self.pinchedView.transform = CGAffineTransformMakeScale(10.0f, 10.0f);
         
     }
                     completion: ^(BOOL finished)
     {
         [self.pinchedView removeFromSuperview];
     }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteBackButtonShow
                                                        object: self];
}

#endif


- (void) handleMainTap: (UIView *) tab
{
    [super handleMainTap:tab];
    
    
    if (!tab || tab.tag == 0)
    {
        // then home button was pressed in either its icon or "all" mode respectively
        if (tabExpanded && !isAnimating)
            [self animateCollectionViewDown:NO];
        
        return;
    }
    
    if (tabExpanded || isAnimating)
        return;
    
    [self animateCollectionViewDown:YES];
    
    
}

#pragma mark - Pushing UICollectionView up and down

-(void)animateCollectionViewDown:(BOOL)down
{
    
    if (down && !tabExpanded)
    {
        
        
        isAnimating = YES;
        
        [UIView animateWithDuration: 0.4
                              delay: 0.0
                            options: UIViewAnimationCurveEaseInOut
                         animations: ^{
                             CGRect currentCollectionViewFrame = self.channelThumbnailCollectionView.frame;
                             currentCollectionViewFrame.origin.y += kCategorySecondRowHeight;
                             //
                             self.channelThumbnailCollectionView.frame = currentCollectionViewFrame;
                         }
                         completion: ^(BOOL result) {
                             
                             tabExpanded = YES;
                             isAnimating = NO;
                             [self.channelThumbnailCollectionView reloadData];
                             CGRect currentCollectionViewFrame = self.channelThumbnailCollectionView.frame;
                             currentCollectionViewFrame.size.height -= kCategorySecondRowHeight;
                             self.channelThumbnailCollectionView.frame = currentCollectionViewFrame;
                         }];
    }
    else if (tabExpanded)
    {
        
        isAnimating = YES;
        
        [UIView animateWithDuration: 0.4
                              delay: 0.1
                            options: UIViewAnimationCurveEaseInOut
                         animations: ^{
                             
                             CGRect currentCollectionViewFrame = self.channelThumbnailCollectionView.frame;
                             currentCollectionViewFrame.origin.y -= kCategorySecondRowHeight;
                             //
                             self.channelThumbnailCollectionView.frame = currentCollectionViewFrame;
                             
                             
                         }  completion: ^(BOOL result) {
                             
                             tabExpanded = NO;
                             isAnimating = NO;
                             
                             [self.channelThumbnailCollectionView reloadData];
                             
                             CGRect currentCollectionViewFrame = self.channelThumbnailCollectionView.frame;
                             currentCollectionViewFrame.size.height += kCategorySecondRowHeight;
                             self.channelThumbnailCollectionView.frame = currentCollectionViewFrame;
                         }];
    }
}

-(void)collapseToParentCategory
{
    [((SYNGenreTabView*)self.tabViewController.tabView) hideSecondaryTabs];
    [self animateCollectionViewDown:NO];
}


- (void) handleNewTabSelectionWithId: (NSString *) selectionId
{

     
}

- (void) handleNewTabSelectionWithGenre: (Genre *) genre
{
    if ([currentGenre.uniqueId isEqualToString: genre.uniqueId])
    {
        return;
    }

    currentCategoryId = genre.uniqueId;

    dataRequestRange = NSMakeRange(0, STANDARD_REQUEST_LENGTH);

    if (genre == nil)
    {
        // all category chosen
        currentCategoryId = @"all";
        currentGenre = nil;
    }
    else
    {
        currentCategoryId = genre.uniqueId;
        currentGenre = genre; 
    }
    
    CGPoint currentOffset = self.channelThumbnailCollectionView.contentOffset;
    currentOffset.y = 0;
    
    // Need to do this immediately, as opposed to animated or we may get strange offsets //
    
    [self.channelThumbnailCollectionView setContentOffset: currentOffset
                                                 animated: NO];
    
    // display what is already in the DB and then load and display again
    
    [self displayChannelsForGenre:genre];
    
    if (self.channels.count > 0)
    {
        if (self.emptyGenreMessageView)
        {
            [self.emptyGenreMessageView removeFromSuperview];
            self.emptyGenreMessageView = nil;
        }
    }
    else
    {
        [self displayEmptyGenreMessage:@"LOADING CHANNELS"];
    }
    
    [self loadChannelsForGenre: genre];
}

- (void) clearedLocationBoundData
{
    [self animateCollectionViewDown:NO];
    
    self.dataRequestRange = NSMakeRange(0, STANDARD_REQUEST_LENGTH);
    
    self.currentGenre = nil;
    
    [self loadChannelsForGenre: nil];
}


#pragma mark - categories tableview

- (void) layoutChannelsCategoryTable
{
    self.categorySelectDismissControl = [[UIControl alloc] initWithFrame: self.view.bounds];
    [self.view addSubview: self.categorySelectDismissControl];
    
    [self.categorySelectDismissControl addTarget: self
                                          action: @selector(toggleChannelsCategoryTable:)
                                forControlEvents: UIControlEventTouchDown];
    
    self.categorySelectDismissControl.hidden = YES;
    
    
    self.categoryTableViewController = [[SYNChannelCategoryTableViewController alloc] init];
    CGRect newFrame = self.channelThumbnailCollectionView.frame;
    newFrame.size.width = self.categoryTableViewController.view.frame.size.width;
    self.categoryTableViewController.view.frame = newFrame;
    [self.view addSubview:self.categoryTableViewController.view];
    self.categoryTableViewController.categoryTableControllerDelegate= self;
    self.categoryTableViewController.view.hidden = YES;
    
    
    newFrame.origin.y -= 44.0f;
    newFrame.size.height = 44.0f;
    newFrame.size.width = 320.0f;
    self.categorySelectButton = [[UIButton alloc] initWithFrame: newFrame];
    
    [self.categorySelectButton setBackgroundImage: [UIImage imageNamed: @"CategoryBar"]
                                         forState: UIControlStateNormal];
    
    [self.categorySelectButton setBackgroundImage: [UIImage imageNamed: @"CategoryBarHighlighted"]
                                         forState: UIControlStateHighlighted];
    
    [self.categorySelectButton addTarget: self
                                  action: @selector(toggleChannelsCategoryTable:)
                        forControlEvents: UIControlEventTouchUpInside];
    
    [self.view addSubview: self.categorySelectButton];
    
    newFrame.origin.x = 40.0f;
    newFrame.origin.y += 3.0f;
    newFrame.size.width = 280.0f;
    
    UILabel* newLabel = [[UILabel alloc] initWithFrame:newFrame];
    newLabel.font = [UIFont boldRockpackFontOfSize:18.0f];
    newLabel.textColor = [UIColor colorWithRed: 106.0f/255.0f green: 114.0f/255.0f blue: 122.0f/255.0f alpha: 1.0f];
    newLabel.shadowColor = [UIColor colorWithWhite: 1.0f alpha: 0.75f];
    newLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    newLabel.text = NSLocalizedString(@"ALL CATEGORIES",nil);
    newLabel.backgroundColor = [UIColor clearColor];
    CGPoint center = newLabel.center;
    [newLabel sizeToFit];
    center.x = newLabel.center.x;
    newLabel.center = center;
    self.categoryNameLabel = newLabel;
    [self.view addSubview: self.categoryNameLabel];
    
    
    newLabel = [[UILabel alloc] initWithFrame: self.categoryNameLabel.frame];
    newLabel.font = self.categoryNameLabel.font;
    newLabel.textColor = self.categoryNameLabel.textColor;
    newLabel.shadowColor = self.categoryNameLabel.shadowColor;
    newLabel.shadowOffset = self.categoryNameLabel.shadowOffset;
    newLabel.backgroundColor = self.categoryNameLabel.backgroundColor;
    newLabel.hidden = YES;
    newLabel.center = center;

    self.subCategoryNameLabel = newLabel;
    [self.view addSubview:self.subCategoryNameLabel];
    
    self.arrowImage =[[UIImageView alloc] initWithImage: [UIImage imageNamed: @"IconCategoryBarChevron~iphone"]];
    center.y -= 4.0f;
    self.arrowImage.center = center;
    self.arrowImage.hidden = YES;
    [self.view addSubview: self.arrowImage];
    
    
    
    
}

- (void) toggleChannelsCategoryTable: (id) sender
{
    if (self.categoryTableViewController.view.hidden)
    {
        CGRect startFrame = self.categoryTableViewController.view.frame;
        startFrame.origin.x = -startFrame.size.width;
        self.categoryTableViewController.view.frame = startFrame;
        self.categoryTableViewController.view.hidden = NO;
        self.categorySelectDismissControl.hidden = NO;
        
        [UIView animateWithDuration: 0.2f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             CGRect endFrame = self.categoryTableViewController.view.frame;
                             endFrame.origin.x = 0;
                             self.categoryTableViewController.view.frame = endFrame;
                         }
                         completion: nil];
    }
    else
    {
        self.categorySelectDismissControl.hidden = YES;
        [UIView animateWithDuration: 0.2f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseIn
                         animations: ^{
                             CGRect endFrame = self.categoryTableViewController.view.frame;
                             endFrame.origin.x = -endFrame.size.width;
                             self.categoryTableViewController.view.frame = endFrame;
                         }
                         completion: ^(BOOL finished) {
                             self.categoryTableViewController.view.hidden = YES;
                         }];
    }
}



- (void) categoryTableController: (SYNChannelCategoryTableViewController *) tableController
               didSelectCategory: (Genre *) category
{
    if (category)
    {
        self.categoryNameLabel.text = category.name;
        [self.categoryNameLabel sizeToFit];
        self.subCategoryNameLabel.hidden = YES;
        self.arrowImage.hidden = YES;
        [self handleNewTabSelectionWithGenre: category];
    }
    else
    {
        self.categoryNameLabel.text = @"ALL CATEGORIES";
        [self.categoryNameLabel sizeToFit];
        self.subCategoryNameLabel.hidden = YES;
        self.arrowImage.hidden = YES;
        [self handleNewTabSelectionWithGenre: nil];
    }
}


- (void) categoryTableController: (SYNChannelCategoryTableViewController *) tableController
            didSelectSubCategory: (SubGenre *) subCategory
{
    self.categoryNameLabel.text = subCategory.genre.name;
    [self.categoryNameLabel sizeToFit];
    self.subCategoryNameLabel.text = subCategory.name;
    self.subCategoryNameLabel.hidden = NO;
    [self.subCategoryNameLabel sizeToFit];
    self.arrowImage.hidden = NO;
    
    CGRect newFrame = self.arrowImage.frame;
    newFrame.origin.x = self.categoryNameLabel.frame.origin.x + self.categoryNameLabel.frame.size.width + 5.0f;
    self.arrowImage.frame = newFrame;
    
    newFrame = self.subCategoryNameLabel.frame;
    newFrame.origin.x = self.arrowImage.frame.origin.x + self.arrowImage.frame.size.width + 5.0f;
    self.subCategoryNameLabel.frame = newFrame;
    
    [self handleNewTabSelectionWithGenre: subCategory];

    [self toggleChannelsCategoryTable:nil];
}

-(void)setRunningNetworkOperation:(MKNetworkOperation *)runningNetworkOperation
{
    if(_runningNetworkOperation)
        [_runningNetworkOperation cancel];
    
    _runningNetworkOperation = runningNetworkOperation;
}

- (void) categoryTableControllerDeselectedAll: (SYNChannelCategoryTableViewController *) tableController
{
    self.categoryNameLabel.text = NSLocalizedString(@"ALL CATEGORIES",nil);
    [self.categoryNameLabel sizeToFit];
    self.subCategoryNameLabel.hidden = YES;
    self.arrowImage.hidden = YES;
    
    [self handleNewTabSelectionWithGenre: nil];
    
    [self toggleChannelsCategoryTable: nil];
}

@end
