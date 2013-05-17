//
//  SYNTopBarViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//


#import "AppConstants.h"
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
#import "SYNObjectFactory.h"
#import "SYNRefreshButton.h"
#import "SYNSearchBoxViewController.h"
#import "SYNSearchRootViewController.h"
#import "SYNSideNavigationViewController.h"
#import "SYNSoundPlayer.h"
#import "SYNVideoViewerViewController.h"
#import "UIFont+SYNFont.h"
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
@property (nonatomic, strong) IBOutlet UILabel* pageTitleLabel;
@property (nonatomic, strong) IBOutlet UIView* dotsView;
@property (nonatomic, strong) IBOutlet UIView* errorContainerView;
@property (nonatomic, strong) IBOutlet UIView* movableButtonsContainer;
@property (nonatomic, strong) IBOutlet UIView* navigationContainerView;
@property (nonatomic, strong) IBOutlet UIView* overlayView;
@property (nonatomic, strong) SYNAccountSettingsModalContainer* modalAccountContainer;
@property (nonatomic, strong) SYNBackButtonControl* backButtonControl;
@property (nonatomic, strong) SYNExistingChannelsViewController* existingChannelsController;
@property (nonatomic, strong) SYNNetworkErrorView* networkErrorView;
@property (nonatomic, strong) SYNSearchBoxViewController* searchBoxController;
@property (nonatomic, strong) SYNSearchRootViewController* searchViewController;
@property (nonatomic, strong) SYNSideNavigationViewController* sideNavigationViewController;
@property (nonatomic, strong) SYNVideoViewerViewController *videoViewerViewController;
@property (nonatomic, strong) UINavigationController* overlayNavigationController;
@property (nonatomic, strong) UIPopoverController* accountSettingsPopover;
@property (nonatomic, strong) UIView* accountSettingsCoverView;
@property (nonatomic, strong) VideoOverlayDismissBlock videoOverlayDismissBlock;
@property (strong, nonatomic) IBOutlet UIView *overlayContainerView;

@end

@implementation SYNMasterViewController

@synthesize containerViewController;
@synthesize pageTitleLabel;
@synthesize showingBackButton;
@synthesize sideNavigationOriginCenterX;
@synthesize isDragging, buttonLocked;
@synthesize overlayNavigationController = _overlayNavigationController;

#pragma mark - Initialise

-(id)initWithContainerViewController:(SYNContainerViewController*)root
{
    if ((self = [super initWithNibName: @"SYNMasterViewController" bundle: nil]))
    {
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        
        
        self.containerViewController = root;
        [self addChildViewController:root];

        
        // == Side Navigation == //
        
        self.sideNavigationViewController = [[SYNSideNavigationViewController alloc] init];
        
        self.sideNavigationViewController.view.frame = CGRectMake(1024.0,
                                                                  ([[SYNDeviceManager sharedInstance] isIPad] ? 0.0 : 58.0f),
                                                                  self.sideNavigationViewController.view.frame.size.width,
                                                                  self.sideNavigationViewController.view.frame.size.height);
        
        
        self.sideNavigationViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        
        self.sideNavigationViewController.user = appDelegate.currentUser;
        
        [self addChildViewController:self.sideNavigationViewController];
        
        
        
        // == Search Box == //
    
        
        self.searchBoxController = [[SYNSearchBoxViewController alloc] init];
        CGRect autocompleteControllerFrame = self.searchBoxController.view.frame;
        autocompleteControllerFrame.origin.x = 10.0;
        autocompleteControllerFrame.origin.y = 10.0;
        self.searchBoxController.view.frame = autocompleteControllerFrame;
        
    }
    return self;
}




#pragma mark - Life Cycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    
    // == Fade in from splash screen (not in AppDelegate so that the Orientation is known) == //
    
    UIImageView *splashView;
    if([[SYNDeviceManager sharedInstance] isIPhone])
    {
        if([[SYNDeviceManager sharedInstance] currentScreenHeight]>480.0f)
        {
            splashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"Default-568h"]];
        }
        else
        {
            splashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"Default"]];
        }
        splashView.center = CGPointMake(splashView.center.x, splashView.center.y-20.0f);

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
    
    
    
    
    
    // == Add the Root Controller which will contain all others (Tabs in our case) == //

    [self.containerView addSubview:containerViewController.view];
    //self.containerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    self.existingChannelsController = [[SYNExistingChannelsViewController alloc] initWithViewId:kExistingChannelsViewId];
    
    
    // == Back Button == //
    
    self.backButtonControl = [SYNBackButtonControl backButton];
    [self.movableButtonsContainer addSubview:self.backButtonControl];
    self.backButtonControl.alpha = 0.0;
    
    self.movableButtonsContainer.userInteractionEnabled = YES;
    
    
    
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
    
    
    
    // == Set up Dots View == //
    
    self.dotsView.backgroundColor = [UIColor clearColor];
    int numberOfDots = [self.containerViewController.childViewControllers count];
    UIImage* dotImage = [UIImage imageNamed:@"NavigationDot"];
    CGPoint center = self.dotsView.center;
    CGRect newFrame = self.dotsView.frame;
    newFrame.size.width = (2*numberOfDots - 1) * dotImage.size.width;
    newFrame.origin.x = round(center.x - newFrame.size.width/2.0f);
    self.dotsView.frame = newFrame;
    CGFloat dotSpacing = 2*dotImage.size.width;
    for(int i = 0; i < numberOfDots; i++)
    {
        UIImageView* dotImageView = [[UIImageView alloc] initWithImage:dotImage];
        CGRect dotImageViewFrame = dotImageView.frame;
        dotImageViewFrame.origin.x = i * dotSpacing;
        dotImageView.frame = dotImageViewFrame;
        [self.dotsView addSubview:dotImageView];
        
        UITapGestureRecognizer* tapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dotTapped:)];
        [dotImageView addGestureRecognizer:tapGestureRecogniser];
     }
    
    [self pageChanged:self.containerViewController.scrollView.page];
    
    
    // == Set Up Notifications == //
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backButtonRequested:) name:kNoteBackButtonShow object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backButtonRequested:) name:kNoteBackButtonHide object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(topRightControlsRequested:) name:kNoteTopRightControlsShow object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(topRightControlsRequested:) name:kNoteTopRightControlsHide object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allNavControlsRequested:) name:kNoteAllNavControlsShow object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allNavControlsRequested:) name:kNoteAllNavControlsHide object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addToChannelRequested:) name:kNoteAddToChannelRequest object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchBarRequested:) name:kNoteSearchBarRequestHide object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchBarRequested:) name:kNoteSearchBarRequestShow object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollerPageChanged:) name:kScrollerPageChanged object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigateToPage:) name:kNavigateToPage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTyped:) name:kSearchTyped object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addedToChannelAction:) name:kNoteAddedToChannel object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createNewChannelAction:) name:kNoteCreateNewChannel object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAccountSettingsPopover) name:kAccountSettingsPressed object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountSettingsLogout) name:kAccountSettingsLogout object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchCancelledIPhone:) name:kSideNavigationSearchCloseNotification object:nil];
    
    
    [self.navigationContainerView addSubview:self.sideNavigationViewController.view];
    
    
}

-(NSUInteger)supportedInterfaceOrientations
{
    if([[SYNDeviceManager sharedInstance]isIPhone])
    {
        return UIInterfaceOrientationMaskPortrait;
    }
    else
    {
        return UIInterfaceOrientationMaskAll;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}



#pragma mark - Scroller Changes

-(void)scrollerPageChanged:(NSNotification*)notification
{
    NSNumber* pageNumber = [[notification userInfo] objectForKey:kCurrentPage];
    if(!pageNumber)
        return;
    
    [self pageChanged:[pageNumber integerValue]];
    
    
}

-(void)pageChanged:(NSInteger)pageNumber
{
    int totalDots = self.dotsView.subviews.count;
    UIImageView* dotImageView;
    for (int i = 0; i < totalDots; i++)
    {
        dotImageView = (UIImageView*)self.dotsView.subviews[i];
        if (i == pageNumber) {
            dotImageView.image = [UIImage imageNamed:@"NavigationDotCurrent"];
        } else {
            dotImageView.image = [UIImage imageNamed:@"NavigationDot"];
        }
        
        
        
    }
    
    
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
    if([[SYNDeviceManager sharedInstance] isIPhone])
    {
        self.existingChannelsController.view.frame = self.view.bounds;
    }
    [self.view addSubview:self.existingChannelsController.view];
    
    self.existingChannelsController.view.alpha = 0.0;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.existingChannelsController.view.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         if(self.overlayNavigationController)
                             self.overlayNavigationController = nil;
                         if(self.videoViewerViewController)
                         {
                             [self removeVideoOverlayController];
                         }
                     }];
    
}


-(void)addedToChannelAction:(NSNotification*)notification
{
    Channel* channel = (Channel*)[[notification userInfo] objectForKey:kChannel];
    if(!channel)
        return;
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kClearAllAddedCells
                                                        object:self];
    
    
    // TODO : Show confirm message
    
}

-(void)createNewChannelAction:(NSNotification*)notification
{
    Channel* channel = (Channel*)[[notification userInfo] objectForKey: kChannel];
    if(!channel)
        return;
    
    // - note: channel.managedObjectContext == appDelegate.chanelsContext 
    
    SYNChannelDetailViewController *channelCreationVC =
    [[SYNChannelDetailViewController alloc] initWithChannel: channel
                                                  usingMode: kChannelDetailsModeEdit] ;
    
    SYNAbstractViewController* showingController = self.containerViewController.showingViewController;
    [showingController animatedPushViewController: channelCreationVC];
}


#pragma mark - Navigation Panel Methods

-(IBAction)showAndHideSideNavigation:(UIButton*)sender
{
    if (buttonLocked)
        return;
    
    if (self.sideNavigationViewController.state == SideNavigationStateFull
       || self.sideNavigationViewController.state == SideNavigationStateHalf)
    {
        self.sideNavigationViewController.state = SideNavigationStateHidden;
        sender.highlighted = NO;
    }
    else
    {
        [self showSideNavigation];
        sender.highlighted = YES;
    }
}


- (void) showSideNavigation
{
    NSString* controllerTitle = self.containerViewController.showingViewController.title;
    
    [self.sideNavigationViewController setSelectedCellByPageName:controllerTitle];
    
    
    self.sideNavigationViewController.state = SideNavigationStateHalf;
    
}




#pragma mark - Video Overlay View

- (void) addVideoOverlayToViewController: (UIViewController *) originViewController
                  withVideoInstanceArray: (NSArray*) videoInstanceArray
                        andSelectedIndex: (int) selectedIndex
                               onDismiss: (VideoOverlayDismissBlock) dismissBlock
{
    self.videoOverlayDismissBlock = dismissBlock;
    
    // Remember the view controller that we came from
    self.originViewController = originViewController;
    
    self.videoViewerViewController = [[SYNVideoViewerViewController alloc] initWithVideoInstanceArray: videoInstanceArray
                                                                                        selectedIndex: selectedIndex];
    [self addChildViewController: self.videoViewerViewController];
    
    self.videoViewerViewController.view.frame = self.overlayView.bounds;
    [self.overlayView addSubview: self.videoViewerViewController.view];
    
    self.videoViewerViewController.view.alpha = 0.0f;
    self.videoViewerViewController.overlayParent = self;
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         self.videoViewerViewController.view.alpha = 1.0f;
                     }
                     completion: ^(BOOL finished) {
                         self.overlayView.userInteractionEnabled = YES;
                     }];
    
    //video overlay bug - keyboard needs to be dismissed if a video is played;
    [self.searchBoxController.searchBoxView.searchTextField resignFirstResponder];
    [self.sideNavigationViewController.searchViewController.searchBoxView.searchTextField resignFirstResponder];
}


- (void) removeVideoOverlayController
{  
    UIView* child = self.overlayView.subviews[0];
    
    [UIView animateWithDuration: 0.25f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         child.alpha = 0.0f;
                     }
                     completion: ^(BOOL finished) {
                         self.overlayView.userInteractionEnabled = NO;
                         [child removeFromSuperview];
                         
                         self.videoOverlayDismissBlock();
                         
                         [self.videoViewerViewController removeFromParentViewController];
                         self.videoViewerViewController = nil;
                     }];
    [self.containerViewController viewWillAppear:NO];
}


#pragma mark - Search Delegate Methods

- (IBAction) showSearchBoxField: (id) sender
{
    
    self.sideNavigationButton.hidden = YES;
    
    CGRect sboxFrame;
    
    // place according to the position of the back button //
    if(showingBackButton)
    {
        sboxFrame = self.searchBoxController.view.frame;
        sboxFrame.origin.x = self.backButtonControl.frame.origin.x + self.backButtonControl.frame.size.width + 16.0;
    }
    else
    {
        sboxFrame.origin.x = 10.0;
    }
    
    sboxFrame.size.width = self.closeSearchButton.frame.origin.x - sboxFrame.origin.x - 8.0;
    sboxFrame.origin.y = 10.0;
    self.searchBoxController.view.frame = sboxFrame;
    
    [self.view insertSubview:self.searchBoxController.view aboveSubview:self.overlayContainerView];
    
    if([[SYNDeviceManager sharedInstance] isIPad] && sender != nil)
    {
        [self.searchBoxController.searchTextField becomeFirstResponder];
    }
    
}

- (void) searchTyped: (NSNotification*) notification
{
    
    NSString* termString = (NSString*)[[notification userInfo] objectForKey: kSearchTerm];
    
    if(!termString)
        return;
    BOOL isIPad =[[SYNDeviceManager sharedInstance] isIPad];
    if(isIPad)
    {
        self.closeSearchButton.hidden = YES;
        self.sideNavigationButton.hidden = NO;
        [self showBackButton: YES];
    }
    
    if(!self.overlayNavigationController)
    {        
        self.searchViewController = [[SYNSearchRootViewController alloc] initWithViewId: kSearchViewId];
        self.overlayNavigationController = [SYNObjectFactory wrapInNavigationController: self.searchViewController];
    }
    
    [self.searchViewController showSearchResultsForTerm: termString];
}


- (void) searchCancelledIPhone: (NSNotification*) notification
{
    [self cancelButtonPressed: nil];
    [self.sideNavigationViewController.view addSubview: self.sideNavigationViewController.searchViewController.searchBoxView];
    self.overlayNavigationController = nil;
}


- (IBAction) cancelButtonPressed: (id) sender
{
    [self.searchBoxController clear];
    [self.searchBoxController.view removeFromSuperview];
    
    self.sideNavigationButton.hidden = NO;
}


#pragma mark - Notification Handlers

- (void) accountSettingsLogout
{
    [appDelegate logout];
}

-(void) searchBarRequested:(NSNotification*)notification
{
    NSString* notifcationName = [notification name];
    if([notifcationName isEqualToString:kNoteSearchBarRequestHide])
        [self cancelButtonPressed:nil];
    else
        [self showSearchBoxField:nil];
        
}

- (void) reachabilityChanged: (NSNotification*) notification
{
    NSString* reachabilityString;
    if ([self.reachability currentReachabilityStatus] == ReachableViaWiFi)
        reachabilityString = @"WiFi";
    else if([self.reachability currentReachabilityStatus] == ReachableViaWWAN)
        reachabilityString = @"WWAN";
    else if([self.reachability currentReachabilityStatus] == NotReachable) 
        reachabilityString = @"None";
    
//    DebugLog(@"Reachability == %@", reachabilityString);
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
        NSString* message = [[SYNDeviceManager sharedInstance] isIPad] ? NSLocalizedString(@"NO NETWORK CONNECTION", nil)
                                                                       : NSLocalizedString(@"NO NETWORK", nil);
        [self presentNetworkErrorViewWithMesssage: message];
    }
}



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
        erroViewFrame.origin.y = [[SYNDeviceManager sharedInstance] currentScreenHeight] - ([[SYNDeviceManager sharedInstance] isIPad] ? 70.0 : 60.0);
        
        self.networkErrorView.frame = erroViewFrame;
    }];
}

-(void)hideNetworkErrorView
{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
        CGRect erroViewFrame = self.networkErrorView.frame;
        erroViewFrame.origin.y = [[SYNDeviceManager sharedInstance] currentScreenHeight];
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

- (void) backButtonRequested: (NSNotification*) notification
{
    NSString* notificationName = [notification name];
    if(!notificationName)
        return;
    
    if([notificationName isEqualToString:kNoteBackButtonShow])
    {
        [self showBackButton:YES];
    }
    else
    {
        [self showBackButton:NO];
    }
}

-(void)topRightControlsRequested:(NSNotification*) notification
{
    NSString* notificationName = [notification name];
    if(!notificationName)
        return;
    if([notificationName isEqualToString:kNoteTopRightControlsShow])
    {
        self.searchButton.hidden = NO;
        self.sideNavigationButton.hidden = NO;
        self.closeSearchButton.hidden = NO;
    }
    else
    {
        self.searchButton.hidden = YES;
        self.sideNavigationButton.hidden = YES;
        self.closeSearchButton.hidden = YES;
    }
    
}

-(void)allNavControlsRequested:(NSNotification*) notification
{
    NSString* notificationName = [notification name];
    if(!notificationName)
        return;
    if([notificationName isEqualToString:kNoteAllNavControlsShow])
    {
        self.searchButton.hidden = NO;
        self.sideNavigationButton.hidden = NO;
        self.closeSearchButton.hidden = NO;
        self.pageTitleLabel.hidden = NO;
        self.dotsView.hidden = NO;
        self.movableButtonsContainer.hidden = NO;
        self.containerViewController.scrollView .scrollEnabled = YES;
    }
    else
    {
        self.searchButton.hidden = YES;
        self.sideNavigationButton.hidden = YES;
        self.closeSearchButton.hidden = YES;
        self.pageTitleLabel.hidden = YES;
        self.dotsView.hidden = YES;
        self.movableButtonsContainer.hidden = YES;
        self.containerViewController.scrollView .scrollEnabled = NO;
    }
    
}



- (void) navigateToPage: (NSNotification*) notification
{
    
    NSString* pageName = [[notification userInfo] objectForKey: @"pageName"];
    if(!pageName)
        return;
    
    
    
    if(self.overlayNavigationController)
    {
        [self showBackButton:NO];
        self.overlayNavigationController = nil;
    }
    else if(showingBackButton)
    {
        [self.containerViewController.showingViewController animatedPopViewController];
    }
    
    [self.containerViewController navigateToPageByName:pageName];
    
    self.sideNavigationViewController.state = SideNavigationStateHidden;
        
}

#pragma mark - Navigation Methods

- (void) showBackButton: (BOOL) show
{
    CGRect targetFrame;
    CGFloat targetAlpha;
    
    // XOR '^' the values so that they return 0 if they are both YES or both NO
    if(!(show ^ showingBackButton))
        return;
    
    if (show)
    {
        [self.backButtonControl addTarget: self
                                   action: @selector(popCurrentViewController:)
                         forControlEvents:UIControlEventTouchUpInside];
        
        //No More Back Title (For Now)
        // [self.backButtonControl setBackTitle: self.pageTitleLabel.text];
        
        // Shrink the Search Box when the back arrow comes on screen //
        if(self.searchBoxController.isOnScreen)
        {
            [UIView animateWithDuration:0.5 animations:^{
                CGRect sboxFrame = self.searchBoxController.view.frame;
                sboxFrame.origin.x = self.backButtonControl.frame.origin.x + self.backButtonControl.frame.size.width + 16.0;
                sboxFrame.size.width = self.closeSearchButton.frame.origin.x - sboxFrame.origin.x - 8.0;
                self.searchBoxController.view.frame = sboxFrame;
            }];
        }
        
        showingBackButton = YES;
        targetFrame = self.movableButtonsContainer.frame;
        targetAlpha = 1.0;
        
        if ([[SYNDeviceManager sharedInstance] isIPad])
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
        [self.backButtonControl removeTarget: self
                                      action: @selector(popCurrentViewController:)
                            forControlEvents: UIControlEventTouchUpInside];
        
        
        showingBackButton = NO;
        targetFrame = self.movableButtonsContainer.frame;
        targetFrame.origin.x = kMovableViewOffX;
        targetAlpha = 0.0;
    }
    
    [UIView animateWithDuration: 0.6f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         self.movableButtonsContainer.frame = targetFrame;
                         self.backButtonControl.alpha = targetAlpha;
                         self.pageTitleLabel.alpha = !targetAlpha;
                         self.dotsView.alpha = !targetAlpha;
                     }
                     completion: nil];

}

- (void) popCurrentViewController: (id) sender
{
    SYNAbstractViewController *abstractVC;
    
    if(_overlayNavigationController)
    {
        if(_overlayNavigationController.viewControllers.count > 1)
        {
            abstractVC = (SYNAbstractViewController *)_overlayNavigationController.topViewController;
            
            
            [abstractVC animatedPopViewController];
            
//            if(self.searchBoxController.isOnScreen)
//            {
//                
//                [self cancelButtonPressed:nil];
//                
//            }
        }
        else
        {
            self.overlayNavigationController = nil;
            [self showBackButton:NO];
        }
        
        
    }
    else
    {
        abstractVC = (SYNAbstractViewController *)self.containerViewController.showingViewController;
        
        
        if(abstractVC.navigationController.viewControllers.count <= 2) {
            self.containerViewController.scrollView.scrollEnabled = YES;
            [self showBackButton:NO];
        }
            
        
        [abstractVC animatedPopViewController];
       
    }
    
    [self.containerViewController viewWillAppear:NO];
    
}


#pragma mark - Account Settings

- (void) accountSettingsLogout: (NSNotification*) notification
{
    [self.accountSettingsPopover dismissPopoverAnimated: NO];
    self.accountSettingsPopover = nil;
    [appDelegate logout];
}


- (void) showAccountSettingsPopover
{
    if(self.accountSettingsPopover)
        return;
    
    SYNAccountSettingsMainTableViewController* accountsTableController = [[SYNAccountSettingsMainTableViewController alloc] init];
    accountsTableController.view.backgroundColor = [UIColor clearColor];
    
    
    
    
    if([[SYNDeviceManager sharedInstance] isIPad])
    {
        
        
        
        
        UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController: accountsTableController];
        navigationController.view.backgroundColor = [UIColor clearColor];
        
        self.accountSettingsPopover = [[UIPopoverController alloc] initWithContentViewController: navigationController];
        self.accountSettingsPopover.popoverContentSize = CGSizeMake(380, 576);
        self.accountSettingsPopover.delegate = self;
        
        self.accountSettingsPopover.popoverBackgroundViewClass = [SYNAccountSettingsPopoverBackgroundView class];
        
        CGRect rect = CGRectMake([[SYNDeviceManager sharedInstance] currentScreenWidth] * 0.5,
                                 [[SYNDeviceManager sharedInstance] currentScreenHeight] * 0.5, 1, 1);
        
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
        
        
        self.modalAccountContainer = [[SYNAccountSettingsModalContainer alloc] initWithNavigationController:navigationController andCompletionBlock:^{
            [self modalAccountContainerDismiss];
        }];
        
        CGRect modalFrame = self.modalAccountContainer.view.frame;
        modalFrame.size.height = self.view.frame.size.height - 60.0f;
        [self.modalAccountContainer setModalViewFrame:modalFrame];
        
        modalFrame.origin.y = [[SYNDeviceManager sharedInstance] currentScreenHeight];
        self.modalAccountContainer.view.frame = modalFrame;
        
        self.accountSettingsCoverView.alpha = 0.0;
        self.accountSettingsCoverView.hidden = NO;
        [self.view addSubview:self.accountSettingsCoverView];
        
        [self.view addSubview:self.modalAccountContainer.view];
        
        modalFrame.origin.y = 60.0;
        
        [UIView animateWithDuration:0.5 animations:^{
           
            self.accountSettingsCoverView.alpha = 0.8;
            self.modalAccountContainer.view.frame = modalFrame;
            
            
        }];
        
    }
}

-(void)modalAccountContainerDismiss
{
    
    CGRect hiddenFrame = self.modalAccountContainer.view.frame;
    hiddenFrame.origin.y = [[SYNDeviceManager sharedInstance] currentScreenHeight];
    [UIView animateWithDuration:0.5 animations:^{
        
        self.accountSettingsCoverView.alpha = 0.0;
        self.modalAccountContainer.view.frame = hiddenFrame;
        
        
    } completion:^(BOOL finished) {
        
        self.accountSettingsCoverView.hidden = YES;
        
        [self.modalAccountContainer.view removeFromSuperview];
        self.modalAccountContainer = nil;
        
        
    }];
    
}


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


#pragma mark - Autorotation Methods

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

    if(self.accountSettingsPopover)
    {
        CGRect rect = CGRectMake([[SYNDeviceManager sharedInstance] currentScreenWidth] * 0.5,
                                 [[SYNDeviceManager sharedInstance] currentScreenHeight] * 0.5, 1, 1);
        
        [self.accountSettingsPopover presentPopoverFromRect: rect
                                                     inView: self.view
                                   permittedArrowDirections: 0
                                                   animated: YES];
    }
    
}





#pragma mark - Overlay Accessor Methods

-(void)setOverlayNavigationController:(UINavigationController *)overlayNavigationController
{
    if(_overlayNavigationController && overlayNavigationController) // there can be only one overlay at a time
        return;
    
    
    if(overlayNavigationController) // if we did not pass nil
    {
        [self.overlayContainerView addSubview:overlayNavigationController.view];
        
        
        

        if([[SYNDeviceManager sharedInstance] isIPhone])
        {
            overlayNavigationController.view.frame = self.overlayContainerView.bounds;
        }
        self.overlayContainerView.userInteractionEnabled = YES;
        self.overlayContainerView.alpha = 0.0;
        [UIView animateWithDuration: 0.5f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseIn
                         animations: ^{
                             self.containerView.alpha = 0.0;
                         }
                         completion: ^(BOOL finished) {
                             self.containerView.hidden = YES;
                             [self addChildViewController:overlayNavigationController];
                             _overlayNavigationController = overlayNavigationController;
                             [UIView animateWithDuration: 0.7f
                                                   delay: 0.2f
                                                 options: UIViewAnimationOptionCurveEaseOut
                                              animations: ^{
                                                  self.overlayContainerView.alpha = 1.0;
                                              }
                                              completion:^(BOOL finished) {
                                                  if([[SYNDeviceManager sharedInstance] isIPhone])
                                                  {
                                                   
                                                      // The search overlay sits on the side navigation on iPhone, move it into the overlay temporarily
                                                     [self.overlayContainerView addSubview: self.sideNavigationViewController.searchViewController.searchBoxView];
                                                  }
                                              }];
                         }];
    }
    else
    {
        if(_overlayContainerView) // nil was passed and there was another on screen (remove)
        {
            NSTimeInterval animationDuration = 0.5f;
            if([[SYNDeviceManager sharedInstance] isIPhone])
            {
                animationDuration = 0.1f;
            }
             self.overlayContainerView.userInteractionEnabled = NO;
            [UIView animateWithDuration: animationDuration
                                  delay: 0.0f
                                options: UIViewAnimationOptionCurveEaseIn
                             animations: ^{
                                 self.overlayContainerView.alpha = 0.0;
                             }
                             completion: ^(BOOL finished) {
                                 [_overlayNavigationController.view removeFromSuperview];
                                 [_overlayNavigationController removeFromParentViewController];
                                 _overlayNavigationController = nil;
                                 self.containerView.hidden = NO;
                                 self.overlayContainerView.userInteractionEnabled = YES;
                                 [UIView animateWithDuration: 0.7f
                                                       delay: 0.2f
                                                     options: UIViewAnimationOptionCurveEaseOut
                                                  animations: ^{
                                                      self.containerView.alpha = 1.0;
                                                      
                                                  }
                                                  completion: nil];
                             }];
        }
        else // nil was passed while there was nothing on screen (it is already nil)
        {
            _overlayContainerView = nil;
        }
       
    }
    
    
}

-(UINavigationController*)overlayNavigationController
{
    return _overlayNavigationController;
}


@end
