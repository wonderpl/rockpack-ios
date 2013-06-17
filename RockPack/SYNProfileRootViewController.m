//
//  SYNYouRootViewController.m
//  rockpack
//
//  Created by Nick Banks on 24/01/2013.
//  Copysubscriptions (c) Rockpack Ltd. All subscriptionss reserved.
//

#import "Channel.h"
#import "ChannelCover.h"
#import "GAI.h"
#import "SYNChannelDetailViewController.h"
#import "SYNChannelMidCell.h"
#import "SYNChannelThumbnailCell.h"
#import "SYNDeletionWobbleLayout.h"
#import "SYNDeviceManager.h"
#import "SYNImagePickerController.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNPassthroughView.h"
#import "SYNProfileRootViewController.h"
#import "SYNSubscriptionsViewController.h"
#import "SYNUserProfileViewController.h"
#import "SYNYouHeaderView.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import "Video.h"
#import <QuartzCore/QuartzCore.h>

#define kInterChannelSpacing 150.0
#define kInterRowMargin 8.0f

@interface SYNProfileRootViewController () <SYNDeletionWobbleLayoutDelegate,
                                            UIGestureRecognizerDelegate,
                                            SYNImagePickerControllerDelegate>
{
    BOOL _isIPhone;
}

// Enable to allow the user to 'pinch out' on thumbnails
#ifdef ALLOWS_PINCH_GESTURES

@property (nonatomic, assign) BOOL userPinchedOut;
@property (nonatomic, strong) NSIndexPath *pinchedIndexPath;
@property (nonatomic, strong) UIImageView *pinchedView;

#endif

@property (nonatomic) BOOL deleteCellModeOn;
@property (nonatomic) BOOL isUserProfile;
@property (nonatomic, assign) BOOL subscriptionsTabActive;
@property (nonatomic, assign, getter = isDeletionModeActive) BOOL deletionModeActive;
@property (nonatomic, strong) IBOutlet UICollectionView *channelThumbnailCollectionView;
@property (nonatomic, strong) SYNDeletionWobbleLayout* channelsLandscapeLayout;
@property (nonatomic, strong) SYNDeletionWobbleLayout* channelsPortraitLayout;
@property (nonatomic, strong) SYNDeletionWobbleLayout* subscriptionsLandscapeLayout;
@property (nonatomic, strong) SYNDeletionWobbleLayout* subscriptionsPortraitLayout;
@property (nonatomic, strong) SYNSubscriptionsViewController* subscriptionsViewController;
@property (nonatomic, strong) SYNUserProfileViewController* userProfileController;
@property (nonatomic, strong) SYNYouHeaderView* headerChannelsView;
@property (nonatomic, strong) SYNYouHeaderView* headerSubscriptionsView;
@property (nonatomic, strong) UITapGestureRecognizer* tapGestureRecognizer;
@property (nonatomic, strong) UIView* deletionCancelView;
@property (nonatomic, weak) UIButton* channelsTabButton;
@property (nonatomic, weak) UIButton* subscriptionsTabButton;
@property (nonatomic, strong) NSIndexPath* indexPathToDelete;


@end


@implementation SYNProfileRootViewController

@synthesize channelOwner = _user;

- (void) loadView
{
    _isIPhone =  [SYNDeviceManager.sharedInstance isIPhone];
    
    // User Profile
    if(!self.hideUserProfile)
    {
        self.userProfileController = [[SYNUserProfileViewController alloc] init];
    }

    // Main Collection View
    self.channelsLandscapeLayout = [SYNDeletionWobbleLayout layoutWithItemSize: CGSizeMake(192.0f, 192.0f)
                                                       minimumInterItemSpacing: 0.0
                                                            minimumLineSpacing: 5.0
                                                               scrollDirection: UICollectionViewScrollDirectionVertical
                                                                  sectionInset: UIEdgeInsetsMake(kInterRowMargin - 8.0, 8.0, kInterRowMargin, 18.0)];
    

    self.subscriptionsLandscapeLayout = [SYNDeletionWobbleLayout layoutWithItemSize:CGSizeMake(192.0, 192.0f)
                                                                        minimumInterItemSpacing: 0.0
                                                                             minimumLineSpacing: 5.0
                                                                                scrollDirection: UICollectionViewScrollDirectionVertical
                                                                                   sectionInset: UIEdgeInsetsMake(kInterRowMargin - 8.0, 12.0, kInterRowMargin, 11.0)];

    if (_isIPhone)
    {
        self.channelsPortraitLayout = [SYNDeletionWobbleLayout layoutWithItemSize: CGSizeMake(158.0f, 158.0f)
                                                          minimumInterItemSpacing: 0.0f
                                                               minimumLineSpacing: 0.0f
                                                                  scrollDirection: UICollectionViewScrollDirectionVertical
                                                                     sectionInset: UIEdgeInsetsMake(3.0, 2.0, 0.0, 2.0)];

        self.subscriptionsPortraitLayout = [SYNDeletionWobbleLayout layoutWithItemSize: CGSizeMake(158.0f, 158.0f)
                                                               minimumInterItemSpacing: 0.0f
                                                                    minimumLineSpacing: 0.0f
                                                                       scrollDirection: UICollectionViewScrollDirectionVertical
                                                                          sectionInset: UIEdgeInsetsMake(3.0, 2.0, 0.0, 2.0)];
    }
    else
    {
        self.channelsPortraitLayout = [SYNDeletionWobbleLayout layoutWithItemSize: CGSizeMake(192.0, 192.0)
                                                          minimumInterItemSpacing: 0.0f
                                                               minimumLineSpacing: 0.0f
                                                                  scrollDirection: UICollectionViewScrollDirectionVertical
                                                                     sectionInset: UIEdgeInsetsMake(kInterRowMargin, 0.0, kInterRowMargin, 0.0)];
        
        self.subscriptionsPortraitLayout = [SYNDeletionWobbleLayout layoutWithItemSize: CGSizeMake(192.0, 192.0)
                                                               minimumInterItemSpacing: 0.0f
                                                                    minimumLineSpacing: 0.0f
                                                                       scrollDirection: UICollectionViewScrollDirectionVertical
                                                                          sectionInset: UIEdgeInsetsMake(kInterRowMargin, 0.0, kInterRowMargin, 0.0)];
    }                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                    
    CGFloat correctWidth = [SYNDeviceManager.sharedInstance isLandscape] ? 600.0 : 400.0;
    
    self.headerChannelsView = [SYNYouHeaderView headerViewForWidth: correctWidth];
    
    if (_isIPhone)
    {
        CGRect newFrame = self.headerChannelsView.frame;
        newFrame.origin.y = 59.0f;
        newFrame.size.height = 43.0f;
        self.headerChannelsView.frame = newFrame;
        [self.headerChannelsView setFontSize: 12.0f];
        
        
        self.headerChannelsView.userInteractionEnabled = NO;
    }
    else
    {
        [self.headerChannelsView setBackgroundImage: ([SYNDeviceManager.sharedInstance isLandscape] ?
                                                      [UIImage imageNamed: @"HeaderProfileChannelsLandscape"] :
                                                      [UIImage imageNamed: @"HeaderProfilePortraitBoth"])];
    }
    
//    [self.headerChannelsView setTitle: [self getHeaderTitleForChannels]
//                        andTotalCount: -1]; // this will put a dash until it is loaded
    
    CGRect collectionViewFrame = CGRectMake(0.0,
                                            self.headerChannelsView.frame.origin.y + self.headerChannelsView.currentHeight,
                                            correctWidth,
                                            [SYNDeviceManager.sharedInstance currentScreenHeightWithStatusBar] - kYouCollectionViewOffsetY);
    
    self.channelThumbnailCollectionView = [[UICollectionView alloc] initWithFrame: collectionViewFrame
                                                             collectionViewLayout: self.channelsLandscapeLayout];
    
    
    self.channelThumbnailCollectionView.dataSource = self;
    self.channelThumbnailCollectionView.delegate = self;
    self.channelThumbnailCollectionView.backgroundColor = [UIColor clearColor];
    self.channelThumbnailCollectionView.showsVerticalScrollIndicator = NO;
    self.channelThumbnailCollectionView.alwaysBounceVertical = YES;
    
    // Subscriptions Collection View
    self.subscriptionsViewController = [[SYNSubscriptionsViewController alloc] initWithViewId: kProfileViewId];
    CGRect subColViewFrame = self.subscriptionsViewController.view.frame;
    subColViewFrame.origin.x = _isIPhone ? 0.0f : collectionViewFrame.origin.x + collectionViewFrame.size.width + 10.0;
    subColViewFrame.origin.y = collectionViewFrame.origin.y;
    subColViewFrame.size.height = collectionViewFrame.size.height;
    subColViewFrame.size.width = [SYNDeviceManager.sharedInstance currentScreenWidth] - subColViewFrame.origin.x - 10.0;
    [self.subscriptionsViewController setViewFrame: subColViewFrame];
    
    if (self.channelOwner)
        self.subscriptionsViewController.channelOwner = self.channelOwner;
    
    self.headerSubscriptionsView = [SYNYouHeaderView headerViewForWidth: 384];
    
    if (_isIPhone)
    {
        CGRect newFrame = self.headerSubscriptionsView.frame;
        newFrame.origin.y = 59.0f;
        newFrame.size.height = 44.0f;
        self.headerSubscriptionsView.frame = newFrame;
        [self.headerSubscriptionsView setFontSize: 12.0f];
        
        
        
        self.headerSubscriptionsView.userInteractionEnabled = NO;
    }
    else
    {
        
        [self.headerSubscriptionsView setBackgroundImage: ([SYNDeviceManager.sharedInstance isLandscape] ? [UIImage imageNamed: @"HeaderProfileSubscriptionsLandscape"] : [UIImage imageNamed: @"HeaderProfilePortraitBoth"])];
    }
    
    CGRect headerSubFrame = self.headerSubscriptionsView.frame;
    headerSubFrame.origin.x = subColViewFrame.origin.x;
    self.headerSubscriptionsView.frame = headerSubFrame;
    
    self.view = [[UIView alloc] initWithFrame: CGRectMake(0.0f,
                                                          0.0f,
                                                          [SYNDeviceManager.sharedInstance currentScreenWidth],
                                                          [SYNDeviceManager.sharedInstance currentScreenHeightWithStatusBar])];
    
    self.deletionCancelView = [[UIView alloc] initWithFrame: CGRectMake(0.0f,
                                                                                    0.0f,
                                                                                    [SYNDeviceManager.sharedInstance currentScreenWidth],
                                                                                    [SYNDeviceManager.sharedInstance currentScreenHeightWithStatusBar])];
    
    self.deletionCancelView.backgroundColor = [UIColor clearColor];
//    self.deletionCancelView.hidden = TRUE;
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                        action: @selector(userTappedDeletionCancelView)];
    
    self.tapGestureRecognizer.delegate = self;
    [self.deletionCancelView addGestureRecognizer: self.tapGestureRecognizer];

    
    self.subscriptionsViewController.headerSubscriptionsView = self.headerSubscriptionsView;
    
    [self.view addSubview: self.headerChannelsView];
    [self.view addSubview: self.headerSubscriptionsView];
    [self.view addSubview: self.userProfileController.view];

    
    if (_isIPhone)
    {
        self.userProfileController.view.center = CGPointMake(160.0f, 28.0f);
    }
    else
    {
        CGRect userProfileFrame = self.userProfileController.view.frame;
        userProfileFrame.origin.y = 80.0;
        self.userProfileController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.userProfileController.view.frame = userProfileFrame;
    }
    
    [self.view addSubview: self.deletionCancelView];
    [self.view addSubview: self.channelThumbnailCollectionView];
    [self.view addSubview: self.subscriptionsViewController.view];
    
    if (_isIPhone)
    {
        UIImage* tabButtonImage = [UIImage imageNamed: @"ButtonProfileChannels"];
        
        UIButton* tabButton = [[UIButton alloc] initWithFrame: CGRectMake(0.0f,
                                                                          self.headerChannelsView.frame.origin.y,
                                                                          tabButtonImage.size.width,
                                                                          tabButtonImage.size.height)];
        [tabButton setImage: tabButtonImage
                   forState: UIControlStateNormal];
        
        [tabButton setImage: [UIImage imageNamed: @"ButtonProfileChannelsHighlighted"]
                   forState: UIControlStateHighlighted];
        
        [tabButton setImage: [UIImage imageNamed: @"ButtonProfileChannelsSelected"]
                   forState: UIControlStateSelected];
        
        [self.view insertSubview: tabButton
                    belowSubview: self.headerChannelsView];
        
        [tabButton addTarget: self
                      action: @selector(channelsTabTapped:)
            forControlEvents: UIControlEventTouchUpInside];
        
        tabButton.showsTouchWhenHighlighted = NO;
        self.channelsTabButton = tabButton;
        
        tabButton = [[UIButton alloc]initWithFrame: CGRectMake(160.0f,
                                                               self.headerSubscriptionsView.frame.origin.y,
                                                               tabButtonImage.size.width,
                                                               tabButtonImage.size.height)];
        [tabButton setImage: tabButtonImage
                   forState: UIControlStateNormal];
        
        [tabButton setImage: [UIImage imageNamed: @"ButtonProfileChannelsHighlighted"]
                   forState: UIControlStateHighlighted];
        
        [tabButton setImage: [UIImage imageNamed: @"ButtonProfileChannelsSelected"]
                   forState: UIControlStateSelected];
        
        [self.view insertSubview: tabButton
                    belowSubview: self.headerChannelsView];
        
        tabButton.showsTouchWhenHighlighted = NO;
        
        [tabButton addTarget: self
                      action: @selector(subscriptionsTabTapped:)
            forControlEvents: UIControlEventTouchUpInside];
        
        self.subscriptionsTabButton = tabButton;
        
        [self updateTabStates];
    }
}


#pragma mark - View Lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId])
    {
        [GAI.sharedInstance.defaultTracker sendView: @"Own Profile"];
    }
    else
    {
        [GAI.sharedInstance.defaultTracker sendView: @"User Profile"];
    }

    // Init collection view
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNChannelMidCell"
                                             bundle: nil];
    
    [self.channelThumbnailCollectionView registerNib: thumbnailCellNib
                          forCellWithReuseIdentifier: @"SYNChannelMidCell"];
    
#ifdef ALLOWS_PINCH_GESTURES
    
    UIPinchGestureRecognizer *pinchOnChannelView = [[UIPinchGestureRecognizer alloc] initWithTarget: self
                                                                                             action: @selector(handlePinchGesture:)];
    
    [self.view addGestureRecognizer: pinchOnChannelView];
#endif
    
    // Long press for entering delete mode
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget: self
                                                                                            action: @selector(activateDeletionMode:)];
    longPress.delegate = self;
    [self.channelThumbnailCollectionView addGestureRecognizer: longPress];
    
    // Tap for exiting delete mode
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                          action: @selector(endDeletionMode:)];
    tap.delegate = self;
    [self.channelThumbnailCollectionView addGestureRecognizer: tap];
    
    
    self.subscriptionsViewController.collectionView.delegate = self;
    
    [self.channelThumbnailCollectionView reloadData];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    self.deletionModeActive = NO;
    
    [self updateLayoutForOrientation: [SYNDeviceManager.sharedInstance orientation]];
    
    self.isViewDirty = YES;
    self.subscriptionsViewController.isViewDirty = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kChannelOwnerUpdateRequest
                                                        object:self
                                                      userInfo:@{kChannelOwner:self.channelOwner}];
    
    
    [self resizeScrollViews];
}


- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];
    
    
    self.deletionModeActive = NO;
}

#pragma mark - Container Scroll Delegates

- (void) viewDidScrollToFront
{
//    [self updateAnalytics];
    
    self.channelThumbnailCollectionView.scrollsToTop = YES;
    
    self.subscriptionsViewController.channelThumbnailCollectionView.scrollsToTop = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kChannelOwnerUpdateRequest
                                                        object:self
                                                      userInfo:@{kChannelOwner:self.channelOwner}];
}

-(void)viewDidScrollToBack
{
    self.channelThumbnailCollectionView.scrollsToTop = NO;
    
    self.subscriptionsViewController.channelThumbnailCollectionView.scrollsToTop = NO;
}


- (void) updateAnalytics
{
    // Google analytics support
//    [GAI.sharedInstance.defaultTracker sendView: @"You - Root"];
}

#pragma mark - Core Data Callbacks

- (void) handleDataModelChange: (NSNotification*) notification
{

    
    NSArray* updatedObjects = [[notification userInfo] objectForKey: NSUpdatedObjectsKey];
    NSArray* insertedObjects = [[notification userInfo] objectForKey: NSInsertedObjectsKey];
    NSArray* deletedObjects = [[notification userInfo] objectForKey: NSDeletedObjectsKey];

    
    [updatedObjects enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop)
    {
        
         if (obj == self.channelOwner)
         {
             
             [self.userProfileController setChannelOwner:(ChannelOwner*)obj];
             
             
             
             // == Handle Updated ==
             
             
             NSMutableArray* updatedIndexPathArray = [NSMutableArray arrayWithCapacity:updatedObjects.count]; // maximum
             
             [self.channelOwner.channels enumerateObjectsUsingBlock:^(Channel* channel, NSUInteger cidx, BOOL *cstop) {
                 
                 if(channel.hasUpdatedValues)
                 {
                     NSLog(@"PR(+) Updated (Channel): %@", channel.title);
                     
                     [updatedIndexPathArray addObject:[NSIndexPath indexPathForItem:cidx inSection:0]];
                 }
                 
                 
             }];
             
             
             // == Handle Inserted ==
             
             
             NSMutableArray* insertedIndexPathArray = [NSMutableArray arrayWithCapacity:insertedObjects.count]; // maximum
             
             [self.channelOwner.channels enumerateObjectsUsingBlock:^(Channel* channel, NSUInteger cidx, BOOL *cstop) {
                 
                 [insertedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                     
                     if(obj == channel)
                     {
                         NSLog(@"PR(+) Inserted (%@): %@", NSStringFromClass([obj class]), ((Channel*)obj).title);
                         
                         [insertedIndexPathArray addObject:[NSIndexPath indexPathForItem:cidx inSection:0]];
                     }
                 }];
                 
             }];
             
             
             // == Handle Deleted == //
             
             NSMutableArray* deletedIndetifiers = [NSMutableArray arrayWithCapacity:deletedObjects.count];
             NSMutableArray* deletedIndexPathArray = [NSMutableArray arrayWithCapacity:deletedObjects.count]; // maximum
             [deletedObjects enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
                 
                 if ([obj isKindOfClass:[Channel class]]) {
                     
                     NSLog(@"PR(-) Deleted: %@", ((Channel*)obj).title);
                     
                     [deletedIndetifiers addObject:((Channel*)obj).uniqueId];
                     
                     
                 }
                 
             }];
             
             int index = 0;
             for(SYNChannelMidCell* cell in self.channelThumbnailCollectionView.visibleCells){
                 
                 if([deletedIndetifiers containsObject:cell.dataIndentifier])
                 {
                     NSLog(@"PR(-) Found Cell at: %i", index);
                     [deletedIndexPathArray addObject:[NSIndexPath indexPathForItem:index inSection:0]];
                 }
                 index++;
                 
             }
             
             if(insertedIndexPathArray.count == 0 && deletedIndexPathArray.count == 0)
             {
         
                
                 [self.headerChannelsView setTitle: [self getHeaderTitleForChannels]
                                     andTotalCount: self.channelOwner.channels.count];
                 
                 
                 
                 if(updatedIndexPathArray.count > 0)
                 {
                     
                     
                     [self.channelThumbnailCollectionView performBatchUpdates:^{
                         
                         [self.channelThumbnailCollectionView reloadItemsAtIndexPaths:updatedIndexPathArray];
                         
                     } completion:^(BOOL finished) {
                         
                         self.isViewDirty = NO;
                        
                         // hack to make the cell appear again, might be an iOS bug
                         [self.channelThumbnailCollectionView performBatchUpdates:^{
                             
                             [self.channelThumbnailCollectionView reloadItemsAtIndexPaths:updatedIndexPathArray];
                             
                         } completion:^(BOOL finished) {
                             
                             self.isViewDirty = NO;
                             
                             
                             
                         }];
                         
                     }];
                     
                     
                 }
                 else
                 {
                     self.isViewDirty = NO;
                 }
                 
                 
                 return;
             }
             
             [self.channelThumbnailCollectionView performBatchUpdates:^{
                 
                 if(insertedIndexPathArray.count > 0)
                     [self.channelThumbnailCollectionView insertItemsAtIndexPaths:insertedIndexPathArray];
                 
                 if(deletedIndexPathArray.count > 0)
                     [self.channelThumbnailCollectionView deleteItemsAtIndexPaths:deletedIndexPathArray];
                 
                 if(updatedIndexPathArray.count > 0)
                     [self.channelThumbnailCollectionView reloadItemsAtIndexPaths:updatedIndexPathArray];
                 
                 
             } completion:^(BOOL finished) {
                 
                 
                 [self.headerChannelsView setTitle: [self getHeaderTitleForChannels]
                                     andTotalCount: self.channelOwner.channels.count];
                 
                 self.isViewDirty = NO;
                 
                 
             }];
             
             
             return;
             
             
         }
        
    }];
}


#pragma mark - gesture-recognition action methods


- (BOOL) gestureRecognizer: (UIGestureRecognizer *) gestureRecognizer
        shouldReceiveTouch: (UITouch *) touch
{
    CGPoint touchPoint = [touch locationInView: self.channelThumbnailCollectionView];
    NSIndexPath *indexPath = [self.channelThumbnailCollectionView indexPathForItemAtPoint: touchPoint];
    
    if (indexPath && [gestureRecognizer isKindOfClass: [UITapGestureRecognizer class]])
    {
        return NO;
    }
    
    return YES;
}


- (void) activateDeletionMode: (UILongPressGestureRecognizer *) recognizer
{
    if(![self.channelOwner.uniqueId isEqualToString:appDelegate.currentUser.uniqueId]) // cannot delete channels of another user
        return;
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        NSIndexPath *indexPath = [self.channelThumbnailCollectionView indexPathForItemAtPoint: [recognizer locationInView: self.channelThumbnailCollectionView]];
        
        if (indexPath)
        {
            self.deletionModeActive = YES;
            SYNDeletionWobbleLayout *layout = (SYNDeletionWobbleLayout *)self.channelThumbnailCollectionView.collectionViewLayout;
            [layout invalidateLayout];
        }
    }
}


- (void) endDeletionMode: (UITapGestureRecognizer *) recognizer
{
    if (self.isDeletionModeActive)
    {
       self.deletionModeActive = NO;
    }
}

- (void) setDeletionModeActive: (BOOL) deletionModeActive
{
    _deletionModeActive = deletionModeActive;
    SYNDeletionWobbleLayout *layout = (SYNDeletionWobbleLayout *)self.channelThumbnailCollectionView.collectionViewLayout;
    [layout invalidateLayout];
    
    self.deletionCancelView.hidden = _deletionModeActive ? FALSE : TRUE;
}


- (void) userTappedDeletionCancelView
{
    self.deletionModeActive = FALSE;
}


#pragma mark - Deletion wobble layout delegate

- (BOOL) isDeletionModeActiveForCollectionView: (UICollectionView *) collectionView
                                        layout: (UICollectionViewLayout*) collectionViewLayout
{
    if (collectionView == self.channelThumbnailCollectionView)
    {
        return self.isDeletionModeActive;
    }
    else
    {
        return NO;
    }
}

#pragma mark - Orientation


- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    [self updateLayoutForOrientation: toInterfaceOrientation];
}


- (void) updateLayoutForOrientation: (UIDeviceOrientation )orientation
{
    CGRect newFrame;
    CGFloat viewHeight;
    SYNDeletionWobbleLayout* channelsLayout;
    SYNDeletionWobbleLayout* subscriptionsLayout;
    BOOL isIPhone = [SYNDeviceManager.sharedInstance isIPhone];
    //Setup the headers
    
    if (isIPhone)
    {
        newFrame = self.headerChannelsView.frame;
        newFrame.size.width = 160.0f;
        self.headerChannelsView.frame = newFrame;
        
        newFrame = self.headerSubscriptionsView.frame;
        newFrame.origin.x = 160.0f;
        newFrame.size.width = 160.0f;
        self.headerSubscriptionsView.frame = newFrame;
        
        viewHeight = MAX([SYNDeviceManager.sharedInstance currentScreenHeight], [SYNDeviceManager.sharedInstance currentScreenWidth]) - 20.0f;
        channelsLayout = self.channelsPortraitLayout;
        subscriptionsLayout = self.subscriptionsPortraitLayout;
    }
    else
    {
        if (UIDeviceOrientationIsPortrait(orientation))
        {
            newFrame = self.headerChannelsView.frame;
            newFrame.size.width = 384.0f;
            self.headerChannelsView.frame = newFrame;
            
            newFrame = self.headerSubscriptionsView.frame;
            newFrame.origin.x = 384.0f ;
            newFrame.size.width = 384.0f;
            self.headerSubscriptionsView.frame = newFrame;
            
            viewHeight = 1004;
            
            channelsLayout = self.channelsPortraitLayout;
            subscriptionsLayout = self.subscriptionsPortraitLayout;
        }
        else
        {
            newFrame = self.headerChannelsView.frame;
            newFrame.size.width = 612.0f;
            self.headerChannelsView.frame = newFrame;
            
            newFrame = self.headerSubscriptionsView.frame;
            newFrame.origin.x = 612.0f ;
            newFrame.size.width = 412.0f;
            self.headerSubscriptionsView.frame = newFrame;
            
            viewHeight = 748;
            
            channelsLayout = self.channelsLandscapeLayout;
            subscriptionsLayout = self.subscriptionsLandscapeLayout;
        }
    
        //Apply correct backgorund images
        [self.headerSubscriptionsView setBackgroundImage:([SYNDeviceManager.sharedInstance isLandscape] ? [UIImage imageNamed:@"HeaderProfileSubscriptionsLandscape"] : [UIImage imageNamed: @"HeaderProfilePortraitBoth"])];
        
        [self.headerChannelsView setBackgroundImage:[SYNDeviceManager.sharedInstance isLandscape] ? [UIImage imageNamed: @"HeaderProfileChannelsLandscape"] : [UIImage imageNamed: @"HeaderProfilePortraitBoth"]];
    }

    NSIndexPath* indexPath = nil;
    if (self.channelThumbnailCollectionView.contentOffset.y > self.subscriptionsViewController.channelThumbnailCollectionView.contentOffset.y)
    {
        UICollectionViewCell* visibleCell = ([[self.channelThumbnailCollectionView visibleCells] count] > 0) ? [self.channelThumbnailCollectionView visibleCells][0] : nil;
        if (visibleCell != nil)
        {
            indexPath = [self.channelThumbnailCollectionView indexPathForCell:visibleCell];
        }
    }
    
    
    // Setup Channel feed collection view
    newFrame = self.channelThumbnailCollectionView.frame;
    newFrame.size.width = isIPhone ? 320.0f : self.headerChannelsView.frame.size.width;
    newFrame.size.height = viewHeight - newFrame.origin.y;
    self.channelThumbnailCollectionView.frame = newFrame;
    self.channelThumbnailCollectionView.collectionViewLayout = channelsLayout;
    [channelsLayout invalidateLayout];
    
    if (indexPath)
    {
        [self.channelThumbnailCollectionView scrollToItemAtIndexPath: indexPath
                                                    atScrollPosition: UICollectionViewScrollPositionTop
                                                            animated: NO];
    }
    
    if (!indexPath)
    {
        UICollectionViewCell* visibleCell = ([[self.subscriptionsViewController.channelThumbnailCollectionView visibleCells] count] > 0) ? [self.subscriptionsViewController.channelThumbnailCollectionView visibleCells][0] : nil;
        if (visibleCell != nil)
        {
            indexPath = [self.subscriptionsViewController.channelThumbnailCollectionView indexPathForCell: visibleCell];
        }
    }
    else
    {
        indexPath = nil;
    }
    
    //Setup subscription feed collection view
    newFrame = self.subscriptionsViewController.view.frame;
    newFrame.size.width = isIPhone ? 320.0f : self.headerSubscriptionsView.frame.size.width;
    newFrame.size.height = viewHeight - newFrame.origin.y;
    newFrame.origin.x = isIPhone ? 0.0f : self.headerSubscriptionsView.frame.origin.x;
    
    self.subscriptionsViewController.view.frame = newFrame;
    self.subscriptionsViewController.channelThumbnailCollectionView.collectionViewLayout = subscriptionsLayout;
    [subscriptionsLayout invalidateLayout];
    
    if (indexPath)
    {
        [self.subscriptionsViewController.channelThumbnailCollectionView scrollToItemAtIndexPath: indexPath
                                                                                atScrollPosition: UICollectionViewScrollPositionTop
                                                                                        animated: NO];
    }
}



#pragma mark - Updating



-(NSString*)getHeaderTitleForChannels
{
    if(_isIPhone)
    {
        if([self.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId])
            return NSLocalizedString(@"profile_screen_section_owner_created_title",nil);
        else
            return NSLocalizedString(@"profile_screen_section_user_created_title",nil);
        
    }
    else
    {
        if([self.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId])
            return NSLocalizedString(@"profile_screen_section_owner_created_title",nil);
        else
            return NSLocalizedString(@"profile_screen_section_user_created_title",nil);
    }
     
}

#pragma mark - UICollectionView DataSource/Delegate

- (NSInteger) collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section
{
    // NSLog(@"%@", user);
    return self.channelOwner.channels.count;
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    Channel *channel = (Channel*)self.channelOwner.channels[indexPath.row];
    
    SYNChannelMidCell *channelThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelMidCell"
                                                                                        forIndexPath: indexPath];
    
   
    [channelThumbnailCell.imageView setImageWithURL: [NSURL URLWithString: channel.channelCover.imageLargeUrl]
                                   placeholderImage: [UIImage imageNamed: @"PlaceholderChannelMid.png"]
                                            options: SDWebImageRetryFailed];
    
    
    // Make sure we can't delete the favourites channel
    if (channel.favouritesValue)
        channelThumbnailCell.deleteButton.enabled = NO;
    else
        channelThumbnailCell.deleteButton.enabled = YES;
    
    
    
    channelThumbnailCell.dataIndentifier = channel.uniqueId;
    
    [channelThumbnailCell setChannelTitle:channel.title];
    [channelThumbnailCell setViewControllerDelegate: self];

    channel.hasUpdatedValues = NO; // since all new changes are shown mark as clean.
    
    return channelThumbnailCell;
}


- (void) collectionView: (UICollectionView *) collectionView
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (self.isDeletionModeActive)
    {
        self.deletionModeActive = NO;
        return;
    }
    
    if(self.isViewDirty)
        return;

    
    Channel *channel;
    
    if (collectionView == self.channelThumbnailCollectionView)
    {
        channel = self.channelOwner.channels[indexPath.row];
    }
    else
    {
        channel = self.channelOwner.subscriptions[indexPath.row];
    }
    
    SYNChannelDetailViewController *channelVC = [[SYNChannelDetailViewController alloc] initWithChannel: channel
                                                                                              usingMode: kChannelDetailsModeDisplay];
    
    [self animatedPushViewController: channelVC];
}


- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    if (!_isIPhone)
    {
        CGPoint offset;
        if ([scrollView isEqual: self.channelThumbnailCollectionView])
        {
            offset = self.channelThumbnailCollectionView.contentOffset;
            offset.y = self.channelThumbnailCollectionView.contentOffset.y;
            [self.subscriptionsViewController.collectionView setContentOffset: offset];
        }
        else if ([scrollView isEqual:self.subscriptionsViewController.collectionView])
        {
            offset = self.subscriptionsViewController.collectionView.contentOffset;
            offset.y = self.subscriptionsViewController.collectionView.contentOffset.y;
            [self.channelThumbnailCollectionView setContentOffset: offset];
        }
    }
}




#ifdef ALLOWS_PINCH_GESTURES
// TODO: Decide whether to keep pinch in or out

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
        
        Channel *channel = user.channels[indexPath.row];
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
    
    Channel *channel = user.channels[indexPath.row];
    
    SYNChannelDetailViewController *channelVC = [[SYNChannelDetailViewController alloc] initWithChannel: channel
                                                                                              usingMode: kChannelDetailsModeDisplay];
    
    channelVC.view.alpha = 0.0f;
    
    [self.navigationController pushViewController: channelVC
                                         animated: NO];
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         
                         // Contract thumbnail view
                         self.view.alpha = 0.0f;
                         channelVC.view.alpha = 1.0f;
                         self.pinchedView.alpha = 0.0f;
                         self.pinchedView.transform = CGAffineTransformMakeScale(10.0f, 10.0f);
                         
                     } completion: ^(BOOL finished) {
                         
                         [self.pinchedView removeFromSuperview];
                     }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteBackButtonShow
                                                        object: self];
}
#endif


- (void) resizeScrollViews
{
    if(_isIPhone)
    {
        return;
    }
    self.channelThumbnailCollectionView.contentInset = UIEdgeInsetsZero;
    self.subscriptionsViewController.collectionView.contentInset = UIEdgeInsetsZero;
    CGSize channelViewSize = self.channelThumbnailCollectionView.contentSize;
    CGSize subscriptionsViewSize = self.subscriptionsViewController.collectionView.contentSize;
    
    if (channelViewSize.height < subscriptionsViewSize.height)
    {
        self.channelThumbnailCollectionView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, subscriptionsViewSize.height - channelViewSize.height, 0.0f);
    }
    else if(channelViewSize.height > subscriptionsViewSize.height)
    {
        self.subscriptionsViewController.collectionView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, channelViewSize.height - subscriptionsViewSize.height, 0.0f);
    }
}


#pragma mark - tab button actions

- (IBAction) channelsTabTapped: (id) sender
{
    self.subscriptionsTabActive = NO;
    [self updateTabStates];
}


- (IBAction) subscriptionsTabTapped: (id) sender
{
    self.subscriptionsTabActive = YES;
    [self updateTabStates];
}


- (void ) updateTabStates
{
    self.channelsTabButton.selected = !self.subscriptionsTabActive;
    self.subscriptionsTabButton.selected = self.subscriptionsTabActive;
    self.channelThumbnailCollectionView.hidden = self.subscriptionsTabActive;
    self.subscriptionsViewController.view.hidden = !self.subscriptionsTabActive;
    
    if (self.subscriptionsTabActive)
    {
        [self.headerChannelsView setColorsForText:[UIColor colorWithRed:106.0f/255.0f green:114.0f/255.0f blue:122.0f/255.0f alpha:1.0f] parentheses:[UIColor colorWithRed:187.0f/255.0f green:187.0f/255.0f blue:187.0f/255.0f alpha:1.0f] number:[UIColor colorWithRed:11.0f/255.0f green:166.0f/255.0f blue:171.0f/255.0f alpha:1.0f]];
        [self.headerSubscriptionsView setColorsForText:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f] parentheses:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f] number:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f]];
    }
    else
    {
        [self.headerSubscriptionsView setColorsForText:[UIColor colorWithRed:106.0f/255.0f green:114.0f/255.0f blue:122.0f/255.0f alpha:1.0f] parentheses:[UIColor colorWithRed:187.0f/255.0f green:187.0f/255.0f blue:187.0f/255.0f alpha:1.0f] number:[UIColor colorWithRed:11.0f/255.0f green:166.0f/255.0f blue:171.0f/255.0f alpha:1.0f]];
        [self.headerChannelsView setColorsForText:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f] parentheses:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f] number:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f]];
    }
    
}

#pragma mark - Deleting Channels

- (void) channelDeleteButtonTapped: (UIButton*) sender
{
    if(_deleteCellModeOn)
        return;
    
    UIView * v = sender.superview.superview;
    self.indexPathToDelete = [self.channelThumbnailCollectionView indexPathForItemAtPoint: v.center];
    
    Channel* channelToDelete = (Channel*)self.channelOwner.channels[self.indexPathToDelete.row];
    if(!channelToDelete)
        return;
    
    NSString* message = [NSString stringWithFormat: NSLocalizedString(@"profile_screen_channel_delete_dialog_description", nil), channelToDelete.title];
    NSString* title = [NSString stringWithFormat: NSLocalizedString(@"profile_screen_channel_delete_dialog_title", nil), channelToDelete.title ];
    
    [[[UIAlertView alloc] initWithTitle: title
                                message: message
                               delegate: self
                      cancelButtonTitle: NSLocalizedString(@"Cancel", nil)
                      otherButtonTitles: NSLocalizedString(@"Delete", nil), nil] show];
}


- (void) alertView: (UIAlertView *) alertView
         willDismissWithButtonIndex: (NSInteger) buttonIndex
{
    if (buttonIndex == 1)
    {
        [self deleteChannel];
    }
    else
    {
        // Cancel Clicked, do nothing
    }
}


- (void) deleteChannel
{
    Channel* channelToDelete = (Channel*)self.channelOwner.channels[self.indexPathToDelete.row];
    if(!channelToDelete)
        return;
    
    [appDelegate.oAuthNetworkEngine deleteChannelForUserId: appDelegate.currentUser.uniqueId
                                                 channelId: channelToDelete.uniqueId
                                         completionHandler: ^(id response) {
                                             
                                             UICollectionViewCell* cell =
                                             [self.channelThumbnailCollectionView cellForItemAtIndexPath:self.indexPathToDelete];
                                             
                                             [UIView animateWithDuration:0.2 animations:^{
                                                 
                                                 cell.alpha = 0.0;
                                                 
                                             } completion:^(BOOL finished) {
                                                 
                                                 for (Channel* userChannel in appDelegate.currentUser.channels)
                                                 {
                                                     if([userChannel.uniqueId isEqualToString:channelToDelete.uniqueId])
                                                     {
                                                         [appDelegate.currentUser.channelsSet removeObject:userChannel];
                                                         [appDelegate.currentUser.managedObjectContext deleteObject:userChannel];
                                                     }
                                                     
                                                 }
                                                 
                                                 
                                                 [[NSNotificationCenter defaultCenter] postNotificationName:kChannelOwnerUpdateRequest
                                                                                                     object:self
                                                                                                   userInfo:@{kChannelOwner:self.channelOwner}];
                                                 
                                                 
                                                 [appDelegate saveContext:YES];
                                                 
                                                 _deleteCellModeOn = NO;
                                                 
                                                 
                                                 
                                             }];
                                             
                                             
                                             
                                             
                                         } errorHandler: ^(id error) {
                                             
                                             
                                                    DebugLog(@"Delete channel NOT succeed");
                                             
                                                    _deleteCellModeOn = NO;
                                              }];
}

- (void) headerTapped
{
    [self.channelThumbnailCollectionView setContentOffset:CGPointZero animated:YES];
    // no need to animate the subscriptions part since it observes the channels thumbnails scroll view
}

#pragma mark - Accessors

- (void) setChannelOwner: (ChannelOwner*) user
{
    if (self.channelOwner) // if we have an existing user
    {
        // remove the listener, even if nil is passed
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSManagedObjectContextObjectsDidChangeNotification
                                                      object:self.channelOwner];
    }
    
    
    if(!user)  { // if no user has been passed, set to nil and then return
        _user = nil;
        return;
    }
        
    
    NSFetchRequest *channelOwnerFetchRequest = [[NSFetchRequest alloc] init];
    
    [channelOwnerFetchRequest setEntity: [NSEntityDescription entityForName: @"ChannelOwner"
                                                     inManagedObjectContext: user.managedObjectContext]];
    
    channelOwnerFetchRequest.includesSubentities = NO;
    
    [channelOwnerFetchRequest setPredicate: [NSPredicate predicateWithFormat: @"uniqueId == %@ AND viewId == %@", user.uniqueId, self.viewId]];
    
    NSError *error = nil;
    NSArray *matchingChannelOwnerEntries = [user.managedObjectContext executeFetchRequest: channelOwnerFetchRequest
                                                                                    error: &error];
    
    if (matchingChannelOwnerEntries.count > 0)
    {
        _user = (ChannelOwner*)matchingChannelOwnerEntries[0];
        _user.markedForDeletionValue = NO;
        
        if(matchingChannelOwnerEntries.count > 1) // housekeeping, there can be only one!
            for (int i = 1; i < matchingChannelOwnerEntries.count; i++)
                [user.managedObjectContext deleteObject:(matchingChannelOwnerEntries[i])];
    }
    else
    {
        IgnoringObjects flags = kIgnoreChannelOwnerObject | kIgnoreVideoInstanceObjects; // these flags are passed to the Channels
        
        _user = [ChannelOwner instanceFromChannelOwner: user
                                             andViewId: self.viewId
                             usingManagedObjectContext: user.managedObjectContext
                                   ignoringObjectTypes: flags];
        
        if(self.channelOwner)
        {
            [self.channelOwner.managedObjectContext save:&error];
            if(error)
                _user = nil; // further error code
            
        }
    }
    
    
    self.userProfileController.channelOwner = self.channelOwner;
    
    self.subscriptionsViewController.channelOwner = self.channelOwner;
    
    if(self.channelOwner) // if a user has been passed or found, monitor
    {
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleDataModelChange:)
                                                     name: NSManagedObjectContextDidSaveNotification
                                                   object: self.channelOwner.managedObjectContext];
        

    }
}


- (ChannelOwner*) channelOwner
{
    return _user;
}

- (void) dealloc
{
    self.channelOwner = nil;
}

@end
