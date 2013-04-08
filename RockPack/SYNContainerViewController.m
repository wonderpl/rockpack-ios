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
#import "SYNFriendsRootViewController.h"
#import "SYNHomeRootViewController.h"
#import "SYNMovableView.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNSearchRootViewController.h"
#import "SYNSearchTabViewController.h"
#import "SYNUserTabView.h"
#import "SYNUserTabViewController.h"
#import "SYNVideosRootViewController.h"
#import "SYNYouRootViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNChannelsAddVideosViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNContainerViewController () <UIPopoverControllerDelegate,
                                          UITextViewDelegate>

@property (nonatomic) BOOL didNotSwipeMessageInbox;
@property (nonatomic) BOOL shouldAnimateViewTransitions;
@property (nonatomic, assign) BOOL didNotSwipeShareMenu;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) double lowPassResults;
@property (nonatomic, assign, getter = isShowingBackButton) BOOL showingBackButton;
@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, getter = isTabBarHidden) BOOL tabBarHidden;

@property (nonatomic, strong) SYNChannelsUserViewController* channelsUserViewController;
@property (nonatomic, strong) SYNSearchRootViewController* searchViewController;
@property (nonatomic, strong) UINavigationController* channelsUserNavigationViewController;
@property (nonatomic, strong) UINavigationController* seachViewNavigationViewController;


@property (nonatomic, readonly) UIScrollView* scrollView;


@property (nonatomic, strong) UIPopoverController *actionButtonPopover;

@property (nonatomic, weak) UIViewController *selectedViewController;
@property (strong, nonatomic) MKNetworkOperation *downloadOperation;




@end

@implementation SYNContainerViewController

@synthesize selectedIndex = _selectedIndex;
@synthesize selectedViewController = _selectedViewController;
@synthesize videoQueueController = videoQueueController;
@synthesize channelsUserNavigationViewController;
@synthesize channelsUserViewController, searchViewController;
@dynamic scrollView;
@dynamic page;

// Initialise all the elements common to all 4 tabs

#pragma mark - View lifecycle


-(void)loadView
{
    CGRect scrollerFrame = CGRectMake(0.0, 0.0, 1024.0, 748.0);
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:scrollerFrame];
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
    
    // == Home Tab
    
    SYNHomeRootViewController *feedRootViewController = [[SYNHomeRootViewController alloc] initWithViewId: @"Home"];
    UINavigationController *feedRootNavigationViewController = [[UINavigationController alloc] initWithRootViewController: feedRootViewController];
    feedRootNavigationViewController.navigationBarHidden = TRUE;
    feedRootNavigationViewController.view.autoresizesSubviews = TRUE;
    feedRootNavigationViewController.view.frame = CGRectMake (0, 0, 1024, 784);
    
    // == Videos Tab
    
    SYNVideosRootViewController *videosRootViewController = [[SYNVideosRootViewController alloc] initWithViewId: @"Videos"];
    videosRootViewController.tabViewController = [[SYNCategoriesTabViewController alloc] init];
    UINavigationController *videosRootNavigationViewController = [[UINavigationController alloc] initWithRootViewController: videosRootViewController];
    videosRootNavigationViewController.navigationBarHidden = TRUE;
    videosRootNavigationViewController.view.autoresizesSubviews = TRUE;
    videosRootNavigationViewController.view.frame = CGRectMake (0, 0, 1024, 686);
    
    // == Channels Tab
    
    SYNChannelsRootViewController *channelsRootViewController = [[SYNChannelsRootViewController alloc] initWithViewId: @"Channels"];
    channelsRootViewController.tabViewController = [[SYNCategoriesTabViewController alloc] init];
    UINavigationController *channelsRootNavigationViewController = [[UINavigationController alloc] initWithRootViewController: channelsRootViewController];
    channelsRootNavigationViewController.navigationBarHidden = TRUE;
    channelsRootNavigationViewController.view.autoresizesSubviews = TRUE;
    channelsRootNavigationViewController.view.frame = CGRectMake (0, 0, 1024, 686);
    
    // == You Tab
    
    SYNYouRootViewController *myRockpackViewController = [[SYNYouRootViewController alloc] initWithViewId: @"You"];
    myRockpackViewController.tabViewController = [[SYNUserTabViewController alloc] init];
    UINavigationController *myRockpackNavigationViewController = [[UINavigationController alloc] initWithRootViewController: myRockpackViewController];
    myRockpackNavigationViewController.navigationBarHidden = TRUE;
    myRockpackNavigationViewController.view.autoresizesSubviews = TRUE;
    myRockpackNavigationViewController.view.frame = CGRectMake (0, 0, 1024, 686);
    
    // == Friends tab
    // TODO: Nest Friends Bar
    SYNFriendsRootViewController *friendsRootViewController = [[SYNFriendsRootViewController alloc] initWithViewId: @"Friends"];
    
    // == Register Controllers
    
    self.viewControllers = @[feedRootNavigationViewController,
                             channelsRootNavigationViewController,
                             myRockpackNavigationViewController];
    
    // == Search (out of normal controller array)
    
    
    self.searchViewController = [[SYNSearchRootViewController alloc] initWithViewId:@"Search"];
    self.searchViewController.tabViewController = [[SYNSearchTabViewController alloc] init];
    self.seachViewNavigationViewController = [[UINavigationController alloc] initWithRootViewController:searchViewController];
    self.seachViewNavigationViewController.navigationBarHidden = YES;
    self.seachViewNavigationViewController.view.autoresizesSubviews = YES;
    self.seachViewNavigationViewController.view.frame = CGRectMake (0, 0, 1024, 686);
    
    
    // == Channels User (out of normal controller array)
    
    self.channelsUserViewController = [[SYNChannelsUserViewController alloc] initWithViewId:@"UserChannels"];
    self.channelsUserViewController.tabViewController = [[SYNUserTabViewController alloc] init];
    self.channelsUserNavigationViewController = [[UINavigationController alloc] initWithRootViewController:channelsUserViewController];
    self.channelsUserNavigationViewController.navigationBarHidden = YES;
    self.channelsUserNavigationViewController.view.autoresizesSubviews = YES;
    self.channelsUserNavigationViewController.view.frame = CGRectMake (0, 0, 1024, 686);
    
    
    // == Video Queue
    
    videoQueueController = [[SYNVideoQueueViewController alloc] init];
    videoQueueController.delegate = self;
    
    
    // Set Initial View Controller
    
    self.shouldAnimateViewTransitions = YES;
    
    
    self.didNotSwipeMessageInbox = TRUE;
    self.didNotSwipeShareMenu = TRUE;
    
    
    // Scroller
    
    CGFloat currentVCOffset = 0.0;
    CGRect currentVCRect;
    for (UIViewController * vc in self.viewControllers)
    {
        currentVCRect = vc.view.frame;
        currentVCRect.origin.x = currentVCOffset;
        
        vc.view.frame = currentVCRect;
        
        [self.scrollView addSubview:vc.view];
        
        currentVCOffset += 1024.0;
    }
    
    self.scrollView.contentSize = CGSizeMake(currentVCOffset, 748.0);
    
    self.selectedViewController = self.viewControllers[0];
    
    
    // notifications
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUserChannel:) name:kShowUserChannels object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backButtonShow:) name:kNoteBackButtonShow object:nil];
}





-(void)backButtonShow:(NSNotification*)notification
{
    
    self.scrollView.scrollEnabled = NO;
    
    
    
}

- (void) createChannelFromVideoQueue
{
    if([self.selectedViewController isKindOfClass:[UINavigationController class]])
    {
        
        SYNAbstractViewController* child = (SYNAbstractViewController*)((UINavigationController*)self.selectedViewController).topViewController;
        [child createChannel: [self.videoQueueController getChannelFromCurrentQueue]];
        
    }

}

-(void)addVideosToExistingChannel
{
    if([self.selectedViewController isKindOfClass:[UINavigationController class]])
    {
        
        SYNAbstractViewController* child = (SYNAbstractViewController*)((UINavigationController*)self.selectedViewController).topViewController;
        [child addToChannel: [self.videoQueueController getChannelFromCurrentQueue]];
        
    }
}

#pragma mark - Tab & Container switching mechanism

// Add the five tab view controllers as sub-view controllers of this view controller
- (void) setViewControllers: (NSArray *) newViewControllers
{
	UIViewController *oldSelectedViewController = self.selectedViewController;
    
	// Remove the old child view controllers.
	for (UIViewController *viewController in _viewControllers)
	{
		[viewController willMoveToParentViewController: nil];
		[viewController removeFromParentViewController];
	}
    
	_viewControllers = [newViewControllers copy];
    
	// This follows the same rules as UITabBarController for trying to
	// re-select the previously selected view controller.
	NSUInteger newIndex = [_viewControllers indexOfObject: oldSelectedViewController];
	if (newIndex != NSNotFound)
    {
		_selectedIndex = newIndex;
    }
	else if (newIndex < [_viewControllers count])
    {
		_selectedIndex = newIndex;
    }
	else
    {
		_selectedIndex = 0;
    }
    
	// Add the new child view controllers.
	for (UIViewController *viewController in _viewControllers)
	{
		[self addChildViewController: viewController];
		[viewController didMoveToParentViewController: self];
	}
}




- (IBAction) recordAction: (UIButton*) button
{
    button.selected = !button.selected;
}


- (void) popoverControllerDidDismissPopover: (UIPopoverController *) popoverController
{
	
}


- (void) popCurrentViewController: (id) sender
{

    UINavigationController *navVC = (UINavigationController *)self.selectedViewController;
    
    SYNAbstractViewController *abstractVC = (SYNAbstractViewController *)navVC.topViewController;
    
    [abstractVC animatedPopViewController];
    
    self.scrollView.scrollEnabled = YES;
    
}


#pragma mark - Show Special Views

- (void) showSearchViewControllerWithTerm:(NSString*)searchTerm
{
     
    
    if(self.selectedViewController != self.seachViewNavigationViewController) {
        self.selectedViewController = self.seachViewNavigationViewController;
        [self setSelectedIndex: -1];
    }
        

    
    [self.searchViewController showSearchResultsForTerm: searchTerm];
    
    
}

- (void) showUserChannel: (NSNotification*) notification
{
    NSDictionary* userInfo = [notification userInfo];
    
    ChannelOwner* channelOwner = (ChannelOwner*)[userInfo objectForKey: @"ChannelOwner"];
    
    if (!channelOwner)
        return;
    
    [self setSelectedIndex: -1]; // turn all off
    
    if(self.selectedViewController != self.channelsUserNavigationViewController)
        self.selectedViewController = self.channelsUserNavigationViewController;
    
    
    [self.channelsUserViewController fetchUserChannels: channelOwner];
}





#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    NSInteger currentPage = self.page;
    
    NSNotification* notification = [NSNotification notificationWithName:kScrollerPageChanged object:self userInfo:@{@"page":@(currentPage)}];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    self.selectedViewController = self.viewControllers[currentPage];
    
    
    SYNAbstractViewController* controllerOnView;
    if([self.selectedViewController isKindOfClass:[UINavigationController class]])
    {
        controllerOnView = (SYNAbstractViewController*)((UINavigationController*)self.selectedViewController).visibleViewController;
    }
    else
    {
        controllerOnView = (SYNAbstractViewController*)self.selectedViewController;
    }
    
    [controllerOnView viewCameToScrollFront];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}

#pragma mark - Getters/Setters

-(void)setPage:(NSInteger)page
{
    if(!self.scrollView.scrollEnabled)
        return;
    
    CGPoint newPoint = CGPointMake(page * 1024.0, 0.0);
    [self.scrollView setContentOffset:newPoint animated:YES];
}

// gets current page that the scroller is at from the current offset

-(NSInteger)page
{
    CGFloat currentScrollerOffset = self.scrollView.contentOffset.x;
    int pageWidth = (int)self.scrollView.contentSize.width / self.viewControllers.count;
    NSInteger page = (currentScrollerOffset / pageWidth); // 0 indexed
    return page;
    
}

-(UIScrollView*)scrollView
{
    return (UIScrollView*)self.view;
}

- (NSString*) description
{
    return NSStringFromClass([self class]);
}

@end
