//
//  SYNYouRootViewController.m
//  rockpack
//
//  Created by Nick Banks on 24/01/2013.
//  Copysubscriptions (c) 2013 Nick Banks. All subscriptionss reserved.
//

#import "Channel.h"
#import "ChannelOwner.h"
#import "SYNChannelThumbnailCell.h"
#import "SYNChannelDetailViewController.h"
#import "SYNDeviceManager.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNYouRootViewController.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+ImageProcessing.h"
#import "Video.h"
#import "SYNUserProfileViewController.h"
#import "SYNSubscriptionsViewController.h"
#import "SYNChannelMidCell.h"
#import "SYNYouHeaderView.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNDeletionWobbleLayout.h"

#define kInterChannelSpacing 150.0
#define kInterRowMarging 12.0

@interface SYNYouRootViewController () <SYNDeletionWobbleLayoutDelegate, UIGestureRecognizerDelegate>


// Enable to allow the user to 'pinch out' on thumbnails
#ifdef ALLOWS_PINCH_GESTURES

@property (nonatomic, assign) BOOL userPinchedOut;
@property (nonatomic, strong) NSIndexPath *pinchedIndexPath;
@property (nonatomic, strong) UIImageView *pinchedView;

#endif

@property (nonatomic, strong) IBOutlet UICollectionView *channelThumbnailCollectionView;

@property (nonatomic, strong) SYNSubscriptionsViewController* subscriptionsViewController;
@property (nonatomic, strong) SYNUserProfileViewController* userProfileController;
@property (nonatomic, strong) SYNYouHeaderView* headerChannelsView;
@property (nonatomic, strong) SYNYouHeaderView* headerSubscriptionsView;

@property (nonatomic, strong) SYNDeletionWobbleLayout* channelsLandscapeLayout;
@property (nonatomic, strong) SYNDeletionWobbleLayout* channelsPortraitLayout;
@property (nonatomic, strong) SYNDeletionWobbleLayout* subscriptionsLandscapeLayout;
@property (nonatomic, strong) SYNDeletionWobbleLayout* subscriptionsPortraitLayout;

@property (nonatomic, weak) Channel* channelDeleteCandidate;
@property (nonatomic, weak) SYNChannelMidCell* cellDeleteCandidate;
@property (nonatomic, strong) UIGestureRecognizer* tapOnScreenRecogniser;

@property (nonatomic) BOOL deleteCellModeOn;

@property (nonatomic, strong) UILongPressGestureRecognizer* longPressGestureRecogniser;

@property (nonatomic, assign) BOOL subscriptionsTabActive;
@property (nonatomic, weak) UIButton* channelsTabButton;
@property (nonatomic, weak) UIButton* subscriptionsTabButton;
<<<<<<< HEAD
@property (nonatomic, assign, getter = isDeletionModeActive) BOOL deletionModeActive;

=======
@property (nonatomic, weak) User* user;
>>>>>>> origin/develop



@end


@implementation SYNYouRootViewController

@synthesize subscriptionsViewController;
@synthesize user;


- (id) initWithViewId: (NSString *) vid
{
    if(self = [super initWithViewId: vid])
    {
        self.title = kProfileTitle;
        
    }
    
    return self;
}


- (void) loadView
{
    
    BOOL isIPhone =  [[SYNDeviceManager sharedInstance] isIPhone];
    
    // User Profile
    if(!isIPhone)
    {
        self.userProfileController = [[SYNUserProfileViewController alloc] init];
    }

    // Main Collection View
    self.channelsLandscapeLayout = [SYNDeletionWobbleLayout layoutWithItemSize: CGSizeMake(184.0, kInterChannelSpacing)
                                                       minimumInterItemSpacing: 0.0
                                                            minimumLineSpacing: 5.0
                                                               scrollDirection: UICollectionViewScrollDirectionVertical
                                                                  sectionInset: UIEdgeInsetsMake(10.0, 8.0, kInterRowMarging, 28.0)];
    

    self.subscriptionsLandscapeLayout = [SYNDeletionWobbleLayout layoutWithItemSize:CGSizeMake(184.0, kInterChannelSpacing)
                                                                        minimumInterItemSpacing:0.0
                                                                             minimumLineSpacing:5.0
                                                                                scrollDirection:UICollectionViewScrollDirectionVertical
                                                                                   sectionInset:UIEdgeInsetsMake(10.0, 30.0, kInterRowMarging, 8.0)];
    
    
    if (isIPhone)
    {
        self.channelsPortraitLayout = [SYNIntegralCollectionViewFlowLayout layoutWithItemSize:CGSizeMake(152.0f, 152.0f) minimumInterItemSpacing:0.0 minimumLineSpacing:6.0 scrollDirection:UICollectionViewScrollDirectionVertical sectionInset:UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)];

        self.subscriptionsPortraitLayout= [SYNIntegralCollectionViewFlowLayout layoutWithItemSize:CGSizeMake(152.0f, 152.0f) minimumInterItemSpacing:0.0 minimumLineSpacing:6.0 scrollDirection:UICollectionViewScrollDirectionVertical sectionInset:UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0)];
    }
    else
    {
        self.channelsPortraitLayout = [SYNDeletionWobbleLayout layoutWithItemSize:CGSizeMake(184.0, kInterChannelSpacing) minimumInterItemSpacing:0.0 minimumLineSpacing:10.0 scrollDirection:UICollectionViewScrollDirectionVertical sectionInset:UIEdgeInsetsMake(10.0, 4.0, kInterRowMarging, 4.0)];
        
        self.subscriptionsPortraitLayout= [SYNDeletionWobbleLayout layoutWithItemSize:CGSizeMake(184.0, kInterChannelSpacing) minimumInterItemSpacing:0.0 minimumLineSpacing:10.0 scrollDirection:UICollectionViewScrollDirectionVertical sectionInset:UIEdgeInsetsMake(10.0, 4.0, kInterRowMarging, 4.0)];
    }
                                                                                                                                                                                                                                                                             
                                                                                                                                                                                                                                                                             
    CGFloat correctWidth = [[SYNDeviceManager sharedInstance] isLandscape] ? 600.0 : 400.0;
    
    self.headerChannelsView = [SYNYouHeaderView headerViewForWidth:correctWidth];
    if(isIPhone)
    {
        CGRect newFrame = self.headerChannelsView.frame;
        newFrame.origin.y = 59.0f;
        newFrame.size.height = 44.0f;
        self.headerChannelsView.frame = newFrame;
        [self.headerChannelsView setFontSize:12.0f];
        [self.headerChannelsView setTitle:NSLocalizedString(@"CHANNELS",nil) andNumber:2];
        self.headerChannelsView.userInteractionEnabled = NO;
    }
    else
    {
        [self.headerChannelsView setTitle:@"YOUR CHANNELS" andNumber:2];
        [self.headerChannelsView setBackgroundImage:([[SYNDeviceManager sharedInstance] isLandscape] ? [UIImage imageNamed:@"HeaderProfileChannelsLandscape"] : [UIImage imageNamed:@"HeaderProfilePortraitBoth"])];
    }
    
    CGRect collectionViewFrame = CGRectMake(0.0,
                                            self.headerChannelsView.frame.origin.y + self.headerChannelsView.currentHeight,
                                            correctWidth,
                                            [[SYNDeviceManager sharedInstance] currentScreenHeight] - 20.0 - kYouCollectionViewOffsetY);
    
    self.channelThumbnailCollectionView = [[UICollectionView alloc] initWithFrame: collectionViewFrame
                                                             collectionViewLayout: self.channelsLandscapeLayout];
    
    
    self.channelThumbnailCollectionView.dataSource = self;
    self.channelThumbnailCollectionView.delegate = self;
    self.channelThumbnailCollectionView.backgroundColor = [UIColor clearColor];
    self.channelThumbnailCollectionView.showsVerticalScrollIndicator = NO;
    self.channelThumbnailCollectionView.alwaysBounceVertical = YES;
    
//    SYNDeletionWobbleLayout

    // Subscriptions Collection View
    
    self.subscriptionsViewController = [[SYNSubscriptionsViewController alloc] initWithViewId: kProfileViewId];
    CGRect subColViewFrame = self.subscriptionsViewController.view.frame;
    subColViewFrame.origin.x = isIPhone ? 0.0f : collectionViewFrame.origin.x + collectionViewFrame.size.width + 10.0;
    subColViewFrame.origin.y = collectionViewFrame.origin.y;
    subColViewFrame.size.height = collectionViewFrame.size.height;
    subColViewFrame.size.width = [[SYNDeviceManager sharedInstance] currentScreenWidth] - subColViewFrame.origin.x - 10.0;
    [self.subscriptionsViewController setViewFrame:subColViewFrame];
    
    self.headerSubscriptionsView = [SYNYouHeaderView headerViewForWidth: 384];
    if(isIPhone)
    {
        CGRect newFrame = self.headerSubscriptionsView.frame;
        newFrame.origin.y = 59.0f;
        newFrame.size.height = 44.0f;
        self.headerSubscriptionsView.frame = newFrame;
        [self.headerSubscriptionsView setFontSize:12.0f];
        [self.headerSubscriptionsView setTitle:NSLocalizedString(@"SUBSCRIPTIONS",nil) andNumber:2];
        self.headerSubscriptionsView.userInteractionEnabled = NO;
    }
    else
    {
        [self.headerSubscriptionsView setTitle:@"YOUR SUBSCRIPTIONS" andNumber: 2];
        [self.headerSubscriptionsView setBackgroundImage:([[SYNDeviceManager sharedInstance] isLandscape] ? [UIImage imageNamed:@"HeaderProfileSubscriptionsLandscape"] : [UIImage imageNamed: @"HeaderProfilePortraitBoth"])];
    }
    CGRect headerSubFrame = self.headerSubscriptionsView.frame;
    headerSubFrame.origin.x = subColViewFrame.origin.x;
    self.headerSubscriptionsView.frame = headerSubFrame;
    
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                         0.0,
                                                         [[SYNDeviceManager sharedInstance] currentScreenWidth],
                                                         [[SYNDeviceManager sharedInstance] currentScreenHeightWithStatusBar])];
    
    self.subscriptionsViewController.headerView = self.headerSubscriptionsView;
    
    [self.view addSubview:self.headerChannelsView];
    
    [self.view addSubview:self.headerSubscriptionsView];
    
    [self.view addSubview:self.userProfileController.view];
    
    [self.view addSubview:self.channelThumbnailCollectionView];
    
    [self.view addSubview:self.subscriptionsViewController.view];
    
    CGRect userProfileFrame = self.userProfileController.view.frame;
    userProfileFrame.origin.y = 80.0;
    self.userProfileController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    self.userProfileController.view.frame = userProfileFrame;
    [self.view addSubview:self.userProfileController.view];
    
    if(isIPhone)
    {
        UIImage* tabButtonImage = [UIImage imageNamed:@"ButtonProfileChannels"];
        UIButton* tabButton = [[UIButton alloc]initWithFrame:CGRectMake(0.0f,self.headerChannelsView.frame.origin.y,tabButtonImage.size.width, tabButtonImage.size.height)];
        [tabButton setImage:tabButtonImage forState:UIControlStateNormal];
        [tabButton setImage:[UIImage imageNamed:@"ButtonProfileChannelsHighlighted"] forState:UIControlStateHighlighted];
        [tabButton setImage:[UIImage imageNamed:@"ButtonProfileChannelsSelected"] forState:UIControlStateSelected];
        [self.view insertSubview:tabButton belowSubview:self.headerChannelsView];
        [tabButton addTarget:self action:@selector(channelsTabTapped:) forControlEvents:UIControlEventTouchUpInside];
        tabButton.showsTouchWhenHighlighted = NO;
        self.channelsTabButton = tabButton;
        
        tabButton = [[UIButton alloc]initWithFrame:CGRectMake(160.0f,self.headerSubscriptionsView.frame.origin.y,tabButtonImage.size.width, tabButtonImage.size.height)];
        [tabButton setImage:tabButtonImage forState:UIControlStateNormal];
        [tabButton setImage:[UIImage imageNamed:@"ButtonProfileChannelsHighlighted"] forState:UIControlStateHighlighted];
        [tabButton setImage:[UIImage imageNamed:@"ButtonProfileChannelsSelected"] forState:UIControlStateSelected];
        [self.view insertSubview:tabButton belowSubview:self.headerChannelsView];
        tabButton.showsTouchWhenHighlighted = NO;
        [tabButton addTarget:self action:@selector(subscriptionsTabTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.subscriptionsTabButton = tabButton;
        
        [self updateTabStates];

    }
    
}

#pragma mark - View Lifecycle


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.user = appDelegate.currentUser;
    
    self.trackedViewName = @"You - Root";
    
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
    
    
//    _longPressGestureRecogniser = [[UILongPressGestureRecognizer alloc] initWithTarget: self
//                                                                                action: @selector(longPressPerformed:)];
//    
//    [self.channelThumbnailCollectionView addGestureRecognizer:_longPressGestureRecogniser];
//    //_longPressGestureRecogniser.delegate = self;
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDataModelChange:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:appDelegate.mainManagedObjectContext];

    
    
    [self reloadCollectionViews];
    
}

-(void)handleDataModelChange:(NSNotification*)notification
{
    NSArray* updatedObjects = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
    [updatedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if ([obj isKindOfClass:[User class]]) {
            [self reloadCollectionViews];
        }
    }];
    
}

//-(void)longPressPerformed:(UILongPressGestureRecognizer*)recogniser
//{
//    if(self.deleteCellModeOn)
//        return;
//    
//    switch (recogniser.state)
//    {
//        case UIGestureRecognizerStateBegan:
//        {
//            self.deleteCellModeOn = YES;
//            
//            
//            
//            //
//            
//            CGPoint pointClicked = [recogniser locationInView:self.channelThumbnailCollectionView];
//            NSIndexPath *currentIndexPath = [self.channelThumbnailCollectionView indexPathForItemAtPoint:pointClicked];
//            
//            if(currentIndexPath.row == 0) // favourites pressed (cannot delete)
//                return;
//            
//            
//            
//            self.cellDeleteCandidate = (SYNChannelMidCell*)[self.channelThumbnailCollectionView cellForItemAtIndexPath: currentIndexPath];
//            
//            self.cellDeleteCandidate.deleteButton.hidden = NO;
//            
//            self.tapOnScreenRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                                 action:@selector(tappedOnScreen:)];
//            
//            [self.view addGestureRecognizer:self.tapOnScreenRecogniser];
//            
//            [UIView animateWithDuration: 0.2
//                                  delay: 0.0
//                                options: UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
//                             animations: ^{
//                 
//                                 self.cellDeleteCandidate.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
//                 
//                           } completion: ^(BOOL finished) {
//                 
//                               [UIView animateWithDuration: 0.2
//                                                     delay: 0.0
//                                                   options: UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn
//                                                animations: ^{
//                                                    
//                                                    
//                                                    self.cellDeleteCandidate.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
//                                                    
//                                                } completion: ^(BOOL finished) {
//                                                    
//                                                }];
//                               
//                           }];
//            
//            
//        }
//        break;
//            
//        default:
//            break;
//            
//            
//    }
//}

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
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        NSIndexPath *indexPath = [self.channelThumbnailCollectionView indexPathForItemAtPoint: [recognizer locationInView: self.channelThumbnailCollectionView]];
        
        if (indexPath)
        {
<<<<<<< HEAD
            self.deletionModeActive = YES;
            SYNDeletionWobbleLayout *layout = (SYNDeletionWobbleLayout *)self.channelThumbnailCollectionView.collectionViewLayout;
            [layout invalidateLayout];
=======
            self.deleteCellModeOn = YES;
            
            //
            
            CGPoint pointClicked = [recogniser locationInView:self.channelThumbnailCollectionView];
            NSIndexPath *currentIndexPath = [self.channelThumbnailCollectionView indexPathForItemAtPoint:pointClicked];
            
            if(currentIndexPath.row == 0) // favourites pressed (cannot delete)
                return;
            
            
            
            self.cellDeleteCandidate = (SYNChannelMidCell*)[self.channelThumbnailCollectionView cellForItemAtIndexPath: currentIndexPath];
            
            self.cellDeleteCandidate.deleteButton.hidden = NO;
            
            self.tapOnScreenRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(tappedOnScreen:)];
            
            [self.view addGestureRecognizer:self.tapOnScreenRecogniser];
            
            [UIView animateWithDuration: 0.2
                                  delay: 0.0
                                options: UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                             animations: ^{
                 
                                 self.cellDeleteCandidate.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
                 
                           } completion: ^(BOOL finished) {
                 
                               [UIView animateWithDuration: 0.2
                                                     delay: 0.0
                                                   options: UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn
                                                animations: ^{
                                                    
                                                    
                                                    self.cellDeleteCandidate.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                                                    
                                                } completion: ^(BOOL finished) {
                                                    
                                                }];
                               
                           }];
            
            
>>>>>>> origin/develop
        }
    }
}

- (void) endDeletionMode: (UITapGestureRecognizer *) recognizer
{
    if (self.isDeletionModeActive)
    {
        NSIndexPath *indexPath = [self.channelThumbnailCollectionView indexPathForItemAtPoint: [recognizer locationInView: self.channelThumbnailCollectionView]];
        
        if (!indexPath)
        {
            self.deletionModeActive = NO;
            SYNDeletionWobbleLayout *layout = (SYNDeletionWobbleLayout *)self.channelThumbnailCollectionView.collectionViewLayout;
            [layout invalidateLayout];
        }
    }
}


#pragma mark - Deletion wobble layout delegate

- (BOOL) isDeletionModeActiveForCollectionView: (UICollectionView *) collectionView
                                        layout: (UICollectionViewLayout*) collectionViewLayout
{
    return self.isDeletionModeActive;
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [self.userProfileController setChannelOwner:appDelegate.currentUser];
    
    self.subscriptionsViewController.collectionView.delegate = self;
    
    [self updateLayoutForOrientation:[[SYNDeviceManager sharedInstance] orientation]];
    
    
    
}


<<<<<<< HEAD
- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];
}


- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    //[self resizeScrollViews];
}
=======
>>>>>>> origin/develop


- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    [self updateLayoutForOrientation:toInterfaceOrientation];
}


- (void) updateLayoutForOrientation: (UIDeviceOrientation )orientation
{
    CGRect newFrame;
    CGFloat viewHeight;
    SYNDeletionWobbleLayout* channelsLayout;
    SYNDeletionWobbleLayout* subscriptionsLayout;
    BOOL isIPhone = [[SYNDeviceManager sharedInstance] isIPhone];
    //Setup the headers
    if(isIPhone)
    {
        
        newFrame = self.headerChannelsView.frame;
        newFrame.size.width = 160.0f;
        self.headerChannelsView.frame = newFrame;
        
        newFrame = self.headerSubscriptionsView.frame;
        newFrame.origin.x = 160.0f;
        newFrame.size.width = 160.0f;
        self.headerSubscriptionsView.frame = newFrame;
        
        viewHeight = MAX([[SYNDeviceManager sharedInstance] currentScreenHeight], [[SYNDeviceManager sharedInstance] currentScreenWidth]) - 20.0f;
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
            
            viewHeight = 718;
            
            channelsLayout = self.channelsLandscapeLayout;
            subscriptionsLayout = self.subscriptionsLandscapeLayout;
        }
    
        //Apply correct backgorund images
        [self.headerSubscriptionsView setBackgroundImage:([[SYNDeviceManager sharedInstance] isLandscape] ? [UIImage imageNamed:@"HeaderProfileSubscriptionsLandscape"] : [UIImage imageNamed: @"HeaderProfilePortraitBoth"])];
        
        [self.headerChannelsView setBackgroundImage:[[SYNDeviceManager sharedInstance] isLandscape] ? [UIImage imageNamed: @"HeaderProfileChannelsLandscape"] : [UIImage imageNamed: @"HeaderProfilePortraitBoth"]];
        
    }
    

    NSIndexPath* indexPath = nil;
    if(self.channelThumbnailCollectionView.contentOffset.y > self.subscriptionsViewController.channelThumbnailCollectionView.contentOffset.y)
    {
        UICollectionViewCell* visibleCell = ([[self.channelThumbnailCollectionView visibleCells] count] > 0) ? [[self.channelThumbnailCollectionView visibleCells] objectAtIndex:0] : nil;
        if(visibleCell != nil) {
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
        UICollectionViewCell* visibleCell = ([[self.subscriptionsViewController.channelThumbnailCollectionView visibleCells] count] > 0) ? [[self.subscriptionsViewController.channelThumbnailCollectionView visibleCells] objectAtIndex: 0] : nil;
        if(visibleCell != nil)
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
    newFrame.size.width = isIPhone ? 320.0f : self.headerChannelsView.frame.size.width;
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







- (void) reloadCollectionViews
{
    [super reloadCollectionViews];
    
    NSInteger totalChannels = user.channels.count;
    NSString* title = [[SYNDeviceManager sharedInstance] isIPhone] ? NSLocalizedString(@"CHANNELS",nil): NSLocalizedString(@"YOUR CHANNELS",nil);
    [self.headerChannelsView setTitle: title
                             andNumber: totalChannels];
    
    [self.subscriptionsViewController reloadCollectionViews];
    [self.channelThumbnailCollectionView reloadData];
}




#pragma mark - UICollectionView DataSource/Delegate

- (NSInteger) collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section
{
    // NSLog(@"%@", user);
    return user.channels.count;
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    
    Channel *channel = (Channel*)user.channels[indexPath.row];
    
    SYNChannelMidCell *channelThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelMidCell"
                                                                                        forIndexPath: indexPath];
    
    channelThumbnailCell.channelImageViewImage = channel.coverThumbnailLargeURL;
    [channelThumbnailCell setChannelTitle:channel.title];
    [channelThumbnailCell setViewControllerDelegate:self];
    
    channelThumbnailCell.deleteButton.hidden = YES;
    
    
    return channelThumbnailCell;
    
}


- (void) collectionView: (UICollectionView *) collectionView
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    if(self.deleteCellModeOn)
        return;
    
    
    Channel *channel;
    
    if(collectionView == self.channelThumbnailCollectionView)
    {
        
        channel = user.channels[indexPath.row];
        
    }
    else
    {
        channel = user.subscriptions[indexPath.row];
    }
    
    
    SYNChannelDetailViewController *channelVC = [[SYNChannelDetailViewController alloc] initWithChannel: channel
                                                                                              usingMode: kChannelDetailsModeDisplay];
    
    [self animatedPushViewController: channelVC];
    
}


- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    if([[SYNDeviceManager sharedInstance] isIPad])
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


- (void) displayNameButtonPressed: (UIButton*) button
{
    SYNChannelThumbnailCell* parent = (SYNChannelThumbnailCell*)[[button superview] superview];
    
    NSIndexPath* indexPath = [self.channelThumbnailCollectionView indexPathForCell: parent];
    
    Channel *channel = user.channels[indexPath.row];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kShowUserChannels
                                                        object: self
                                                      userInfo: @{@"ChannelOwner" : channel.channelOwner}];
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
        [self.pinchedView setAsynchronousImageFromURL: [NSURL URLWithString: channel.coverThumbnailLargeURL]
                                     placeHolderImage: nil];
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




-(void)resizeScrollViews
{
    CGSize channelViewSize = self.channelThumbnailCollectionView.contentSize;
    CGSize subscriptionsViewSize = self.subscriptionsViewController.collectionView.contentSize;
    
    if(channelViewSize.height == subscriptionsViewSize.height)
        return;
    
    CGRect paddingRect = CGRectZero;
    paddingRect.origin.x = 0.0;
    paddingRect.origin.y = channelViewSize.height;
    paddingRect.size.width = channelViewSize.width;
    paddingRect.size.height = 600.0;
    UIView* paddingView = [[UIView alloc] initWithFrame:paddingRect];
    paddingView.backgroundColor = [UIColor blueColor];
    
    [self.channelThumbnailCollectionView addSubview:paddingView];
    channelViewSize.height = 2000.0;
    [self.channelThumbnailCollectionView setContentSize:CGSizeMake(channelViewSize.width, 1000)];
}

#pragma mark - tab button actions
-(IBAction)channelsTabTapped:(id)sender
{
    self.subscriptionsTabActive = NO;
    [self updateTabStates];
}

-(IBAction)subscriptionsTabTapped:(id)sender
{
    self.subscriptionsTabActive = YES;
    [self updateTabStates];
}

-(void)updateTabStates
{
    self.channelsTabButton.selected = !self.subscriptionsTabActive;
    self.subscriptionsTabButton.selected = self.subscriptionsTabActive;
    self.channelThumbnailCollectionView.hidden = self.subscriptionsTabActive;
    self.subscriptionsViewController.view.hidden = !self.subscriptionsTabActive;
    
    if(self.subscriptionsTabActive)
    {
        [self.headerChannelsView setColorsForText:[UIColor colorWithRed:106.0f/255.0f green:114.0f/255.0f blue:122.0f/255.0f alpha:1.0f] parentheses:[UIColor colorWithRed:187.0f/255.0f green:187.0f/255.0f blue:187.0f/255.0f alpha:1.0f] number:[UIColor colorWithRed:32.0f/255.0f green:195.0f/255.0f blue:226.0f/255.0f alpha:1.0f]];
        [self.headerSubscriptionsView setColorsForText:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f] parentheses:[UIColor colorWithRed:187.0f/255.0f green:187.0f/255.0f blue:187.0f/255.0f alpha:1.0f] number:[UIColor colorWithRed:32.0f/255.0f green:195.0f/255.0f blue:226.0f/255.0f alpha:1.0f]];
    }
    else
    {
        [self.headerSubscriptionsView setColorsForText:[UIColor colorWithRed:106.0f/255.0f green:114.0f/255.0f blue:122.0f/255.0f alpha:1.0f] parentheses:[UIColor colorWithRed:187.0f/255.0f green:187.0f/255.0f blue:187.0f/255.0f alpha:1.0f] number:[UIColor colorWithRed:32.0f/255.0f green:195.0f/255.0f blue:226.0f/255.0f alpha:1.0f]];
        [self.headerChannelsView setColorsForText:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f] parentheses:[UIColor colorWithRed:187.0f/255.0f green:187.0f/255.0f blue:187.0f/255.0f alpha:1.0f] number:[UIColor colorWithRed:32.0f/255.0f green:195.0f/255.0f blue:226.0f/255.0f alpha:1.0f]];
    }
    
}

-(void)tappedOnScreen:(UIGestureRecognizer*)recogniser
{
    self.cellDeleteCandidate.deleteButton.hidden = YES;
    self.deleteCellModeOn = NO;
    [self.view removeGestureRecognizer:self.tapOnScreenRecogniser];
    
    
}



-(void)channelDeleteButtonTapped:(UIButton*)sender
{
    
    UIView *v = sender.superview.superview;
    NSIndexPath *indexPath = [self.channelThumbnailCollectionView indexPathForItemAtPoint: v.center];
    self.channelDeleteCandidate = (Channel*)user.channels[indexPath.row];
    
    NSString* message = [NSString stringWithFormat:@"You are about to delete %@", _channelDeleteCandidate.title];
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Delete?"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    
    [alertView show];
    
    
    
}
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        [self deleteChannel];
    }
    else
    {
        // Cancel Clicked
    }
}
-(void)deleteChannel
{
    [appDelegate.oAuthNetworkEngine deleteChannelForUserId:appDelegate.currentUser.uniqueId
                                                 channelId:self.channelDeleteCandidate.uniqueId
                                         completionHandler:^(id response) {
                                             
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 
                                                 NSMutableOrderedSet *channelsSet = [NSMutableOrderedSet orderedSetWithOrderedSet:appDelegate.currentUser.channels];
                                                 
                                                 [channelsSet removeObject:self.channelDeleteCandidate];
                                                 
                                                 [appDelegate.currentUser setChannels:channelsSet];
                                                 
                                                 
                                                 [appDelegate saveContext:YES];
                                                 
                                                 
                                                 _deleteCellModeOn = NO;
                                                 
                                                 [_channelThumbnailCollectionView reloadData];
                                                 [_channelThumbnailCollectionView setNeedsLayout];
                                                 
                                                 
                                             });
                                             
                                             
                                         } errorHandler:^(id error) {
                                             
                                             DebugLog(@"Delete channel NOT succeed");
                                             
                                         }];
}



@end
