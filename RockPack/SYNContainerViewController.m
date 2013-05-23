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
#import "SYNFeedRootViewController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNProfileRootViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNGenreTabViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SYNDeviceManager.h"
#import "SYNObjectFactory.h"

@interface SYNContainerViewController () <UIPopoverControllerDelegate,
                                          UITextViewDelegate>

@property (nonatomic) BOOL didNotSwipeMessageInbox;
@property (nonatomic) BOOL shouldAnimateViewTransitions;
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
    BOOL isIPad = [[SYNDeviceManager sharedInstance] isIPad];
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
    
    // == Register Notifications == //
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(backButtonShow:)
                                                 name: kNoteBackButtonShow
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(backButtonHide:)
                                                 name: kNoteBackButtonHide
                                                object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(profileRequested:)
                                                 name: kProfileRequested
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(channelDetailsRequested:)
                                                 name: kChannelDetailsRequested
                                               object: nil];
    
    // == Set Firts Page == //
    if (appDelegate.currentUser.subscriptions.count > 3)
    {
        self.selectedNavigationController = self.childViewControllers[0];
        // page is set automatically because it is the first one
    }
    else
    {
        self.selectedNavigationController = self.childViewControllers[1];
        self.scrollView.page = 1;
    }
}


- (void) viewWillAppear: (BOOL) animated
{
    [self packViewControllersForInterfaceOrientation: [[SYNDeviceManager sharedInstance] orientation]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kScrollerPageChanged
                                                        object: self
                                                      userInfo: @{kCurrentPage:@(self.scrollView.page)}];
    //FIXME: Nick to rework
    [self.childViewControllers makeObjectsPerformSelector: @selector(viewWillAppear:)
                                               withObject: nil];
}


#pragma mark - Placement of Views

- (void) packViewControllersForInterfaceOrientation: (UIInterfaceOrientation) orientation
{
    CGRect newFrame;
    if ([[SYNDeviceManager sharedInstance] isIPhone])
    {
        // The full screen video player can interfere with reading the screen dimensions on viewWillAppear.
        // Use MAX and MIN to determine which one is width and which one is height
        CGSize screenSize = CGSizeMake([[SYNDeviceManager sharedInstance] currentScreenWidth],[[SYNDeviceManager sharedInstance] currentScreenHeight]);
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

- (void) profileRequested: (NSNotification*) notification
{
    ChannelOwner* channelOwner = (ChannelOwner*)[[notification userInfo] objectForKey: kChannelOwner];
    if (!channelOwner)
        return;
    
    [self.showingViewController viewProfileDetails:channelOwner];
}


- (void) channelDetailsRequested: (NSNotification*) notification
{
    Channel* channel = (Channel*)[[notification userInfo] objectForKey: kChannel];
    if (!channel)
        return;
    
    [self.showingViewController viewChannelDetails: channel];
}


- (void) backButtonShow: (NSNotification*) notification
{
    self.scrollView.scrollEnabled = NO;
}


- (void) backButtonHide: (NSNotification*) notification
{
    self.scrollView.scrollEnabled = YES;
}


- (void) navigateToPageByName: (NSString*) pageName
{
    int page = 0;
    for (UINavigationController* nvc in self.childViewControllers)
    {
        if ([pageName isEqualToString:nvc.title])
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
    [self scrollViewDidEndDecelerating:scrollView];
}


- (void) scrollViewDidEndDecelerating: (UIScrollView *) scrollView
{
    scrollingDirection = ScrollingDirectionNone;
    
    self.selectedNavigationController = self.childViewControllers[self.scrollView.page];
    
    self.currentPageOffset = self.scrollView.contentOffset;
    
    [self.showingViewController viewDidScrollToFront];
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
    UINavigationController* navController =(UINavigationController*)self.selectedNavigationController;
    return (SYNAbstractViewController*)[navController.viewControllers objectAtIndex: 0];

}


- (SYNAbstractViewController*) nextShowingViewController
{
    UINavigationController* navigationController;
    if (self.scrollingDirection == ScrollingDirectionRight && (self.currentPage+1) < self.childViewControllers.count) {
        navigationController = self.childViewControllers[(self.currentPage+1)];
    }
    else if (self.scrollingDirection == ScrollingDirectionLeft && (self.currentPage-1) >= 0) {
        navigationController = self.childViewControllers[(self.currentPage-1)];
    }
    
    return (SYNAbstractViewController*)(navigationController.visibleViewController);
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
