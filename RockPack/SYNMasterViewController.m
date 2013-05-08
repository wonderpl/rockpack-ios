//
//  SYNTopBarViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNMasterViewController.h"
#import "AppConstants.h"
#import "SYNActivityPopoverViewController.h"
#import "SYNSideNavigationViewController.h"
#import "SYNContainerViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNSoundPlayer.h"
#import "SYNContainerViewController.h"
#import "SYNBackButtonControl.h"
#import "SYNVideoViewerViewController.h"
#import "SYNAccountSettingsMainTableViewController.h"
#import "SYNRefreshButton.h"
#import "SYNSearchBoxViewController.h"
#import "SYNDeviceManager.h"
#import "SYNExistingChannelsViewController.h"
#import "SYNDeviceManager.h"
#import "SYNChannelDetailViewController.h"
#import "SYNObjectFactory.h"
#import "SYNFacebookManager.h"
#import "SYNDeviceManager.h"

#import "SYNSearchRootViewController.h"
#import "SYNAccountSettingsModalContainer.h"
#import "SYNNetworkErrorView.h"

#import <QuartzCore/QuartzCore.h>

#define kMovableViewOffX -58
#define kMovableViewReloadButtonX 70
#define kMovableViewReloadButtonXIPhone 63

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
@property (nonatomic, strong) SYNBackButtonControl* backButtonControl;
@property (nonatomic, strong) SYNExistingChannelsViewController* existingChannelsController;
@property (nonatomic, strong) SYNNetworkErrorView* networkErrorView;
@property (nonatomic, strong) SYNRefreshButton* refreshButton;
@property (nonatomic, strong) SYNSearchBoxViewController* searchBoxController;
@property (nonatomic, strong) SYNSearchRootViewController* searchViewController;
@property (nonatomic, strong) SYNSideNavigationViewController* sideNavigationViewController;
@property (nonatomic, strong) SYNVideoViewerViewController *videoViewerViewController;
@property (nonatomic, strong) UINavigationController* overlayNavigationController;
@property (nonatomic, strong) UIPopoverController* accountSettingsPopover;
@property (nonatomic, strong) VideoOverlayDismissBlock videoOverlayDismissBlock;
@property (strong, nonatomic) IBOutlet UIView *overlayContainerView;
@property (strong, nonatomic) Reachability *reachability;

@property (nonatomic, strong) UIView* accountSettingsCoverView;

@property (nonatomic, strong) SYNAccountSettingsModalContainer* modalAccountContainer;


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
        CGRect sideNavigationFrame = self.sideNavigationViewController.view.frame;
        sideNavigationFrame.origin.x = 1024.0;
        
        sideNavigationFrame.origin.y = [[SYNDeviceManager sharedInstance] isIPad] ? 0.0 : 58.0f;
        
        
        self.sideNavigationViewController.view.frame = sideNavigationFrame;
        self.sideNavigationViewController.user = appDelegate.currentUser;
        self.sideNavigationViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        
        
        
        
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
    
    // == Refresh button == //
    
    CGRect movableViewFrame = self.movableButtonsContainer.frame;
    movableViewFrame.origin.x = kMovableViewOffX;
    self.movableButtonsContainer.frame = movableViewFrame;
    
    self.refreshButton = [SYNRefreshButton refreshButton];
    [self.refreshButton addTarget:self action:@selector(refreshButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    CGRect refreshButtonFrame = self.refreshButton.frame;
    refreshButtonFrame.origin.x = [[SYNDeviceManager sharedInstance] isIPad]?kMovableViewReloadButtonX:kMovableViewReloadButtonXIPhone;
    self.refreshButton.frame = refreshButtonFrame;
    [self.movableButtonsContainer addSubview:self.refreshButton];
    
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addToChannelRequested:) name:kNoteAddToChannelRequest object:nil];
    
    
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

-(void)refreshButtonPressed
{
    [self.refreshButton startRefreshCycle];
    
    [self.containerViewController.showingViewController refresh];
}

- (void) refreshCycleComplete
{
    [self.refreshButton endRefreshCycle];
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
                         self.videoViewerViewController = nil;
                         [child removeFromSuperview];
                         
                         self.videoOverlayDismissBlock();
                         
                         [self.videoViewerViewController removeFromParentViewController];
                     }];
}


#pragma mark - Search Delegate Methods

- (IBAction) showSearchBoxField: (id) sender
{
    
    self.sideNavigationButton.hidden = YES;
    
    CGRect sboxFrame;
    
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
    
    [self.navigationContainerView addSubview:self.searchBoxController.view];
    
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


- (void) reachabilityChanged: (NSNotification*) notification
{
    NSString* reachabilityString;
    if ([self.reachability currentReachabilityStatus] == ReachableViaWiFi)
        reachabilityString = @"WiFi";
    else if([self.reachability currentReachabilityStatus] == ReachableViaWWAN)
        reachabilityString = @"WWAN";
    else if([self.reachability currentReachabilityStatus] == NotReachable) 
        reachabilityString = @"None";
    
    DebugLog(@"Reachability == %@", reachabilityString);
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
        NSString* message = [[SYNDeviceManager sharedInstance] isIPad] ? @"NO NETWORK CONNECTION" : @"NO NETWORK" ;
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
    
    [self alignErrorMessage];
    
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
    
    if([notificationName isEqualToString:kNoteBackButtonShow])
    {
        [self showBackButton:YES];
    }
    else
    {
        [self showBackButton:NO];
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
        
        [self.backButtonControl setBackTitle: self.pageTitleLabel.text];
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
        targetFrame.origin.x = 8.0;
        targetAlpha = 1.0;
    }
    else
    {
        [self.backButtonControl removeTarget: self
                                      action: @selector(popCurrentViewController:)
                            forControlEvents: UIControlEventTouchUpInside];
        
        if(self.searchBoxController.isOnScreen)
        {
            [self cancelButtonPressed:nil];
            
        }
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
                         self.refreshButton.alpha = !targetAlpha;
                     }
                     completion: nil];

}

- (void) popCurrentViewController: (id) sender
{
    if(_overlayNavigationController)
    {
        if(_overlayNavigationController.viewControllers.count > 1)
        {
            SYNAbstractViewController *abstractVC = (SYNAbstractViewController *)_overlayNavigationController.topViewController;
            
            [abstractVC animatedPopViewController];
        }
        else
        {
            self.overlayNavigationController = nil;
            [self showBackButton:NO];
        }
    }
    else
    {
        [self.containerViewController popCurrentViewController:sender];
    }
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
    
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController: accountsTableController];
    navigationController.view.backgroundColor = [UIColor clearColor];
    
    
    
    
    if([[SYNDeviceManager sharedInstance] isIPad])
    {
        [[UINavigationBar appearance] setTitleTextAttributes:
         @{UITextAttributeTextColor:[UIColor darkGrayColor], UITextAttributeFont:[UIFont rockpackFontOfSize:22.0]}];
        
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
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"ButtonProfileChannels"]
                                           forBarMetrics:UIBarMetricsDefault];
        
        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
        
        [[UINavigationBar appearance] setFrame:CGRectMake(0.0, 0.0, 320.0, 300.0)];
        
        
        [[UINavigationBar appearance] setTitleTextAttributes:
         @{UITextAttributeTextColor:[UIColor darkGrayColor], UITextAttributeFont:[UIFont rockpackFontOfSize:22.0]}];
        
        
        
        UIButton* doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* doneImage = [UIImage imageNamed:@"ButtonSettingsDone"];
        doneButton.frame = CGRectMake(0.0, 0.0, doneImage.size.width, doneImage.size.height);
        [doneButton addTarget:self action:@selector(modalAccountContainerDismiss) forControlEvents:UIControlEventTouchUpInside];
        [doneButton setImage:doneImage forState:UIControlStateNormal];
        
        UIBarButtonItem* buttonItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
        
        
        accountsTableController.navigationItem.rightBarButtonItem = buttonItem;
        
        
        
        self.modalAccountContainer = [[SYNAccountSettingsModalContainer alloc] initWithNavigationController:navigationController];
        
        CGRect modalFrame = self.modalAccountContainer.view.frame;
        modalFrame.size.height = 520.0;
        self.modalAccountContainer.view.frame = modalFrame;
        
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
    if(self.networkErrorView)
    {
        [self alignErrorMessage];
    }
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



-(void)alignErrorMessage
{
    
    self.networkErrorView.center = CGPointMake([[SYNDeviceManager sharedInstance] currentScreenWidth] * 0.5, self.networkErrorView.center.y);
    self.networkErrorView.frame = CGRectIntegral(self.networkErrorView.frame);
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
