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
#import "GAI.h"
#import "MKNetworkEngine.h"
#import "SYNActivityPopoverViewController.h"
#import "SYNContainerViewController.h"
#import "SYNChannelsRootViewController.h"
#import "SYNFeedRootViewController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNProfileRootViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNGenreTabViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SYNDeviceManager.h"
#import "SYNObjectFactory.h"
#import "SYNChannelDetailViewController.h"
#import "SYNMasterViewController.h"

@interface SYNContainerViewController () <UIPopoverControllerDelegate,
                                          UITextViewDelegate>

@property (nonatomic) BOOL didNotSwipeMessageInbox;
@property (nonatomic) BOOL shouldAnimateViewTransitions;
@property (nonatomic) int lastSelectedPageIndex;
@property (nonatomic, assign) BOOL didNotSwipeShareMenu;
@property (nonatomic, assign) double lowPassResults;
@property (nonatomic, assign, getter = isShowingBackButton) BOOL showingBackButton;
@property (nonatomic, getter = isTabBarHidden) BOOL tabBarHidden;
@property (nonatomic, readonly) CGFloat currentScreenOffset;
@property (nonatomic, strong) UIPopoverController *actionButtonPopover;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;
@property (nonatomic, weak) UINavigationController *selectedNavigationController;
@property (strong, nonatomic) MKNetworkOperation *downloadOperation;

@end


@implementation SYNContainerViewController

@dynamic scrollView;
@dynamic showingBaseViewController;
@dynamic showingViewController;

@synthesize appDelegate;
@synthesize currentPage;
@synthesize currentPageOffset;
@synthesize currentScreenOffset;
@synthesize scrollingDirection;
@synthesize selectedNavigationController;

// Initialise all the elements common to all 4 tabs

#pragma mark - View lifecycle

- (void) loadView
{
    CGRect scrollerFrame = CGRectMake(0.0, 0.0, [SYNDeviceManager.sharedInstance currentScreenWidth], [SYNDeviceManager.sharedInstance currentScreenHeight]);
    SYNContainerScrollView* scrollView = [[SYNContainerScrollView alloc] initWithFrame:scrollerFrame];

    scrollView.autoresizingMask = UIViewAutoresizingNone;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    
    self.view = scrollView;
    
    // Indicate that we don't start with a selected page
    self.lastSelectedPageIndex = -1;
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    // == Feed Page == //
    SYNFeedRootViewController *feedRootViewController = [[SYNFeedRootViewController alloc] initWithViewId: kFeedViewId];
    
    // == Channels Page == //
    SYNChannelsRootViewController *channelsRootViewController = [[SYNChannelsRootViewController alloc] initWithViewId: kChannelsViewId];
    BOOL isIPad = [SYNDeviceManager.sharedInstance isIPad];
    if (isIPad)
    {
        channelsRootViewController.tabViewController = [[SYNGenreTabViewController alloc] initWithHomeButton: @"ALL"];
        [channelsRootViewController addChildViewController: channelsRootViewController.tabViewController];
    }
    else
    {
        channelsRootViewController.enableCategoryTable = YES;
    }
    
    // == Profile Page == //
    SYNProfileRootViewController *myRockpackViewController = [[SYNProfileRootViewController alloc] initWithViewId: kProfileViewId];
    if (!isIPad)
    {
        myRockpackViewController.hideUserProfile = YES;
    }
    
    myRockpackViewController.user = appDelegate.currentUser;
    
    self.shouldAnimateViewTransitions = YES;
    
    self.didNotSwipeMessageInbox = YES;
    self.didNotSwipeShareMenu = YES;

    // == Populate Scroller == //
    CGRect scrollerFrame = CGRectMake(0.0, 0.0, 1024.0, 748.0);
    self.scrollView.frame = scrollerFrame;
    UINavigationController* feedNavController = [SYNObjectFactory wrapInNavigationController: feedRootViewController];
    feedNavController.view.frame = CGRectMake (0.0f, 0.0f, 1024.0f, 748.0f);

    [self addChildViewController: feedNavController];
    
    [self addChildViewController: [SYNObjectFactory wrapInNavigationController: channelsRootViewController]];
    
    [self addChildViewController: [SYNObjectFactory wrapInNavigationController: myRockpackViewController]];
    
    [self packViewControllersForInterfaceOrientation:UIDeviceOrientationLandscapeLeft];
    
    
   
    
    // == Set Firts Page == //
    
    if (appDelegate.currentUser.subscriptions.count > 3)
    {
        self.selectedNavigationController = self.childViewControllers[0];
        // page is set automatically because it is the first one
        self.lastSelectedPageIndex = 0;
    }
    else
    {
        self.selectedNavigationController = self.childViewControllers[1];
        self.scrollView.page = 1;
        self.lastSelectedPageIndex = 1;
    }
    
    [self.showingBaseViewController viewDidScrollToFront];
}


- (void) viewWillAppear: (BOOL) animated
{
    [self packViewControllersForInterfaceOrientation: [SYNDeviceManager.sharedInstance orientation]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kScrollerPageChanged
                                                        object: self
                                                      userInfo: @{kCurrentPage:@(self.scrollView.page)}];
}

- (void) dealloc
{
    // Defensive programming
    self.scrollView.delegate = nil;
}

-(void)swipedTo:(UISwipeGestureRecognizerDirection)direction
{
    NSInteger page = self.currentPage;
  
    if(direction == UISwipeGestureRecognizerDirectionLeft) // go right
    {
        page = self.currentPage + 1 < self.childViewControllers.count ? self.currentPage + 1 : self.currentPage;
    }
    else if (direction == UISwipeGestureRecognizerDirectionRight) // go left
    {
        page = self.currentPage - 1 >= 0 ? self.currentPage - 1 : self.currentPage;
    }
    else
    {
        return;
    }
    
    [self.scrollView setPage: page animated: YES];
}


#pragma mark - maintaion orientation

-(void)refreshView
{
    [self packViewControllersForInterfaceOrientation: [SYNDeviceManager.sharedInstance orientation]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kScrollerPageChanged
                                                        object: self
                                                      userInfo: @{kCurrentPage:@(self.scrollView.page)}];
}

#pragma mark - Placement of Views

- (void) packViewControllersForInterfaceOrientation: (UIInterfaceOrientation) orientation
{
    CGRect newFrame;
    if ([SYNDeviceManager.sharedInstance isIPhone])
    {
        // The full screen video player can interfere with reading the screen dimensions on viewWillAppear.
        // Use MAX and MIN to determine which one is width and which one is height
        CGSize screenSize = CGSizeMake([SYNDeviceManager.sharedInstance currentScreenWidth],[SYNDeviceManager.sharedInstance currentScreenHeight]);
        newFrame = CGRectMake(0, 0, MIN(screenSize.width, screenSize.height), MAX(screenSize.width, screenSize.height) - 20.0f);
    }
    else if (UIDeviceOrientationIsLandscape(orientation))
    {
        newFrame = CGRectMake(0.0f, 0.0f, 1024.0f, 748.0f);
    }
    else
    {
        newFrame = CGRectMake(0.0, 0.0f, 768.0f, 1004.0f);
    }
    self.scrollView.frame = newFrame;
    for (UIViewController* controller in self.childViewControllers)
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


- (void) addChildViewController: (UIViewController *) childController
{
    [childController willMoveToParentViewController: self];
    
    [super addChildViewController: childController];
    
    [self.scrollView addSubview: childController.view];
    
    [childController didMoveToParentViewController: self];
}


#pragma mark - Notification Methods




- (void) backButtonWillShow
{
    self.scrollView.scrollEnabled = NO;
}


- (void) backButtonwillHide
{
    self.scrollView.scrollEnabled = YES;
}


- (void) navigateToPageByName: (NSString*) pageName
{
    int page = 0;
    
    for (UINavigationController* nvc in self.childViewControllers)
    {
        if ([pageName isEqualToString: nvc.title])
        {
            [self.scrollView setPage: page
                            animated: YES];
            break;
        }
        page++;
    }
}


#pragma mark - UIScrollViewDelegate

- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    if (self.currentPageOffset.x < self.scrollView.contentOffset.x - 8.0)
    {
        scrollingDirection = ScrollingDirectionRight;
    }
    else if (self.currentPageOffset.x > self.scrollView.contentOffset.x + 8.0)
    {
        scrollingDirection = ScrollingDirectionLeft;
    }
}


- (void) scrollViewDidEndScrollingAnimation: (UIScrollView *) scrollView
{
    // catch programmatic animations
    [self scrollViewDidEndDecelerating: scrollView];
}


- (void) scrollViewDidEndDecelerating: (UIScrollView *) scrollView
{
    scrollingDirection = ScrollingDirectionNone;
    
    self.selectedNavigationController = self.childViewControllers[self.scrollView.page];
    
    self.currentPageOffset = self.scrollView.contentOffset;
    
    
    // These are the things we need to do if the page has actually changed    
    if (self.currentPage != self.lastSelectedPageIndex)
    {        
        // Update google analytics
        id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
        
        [tracker sendEventWithCategory: @"uiAction"
                            withAction: @"navigationSwipe"
                             withLabel: nil
                             withValue: nil];
        
        // Now let the page know that it has the focus
        if(self.lastSelectedPageIndex >=0 && self.lastSelectedPageIndex <3)
        {
            SYNAbstractViewController* lastSelectedViewController = (SYNAbstractViewController*)((UINavigationController*)self.childViewControllers[self.lastSelectedPageIndex]).viewControllers[0];
            [lastSelectedViewController viewDidScrollToBack];
            NSLog(@"last vc: %@ at %i", lastSelectedViewController.title, self.lastSelectedPageIndex);
        }
        
         [self.showingBaseViewController viewDidScrollToFront];
        
        // Remember our last page
        self.lastSelectedPageIndex = self.currentPage;
    }
}


#pragma mark - Rotation Callbacks

- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    [super willAnimateRotationToInterfaceOrientation: toInterfaceOrientation
                                            duration: duration];
    
    [self packViewControllersForInterfaceOrientation: toInterfaceOrientation];
    
}


#pragma mark - Getters/Setters


- (SYNAbstractViewController*) showingViewController
{
    UINavigationController* selectedNavController = (UINavigationController*)self.selectedNavigationController;
    return (SYNAbstractViewController*)selectedNavController.topViewController;
    
}

- (SYNAbstractViewController*) showingBaseViewController
{
    UINavigationController* selectedNavController = (UINavigationController*)self.selectedNavigationController;
    return (SYNAbstractViewController*)selectedNavController.viewControllers[0];

}


- (void) setSelectedNavigationController: (UINavigationController *) selectedVC
{
    selectedNavigationController = selectedVC;
    
    // == notify the page change for the MasterViewController to catch it == //
    [[NSNotificationCenter defaultCenter] postNotificationName: kScrollerPageChanged
                                                        object: self
                                                      userInfo: @{kCurrentPage:@(self.scrollView.page)}];
}



- (SYNContainerScrollView*) scrollView
{
    return (SYNContainerScrollView*)self.view;
}

- (NSString*) description
{
    return NSStringFromClass([self class]);
}


- (NSInteger) currentPage
{
    return self.scrollView.page;
}

@end
