//
//  SYNBottomTabViewController.m
//  RockPack
//
//  Created by Nick Banks on 13/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "AudioToolbox/AudioToolbox.h"
#import "ChannelOwner.h"
#import "MKNetworkEngine.h"
#import "SYNActivityPopoverViewController.h"
#import "SYNContainerViewController.h"
#import "SYNChannelsRootViewController.h"
#import "SYNChannelsUserViewController.h"
#import "SYNFeedRootViewController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNProfileRootViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNCategoriesTabViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SYNDeviceManager.h"
#import "SYNExistingChannelsViewController.h"
#import "SYNObjectFactory.h"

@interface SYNContainerViewController () <UIPopoverControllerDelegate,
                                          UITextViewDelegate>

@property (nonatomic) BOOL didNotSwipeMessageInbox;
@property (nonatomic) BOOL shouldAnimateViewTransitions;
@property (nonatomic, assign) BOOL didNotSwipeShareMenu;
@property (nonatomic, assign) double lowPassResults;
@property (nonatomic, assign, getter = isShowingBackButton) BOOL showingBackButton;


@property (nonatomic, getter = isTabBarHidden) BOOL tabBarHidden;


@property (nonatomic, weak) SYNAppDelegate* appDelegate;


@property (nonatomic, strong) UIPopoverController *actionButtonPopover;

@property (nonatomic, weak) UINavigationController *selectedNavigationController;
@property (strong, nonatomic) MKNetworkOperation *downloadOperation;

@property (nonatomic, readonly) CGFloat currentScreenOffset;





@end

@implementation SYNContainerViewController

@synthesize selectedNavigationController;
@synthesize currentScreenOffset;
@synthesize scrollingDirection;
@synthesize currentPageOffset;
@synthesize appDelegate;
@synthesize currentPage;

@dynamic showingViewController;

@dynamic scrollView;

// Initialise all the elements common to all 4 tabs

#pragma mark - View lifecycle


-(void)loadView
{
    CGRect scrollerFrame = CGRectMake(0.0, 0.0, [[SYNDeviceManager sharedInstance] currentScreenWidth], [[SYNDeviceManager sharedInstance] currentScreenHeight]);
    SYNContainerScrollView* scrollView = [[SYNContainerScrollView alloc] initWithFrame:scrollerFrame];

    scrollView.autoresizingMask = UIViewAutoresizingNone;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    
    self.view = scrollView;
}
 	
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    // == Feed Page == //
    
    SYNFeedRootViewController *feedRootViewController = [[SYNFeedRootViewController alloc] initWithViewId: kFeedViewId];
    
    
    // == Channels Page == //
    
    SYNChannelsRootViewController *channelsRootViewController = [[SYNChannelsRootViewController alloc] initWithViewId: kChannelsViewId];
    if([[SYNDeviceManager sharedInstance] isIPad])
    {
        channelsRootViewController.tabViewController = [[SYNCategoriesTabViewController alloc] initWithHomeButton: TRUE];
        [channelsRootViewController addChildViewController:channelsRootViewController.tabViewController];
    }
    else
    {
        channelsRootViewController.enableCategoryTable = YES;
    }
    
    // == Profile Page == //
    
    SYNProfileRootViewController *myRockpackViewController = [[SYNProfileRootViewController alloc] initWithViewId: kProfileViewId];
    myRockpackViewController.user = appDelegate.currentUser;
    
    
    self.shouldAnimateViewTransitions = YES;
    
    
    self.didNotSwipeMessageInbox = YES;
    self.didNotSwipeShareMenu = YES;
    
    
    // == Populate Scroller == //
    
    CGRect scrollerFrame = CGRectMake(0.0, 0.0, 1024.0, 748.0);
    self.scrollView.frame = scrollerFrame;
    UINavigationController* feedNavController = [SYNObjectFactory wrapInNavigationController:feedRootViewController];
    feedNavController.view.frame = CGRectMake (0.0f, 0.0f, 1024.0f, 748.0f);

    [self addChildViewController:feedNavController];
    
    [self addChildViewController:[SYNObjectFactory wrapInNavigationController:channelsRootViewController]];
    
    [self addChildViewController:[SYNObjectFactory wrapInNavigationController:myRockpackViewController]];
    
    
    [self packViewControllersForInterfaceOrientation:UIDeviceOrientationLandscapeLeft];
    
    self.selectedNavigationController = self.childViewControllers[0];
    
    
    
    // == Register Notifications == //
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backButtonShow:) name:kNoteBackButtonShow object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backButtonHide:) name:kNoteBackButtonHide object:nil];
}

-(void) viewWillAppear:(BOOL)animated
{
    [self packViewControllersForInterfaceOrientation:[[SYNDeviceManager sharedInstance] orientation]];
    
    
}

#pragma mark - Placement of Views

-(void)packViewControllersForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    CGRect newFrame;
    if([[SYNDeviceManager sharedInstance] isIPhone])
    {
        // The full screen video player can interfere with reading the screen dimensions on viewWillAppear.
        // Use MAX and MIN to determine which one is width and which one is height
        CGSize screenSize = CGSizeMake([[SYNDeviceManager sharedInstance] currentScreenWidth],[[SYNDeviceManager sharedInstance] currentScreenHeight]);
        newFrame = CGRectMake(0, 0, MIN(screenSize.width, screenSize.height), MAX(screenSize.width, screenSize.height) - 20.0f);
    }
    else if(UIDeviceOrientationIsLandscape(orientation))
    {
        newFrame = CGRectMake(0.0f, 0.0f, 1024.0f, 748.0f);
    }
    else
    {
        newFrame = CGRectMake(0.0, 0.0f, 768.0f, 1004.0f);
    }
    self.scrollView.frame = newFrame;
    for(UIViewController* controller in self.childViewControllers)
    {
        controller.view.frame = newFrame;
        
        UINavigationController* navController = (UINavigationController*)controller;
        navController.topViewController.view.frame = controller.view.bounds;
        
        newFrame.origin.x += newFrame.size.width;
    }
    
    // pack replacement
    //get page before resizing scrollview
    int showingPage = self.currentPage;
    
    //resize scrollview
    self.scrollView.contentSize = CGSizeMake(newFrame.origin.x, newFrame.size.height);
    
    //adjust offset
    self.currentPageOffset = CGPointMake(showingPage * newFrame.size.width,0);
    [self.scrollView setContentOffset:self.currentPageOffset];
    
    scrollingDirection = ScrollingDirectionNone;
}

-(void)addChildViewController:(UIViewController *)childController
{
    [childController willMoveToParentViewController:self];
    
    [super addChildViewController:childController];
    
    [self.scrollView addSubview:childController.view];
    
    [childController didMoveToParentViewController:self];
}


-(void)backButtonShow:(NSNotification*)notification
{
    self.scrollView.scrollEnabled = NO;
}

-(void)backButtonHide:(NSNotification*)notification
{
    
    self.scrollView.scrollEnabled = YES;
}


#pragma mark - Navigation Methods

- (void) popCurrentViewController: (id) sender
{
    
    
    SYNAbstractViewController *abstractVC = (SYNAbstractViewController *)self.selectedNavigationController.topViewController;
    
    [abstractVC animatedPopViewController];
    
    
}

-(void) navigateToPageByName:(NSString*)pageName
{
    int page = 0;
    for (UINavigationController* nvc in self.childViewControllers)
    {
        if([pageName isEqualToString:nvc.title]) {
            self.scrollView.page = page;
            break;
        }
        page++;
    }
}

-(void)navigateToPageByName:(NSString *)pageName byPoppingNagivationController:(BOOL)pop
{
    if(!pop) {
        [self navigateToPageByName:pageName];
    } else {
        [self.showingViewController animatedPopViewController];
        [self navigateToPageByName:pageName];
    }
    
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if(self.currentPageOffset.x < self.scrollView.contentOffset.x - 8.0)
    {
        
        scrollingDirection = ScrollingDirectionRight;
    }
    else if(self.currentPageOffset.x > self.scrollView.contentOffset.x + 8.0)
    {
        
        scrollingDirection = ScrollingDirectionLeft;
    }
    
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // catch programmatic animations
    [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    scrollingDirection = ScrollingDirectionNone;
    
    self.selectedNavigationController = self.childViewControllers[self.scrollView.page];
    
    self.currentPageOffset = self.scrollView.contentOffset;
    
    [self.showingViewController viewCameToScrollFront];
}

#pragma mark - Rotation Callbacks

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self packViewControllersForInterfaceOrientation:toInterfaceOrientation];
    
}

#pragma mark - Getters/Setters

-(SYNAbstractViewController*)showingViewController
{

    return (SYNAbstractViewController*)((UINavigationController*)self.selectedNavigationController).visibleViewController;

}


-(SYNAbstractViewController*)nextShowingViewController
{
    UINavigationController* navigationController;
    if(self.scrollingDirection == ScrollingDirectionRight && (self.currentPage+1) < self.childViewControllers.count) {
        navigationController = self.childViewControllers[(self.currentPage+1)];
    } else if(self.scrollingDirection == ScrollingDirectionLeft && (self.currentPage-1) >= 0) {
        navigationController = self.childViewControllers[(self.currentPage-1)];
    }
    return (SYNAbstractViewController*)(navigationController.visibleViewController);
}





-(void)setSelectedNavigationController:(UINavigationController *)selectedVC
{
    selectedNavigationController = selectedVC;
    
    // == notify the page change for the MasterViewController to catch it == //
    [[NSNotificationCenter defaultCenter] postNotificationName:kScrollerPageChanged
                                                        object:self
                                                      userInfo:@{kCurrentPage:@(self.scrollView.page)}];
}



-(SYNContainerScrollView*)scrollView
{
    return (SYNContainerScrollView*)self.view;
}

- (NSString*) description
{
    return NSStringFromClass([self class]);
}


-(NSInteger)currentPage
{
    return self.scrollView.page;
}



@end
