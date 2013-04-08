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



@property (nonatomic, strong) IBOutlet UIView* containerView;

@property (nonatomic, strong) UIPopoverController *actionButtonPopover;

@property (nonatomic, weak) UIViewController *selectedViewController;
@property (strong, nonatomic) MKNetworkOperation *downloadOperation;

@property (nonatomic, strong) IBOutlet UIView* tabsViewContainer;



@end

@implementation SYNContainerViewController

@synthesize selectedIndex = _selectedIndex;
@synthesize selectedViewController = _selectedViewController;
@synthesize videoQueueController = videoQueueController;
@synthesize channelsUserNavigationViewController;
@synthesize channelsUserViewController, searchViewController;

// Initialise all the elements common to all 4 tabs

#pragma mark - View lifecycle
 	
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // == Home Tab
    
    SYNHomeRootViewController *homeRootViewController = [[SYNHomeRootViewController alloc] initWithViewId: @"Home"];
    UINavigationController *homeRootNavigationViewController = [[UINavigationController alloc] initWithRootViewController: homeRootViewController];
    homeRootNavigationViewController.navigationBarHidden = TRUE;
    homeRootNavigationViewController.view.autoresizesSubviews = TRUE;
    homeRootNavigationViewController.view.frame = CGRectMake (0, 0, 1024, 784);
    
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
    
    SYNYouRootViewController *youRootViewController = [[SYNYouRootViewController alloc] initWithViewId: @"You"];
    youRootViewController.tabViewController = [[SYNUserTabViewController alloc] init];
    UINavigationController *youRootRootNavigationViewController = [[UINavigationController alloc] initWithRootViewController: youRootViewController];
    youRootRootNavigationViewController.navigationBarHidden = TRUE;
    youRootRootNavigationViewController.view.autoresizesSubviews = TRUE;
    youRootRootNavigationViewController.view.frame = CGRectMake (0, 0, 1024, 686);
    
    // == Friends tab
    // TODO: Nest Friends Bar
    SYNFriendsRootViewController *friendsRootViewController = [[SYNFriendsRootViewController alloc] initWithViewId: @"Friends"];
    
    // == Register Controllers
    
    self.viewControllers = @[homeRootNavigationViewController,
                             videosRootNavigationViewController,
                             channelsRootNavigationViewController,
                             youRootRootNavigationViewController,
                             friendsRootViewController];
    
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
    
    [self repositionQueueView];
    
    // Set Initial View Controller
    
    self.shouldAnimateViewTransitions = YES;
    
    [self setSelectedIndex: 2];
    
    self.didNotSwipeMessageInbox = TRUE;
    self.didNotSwipeShareMenu = TRUE;
    
    // notifications
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUserChannel:) name:kShowUserChannels object:nil];
}



- (void) repositionQueueView
{
    videoQueueController.view.center = CGPointMake(videoQueueController.view.center.x, [[UIScreen mainScreen] bounds].size.width + 60);
    
    [self.view insertSubview: videoQueueController.view
                belowSubview: self.tabsViewContainer];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    // Register for tab bar hiding notifications
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(hideTabBar)
                                                 name: kNoteHideTabBar
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(showTabBar)
                                                 name: kNoteShowTabBar
                                               object: nil];
}

- (void) viewWillDisappear: (BOOL) animated
{
    // Deregister for tab bar hiding notifications
     [[NSNotificationCenter defaultCenter] removeObserver: self
                                                     name: kNoteHideTabBar
                                                   object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kNoteShowTabBar
                                                  object: nil];
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


// Set the selected tab (with no animation)

- (void) setSelectedIndex: (NSInteger) newSelectedIndex
{
	[self setSelectedIndex: newSelectedIndex
                  animated: NO];
}


// Set the selected tab (with animation if required)

- (void) setSelectedIndex: (NSUInteger) newSelectedIndex
                 animated: (BOOL) animated
{
    if (_selectedIndex == newSelectedIndex)
    {
        if ([_selectedViewController isKindOfClass: [UINavigationController class]])
        {
            [self popCurrentViewController: (UIButton *)self.tabsViewContainer.subviews[_selectedIndex]];
        }
        return;
    }

    _selectedIndex = newSelectedIndex;
    
    for (UIButton* tabButton in self.tabsViewContainer.subviews)
    {
        tabButton.selected = NO;
        tabButton.userInteractionEnabled = YES;
    }
        

    if(_selectedIndex < 0 || _selectedIndex > self.tabsViewContainer.subviews.count)
        return;
    
    
    UIButton* toButton = (UIButton *)self.tabsViewContainer.subviews[_selectedIndex];
    toButton.selected = YES;
    // toButton.userInteractionEnabled = NO;
    
    
    self.selectedViewController = (UIViewController*)self.viewControllers[_selectedIndex];
    
    
}

- (void) setSelectedViewController: (UIViewController *) newSelectedViewController
{
    // if we try and push the same controller, escape
    
    if(_selectedViewController == newSelectedViewController)
    {
        return;
    }
        
    // even if nill, that is OK. It will just animate the selectedViewController out.
    
    if (newSelectedViewController)
    {
        [self.containerView addSubview:newSelectedViewController.view];
    }
    
    if (self.shouldAnimateViewTransitions)
    {
        self.view.userInteractionEnabled = NO;
        
        newSelectedViewController.view.alpha = 0.0f;
        
        [UIView animateWithDuration: kTabAnimationDuration
         delay: 0.0f
         options: UIViewAnimationOptionCurveEaseInOut
         animations: ^
         {
             _selectedViewController.view.alpha = 0.0f;
             
             if(newSelectedViewController)
                 newSelectedViewController.view.alpha = 1.0f;
         }
         completion: ^(BOOL finished)
         {
             [_selectedViewController.view removeFromSuperview];
             
             self.view.userInteractionEnabled = YES;
             
             _selectedViewController = newSelectedViewController;
         }];
    }
    else
    {
        [_selectedViewController.view removeFromSuperview];
        
        _selectedViewController = newSelectedViewController;
    }
    
    if ([newSelectedViewController isKindOfClass: [UINavigationController class]] &&
        [[(UINavigationController *)newSelectedViewController viewControllers] count] > 1)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: kNoteBackButtonShow
                                                            object: self];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: kNoteBackButtonHide
                                                            object: self];
    }
    
}


// Use the tag index of the button (100 - 103) to calculate the button index

- (IBAction) tabButtonPressed: (UIButton *) sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteTabPressed object:self];
    
	[self setSelectedIndex: sender.tag - kBottomTabIndexOffset
                  animated: YES];
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


- (void) showTabBar
{
    if (self.isTabBarHidden == TRUE)
    {
        self.tabBarHidden = !self.tabBarHidden;
        
        [UIView animateWithDuration: kTabAnimationDuration
         delay: 0.0f
         options: UIViewAnimationOptionCurveEaseInOut
         animations: ^
         {
             // Move the tab view so that it is just off the bottom of the screen
             CGRect tabContainerViewFrame = self.tabsViewContainer.frame;
             tabContainerViewFrame.origin.y -= tabContainerViewFrame.size.height;
             self.tabsViewContainer.frame = tabContainerViewFrame;
         }
         completion: ^(BOOL finished)
         {
         }];
    }
}


- (void) hideTabBar
{
    if (self.isTabBarHidden == FALSE)
    {
        self.tabBarHidden = !self.tabBarHidden;
    }
    
    [UIView animateWithDuration: kTabAnimationDuration
     delay: 0.0f
     options: UIViewAnimationOptionCurveEaseInOut
     animations: ^
     {
         // Move the tab view so that it is just off the bottom of the screen
         CGRect tabContainerViewFrame = self.tabsViewContainer.frame;
         tabContainerViewFrame.origin.y += tabContainerViewFrame.size.height;
         self.tabsViewContainer.frame = tabContainerViewFrame;
     }
     completion: ^(BOOL finished)
     {
     }];
}


- (NSString*) description
{
    return NSStringFromClass([self class]);
}

@end
