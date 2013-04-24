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
#import "SYNAutocompletePopoverBackgroundView.h"
#import "SYNContainerViewController.h"
#import "SYNBackButtonControl.h"

#import "SYNVideoViewerViewController.h"
#import "SYNAccountSettingsMainTableViewController.h"
#import "SYNCategoryChooserViewController.h"
#import "SYNRefreshButton.h"
#import "SYNSearchBoxViewController.h"
#import "SYNDeviceManager.h"
#import "SYNExistingChannelsViewController.h"
#import "SYNDeviceManager.h"
#import "SYNChannelDetailViewController.h"
#import "SYNChannelsDetailsCreationViewController.h"
#import "SYNObjectFactory.h"

#import "SYNSearchRootViewController.h"

#import "SYNNetworkErrorView.h"

#import <QuartzCore/QuartzCore.h>

#define kMovableViewOffX -58
#define kSearchBoxShrinkFactor 136.0

typedef void(^AnimationCompletionBlock)(BOOL finished);

@interface SYNMasterViewController ()

@property (nonatomic, strong) SYNBackButtonControl* backButtonControl;

@property (nonatomic, strong) IBOutlet UIButton* closeSearchButton;
@property (nonatomic, strong) IBOutlet UIButton* addToChannelButton;
@property (nonatomic, strong) IBOutlet UIView* overlayView;
@property (nonatomic, strong) IBOutlet UIView* navigatioContainerView;
@property (nonatomic, strong) IBOutlet UIView* dotsView;
@property (nonatomic, strong) IBOutlet UIView* errorContainerView;
@property (nonatomic, strong) IBOutlet UILabel* pageTitleLabel;
@property (nonatomic, strong) IBOutlet UIButton* searchButton;
@property (nonatomic, strong) IBOutlet UIView* movableButtonsContainer;
@property (strong, nonatomic) Reachability *reachability;

@property (nonatomic, strong) SYNSearchRootViewController* searchViewController;

@property (nonatomic, strong) SYNNetworkErrorView* networkErrorView;
@property (strong, nonatomic) IBOutlet UIView *overlayContainerView;

@property (nonatomic, strong) UINavigationController* overlayNavigationController;

@property (nonatomic, strong) UIPopoverController* accountSettingsPopover;
@property (nonatomic, strong) IBOutlet UIButton* sideNavigationButton;
@property (nonatomic) CGFloat sideNavigationOriginCenterX;
@property (nonatomic) BOOL buttonLocked;

@property (nonatomic) BOOL isDragging;


@property (nonatomic, strong) SYNRefreshButton* refreshButton;

@property (nonatomic) BOOL showingBackButton;


@property (nonatomic, strong) SYNExistingChannelsViewController* existingChannelsController;



@property (nonatomic) CGRect addToChannelFrame;

@property (nonatomic, strong) SYNSearchBoxViewController* searchBoxController;


@property (nonatomic, strong) SYNVideoViewerViewController *videoViewerViewController;
@property (nonatomic, strong) SYNCategoryChooserViewController *categoryChooserViewController;

@property (nonatomic, strong) SYNSideNavigationViewController* sideNavigationViewController;



@end

@implementation SYNMasterViewController

@synthesize containerViewController;
@synthesize pageTitleLabel;
@synthesize showingBackButton;
@synthesize addToChannelFrame;
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
        NSLog(@"Current width: %f", sideNavigationFrame.origin.x);
        sideNavigationFrame.origin.y = 74.0;
        self.sideNavigationViewController.view.frame = sideNavigationFrame;
        self.sideNavigationViewController.user = appDelegate.currentUser;
        self.sideNavigationViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        
        
//        UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sideNavigationPanned:)];
//        [self.sideNavigationViewController.view addGestureRecognizer:panGesture];
        
        
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
    refreshButtonFrame.origin.x = 70.0f;
    self.refreshButton.frame = refreshButtonFrame;
    [self.movableButtonsContainer addSubview:self.refreshButton];
    
    
    // == Fade in from splash screen (not in AppDelegate so that the Orientation is known) == //
    
    UIImageView *splashView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 1024, 748)];
    splashView.image = [UIImage imageNamed:  @"Default-Landscape.png"];
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
    
    self.navigatioContainerView.userInteractionEnabled = YES;
    
    
    
    
    
    // == Add the Root Controller which will contain all others (Tabs in our case) == //

    [self.containerView addSubview:containerViewController.view];
    //self.containerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    self.existingChannelsController = [[SYNExistingChannelsViewController alloc] initWithViewId:kExistingChannelsViewId];
    
    
    // == Back Button == //
    
    self.backButtonControl = [SYNBackButtonControl backButton];
    [self.movableButtonsContainer addSubview:self.backButtonControl];
    self.backButtonControl.alpha = 0.0;
    
    self.movableButtonsContainer.userInteractionEnabled = YES;
    
    
    
    self.pageTitleLabel.font = [UIFont boldRockpackFontOfSize:30];
    self.pageTitleLabel.textColor = [UIColor colorWithRed:(40.0/255.0)
                                                    green:(45.0/255.0)
                                                     blue:(51.0/255.0)
                                                    alpha:(1.0)];
    
    self.reachability = [Reachability reachabilityWithHostname:appDelegate.networkEngine.hostName];
    
    // == Add to Channel Button == //
    
    originalAddButtonX = self.addToChannelButton.frame.origin.x;
    addToChannelFrame = self.addToChannelButton.frame;
    
    
    // == Set up Dots View == //
    
    self.dotsView.backgroundColor = [UIColor clearColor];
    
    
    for(int i = 0; i < 3; i++)
    {
        UIImageView* dotImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavigationDot"]];
        CGRect dotImageViewFrame = dotImageView.frame;
        dotImageViewFrame.origin.x = i * 30.0;
        dotImageView.frame = dotImageViewFrame;
        [self.dotsView addSubview:dotImageView];
        
        UITapGestureRecognizer* tapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dotTapped:)];
        [dotImageView addGestureRecognizer:tapGestureRecogniser];
     }
    
    [self pageChanged:self.containerViewController.scrollView.page];
    
    
    // == Set Up Notifications == //
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backButtonRequested:) name:kNoteBackButtonShow object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backButtonRequested:) name:kNoteBackButtonHide object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollerPageChanged:) name:kScrollerPageChanged object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigateToPage:) name:kNavigateToPage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTyped:) name:kSearchTyped object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addToChannelAction:) name:kNoteAddToChannel object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createNewChannelAction:) name:kNoteCreateNewChannel object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAccountSettingsPopover) name:kAccountSettingsPressed object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountSettingsLogout) name:kAccountSettingsLogout object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    [self.containerViewController.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
    
    [self.navigatioContainerView addSubview:self.sideNavigationViewController.view];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.containerViewController.scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

-(void)refreshButtonPressed
{
    [self.refreshButton startRefreshCycle];
    
    [self.containerViewController.showingViewController refresh];
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
    
    originalAddButtonX = self.addToChannelButton.frame.origin.x;
    
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

-(IBAction)addToChannelPressed:(id)sender
{
    
    [self.view addSubview:self.existingChannelsController.view];
    [self addChildViewController:self.existingChannelsController];
    
    self.existingChannelsController.view.alpha = 0.0;
    
    [UIView animateWithDuration:0.3
                     animations:^{
        self.existingChannelsController.view.alpha = 1.0;
    }];
    
}


-(void)addToChannelAction:(NSNotification*)notification
{
    Channel* channel = (Channel*)[[notification userInfo] objectForKey:kChannel];
    if(!channel)
        return;
    
    DebugLog(@"Goint to add Channel with %d video instances", channel.videoInstances.count);
    
    // TODO : Show confirm message
    
}

-(void)createNewChannelAction:(NSNotification*)notification
{
    
    Channel* channel = (Channel*)[[notification userInfo] objectForKey:kChannel];
    if(!channel)
        return;
    
    SYNChannelsDetailsCreationViewController *channelCreationVC =
    [[SYNChannelsDetailsCreationViewController alloc] initWithChannel: channel];
    SYNAbstractViewController* showingController = self.containerViewController.showingViewController;
    [showingController animatedPushViewController: channelCreationVC];
}



#pragma mark - Navigation Panel Methods

-(IBAction)showAndHideSideNavigation:(UIButton*)sender
{
    if(buttonLocked)
        return;
    
    if(self.sideNavigationViewController.state == SideNavigationStateFull
       || self.sideNavigationViewController.state == SideNavigationStateHalf) {
        [self hideSideNavigation];
        sender.highlighted = NO;
    }

    else {
        [self showSideNavigation];
        sender.highlighted = YES;
    }
        
}

- (void) showSideNavigation
{
    
    
    NSString* controllerTitle = self.containerViewController.showingViewController.title;
    
    [self.sideNavigationViewController setSelectedCellByPageName:controllerTitle];
    
    
    [[SYNSoundPlayer sharedInstance] playSoundByName:kSoundNewSlideIn];
    
    
    [UIView animateWithDuration: kRockieTalkieAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations: ^{
                         
                         CGRect sideNavigationFrame = self.sideNavigationViewController.view.frame;
                         
                         sideNavigationFrame.origin.x = 1024.0 - 192.0;
                         self.sideNavigationViewController.view.frame =  sideNavigationFrame;
                         
                     } completion: ^(BOOL finished) {
                         
                         self.sideNavigationViewController.state = SideNavigationStateHalf;
                         
                     }];
    
    
}



-(void)sideNavigationSwiped
{
    [self hideSideNavigation];
}



- (void) hideSideNavigation
{

    
    [[SYNSoundPlayer sharedInstance] playSoundByName: kSoundNewSlideOut];
    
    [UIView animateWithDuration: 0.2f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations: ^ {
                         
                         CGRect sideNavigationFrame = self.sideNavigationViewController.view.frame;
                         sideNavigationFrame.origin.x = 1024;
                         self.sideNavigationViewController.view.frame =  sideNavigationFrame;
                         
                     } completion: ^(BOOL finished) {
                         
                         [self.sideNavigationViewController reset];
                         [self.sideNavigationViewController deselectAllCells];
                         self.sideNavigationViewController.state = SideNavigationStateHidden;
                         
                     }];
}



#pragma mark - Video Overlay View

- (void) addVideoOverlayToViewController: (UIViewController *) originViewController
            withFetchedResultsController: (NSFetchedResultsController*) fetchedResultsController
                            andIndexPath: (NSIndexPath *) indexPath {
    
    // Remember the view controller that we came from
    self.originViewController = originViewController;
    
    
    
    self.videoViewerViewController = [[SYNVideoViewerViewController alloc] initWithFetchedResultsController: fetchedResultsController
                                                                                          selectedIndexPath: (NSIndexPath *) indexPath];
    [self.overlayView addSubview:self.videoViewerViewController.view];
    
    self.videoViewerViewController.view.alpha = 0.0f;
    self.videoViewerViewController.overlayParent = self;
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
         self.videoViewerViewController.view.alpha = 1.0f;
     }
     completion: ^(BOOL finished)
     {
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
                     } completion: ^(BOOL finished) {
                         self.overlayView.userInteractionEnabled = NO;
                         self.videoViewerViewController = nil;
                         [child removeFromSuperview];
                         
                     }];

}

- (void) addCategoryChooserOverlayToViewController: (UIViewController *) originViewController
{
    // Remember the view controller that we came from
    self.originViewController = originViewController;

    self.categoryChooserViewController = [[SYNCategoryChooserViewController alloc] init];
    
    [self.overlayView addSubview: self.categoryChooserViewController.view];
    [originViewController addChildViewController:self.categoryChooserViewController];
    
    self.categoryChooserViewController.view.alpha = 0.0f;
    self.categoryChooserViewController.overlayParent = self;
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         self.categoryChooserViewController.view.alpha = 1.0f;
                     } completion: ^(BOOL finished) {
                         self.overlayView.userInteractionEnabled = YES;
                     }];
}

- (void) removeCategoryChooserOverlayController
{
    
    UIView* child = self.overlayView.subviews[0];
    
    [UIView animateWithDuration: 0.25f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         child.alpha = 0.0f;
                     } completion: ^(BOOL finished) {
                         self.overlayView.userInteractionEnabled = NO;
                         self.videoViewerViewController = nil;
                         [child removeFromSuperview];
                         
                     }];

}


#pragma mark - Search Delegate Methods

-(IBAction)showSearchBoxField:(id)sender
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
    
    [self.view addSubview:self.searchBoxController.view];
    
}

-(void)searchTyped:(NSNotification*)notification
{
    
    
    NSString* termString = (NSString*)[[notification userInfo] objectForKey:kSearchTerm];
    
    if(!termString)
        return;
    
    self.closeSearchButton.hidden = YES;
    self.sideNavigationButton.hidden = NO;
    
    [self showSearchViewControllerWithTerm:termString];
    
}

- (void) showSearchViewControllerWithTerm:(NSString*)searchTerm
{
    
    [self showBackButton:YES];
    
    
    self.searchViewController = [[SYNSearchRootViewController alloc] initWithViewId: kSearchViewId];
    self.overlayNavigationController = [SYNObjectFactory wrapInNavigationController:self.searchViewController];
    
    [self.searchViewController showSearchResultsForTerm: searchTerm];
    
}



-(IBAction)cancelButtonPressed:(id)sender
{
    [self.searchBoxController clear];
    [self.searchBoxController.view removeFromSuperview];
    
    
    self.sideNavigationButton.hidden = NO;
    
    
}


#pragma mark - Notification Handlers

-(void)accountSettingsLogout
{
    [appDelegate logout];
}

-(void) reachabilityChanged:(NSNotification*) notification
{
    NSString* reachabilityString;
    if([self.reachability currentReachabilityStatus] == ReachableViaWiFi)
        reachabilityString = @"WiFi";
    else if([self.reachability currentReachabilityStatus] == ReachableViaWWAN)
        reachabilityString = @"WWAN";
    else if([self.reachability currentReachabilityStatus] == NotReachable) 
        reachabilityString = @"None";
    
    DebugLog(@"Reachability == %@", reachabilityString);
    if([self.reachability currentReachabilityStatus] == ReachableViaWiFi)
    {
        if(self.networkErrorView)
        {
            [self hideNetworkErrorView];
        }
    }
    else if([self.reachability currentReachabilityStatus] == ReachableViaWWAN)
    {
        if(self.networkErrorView)
        {
            [self hideNetworkErrorView];
        }
    }
    else if([self.reachability currentReachabilityStatus] == NotReachable)
    {
        [self presentNetworkErrorViewWithMesssage:@"NO NETWORK CONNECTION"];
        
        
    }
    
    
}



-(void)presentNetworkErrorViewWithMesssage:(NSString*)message
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
        erroViewFrame.origin.y = [[SYNDeviceManager sharedInstance] currentScreenHeight] - 70.0;
        
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"contentOffset"]) {
        
        CGPoint newContentOffset = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
        CGFloat diff = fabsf(newContentOffset.x - self.containerViewController.currentPageOffset.x);
        diff = diff/[[SYNDeviceManager sharedInstance] currentScreenWidth];
        if (diff >1.0f)
        {
            diff = diff - truncf(diff);
        }
        SYNAbstractViewController* nextViewController = [self.containerViewController nextShowingViewController];
        
        if(nextViewController.needsAddButton && !self.containerViewController.showingViewController.needsAddButton)
        {
            self.addToChannelButton.alpha = diff;
        }
        else if(!nextViewController.needsAddButton && self.containerViewController.showingViewController.needsAddButton)
        {
            self.addToChannelButton.alpha = 1.0f - diff;
        }
        else
        {
            self.addToChannelButton.alpha = self.containerViewController.showingViewController.needsAddButton? 1.0f:0.0f; 
        }

    }
}

-(void)dotTapped:(UIGestureRecognizer*)recogniser
{
    
}

-(void)backButtonRequested:(NSNotification*)notification
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



-(void)navigateToPage:(NSNotification*)notification
{
    
    NSString* pageName = [[notification userInfo] objectForKey:@"pageName"];
    if(!pageName)
        return;
    
    
    [self.containerViewController navigateToPageByName:pageName];
    
    if(self.sideNavigationViewController.state != SideNavigationStateHidden)
        [self hideSideNavigation];
    
    
    
}

#pragma mark - Navigation Methods

- (void) showBackButton: (BOOL) show
{
    CGRect targetFrame;
    CGFloat targetAlpha;
    
    if (show)
    {
        [self.backButtonControl addTarget:self action:@selector(popCurrentViewController:) forControlEvents:UIControlEventTouchUpInside];
        [self.backButtonControl setBackTitle:self.pageTitleLabel.text];
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
        [self.backButtonControl removeTarget:self action:@selector(popCurrentViewController:) forControlEvents:UIControlEventTouchUpInside];
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
                     animations: ^
                     {
                         self.movableButtonsContainer.frame = targetFrame;
                         self.backButtonControl.alpha = targetAlpha;
                         self.pageTitleLabel.alpha = !targetAlpha;
                         self.dotsView.alpha = !targetAlpha;
                         self.refreshButton.alpha = !targetAlpha;
                     }
                     completion: ^(BOOL finished)
                     {
                         
                     }];

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


#pragma mark - Helper Methods

-(void)showAddButton
{
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         
                         self.addToChannelButton.frame = self.addToChannelFrame;
        
                   } completion:^(BOOL finished) {
                       
                       
                
                   }];
    
}

-(void)hideAddButton
{
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         
                         self.addToChannelButton.alpha = 0.0;
                         
                     } completion:^(BOOL finished) {
                         
                         [self moveAddButtonOutOfWay];
                         
                     }];
    
}

-(void)moveAddButtonOutOfWay
{
    
    self.addToChannelButton.frame = CGRectMake(self.view.frame.size.width + 2.0,
                                               addToChannelFrame.origin.y,
                                               addToChannelFrame.size.width,
                                               addToChannelFrame.size.height);
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
    
    SYNAccountSettingsMainTableViewController* mainTable = [[SYNAccountSettingsMainTableViewController alloc] init];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController: mainTable];
    
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

    //[self.existingChannelsController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    originalAddButtonX = self.addToChannelButton.frame.origin.x;
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
        self.overlayContainerView.alpha = 0.0;
        [UIView animateWithDuration: 0.5f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseIn
                         animations: ^{
                             self.containerView.alpha = 0.0;
                         }
                         completion: ^(BOOL finished) {
                             _overlayNavigationController = overlayNavigationController;
                             [self addChildViewController:_overlayNavigationController];
                             [UIView animateWithDuration: 0.7f
                                                   delay: 0.2f
                                                 options: UIViewAnimationOptionCurveEaseOut
                                              animations: ^{
                                                  self.overlayContainerView.alpha = 1.0;
                                              }
                                              completion: nil];
                         }];
    }
    else
    {
        [UIView animateWithDuration: 0.5f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseIn
                         animations: ^{
                             self.overlayContainerView.alpha = 0.0;
                         }
                         completion: ^(BOOL finished) {
                             [_overlayNavigationController.view removeFromSuperview];
                             [_overlayNavigationController removeFromParentViewController];
                             _overlayNavigationController = nil;
                             [UIView animateWithDuration: 0.7f
                                                   delay: 0.2f
                                                 options: UIViewAnimationOptionCurveEaseOut
                                              animations: ^{
                                                  self.containerView.alpha = 1.0;
                                                  
                                              }
                                              completion: nil];
                         }];
    }
    
    
}

-(UINavigationController*)overlayNavigationController
{
    return _overlayNavigationController;
}


@end
