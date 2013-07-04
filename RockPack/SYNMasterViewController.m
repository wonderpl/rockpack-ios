//
//  SYNTopBarViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//


#import "AppConstants.h"
#import "GAI.h"
#import "SYNAccountSettingsMainTableViewController.h"
#import "SYNAccountSettingsModalContainer.h"
#import "SYNActivityPopoverViewController.h"
#import "SYNBackButtonControl.h"
#import "SYNChannelDetailViewController.h"
#import "SYNContainerViewController.h"
#import "SYNDeviceManager.h"
#import "SYNExistingChannelsViewController.h"
#import "SYNFacebookManager.h"
#import "SYNMasterViewController.h"
#import "SYNNetworkErrorView.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNPageView.h"
#import "SYNCautionMessageView.h"
#import "SYNSearchBoxViewController.h"
#import "SYNSearchRootViewController.h"
#import "SYNSideNavigationViewController.h"
#import "SYNSoundPlayer.h"
#import "SYNVideoPlaybackViewController.h"
#import "SYNVideoViewerViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNCaution.h"
#import "VideoInstance.h"
#import <QuartzCore/QuartzCore.h>

#define kMovableViewOffX -58

#define kSearchBoxShrinkFactor 136.0



typedef void(^AnimationCompletionBlock)(BOOL finished);

@interface SYNMasterViewController ()

@property (nonatomic) BOOL buttonLocked;
@property (nonatomic) BOOL isDragging;
@property (nonatomic) BOOL showingBackButton;
@property (nonatomic) CGFloat sideNavigationOriginCenterX;
@property (nonatomic, strong) IBOutlet UIButton* closeSearchButton;
@property (nonatomic, strong) IBOutlet UIButton* searchButton;
@property (nonatomic, strong) IBOutlet UIButton* sideNavigationButton;
@property (nonatomic, strong) IBOutlet UIButton* hideNavigationButton;
@property (nonatomic, strong) IBOutlet UILabel* pageTitleLabel;
@property (nonatomic, strong) IBOutlet SYNPageView* pagePositionIndicatorView;
@property (nonatomic, strong) IBOutlet UIView* errorContainerView;
@property (nonatomic, strong) IBOutlet UIView* navigationContainerView;
@property (nonatomic, strong) IBOutlet UIView* overlayView;
@property (nonatomic, strong) IBOutlet UIView* darkOverlayView;
@property (nonatomic, strong) SYNAccountSettingsModalContainer* modalAccountContainer;
@property (nonatomic, strong) SYNBackButtonControl* backButtonControl;
@property (nonatomic, strong) SYNExistingChannelsViewController* existingChannelsController;
@property (nonatomic, strong) SYNNetworkErrorView* networkErrorView;
@property (nonatomic, strong) SYNSearchBoxViewController* searchBoxController;
@property (nonatomic, strong) SYNSearchRootViewController* searchViewController;
@property (nonatomic, strong) SYNSideNavigationViewController* sideNavigationViewController;
@property (nonatomic, strong) SYNVideoViewerViewController *videoViewerViewController;
@property (nonatomic, strong) UIPopoverController* accountSettingsPopover;
@property (nonatomic, strong) UIView* accountSettingsCoverView;
@property (strong, nonatomic) IBOutlet UIView *overlayContainerView;
@property (nonatomic, strong) IBOutlet UIButton* headerButton;
@property (nonatomic) NavigationButtonsAppearence currentNavigationButtonsAppearence;

@property (nonatomic) BOOL searchIsInProgress;

@property (nonatomic, strong) UINavigationController* mainNavigationController;

@end

@implementation SYNMasterViewController

@dynamic containerViewController;

@synthesize pageTitleLabel;
@synthesize showingBackButton;
@synthesize mainNavigationController;
@synthesize currentNavigationButtonsAppearence;

@dynamic showingBaseViewController;
@dynamic showingViewController;

@synthesize sideNavigationOriginCenterX;
@synthesize isDragging, buttonLocked;

#pragma mark - Object lifecycle

- (id) initWithContainerViewController: (SYNContainerViewController*) root
{
    if ((self = [super initWithNibName: @"SYNMasterViewController" bundle: nil]))
    {
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        // == main navigation == //
        
        self.mainNavigationController = [[UINavigationController alloc] initWithRootViewController:root];
        self.mainNavigationController.navigationBarHidden = YES;
        self.mainNavigationController.delegate = self;
        self.mainNavigationController.view.autoresizesSubviews = YES;
        self.mainNavigationController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.mainNavigationController.wantsFullScreenLayout = YES;
        
        appDelegate.viewStackManager.navigationController = self.mainNavigationController;
        
        [self addChildViewController:self.mainNavigationController];

        // == Side Navigation == //
        self.sideNavigationViewController = [[SYNSideNavigationViewController alloc] init];
        
        self.sideNavigationViewController.view.frame = CGRectMake(1024.0,
                                                                  ([SYNDeviceManager.sharedInstance isIPad] ? 0.0 : 58.0f),
                                                                  self.sideNavigationViewController.view.frame.size.width,
                                                                  self.sideNavigationViewController.view.frame.size.height);

        self.sideNavigationViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        
        self.sideNavigationViewController.user = appDelegate.currentUser;
        
        [self addChildViewController:self.sideNavigationViewController];
        
        // == Search Controller == //
        
        
        self.searchViewController = [[SYNSearchRootViewController alloc] initWithViewId: kSearchViewId];

        // == Search Box == //
    
        if([SYNDeviceManager.sharedInstance isIPad])
        {
            self.searchBoxController = [[SYNSearchBoxViewController alloc] init];
            CGRect autocompleteControllerFrame = self.searchBoxController.view.frame;
            autocompleteControllerFrame.origin.x = 10.0;
            autocompleteControllerFrame.origin.y = 10.0;
            self.searchBoxController.view.frame = autocompleteControllerFrame;
        }
    }
    
    return self;
}


- (void) dealloc
{
    // Defensive programming
    self.accountSettingsPopover.delegate = nil;
}


#pragma mark - View lifecycle


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Setup the dependency between nav controller and button
    // Not super-elegant, but as the nav controller is controlled from multiple places
    // it is the only way to guarantee it will work nicely
    self.sideNavigationViewController.captiveButton = self.sideNavigationButton;
    self.sideNavigationViewController.darkOverlay = self.darkOverlayView;
        
    // == Fade in from splash screen (not in AppDelegate so that the Orientation is known) == //
    
    UIImageView *splashView;
    if ([SYNDeviceManager.sharedInstance isIPhone])
    {
        if ([SYNDeviceManager.sharedInstance currentScreenHeight]>480.0f)
        {
            splashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"Default-568h"]];
        }
        else
        {
            splashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"Default"]];
        }
        splashView.center = CGPointMake(160.0f, splashView.center.y - 20.0f);
    }
    else
    {
        splashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"Default"]];
    }
    
	[self.view addSubview: splashView];
    
    [UIView animateWithDuration: kSplashAnimationDuration
                          delay: kSplashViewDuration
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         splashView.alpha = 0.0f;
                     } completion: ^(BOOL finished) {
                         splashView.alpha = 0.0f;
                         [splashView removeFromSuperview];
                     }];
    
    self.navigationContainerView.userInteractionEnabled = YES;
    
    self.currentNavigationButtonsAppearence = NavigationButtonsAppearenceBlack;
    
    // == Add the Root Navigation Controller == //

    self.mainNavigationController.view.frame = self.view.frame;
    [self.view insertSubview:self.mainNavigationController.view atIndex:0];
    

    self.existingChannelsController = [[SYNExistingChannelsViewController alloc] initWithViewId:kExistingChannelsViewId];

    // == Back Button == //
    
    self.backButtonControl = [SYNBackButtonControl backButton];
    CGRect backButtonFrame = self.backButtonControl.frame;
    backButtonFrame.origin.y = 10.0f;
    self.backButtonControl.frame = backButtonFrame;
    [self.view insertSubview:self.backButtonControl belowSubview:self.overlayContainerView];
    self.backButtonControl.alpha = 0.0;
    
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTapped:)];
    UISwipeGestureRecognizer* leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(headerSwiped:)];
    leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    UISwipeGestureRecognizer* rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(headerSwiped:)];
    rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.headerButton addGestureRecognizer:tapGesture];
    [self.headerButton addGestureRecognizer:leftSwipeGesture];
    [self.headerButton addGestureRecognizer:rightSwipeGesture];
    
    self.pageTitleLabel.font = [UIFont boldRockpackFontOfSize:self.pageTitleLabel.font.pointSize];
    self.pageTitleLabel.textColor = [UIColor colorWithRed:(40.0/255.0)
                                                    green:(45.0/255.0)
                                                     blue:(51.0/255.0)
                                                    alpha:(1.0)];
    
    self.reachability = [Reachability reachabilityWithHostname:appDelegate.networkEngine.hostName];
    
    self.accountSettingsCoverView = [[UIView alloc] initWithFrame:self.view.frame];
    self.accountSettingsCoverView.backgroundColor = [UIColor darkGrayColor];
    self.accountSettingsCoverView.alpha = 0.5;
    self.accountSettingsCoverView.hidden = YES;
    
    self.closeSearchButton.hidden = YES;
    
    [self pageChanged:self.containerViewController.scrollView.page];
    
    self.darkOverlayView.hidden = YES;
    
    
    // == Set Up Notifications == //
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profileRequested:) name:kProfileRequested object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelDetailsRequested:) name:kChannelDetailsRequested object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allNavControlsRequested:) name:kNoteAllNavControlsShow object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allNavControlsRequested:) name:kNoteAllNavControlsHide object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideTitleAndDots:) name:kNoteHideTitleAndDots object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addToChannelRequested:) name:kNoteAddToChannelRequest object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollerPageChanged:) name:kScrollerPageChanged object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigateToPage:) name:kNavigateToPage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTyped:) name:kSearchTyped object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addedToChannelAction:) name:kNoteVideoAddedToExistingChannel object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createNewChannelAction:) name:kNoteCreateNewChannel object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAccountSettingsPopover) name:kAccountSettingsPressed object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountSettingsLogout) name:kAccountSettingsLogout object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchCancelledIPhone:) name:kSideNavigationSearchCloseNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelSuccessfullySaved:) name:kNoteChannelSaved object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentSuccessNotificationWithCaution:) name:kNoteSavingCaution object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideOrShowNetworkMessages:) name:kNoteHideNetworkMessages object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideOrShowNetworkMessages:) name:kNoteShowNetworkMessages object:nil];
    
    
    
    
    [self.navigationContainerView addSubview:self.sideNavigationViewController.view]; 
}

// this is triggered when a component requests a view at the base of the stack
- (void) profileRequested: (NSNotification*) notification
{
    ChannelOwner* channelOwner = (ChannelOwner*)[notification userInfo][kChannelOwner];
    if (!channelOwner)
        return;
    
    [appDelegate.viewStackManager viewProfileDetails:channelOwner];
}


- (void) channelDetailsRequested: (NSNotification*) notification
{
    
    
    Channel* channel = (Channel*)[notification userInfo][kChannel];
    if (!channel)
        return;
    
    SYNChannelDetailViewController *channelVC = [[SYNChannelDetailViewController alloc] initWithChannel: channel
                                                                                              usingMode: kChannelDetailsModeDisplay];
    channelVC.autoplayVideoId = [notification userInfo][kAutoPlayVideoId];
    
    [appDelegate.viewStackManager pushController:channelVC];
}

-(void)headerSwiped:(UISwipeGestureRecognizer*)recogniser
{
    [self.containerViewController swipedTo:recogniser.direction];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [self.containerViewController.scrollView addObserver: self forKeyPath: kCollectionViewContentOffsetKey
                                                 options: NSKeyValueObservingOptionNew
                                                 context: nil];
}


- (void) viewWillDisappear: (BOOL) animated
{
    [self.containerViewController.scrollView removeObserver: self
                                                 forKeyPath: kCollectionViewContentOffsetKey];
    
    [super viewWillDisappear: animated];
}


- (void) observeValueForKeyPath: (NSString *) keyPath
                       ofObject: (id) object
                         change: (NSDictionary *) change
                        context: (void *) context
{
    if ([keyPath isEqualToString: kCollectionViewContentOffsetKey])
    {
        CGRect scrollViewFrame = self.containerViewController.scrollView.frame;
        CGSize scrollViewContentSize = self.containerViewController.scrollView.contentSize;
        CGPoint scrollViewContentOffset = self.containerViewController.scrollView.contentOffset;
        
        CGFloat frameWidth = scrollViewFrame.size.width;
        CGFloat contentWidth = scrollViewContentSize.width;
        CGFloat offset = scrollViewContentOffset.x;
        
        self.pagePositionIndicatorView.position = offset / (contentWidth - frameWidth);
    }
}

#pragma mark - Scroller Changes

-(void)scrollerPageChanged:(NSNotification*)notification
{
    NSNumber* pageNumber = [notification userInfo][kCurrentPage];
    if(!pageNumber)
        return;
    
    [self pageChanged:[pageNumber integerValue]];
    
    
}

-(void)pageChanged:(NSInteger)pageNumber
{
    
    self.pageTitleLabel.text = [self.containerViewController.showingViewController.title uppercaseString];
    
    
    if(self.sideNavigationViewController.state == SideNavigationStateFull)
    {
        [self.sideNavigationViewController deselectAllCells];
        [self showSideNavigation];
    }
    else
    {
        NSString* controllerTitle = self.containerViewController.showingViewController.title;
        
        [self.sideNavigationViewController setSelectedCellByPageName:controllerTitle];

    }
}


#pragma mark - Channel Creation Methods

-(void)addToChannelRequested:(NSNotification*)notification
{
    
    [self addChildViewController:self.existingChannelsController];

    [self.view addSubview:self.existingChannelsController.view];
    
    // animate in //
    
    self.existingChannelsController.view.alpha = 1.0f;
    
    CGRect newFrame = self.existingChannelsController.view.frame;
    newFrame.origin.y = newFrame.size.height;
    self.existingChannelsController.view.frame = newFrame;
    [self.existingChannelsController prepareForAppearAnimation];
    
    
    [UIView animateWithDuration: kAddToChannelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         CGRect newFrame = self.existingChannelsController.view.frame;
                         newFrame.origin.y = 0.0f;
                         self.existingChannelsController.view.frame = newFrame;
                     }
                     completion: ^(BOOL finished) {
                         [self.existingChannelsController runAppearAnimation];
                         if(self.videoViewerViewController)
                         {
                             [self.videoViewerViewController pauseIfVideoActive];
                         }

                     }];
}

-(void)createNewChannelAction:(NSNotification*)notification
{
    if(self.videoViewerViewController)
    {
        [self removeVideoOverlayController];
    }
    
    if([[SYNDeviceManager sharedInstance] isIPhone])
    {
        //On iPhone the create workflow is presented modally on the existing channels page. Therefore return after closing the video player.
        return;
    }
    
    
    // this channel's managedObjectContext is the appDelegate.channelManagedObjectContext
    SYNChannelDetailViewController *channelCreationVC =
    [[SYNChannelDetailViewController alloc] initWithChannel: appDelegate.videoQueue.currentlyCreatingChannel
                                                  usingMode: kChannelDetailsModeCreate] ;
    
    // either the current view on the container scroll view or the overlay navigation controller as in search mode
    [appDelegate.viewStackManager pushController:channelCreationVC];
}

-(void)addedToChannelAction:(NSNotification*)notification
{
    
    Channel* selectedChannel = (Channel*)[notification userInfo][kChannel];
    if(!selectedChannel)
    {
        //Channel select was cancelled.
        [[NSNotificationCenter defaultCenter] postNotificationName: kVideoQueueClear
                                                            object: nil];
        [self resumeVideoIfShowing];
        return;
    }
    
    NSString* message = [SYNDeviceManager.sharedInstance isIPhone]?
    NSLocalizedString(@"VIDEO SUCCESSFULLY ADDED",nil):
    NSLocalizedString(@"YOUR VIDEOS HAVE BEEN SUCCESSFULLY ADDED INTO YOUR CHANNEL",nil);
    
    Channel* currentlyCreating = appDelegate.videoQueue.currentlyCreatingChannel;

    NSMutableOrderedSet* setOfVideosToPost = [NSMutableOrderedSet orderedSetWithOrderedSet:selectedChannel.videoInstancesSet];
    for (VideoInstance* newVideoInstance in currentlyCreating.videoInstances)
    {
        [setOfVideosToPost addObject:newVideoInstance];
    }
    
    
    
    [appDelegate.oAuthNetworkEngine updateVideosForChannelForUserId: appDelegate.currentUser.uniqueId
                                                          channelId: selectedChannel.uniqueId
                                                   videoInstanceSet: setOfVideosToPost
                                                      clearPrevious: NO
                                                  completionHandler: ^(NSDictionary* result) {
                                                      
                                                      id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
                                                      
                                                      [tracker sendEventWithCategory: @"goal"
                                                                          withAction: @"channelUpdated"
                                                                           withLabel: nil
                                                                           withValue: nil];
                                                      
                                                      [self presentSuccessNotificationWithMessage:message];
                                                      
                                                      [[NSNotificationCenter defaultCenter] postNotificationName: kVideoQueueClear
                                                                                                          object: self];
                                                      [self resumeVideoIfShowing];
                                                      
                                                  } errorHandler:^(NSDictionary* errorDictionary) {
                                                      
                                                      [[NSNotificationCenter defaultCenter] postNotificationName: kVideoQueueClear
                                                                                                          object: self];
                                                      [self resumeVideoIfShowing];
      
                                                  }];
    
}

- (void) resumeVideoIfShowing
{
    //Special case! If we have a videoViewerViewContoroller here it means we are returning from the add to channel selector.
    // try to resume playback.
    if(self.videoViewerViewController)
    {
        [self.videoViewerViewController playIfVideoActive];
    }
}



#pragma mark - Navigation Panel Methods

- (IBAction) showAndHideSideNavigation: (UIButton*) sender
{
    if (buttonLocked)
        return;
    
    if (self.sideNavigationViewController.state == SideNavigationStateFull
       || self.sideNavigationViewController.state == SideNavigationStateHalf)
    {
        self.sideNavigationViewController.state = SideNavigationStateHidden;
        self.darkOverlayView.alpha = 1.0;
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.darkOverlayView.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             self.darkOverlayView.hidden = YES;
                         }];

//        sender.selected = NO;
    }
    else
    {
        [self showSideNavigation];
        self.darkOverlayView.alpha = 0.0;
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.darkOverlayView.alpha = 1.0;
                         } completion:^(BOOL finished) {
                             self.darkOverlayView.hidden = NO;
                         }];
//        sender.selected = YES;
    }
}



-(void)headerTapped:(UIGestureRecognizer*)recogniser
{
    [self.showingViewController headerTapped];
}


- (void) showSideNavigation
{
    NSString* controllerTitle = self.containerViewController.showingViewController.title;
    
    [self.sideNavigationViewController setSelectedCellByPageName: controllerTitle];
    
    self.darkOverlayView.alpha = 0.0;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.darkOverlayView.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         self.darkOverlayView.hidden = NO;
                     }];
    self.sideNavigationViewController.state = SideNavigationStateHalf;
    
}

- (IBAction)hideNavigation:(UIButton*)sender{
    self.sideNavigationViewController.state = SideNavigationStateHidden;
    self.darkOverlayView.alpha = 1.0;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.darkOverlayView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         self.darkOverlayView.hidden = YES;
                     }];
}


#pragma mark - Video Overlay View

- (void) addVideoOverlayToViewController: (SYNAbstractViewController *) originViewController
                  withVideoInstanceArray: (NSArray*) videoInstanceArray
                        andSelectedIndex: (int) selectedIndex fromCenter:(CGPoint)centerPoint
{
    // FIXME: Replace with something more elegant (i.e. anything else)
    appDelegate.searchRefreshDisabled = TRUE;
    
    if(self.videoViewerViewController)
    {
        //Prevent presenting two video players.
        return;
    }
    
    // Remember the view controller that we came from
    self.originViewController = originViewController;
    
    self.videoViewerViewController = [[SYNVideoViewerViewController alloc] initWithVideoInstanceArray: videoInstanceArray
                                                                                        selectedIndex: selectedIndex];
    
    if([originViewController isKindOfClass:[SYNChannelDetailViewController class]])
    {
        self.videoViewerViewController.shownFromChannelScreen = YES;
        
        //FIXME: FAVOURITES Part of workaround for missing favourites functionality. Remove once resolved.
        SYNChannelDetailViewController* channelDetailViewController = (SYNChannelDetailViewController*)originViewController;
        if([channelDetailViewController isFavouritesChannel])
        {
            [self.videoViewerViewController markAsFavourites];
        }
    }
    
    [self addChildViewController: self.videoViewerViewController];
    
    
    self.videoViewerViewController.view.frame = self.overlayView.bounds;
    [self.overlayView addSubview: self.videoViewerViewController.view];
    self.videoViewerViewController.overlayParent = self;
    [self.videoViewerViewController prepareForAppearAnimation];

    CGPoint delta = [self.originViewController.view convertPoint:centerPoint toView:self.view];
    CGPoint originalCenter = self.videoViewerViewController.view.center;
    self.videoViewerViewController.view.center = delta;
    self.videoViewerViewController.view.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    self.videoViewerViewController.view.alpha = 0.0f;
    
    
    [UIView animateWithDuration: kVideoInAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                                 self.videoViewerViewController.view.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                         self.self.videoViewerViewController.view.center = originalCenter;
                                self.videoViewerViewController.view.alpha = 1.0f;
                     }
                     completion: ^(BOOL finished) {
                         [self.videoViewerViewController runAppearAnimation];
                         self.overlayView.userInteractionEnabled = YES;
    }];
    
    //video overlay bug - keyboard needs to be dismissed if a video is played;
    [self.searchBoxController.searchBoxView.searchTextField resignFirstResponder];
    [self.sideNavigationViewController.searchViewController.searchBoxView.searchTextField resignFirstResponder];
}


- (void) removeVideoOverlayController
{
    // FIXME: Replace with something more elegant (i.e. anything else)
    appDelegate.searchRefreshDisabled = FALSE;
    
    if(!self.videoViewerViewController)
    {
        return;
    }
    
    if([self.originViewController isKindOfClass:[SYNChannelDetailViewController class]])
    {
        SYNChannelDetailViewController* channelDetailViewController = (SYNChannelDetailViewController*)self.originViewController;
        if([channelDetailViewController isFavouritesChannel])
        {
            [channelDetailViewController refreshFavouritesChannel];
        }
 
    }
    
    UIView* child = self.overlayView.subviews[0];
    
    [UIView animateWithDuration: kVideoOutAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         self.videoViewerViewController.view.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
                         self.videoViewerViewController.view.alpha = 0.0f;
                     }
                     completion: ^(BOOL finished) {
                         self.overlayView.userInteractionEnabled = NO;
                         [child removeFromSuperview];
                         [self.videoViewerViewController.view removeFromSuperview];
                         [self.videoViewerViewController removeFromParentViewController];
                         self.videoViewerViewController = nil;
                     }];
    
    
    [self.originViewController videoOverlayDidDissapear];
    //FIXME: Nick to rework
    [self.containerViewController viewWillAppear:NO];
}


#pragma mark - Search (Text Delegate) Methods

- (IBAction) showSearchBoxField: (id) sender
{
    
    if (self.isInSearchMode) // if it is on stage already
        return;
    
    self.darkOverlayView.alpha = 1.0;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.darkOverlayView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         self.darkOverlayView.hidden = YES;
                     }];
    
    CGRect sboxFrame = self.searchBoxController.view.frame;
    
    // place according to the position of the back button //
    if (showingBackButton)
    {
        sboxFrame.origin.x = 76.0f;
    }
    else
    {
        sboxFrame.origin.x = 10.0;
    }
    
    sboxFrame.size.width = self.closeSearchButton.frame.origin.x - sboxFrame.origin.x - 8.0;
    sboxFrame.origin.y = 10.0;
    self.searchBoxController.view.frame = sboxFrame;
    
    [self.view insertSubview:self.searchBoxController.view aboveSubview:self.overlayContainerView];
    
    self.searchBoxController.searchTextField.text = @"";
    
    if ([SYNDeviceManager.sharedInstance isIPad] && sender != nil)
    {
        [self.searchBoxController.searchTextField becomeFirstResponder];
    }
    
    self.closeSearchButton.hidden = NO;
    self.sideNavigationButton.hidden = YES;
}

- (void) searchTyped: (NSNotification*) notification
{
    // TODO: Add GA here
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker sendEventWithCategory: @"uiAction"
                        withAction: @"searchInitiate"
                         withLabel: nil
                         withValue: nil];
    
    NSString* termString = (NSString*)[notification userInfo][kSearchTerm];
    
    if(!termString)
        return;
    
    BOOL isIPad = [SYNDeviceManager.sharedInstance isIPad];
    if(isIPad)
    {
        self.closeSearchButton.hidden = YES;
        self.sideNavigationButton.hidden = NO;
        
    }
    
        
    if(!self.searchIsInProgress)
        [appDelegate.viewStackManager pushController:self.searchViewController];
    else
        [appDelegate.viewStackManager popToController:self.searchViewController];
    
    if([[SYNDeviceManager sharedInstance] isIPhone])
    {
        //[self.searchViewController.view addSubview:self.sideNavigationViewController.searchViewController.searchBoxView];
        self.searchViewController.searchBoxViewController = self.sideNavigationViewController.searchViewController;
        [self hideNavigation:nil];
    }
    
    
    [self.searchViewController showSearchResultsForTerm: termString];
    
}


- (void) searchCancelledIPhone: (NSNotification*) notification
{
    if(self.searchViewController.navigationController.topViewController == self.searchViewController)
    {
        [self cancelButtonPressed: nil];
        [appDelegate.viewStackManager popController];
    }
    self.closeSearchButton.hidden = YES;
    self.sideNavigationButton.hidden = NO;
    [UIView animateWithDuration:0.3
                        animations:^{
                self.darkOverlayView.alpha = 1.0;
                        } completion:^(BOOL finished) {
                            self.darkOverlayView.hidden = NO;
                       }];

    [self.sideNavigationViewController.searchViewController removeFromParentViewController];
    [self.view insertSubview:self.sideNavigationViewController.searchViewController.searchBoxView belowSubview:self.overlayView];
}


- (IBAction) cancelButtonPressed: (id) sender
{
    [self.searchBoxController clear];
    [self.searchBoxController.view removeFromSuperview];
    
    self.sideNavigationButton.hidden = NO;
    
    self.closeSearchButton.hidden = YES;
}


#pragma mark - Notification Handlers

- (void) accountSettingsLogout
{
    [appDelegate logout];
}



- (void) reachabilityChanged: (NSNotification*) notification
{
#ifdef PRINT_REACHABILITY
    NSString* reachabilityString;
    if ([self.reachability currentReachabilityStatus] == ReachableViaWiFi)
        reachabilityString = @"WiFi";
    else if([self.reachability currentReachabilityStatus] == ReachableViaWWAN)
        reachabilityString = @"WWAN";
    else if([self.reachability currentReachabilityStatus] == NotReachable) 
        reachabilityString = @"None";
    
    DebugLog(@"Reachability == %@", reachabilityString);
#endif
    
    if ([self.reachability currentReachabilityStatus] == ReachableViaWiFi)
    {
        if (self.networkErrorView)
        {
            [self hideNetworkErrorView];
        }
    }
    else if([self.reachability currentReachabilityStatus] == ReachableViaWWAN)
    {
        if (self.networkErrorView)
        {
            [self hideNetworkErrorView];
        }
    }
    else if ([self.reachability currentReachabilityStatus] == NotReachable)
    {
        NSString* message = [SYNDeviceManager.sharedInstance isIPad] ? NSLocalizedString(@"No_Network_iPad", nil)
                                                                       : NSLocalizedString(@"No_Network_iPhone", nil);
        [self presentNetworkErrorViewWithMesssage: message];
    }
}




-(void)hideNetworkErrorView
{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
        CGRect erroViewFrame = self.networkErrorView.frame;
        erroViewFrame.origin.y = [SYNDeviceManager.sharedInstance currentScreenHeight];
        self.networkErrorView.frame = erroViewFrame;
    } completion:^(BOOL finished) {
        [self.networkErrorView removeFromSuperview];
        self.networkErrorView = nil;
    }];
}



- (void) dotTapped: (UIGestureRecognizer*) recogniser
{
    // TODO: Need to implement this
}



- (void) allNavControlsRequested: (NSNotification*) notification
{
    NSString* notificationName = [notification name];
    if (!notificationName)
        return;
    
    if ([notificationName isEqualToString: kNoteAllNavControlsShow])
    {
        self.searchButton.hidden = NO;
        
        self.sideNavigationButton.hidden = NO;
        self.closeSearchButton.hidden = YES;
        self.backButtonControl.hidden = NO;
        
        if(self.isInSearchMode && [[SYNDeviceManager sharedInstance] isIPad])
        {
            self.sideNavigationButton.hidden = YES;
        }
        
        self.pageTitleLabel.hidden = NO;
        
        self.pagePositionIndicatorView.hidden = NO;
        self.backButtonControl.hidden = NO;
    }
    else
    {
        self.searchButton.hidden = YES;
        self.sideNavigationButton.hidden = YES;
        self.closeSearchButton.hidden = YES;
        self.pageTitleLabel.hidden = YES;
        self.pagePositionIndicatorView.hidden = YES;
        self.backButtonControl.hidden = YES;
        self.sideNavigationViewController.state = SideNavigationStateHidden;
    }
}




- (void) navigateToPage: (NSNotification*) notification
{
    
    NSString* pageName = [notification userInfo][@"pageName"];
    if(!pageName)
        return;
    

    if(self.isInSearchMode)
    {
        [self cancelButtonPressed:nil];
    }

    if (showingBackButton)
    {
        //pop the current section navcontroller to the root controller
        [appDelegate.viewStackManager popToRootController];
        
        [self showBackButton:NO];
        

    }
    
    //Scroll to the requested page
    [self.containerViewController navigateToPageByName: pageName];
    
    self.sideNavigationViewController.state = SideNavigationStateHidden;
        
}


- (void) channelSuccessfullySaved: (NSNotification*) note
{
    NSString* message =
    [SYNDeviceManager.sharedInstance isIPhone] ? NSLocalizedString(@"CHANNEL SAVED",nil) :
    NSLocalizedString(@"YOUR CHANNEL HAS BEEN SAVED SUCCESSFULLY",nil);
    [self presentSuccessNotificationWithMessage:message];
}


- (void) hideOrShowNetworkMessages: (NSNotification*) note
{
    if ([note.name isEqualToString: kNoteShowNetworkMessages])
    {
        self.errorContainerView.hidden = NO;
        [UIView animateWithDuration: 0.3f
                              delay: 0.0f
                            options: UIViewAnimationCurveEaseOut
                         animations: ^{
                             CGRect newFrame = self.errorContainerView.frame;
                             newFrame.origin.y = 0.0f;
                             self.errorContainerView.frame = newFrame;
                         }
                         completion:nil];
    }
    else
    {
        [UIView animateWithDuration: 0.3f
                              delay: 0.0f
                            options: UIViewAnimationCurveEaseIn
                         animations: ^{
                             CGRect newFrame = self.errorContainerView.frame;
                             newFrame.origin.y = 60.0f;
                             self.errorContainerView.frame = newFrame;
                         }
                         completion: ^(BOOL finished){
                             if (finished)
                             {
                                 self.errorContainerView.hidden = YES;
                             }
                         }];
    }
}

-(void)hideTitleAndDots:(NSNotification*)note
{
    self.pagePositionIndicatorView.alpha = 0.0f;
    self.pageTitleLabel.alpha = 0.0f;
}



#pragma mark - Account Settings

- (void) showAccountSettingsPopover
{
    if(self.accountSettingsPopover)
        return;
    
    SYNAccountSettingsMainTableViewController* accountsTableController = [[SYNAccountSettingsMainTableViewController alloc] init];
    accountsTableController.view.backgroundColor = [UIColor clearColor];
    
    
    
    
    if([SYNDeviceManager.sharedInstance isIPad])
    {
        
        UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController: accountsTableController];
        navigationController.view.backgroundColor = [UIColor clearColor];
        
        self.accountSettingsPopover = [[UIPopoverController alloc] initWithContentViewController: navigationController];
        self.accountSettingsPopover.popoverContentSize = CGSizeMake(380, 576);
        self.accountSettingsPopover.delegate = self;
        
        self.accountSettingsPopover.popoverBackgroundViewClass = [SYNAccountSettingsPopoverBackgroundView class];
        
        CGRect rect = CGRectMake([SYNDeviceManager.sharedInstance currentScreenWidth] * 0.5,
                                 [SYNDeviceManager.sharedInstance currentScreenHeight] * 0.5, 1, 1);
        
        [self.accountSettingsPopover presentPopoverFromRect: rect
                                                     inView: self.view
                                   permittedArrowDirections: 0
                                                   animated: YES];
    }
    else
    {
        UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController: accountsTableController];
        navigationController.view.backgroundColor = [UIColor clearColor];
        navigationController.navigationBarHidden = YES;
        
        __weak SYNMasterViewController* weakSelf = self;
        self.modalAccountContainer = [[SYNAccountSettingsModalContainer alloc] initWithNavigationController:navigationController andCompletionBlock:^{
            [weakSelf modalAccountContainerDismiss];
        }];
        
        CGRect modalFrame = self.modalAccountContainer.view.frame;
        modalFrame.size.height = self.view.frame.size.height - 60.0f;
        [self.modalAccountContainer setModalViewFrame:modalFrame];
        
        modalFrame.origin.y = [SYNDeviceManager.sharedInstance currentScreenHeight];
        self.modalAccountContainer.view.frame = modalFrame;
        
        self.accountSettingsCoverView.alpha = 0.0;
        self.accountSettingsCoverView.hidden = NO;
        [self.view addSubview:self.accountSettingsCoverView];
        
        [self.view addSubview:self.modalAccountContainer.view];
        
        modalFrame.origin.y = 60.0;
        
        [UIView animateWithDuration:0.3 animations:^{
           
            self.accountSettingsCoverView.alpha = 0.8;
            self.modalAccountContainer.view.frame = modalFrame;
            
            
        }];
        
    }
}

-(void)modalAccountContainerDismiss
{
    
    CGRect hiddenFrame = self.modalAccountContainer.view.frame;
    hiddenFrame.origin.y = [SYNDeviceManager.sharedInstance currentScreenHeight];
    [UIView animateWithDuration:0.5 animations:^{
        
        self.accountSettingsCoverView.alpha = 0.0;
        self.modalAccountContainer.view.frame = hiddenFrame;
        
        
    } completion:^(BOOL finished) {
        
        self.accountSettingsCoverView.hidden = YES;
        
        [self.modalAccountContainer.view removeFromSuperview];
        self.modalAccountContainer = nil;
        
        
    }];
    
}

- (void) accountSettingsLogout: (NSNotification*) notification
{
    [self.accountSettingsPopover dismissPopoverAnimated: NO];
    self.accountSettingsPopover = nil;
    [appDelegate logout];
}

#pragma mark - Popover Methods

- (void) hideAutocompletePopover
{
    
    if (!self.accountSettingsPopover)
        return;
    
    [self.accountSettingsPopover dismissPopoverAnimated: YES];
}

- (void) popoverControllerDidDismissPopover: (UIPopoverController *) popoverController
{
    if (popoverController == self.accountSettingsPopover)
    {
        
        self.accountSettingsPopover = nil;
    }
    
}

#pragma mark - Message Bars

- (void) presentNetworkErrorViewWithMesssage: (NSString*) message
{
    if(self.networkErrorView)
    {
        [self.networkErrorView setText:message];
        return;
    }
    
    self.networkErrorView = [SYNNetworkErrorView errorView];
    [self.networkErrorView setText:message];
    [self.errorContainerView addSubview:self.networkErrorView];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect erroViewFrame = self.networkErrorView.frame;
        erroViewFrame.origin.y = [SYNDeviceManager.sharedInstance currentScreenHeightWithStatusBar] - erroViewFrame.size.height;
        
        self.networkErrorView.frame = erroViewFrame;
    }];
}


- (void) presentSuccessNotificationWithMessage : (NSString*) message
{
    
    __block SYNNetworkErrorView* successNotification = [[SYNNetworkErrorView alloc] init];
    successNotification.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"BarSucess"]];
    [successNotification setText: message];
    [self.errorContainerView addSubview: successNotification];
    
    [UIView animateWithDuration: 0.3f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         CGRect newFrame = successNotification.frame;
                         newFrame.origin.y = [SYNDeviceManager.sharedInstance currentScreenHeightWithStatusBar] - newFrame.size.height;
                         successNotification.frame = newFrame;
                     }
                     completion: ^(BOOL finished) {
                         
                         [UIView animateWithDuration: 0.3f
                                               delay: 4.0f
                                             options: UIViewAnimationOptionCurveEaseIn
                                          animations: ^{
                                              CGRect newFrame = successNotification.frame;
                                              newFrame.origin.y = [SYNDeviceManager.sharedInstance currentScreenHeightWithStatusBar] + newFrame.size.height;
                                              successNotification.frame = newFrame;
                                          }
                                          completion: ^(BOOL finished) {
                                              [successNotification removeFromSuperview];
                                          }];
                     }];
}

- (void) presentSuccessNotificationWithCaution:(NSNotification*)notification
{
    SYNCaution* caution = [notification userInfo][kCaution];
    if(!caution)
        return;
    
    SYNCautionMessageView* cautionMessageView = [SYNCautionMessageView withCaution:caution];
    
    [cautionMessageView presentInView:self.view];
    
    
    
    
}


#pragma mark - Interface Orientation Methods

- (NSUInteger) supportedInterfaceOrientations
{
    if ([SYNDeviceManager.sharedInstance isIPhone])
    {
        return UIInterfaceOrientationMaskPortrait;
    }
    else
    {
        return UIInterfaceOrientationMaskAll;
    }
}


- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation: toInterfaceOrientation
                                            duration: duration];

    if (self.accountSettingsPopover)
    {
        CGRect rect = CGRectMake([SYNDeviceManager.sharedInstance currentScreenWidth] * 0.5,
                                 [SYNDeviceManager.sharedInstance currentScreenHeight] * 0.5, 1, 1);
        
        [self.accountSettingsPopover presentPopoverFromRect: rect
                                                     inView: self.view
                                   permittedArrowDirections: 0
                                                   animated: YES];
        
        
    }
    
}



- (SYNAbstractViewController*) showingViewController
{
    if([self.mainNavigationController.topViewController isKindOfClass:[SYNContainerViewController class]])
        return self.containerViewController.showingViewController;
    else
        return (SYNAbstractViewController*)self.mainNavigationController.topViewController;
    
}



-(BOOL)isInSearchMode
{
    return (BOOL)self.searchBoxController.view.superview;
}



-(void)changeControlButtonsTo:(NavigationButtonsAppearence)appearence
{
    
    
    if(appearence == self.currentNavigationButtonsAppearence)
        return;
    
    self.currentNavigationButtonsAppearence = appearence;
    
    if(appearence == NavigationButtonsAppearenceWhite) // white buttons
    {
        [self.searchButton setImage:[UIImage imageNamed:@"ButtonSearchCD"] forState:UIControlStateNormal];
        [self.searchButton setImage:[UIImage imageNamed:@"ButtonSearchHighlightedCD"] forState:UIControlStateHighlighted];
        
        [self.closeSearchButton setImage:[UIImage imageNamed:@"ButtonCancelCD"] forState:UIControlStateNormal];
        [self.closeSearchButton setImage:[UIImage imageNamed:@"ButtonCancelCD"] forState:UIControlStateHighlighted];
        
        [self.backButtonControl.button setImage:[UIImage imageNamed:@"ButtonBackCD"] forState:UIControlStateNormal];
        [self.backButtonControl.button setImage:[UIImage imageNamed:@"ButtonBackHighlightedCD"] forState:UIControlStateHighlighted];
        
        [self.sideNavigationButton setImage:[UIImage imageNamed:@"ButtonNavCD"] forState:UIControlStateNormal];
        [self.sideNavigationButton setImage:[UIImage imageNamed:@"ButtonNavHighlightedCD"] forState:UIControlStateHighlighted];
        [self.sideNavigationButton setImage:[UIImage imageNamed:@"ButtonNavSelectedCD"] forState:UIControlStateSelected];
        
    }
    else if(appearence == NavigationButtonsAppearenceBlack) // black buttons
    {
        [self.searchButton setImage:[UIImage imageNamed:@"ButtonSearch"] forState:UIControlStateNormal];
        [self.searchButton setImage:[UIImage imageNamed:@"ButtonSearchHighlighted"] forState:UIControlStateHighlighted];
        
        [self.closeSearchButton setImage:[UIImage imageNamed:@"ButtonCancel"] forState:UIControlStateNormal];
        [self.closeSearchButton setImage:[UIImage imageNamed:@"ButtonCancelHighlighted"] forState:UIControlStateHighlighted];
        
        
        [self.backButtonControl.button setImage:[UIImage imageNamed:@"ButtonBack"] forState:UIControlStateNormal];
        [self.backButtonControl.button setImage:[UIImage imageNamed:@"ButtonBackHighlighted"] forState:UIControlStateHighlighted];
        
        [self.sideNavigationButton setImage:[UIImage imageNamed:@"ButtonNav"] forState:UIControlStateNormal];
        [self.sideNavigationButton setImage:[UIImage imageNamed:@"ButtonNavHighlighted"] forState:UIControlStateHighlighted];
        [self.sideNavigationButton setImage:[UIImage imageNamed:@"ButtonNavSelected"] forState:UIControlStateSelected];
    }
}

-(SYNContainerViewController*)containerViewController
{
    return (SYNContainerViewController*)self.mainNavigationController.viewControllers[0];
}


- (void) showBackButton: (BOOL) show 
{
    CGRect targetFrame;
    CGFloat targetAlpha;
    
    // XOR '^' the values so that they return 0 if they are both YES or both NO
    if(!(show ^ showingBackButton))
        return;
    
    
    if (show)
    {
        [self.backButtonControl addTarget: appDelegate.viewStackManager
                                   action: @selector(popController)
                         forControlEvents:UIControlEventTouchUpInside];
        
        
        
        showingBackButton = YES;
        targetFrame = self.backButtonControl.frame;
        targetAlpha = 1.0;
        
        if ([SYNDeviceManager.sharedInstance isIPad])
        {
            targetFrame.origin.x = 10.0;
        }
        
        else
        {
            targetFrame.origin.x = 5.0;
        }
    }
    else
    {
        [self.backButtonControl removeTarget: appDelegate.viewStackManager
                                      action: @selector(popController)
                            forControlEvents: UIControlEventTouchUpInside];
        
        
        
        showingBackButton = NO;
        targetFrame = self.backButtonControl.frame;
        targetFrame.origin.x = kMovableViewOffX;
        targetAlpha = 0.0;
    }
    
    [UIView animateWithDuration: 0.6f
                          delay: (show && self.isInSearchMode ? 0.4f : 0.0f)
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         self.backButtonControl.frame = targetFrame;
                         self.backButtonControl.alpha = targetAlpha;
                         self.pageTitleLabel.alpha = !targetAlpha;
                         self.pagePositionIndicatorView.alpha = !targetAlpha;
                     } completion:nil];
    
    [UIView animateWithDuration: 0.6f
                          delay: (show ? 0.0f : 0.4f)
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         CGRect sboxFrame = self.searchBoxController.view.frame;
                         sboxFrame.origin.x = (show ? 76.0f : 10.0f);
                         sboxFrame.size.width = self.closeSearchButton.frame.origin.x - sboxFrame.origin.x - 8.0;
                         self.searchBoxController.view.frame = sboxFrame;
                     } completion:nil];
    
}

#pragma mark - Delegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
    
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
    
    if([viewController isKindOfClass:[SYNContainerViewController class]]) // special case for the container which is not an abstract view controller
    {
        [self changeControlButtonsTo:NavigationButtonsAppearenceBlack];
        [self cancelButtonPressed:nil];
    }
    else
    {
        SYNAbstractViewController* abstractController = (SYNAbstractViewController*)viewController;
        [self changeControlButtonsTo:abstractController.navigationAppearence];
        
        if(abstractController.alwaysDisplaysSearchBox)
        {
            if([[SYNDeviceManager sharedInstance] isIPhone])
            {
                [self.sideNavigationViewController.searchViewController removeFromParentViewController];
                UIView* searchBar = self.sideNavigationViewController.searchViewController.searchBoxView;
                [self.view insertSubview:searchBar belowSubview:self.overlayView];
            }
            else
            {
                [self showSearchBoxField:nil];
                self.closeSearchButton.hidden = YES;
                self.sideNavigationButton.hidden = NO;
            }
        }
        else
        {
            if([[SYNDeviceManager sharedInstance] isIPhone])
            {
                if ([[self.view subviews] containsObject:self.sideNavigationViewController.searchViewController.searchBoxView])
                {
                    [self.sideNavigationViewController.searchViewController.searchBoxView removeFromSuperview];
                }
            }
            if(self.isInSearchMode)
            {
                self.closeSearchButton.hidden = NO;
                self.sideNavigationButton.hidden = YES;
            }
        }
    }
    
    
    
    [self showBackButton:(navigationController.viewControllers.count > 1)];
    
    
}

// returns whether the searchViewController has been pushed to the stack previously
-(BOOL)searchIsInProgress
{
    return [self.mainNavigationController.viewControllers containsObject:self.searchViewController];
}

@end
