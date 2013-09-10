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
#import "SYNChannelDetailViewController.h"
#import "SYNChannelsRootViewController.h"
#import "SYNContainerViewController.h"
#import "SYNDeviceManager.h"
#import "SYNFeedRootViewController.h"
#import "SYNGenreTabViewController.h"
#import "SYNMasterViewController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNProfileRootViewController.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>

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
@property (nonatomic, weak) SYNAppDelegate *appDelegate;
@property (strong, nonatomic) MKNetworkOperation *downloadOperation;

@end


@implementation SYNContainerViewController

// Initialise all the elements common to all 4 tabs
#pragma mark - View lifecycle

- (void) loadView
{
    CGRect scrollerFrame = CGRectMake(0.0, 0.0, [SYNDeviceManager.sharedInstance currentScreenWidth], [SYNDeviceManager.sharedInstance currentScreenHeight]);
    SYNContainerScrollView *scrollView = [[SYNContainerScrollView alloc] initWithFrame: scrollerFrame];
    
    scrollView.autoresizingMask = UIViewAutoresizingNone;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.bounces = NO;
    scrollView.scrollsToTop = NO;
    
    self.view = scrollView;
    
    // Indicate that we don't start with a selected page
    self.lastSelectedPageIndex = -1;
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    // == Feed Page == //
    SYNFeedRootViewController *feedRootViewController = [[SYNFeedRootViewController alloc] initWithViewId: kFeedViewId];
    
    // == Channels Page == //
    SYNChannelsRootViewController *channelsRootViewController = [[SYNChannelsRootViewController alloc] initWithViewId: kChannelsViewId];
    
    if (IS_IPAD)
    {
        channelsRootViewController.tabViewController = [[SYNGenreTabViewController alloc] initWithHomeButton: @"POPULAR"];
        [channelsRootViewController addChildViewController: channelsRootViewController.tabViewController];
    }
    else
    {
        channelsRootViewController.enableCategoryTable = YES;
    }
    
    // == Profile Page == //
    SYNProfileRootViewController *profileViewController = [[SYNProfileRootViewController alloc] initWithViewId: kProfileViewId];
    
    if (!IS_IPAD)
    {
        profileViewController.hideUserProfile = YES;
    }
    
    profileViewController.user = self.appDelegate.currentUser;
    
    self.shouldAnimateViewTransitions = YES;
    
    self.didNotSwipeMessageInbox = YES;
    self.didNotSwipeShareMenu = YES;
    
    // == Populate Scroller == //
    CGRect scrollerFrame = CGRectMake(0.0, 0.0, 1024.0, 748.0);
    self.scrollView.frame = scrollerFrame;
    
    [self addChildViewController: feedRootViewController];
    
    [self addChildViewController: channelsRootViewController];
    
    [self addChildViewController: profileViewController];
    
    [self packViewControllersForInterfaceOrientation: UIDeviceOrientationLandscapeLeft];

    // == Set Firts Page == //
    if (self.appDelegate.currentUser.subscriptions.count > 3)
    {
        self.scrollView.page = self.lastSelectedPageIndex = 0;
    }
    else
    {
        self.scrollView.page = self.lastSelectedPageIndex = 1;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kScrollerPageChanged
                                                        object: self
                                                      userInfo: @{kCurrentPage: @(self.scrollView.page)}];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [self packViewControllersForInterfaceOrientation: [SYNDeviceManager.sharedInstance orientation]];
    
}


- (void) dealloc
{
    // Defensive programming
    self.scrollView.delegate = nil;
}


- (void) swipedTo: (UISwipeGestureRecognizerDirection) direction
{
    NSInteger page = self.currentPage;
    
    if (direction == UISwipeGestureRecognizerDirectionLeft) // go right
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
    
    [self.scrollView setPage: page
                    animated: YES];
}

-(void)firstFadedInto
{
    [self.showingViewController viewDidScrollToFront];
    
}

#pragma mark - maintaion orientation

- (void) refreshView
{
    [self packViewControllersForInterfaceOrientation: [SYNDeviceManager.sharedInstance orientation]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kScrollerPageChanged
                                                        object: self
                                                      userInfo: @{kCurrentPage: @(self.scrollView.page)}];
}


#pragma mark - Placement of Views

- (void) packViewControllersForInterfaceOrientation: (UIInterfaceOrientation) orientation
{
    CGRect newFrame;
    
    if (IS_IPHONE)
    {
        // The full screen video player can interfere with reading the screen dimensions on viewWillAppear.
        // Use MAX and MIN to determine which one is width and which one is height
        CGSize screenSize = CGSizeMake([SYNDeviceManager.sharedInstance currentScreenWidth], [SYNDeviceManager.sharedInstance currentScreenHeight]);
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
    
    for (SYNAbstractViewController *controller in self.childViewControllers)
    {
        controller.view.frame = newFrame;
        
        newFrame.origin.x += newFrame.size.width;
    }
    
    // pack replacement
    //get page before resizing scrollview
    int showingPage = self.currentPage;
    
    //resize scrollview
    self.scrollView.contentSize = CGSizeMake(newFrame.origin.x, newFrame.size.height);
    
    //adjust offset
    self.currentPageOffset = CGPointMake(showingPage * newFrame.size.width, 0);
    
    [self.scrollView setContentOffset: self.currentPageOffset];
}


- (void) addChildViewController: (UIViewController *) childController
{
    [childController willMoveToParentViewController: self];
    
    [super addChildViewController: childController];
    
    [self.scrollView addSubview: childController.view];
    
    [childController didMoveToParentViewController: self];
}


#pragma mark - Notification Methods


- (void) navigateToPageByName: (NSString *) pageName
{
    int page = 0;
    
    for (SYNAbstractViewController *nvc in self.childViewControllers)
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

-(SYNAbstractViewController*)viewControllerByPageName: (NSString *) pageName
{
    SYNAbstractViewController* child;
    for (child in self.childViewControllers)
    {
        if ([pageName isEqualToString: child.title])
            break;
           
    }
    return child;
}

#pragma mark - UIScrollViewDelegate



- (void) scrollViewDidEndScrollingAnimation: (UIScrollView *) scrollView
{
    // catch programmatic animations
    [self scrollViewDidEndDecelerating: scrollView];
}


- (void) scrollViewDidEndDecelerating: (UIScrollView *) scrollView
{
    self.currentPageOffset = self.scrollView.contentOffset;
    
    // These are the things we need to do if the page has actually changed
    if (self.currentPage != self.lastSelectedPageIndex)
    {
        // Now let the page know that it has the focus
        if (self.lastSelectedPageIndex >= 0 && self.lastSelectedPageIndex < 3)
        {
            SYNAbstractViewController *lastSelectedViewController = (SYNAbstractViewController *) self.childViewControllers[self.lastSelectedPageIndex];
            [lastSelectedViewController viewDidScrollToBack];
        }
        
        [self.showingViewController viewDidScrollToFront];
        
        // Remember our last page
        self.lastSelectedPageIndex = self.currentPage;
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kScrollerPageChanged
                                                            object: self
                                                          userInfo: @{kCurrentPage: @(self.scrollView.page)}];
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

- (SYNAbstractViewController *) showingViewController
{
    int currentPage = self.scrollView.page;
    currentPage = MIN (self.childViewControllers.count, currentPage);
    currentPage = MAX (0, currentPage);
    
    return self.childViewControllers[currentPage];
}


- (SYNContainerScrollView *) scrollView
{
    return (SYNContainerScrollView *) self.view;
}


- (NSString *) description
{
    return NSStringFromClass([self class]);
}


- (NSInteger) currentPage
{
    return self.scrollView.page;
}


@end
