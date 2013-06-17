//
//  SYNTopBarViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
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
#import "SYNOAuthNetworkEngine.h"
#import "SYNObjectFactory.h"
#import "SYNSearchBoxViewController.h"
#import "SYNSearchRootViewController.h"
#import "SYNSideNavigationViewController.h"
#import "SYNSoundPlayer.h"
#import "SYNVideoViewerViewController.h"
#import "UIFont+SYNFont.h"
#import "VideoInstance.h"
#import <QuartzCore/QuartzCore.h>
#import "SYNVideoPlaybackViewController.h"

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
@property (nonatomic, strong) IBOutlet UIView* dotsView;
@property (nonatomic, strong) IBOutlet UIView* errorContainerView;
@property (nonatomic, strong) IBOutlet UIView* movableButtonsContainer;
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
@property (nonatomic, strong) UINavigationController* overlayNavigationController;
@property (nonatomic, strong) UIPopoverController* accountSettingsPopover;
@property (nonatomic, strong) UIView* accountSettingsCoverView;
@property (strong, nonatomic) IBOutlet UIView *overlayContainerView;
@property (nonatomic, strong) IBOutlet UIButton* headerButton;

@end

@implementation SYNMasterViewController

@synthesize containerViewController;
@synthesize pageTitleLabel;
@synthesize showingBackButton;

@dynamic showingBaseViewController;
@dynamic showingViewController;

@synthesize sideNavigationOriginCenterX;
@synthesize isDragging, buttonLocked;
@synthesize overlayNavigationController = _overlayNavigationController;

#pragma mark - Initialise

- (id) initWithContainerViewController: (SYNContainerViewController*) root
{
    if ((self = [super initWithNibName: @"SYNMasterViewController" bundle: nil]))
    {
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];

        self.containerViewController = root;
        [self addChildViewController:root];

        // == Side Navigation == //
        self.sideNavigationViewController = [[SYNSideNavigationViewController alloc] init];
        
        self.sideNavigationViewController.view.frame = CGRectMake(1024.0,
                                                                  ([SYNDeviceManager.sharedInstance isIPad] ? 0.0 : 58.0f),
                                                                  self.sideNavigationViewController.view.frame.size.width,
                                                                  self.sideNavigationViewController.view.frame.size.height);

        self.sideNavigationViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        
        self.sideNavigationViewController.user = appDelegate.currentUser;
        
        [self addChildViewController:self.sideNavigationViewController];

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




#pragma mark - Life Cycle


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
    
    // == Add the Root Controller which will contain all others (Tabs in our case) == //

    [self.containerView addSubview:containerViewController.view];
    //self.containerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.existingChannelsController = [[SYNExistingChannelsViewController alloc] initWithViewId:kExistingChannelsViewId];

    // == Back Button == //
    
    self.backButtonControl = [SYNBackButtonControl backButton];
    [self.movableButtonsContainer addSubview: self.backButtonControl];
    self.backButtonControl.alpha = 0.0;
    
    self.movableButtonsContainer.userInteractionEnabled = YES;
    
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
    
    
    
    // == Set up Dots View == //
    
    self.dotsView.backgroundColor = [UIColor clearColor];
    int numberOfDots = [self.containerViewController.childViewControllers count];
    UIImage* dotImage = [UIImage imageNamed:@"NavigationDot"];
    CGPoint center = self.dotsView.center;
    CGRect newFrame = self.dotsView.frame;
    newFrame.size.width = (2 * numberOfDots - 1) * dotImage.size.width;
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
    
    self.darkOverlayView.hidden = YES;
    
    
    // == Set Up Notifications == //
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backButtonRequested:) name:kNoteBackButtonShow object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backButtonRequested:) name:kNoteBackButtonHide object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeControlButtonsToMode:) name:kMainControlsChangeEnter object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeControlButtonsToMode:) name:kMainControlsChangeLeave object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allNavControlsRequested:) name:kNoteAllNavControlsShow object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allNavControlsRequested:) name:kNoteAllNavControlsHide object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideSomeNavControlsRequested:) name:kChannelsNavControlsHide object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideTitleAndDots:) name:kNoteHideTitleAndDots object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addToChannelRequested:) name:kNoteAddToChannelRequest object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchBarRequested:) name:kNoteSearchBarRequestHide object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchBarRequested:) name:kNoteSearchBarRequestShow object:nil];
    
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideOrShowNetworkMessages:) name:kNoteHideNetworkMessages object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideOrShowNetworkMessages:) name:kNoteShowNetworkMessages object:nil];
    
    [self.navigationContainerView addSubview:self.sideNavigationViewController.view];
    
    
}


-(void)headerSwiped:(UISwipeGestureRecognizer*)recogniser
{
    [self.containerViewController swipedTo:recogniser.direction];
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
    
    
    self.pageTitleLabel.text = [self.containerViewController.showingBaseViewController.title uppercaseString];
    
    
    if(self.sideNavigationViewController.state == SideNavigationStateFull)
    {
        [self.sideNavigationViewController deselectAllCells];
        [self showSideNavigation];
    }
    else
    {
        NSString* controllerTitle = self.containerViewController.showingBaseViewController.title;
        
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
    
    Channel* channel = (Channel*)[[notification userInfo] objectForKey: kChannel];
    if(!channel)
        return;
    
    // this channel's managedObjectContext is the appDelegate.channelManagedObjectContext
    SYNChannelDetailViewController *channelCreationVC =
    [[SYNChannelDetailViewController alloc] initWithChannel: channel
                                                  usingMode: kChannelDetailsModeEdit] ;
    
    // either the current view on the container scroll view or the overlay navigation controller as in search mode
    SYNAbstractViewController* showingController = self.showingBaseViewController;
    [showingController animatedPushViewController: channelCreationVC];
}

-(void)addedToChannelAction:(NSNotification*)notification
{
    
    Channel* selectedChannel = (Channel*)[[notification userInfo] objectForKey:kChannel];
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

-(void)resumeVideoIfShowing
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
    NSString* controllerTitle = self.containerViewController.showingBaseViewController.title;
    
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
    

    if(!self.overlayNavigationController) {// we are on the main stage and the X button should appear
        self.sideNavigationButton.hidden = YES;
        self.closeSearchButton.hidden = NO;
    }
    
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
    
    self.searchBoxController.searchTextField.text = @"";
    
    if ([SYNDeviceManager.sharedInstance isIPad] && sender != nil)
    {
        [self.searchBoxController.searchTextField becomeFirstResponder];
    }
}

- (void) searchTyped: (NSNotification*) notification
{
    
    NSString* termString = (NSString*)[[notification userInfo] objectForKey: kSearchTerm];
    
    if(!termString)
        return;
    
    BOOL isIPad = [SYNDeviceManager.sharedInstance isIPad];
    if(isIPad)
    {
        self.closeSearchButton.hidden = YES;
        self.sideNavigationButton.hidden = NO;
        
    }
    
    if(!self.overlayNavigationController)
    {        
        self.searchViewController = [[SYNSearchRootViewController alloc] initWithViewId: kSearchViewId];
        self.overlayNavigationController = [SYNObjectFactory wrapInNavigationController: self.searchViewController];
    }
    else if([[SYNDeviceManager sharedInstance] isIPhone])
    {
        [self.searchViewController.view addSubview:self.sideNavigationViewController.searchViewController.searchBoxView];
        self.searchViewController.searchBoxViewController = self.sideNavigationViewController.searchViewController;
        SYNAbstractViewController* topController = (SYNAbstractViewController*)self.searchViewController.navigationController.topViewController;
        [topController animatedPopToRootViewController];
    }
    
    
    
    [self.searchViewController showSearchResultsForTerm: termString];
    
}


- (void) searchCancelledIPhone: (NSNotification*) notification
{
    if(self.searchViewController.navigationController.topViewController == self.searchViewController)
    {
        [self cancelButtonPressed: nil];
        self.overlayNavigationController = nil;
    }
    self.closeSearchButton.hidden = YES;
    self.sideNavigationButton.hidden = NO;
    [UIView animateWithDuration:0.3
                        animations:^{
                self.darkOverlayView.alpha = 1.0;
                        } completion:^(BOOL finished) {
                            self.darkOverlayView.hidden = NO;
                       }];

    [self.view addSubview: self.sideNavigationViewController.searchViewController.searchBoxView];
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



- (void) backButtonRequested: (NSNotification*) notification
{
    NSString* notificationName = [notification name];
    if(!notificationName)
        return;
    
    SYNAbstractViewController* sender = (SYNAbstractViewController*)[notification object];
    if(!sender)
        return;
    
    // BOOL toleratesSearchBar = sender.toleratesSearchBar;
    
    if([notificationName isEqualToString:kNoteBackButtonShow])
    {
        [self showBackButton:YES];
    }
    else
    {
        [self showBackButton:NO];
    }
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
        
        if(self.isInSearchMode && [[SYNDeviceManager sharedInstance] isIPad])
        {
            self.sideNavigationButton.hidden = YES;
        }
        
        
        
        self.pageTitleLabel.hidden = NO;
        
        self.dotsView.hidden = NO;
        self.movableButtonsContainer.hidden = NO;
    }
    else
    {
        self.searchButton.hidden = YES;
        self.sideNavigationButton.hidden = YES;
        self.closeSearchButton.hidden = YES;
        self.pageTitleLabel.hidden = YES;
        self.dotsView.hidden = YES;
        self.movableButtonsContainer.hidden = YES;
        self.sideNavigationViewController.state = SideNavigationStateHidden;
    }
}

- (void) hideSomeNavControlsRequested: (NSNotification*) notification
{
    self.searchButton.hidden = YES;
    self.closeSearchButton.hidden = YES;
    self.sideNavigationButton.hidden = YES;
    self.sideNavigationViewController.state = SideNavigationStateHidden;
}


- (void) navigateToPage: (NSNotification*) notification
{
    
    NSString* pageName = [[notification userInfo] objectForKey: @"pageName"];
    if(!pageName)
        return;
    

    if(self.isInSearchMode)
    {
        [self cancelButtonPressed:nil];
    }
    self.overlayNavigationController = nil; // animate the overlay out using the setter method

    if (showingBackButton)
    {
        //pop the current section navcontroller to the root controller
        SYNAbstractViewController* abstractVC = (SYNAbstractViewController *)self.containerViewController.showingBaseViewController;
        [abstractVC animatedPopToRootViewController];
        
        [self showBackButton:NO];
        

    }
    
    //Scroll to the requested page
    [self.containerViewController navigateToPageByName: pageName];
    
    self.sideNavigationViewController.state = SideNavigationStateHidden;
        
}


- (void) channelSuccessfullySaved: (NSNotification*) note
{
    NSString* message = [SYNDeviceManager.sharedInstance isIPhone]?
    NSLocalizedString(@"CHANNEL SAVED",nil):
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
    self.dotsView.alpha = 0.0f;
    self.pageTitleLabel.alpha = 0.0f;
}


#pragma mark - Navigation Methods

// when a view is pushed, this gets called

- (void) showBackButton: (BOOL) show // popping
{
    CGRect targetFrame;
    CGFloat targetAlpha;
    
    // XOR '^' the values so that they return 0 if they are both YES or both NO
    if(!(show ^ showingBackButton))
        return;
    
    CGFloat newSearchBoxOrigin;
    
    
    if (show)
    {
        [self.backButtonControl addTarget: self
                                   action: @selector(popCurrentViewController:)
                         forControlEvents:UIControlEventTouchUpInside];
        
        //No More Back Title (For Now)
        // [self.backButtonControl setBackTitle: self.pageTitleLabel.text];
        
        
        newSearchBoxOrigin = self.backButtonControl.frame.origin.x + self.backButtonControl.frame.size.width + 16.0;
        
        showingBackButton = YES;
        targetFrame = self.movableButtonsContainer.frame;
        targetAlpha = 1.0;
        
        if ([SYNDeviceManager.sharedInstance isIPad])
        {
            targetFrame.origin.x = 10.0;
        }
        
        else
        {
            targetFrame.origin.x = 5.0;
        }
        [self.containerViewController backButtonWillShow];
    }
    else
    {
        [self.backButtonControl removeTarget: self
                                      action: @selector(popCurrentViewController:)
                            forControlEvents: UIControlEventTouchUpInside];
        
        newSearchBoxOrigin = 10.0;
        
        
        showingBackButton = NO;
        targetFrame = self.movableButtonsContainer.frame;
        targetFrame.origin.x = kMovableViewOffX;
        targetAlpha = 0.0;
        [self.containerViewController backButtonwillHide];
    }
    
    [UIView animateWithDuration: 0.6f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         self.movableButtonsContainer.frame = targetFrame;
                         self.backButtonControl.alpha = targetAlpha;
                         self.pageTitleLabel.alpha = !targetAlpha;
                         self.dotsView.alpha = !targetAlpha;
                         
                         // Re-Asjust the Search Box when the back arrow comes on/off screen //
                         
                         if(self.isInSearchMode)
                         {
                             CGRect sboxFrame = self.searchBoxController.view.frame;
                             sboxFrame.origin.x = newSearchBoxOrigin;
                             sboxFrame.size.width = self.closeSearchButton.frame.origin.x - sboxFrame.origin.x - 8.0;
                             self.searchBoxController.view.frame = sboxFrame;
                         }
                     }
                     completion:^(BOOL finished)
                     {
                         
                     }];
    
    

}

- (void) popCurrentViewController: (id) sender
{
    
    
    if(self.showingViewController.isLocked)
        return;
    
    SYNAbstractViewController *abstractVC;
    
    if(_overlayNavigationController)
    {
        if(_overlayNavigationController.viewControllers.count > 1) // if the overlayController has itself pushed views, pop one of them
        {
            abstractVC = (SYNAbstractViewController *)_overlayNavigationController.topViewController;
            
            
            [abstractVC animatedPopViewController];
            

        }
        else // go back to containerView
        {
            
            if(self.isInSearchMode)
            {
                [self cancelButtonPressed:nil];
            }
            self.overlayNavigationController = nil; // animate the overlay out using the setter method

            
        }
        
    }
    else
    {
        abstractVC = (SYNAbstractViewController *)self.containerViewController.showingBaseViewController;
        
        [abstractVC animatedPopViewController];
        
        if(abstractVC.navigationController.viewControllers.count < 2) {
            
            self.containerViewController.scrollView.scrollEnabled = YES;
            
            if(self.isInSearchMode)
            {
                self.closeSearchButton.hidden = NO;
                self.sideNavigationButton.hidden = YES;
            }
            
            [self showBackButton:NO];
        }
            
        
       
    }
    
    
    
    [self.containerViewController refreshView];
    
    
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
        
        
        self.modalAccountContainer = [[SYNAccountSettingsModalContainer alloc] initWithNavigationController:navigationController andCompletionBlock:^{
            [self modalAccountContainerDismiss];
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
        
        [UIView animateWithDuration:0.5 animations:^{
           
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


- (void) presentSuccessNotificationWithMessage: (NSString*) message
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


#pragma mark - Overlay Accessor Methods

-(void) setOverlayNavigationController: (UINavigationController *) overlayNavigationController
{
    if (_overlayNavigationController && overlayNavigationController) // there can be only one overlay at a time
        return;

    if (overlayNavigationController) // if we did not pass nil
    {
        [self.overlayContainerView addSubview:overlayNavigationController.view];
        

        if ([SYNDeviceManager.sharedInstance isIPhone])
        {
            overlayNavigationController.view.frame = self.overlayContainerView.bounds;
        }
        else
        {
            [self showBackButton: YES];
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

                             [_overlayNavigationController removeFromParentViewController];
                             _overlayNavigationController = overlayNavigationController;
                             [self addChildViewController: _overlayNavigationController];
                             
                             [UIView animateWithDuration: 0.7f
                                                   delay: 0.2f
                                                 options: UIViewAnimationOptionCurveEaseOut
                                              animations: ^{
                                                  self.overlayContainerView.alpha = 1.0;
                                              }
                                              completion:^(BOOL finished) {
                                                  if ([SYNDeviceManager.sharedInstance isIPhone])
                                                  {
                                                      // The search overlay sits on the side navigation on iPhone, move it into the overlay temporarily
                                                     [[[self.overlayNavigationController.viewControllers objectAtIndex:0] view] addSubview: self.sideNavigationViewController.searchViewController.searchBoxView];
                                                  }
                                              }];
                         }];
    }
    else
    {
        if(_overlayContainerView) // nil was passed and there was another on screen (remove)
        {
            NSTimeInterval animationDuration = 0.5f;
            if([SYNDeviceManager.sharedInstance isIPhone])
            {
                animationDuration = 0.1f;
            }

            // if the controller underneath has not popped controllers to its stack, hide back button //

            if(self.containerViewController.showingBaseViewController.navigationController.viewControllers.count == 1)
            {
                [self showBackButton:NO];
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


- (UINavigationController*) overlayNavigationController
{
    return _overlayNavigationController;
}



// this always gets the BOTTOM of the showing navigation controller

- (SYNAbstractViewController*) showingViewController
{
    SYNAbstractViewController* absctractVc;
    if (self.overlayNavigationController)
        absctractVc = (SYNAbstractViewController*)self.overlayNavigationController.topViewController;
    else
        absctractVc = self.containerViewController.showingViewController;
    
    return absctractVc;
}

- (SYNAbstractViewController*) showingBaseViewController
{
    SYNAbstractViewController* absctractVc;
    if (self.overlayNavigationController)
        absctractVc = (SYNAbstractViewController*)self.overlayNavigationController.viewControllers[0];
    else
        absctractVc = self.containerViewController.showingBaseViewController;
    
    return absctractVc;
}

-(BOOL)isInSearchMode
{
    return (BOOL)self.searchBoxController.view.superview;
}

-(void)changeControlButtonsToMode:(NSNotification*)notification
{
    SYNAbstractViewController* object = [notification object];
    if(!object)
        return;
    
    if([object.viewId isEqualToString:kChannelDetailsViewId] && [[notification name] isEqualToString:kMainControlsChangeEnter])
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
    else
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
@end
