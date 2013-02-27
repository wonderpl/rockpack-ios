//
//  SYNBottomTabViewController.m
//  RockPack
//
//  Created by Nick Banks on 13/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "AudioToolbox/AudioToolbox.h"
#import "MKNetworkEngine.h"
#import "SYNActivityPopoverViewController.h"
#import "SYNBottomTabViewController.h"
#import "SYNChannelsRootViewController.h"
#import "SYNVideosRootViewController.h"
#import "SYNFriendsRootViewController.h"
#import "SYNHomeRootViewController.h"
#import "SYNMovableView.h"
#import "SYNYouRootViewController.h"
#import "SYNVideoDB.h"
#import "SYNVideoDownloadEngine.h"
#import "UIFont+SYNFont.h"
#import "SYNSearchTabViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNBottomTabViewController () <UIPopoverControllerDelegate,
                                          UITextViewDelegate>

@property (nonatomic) BOOL didNotSwipeMessageInbox;
@property (nonatomic, assign) BOOL didNotSwipeShareMenu;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) double lowPassResults;
@property (nonatomic, assign, getter = isShowingBackButton) BOOL showingBackButton;
@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, strong) UIViewController* searchViewController;

@property (nonatomic, strong) IBOutlet UIButton *recordButton;
@property (nonatomic, strong) IBOutlet UIButton *writeMessageButton;

@property (nonatomic, strong) IBOutlet UIView* containerView;

@property (nonatomic, strong) UIPopoverController *actionButtonPopover;

@property (nonatomic, weak) UIViewController *selectedViewController;
@property (strong, nonatomic) MKNetworkOperation *downloadOperation;
@property (strong, nonatomic) SYNVideoDownloadEngine *downloadEngine;

@property (nonatomic, strong) IBOutlet UIView* tabsViewContainer;

@end

@implementation SYNBottomTabViewController

@synthesize selectedIndex = _selectedIndex;
@synthesize selectedViewController = _selectedViewController;

// Initialise all the elements common to all 4 tabs

#pragma mark - View lifecycle
 	
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Home Tab
    SYNHomeRootViewController *homeRootViewController = [[SYNHomeRootViewController alloc] initWithViewId:@"Home"];
    UINavigationController *homeRootNavigationViewController = [[UINavigationController alloc] initWithRootViewController: homeRootViewController];
    homeRootNavigationViewController.navigationBarHidden = TRUE;
    homeRootNavigationViewController.view.autoresizesSubviews = TRUE;
    homeRootNavigationViewController.view.frame = CGRectMake (0, 0, 1024, 784);
    
    // Channels tab
    SYNChannelsRootViewController *channelsRootViewController = [[SYNChannelsRootViewController alloc] initWithViewId:@"Channels"];
    channelsRootViewController.tabViewController = [[SYNCategoriesTabViewController alloc] init];
    UINavigationController *channelsRootNavigationViewController = [[UINavigationController alloc] initWithRootViewController: channelsRootViewController];
    channelsRootNavigationViewController.navigationBarHidden = TRUE;
    channelsRootNavigationViewController.view.autoresizesSubviews = TRUE;
    channelsRootNavigationViewController.view.frame = CGRectMake (0, 0, 1024, 686);
    
    // Discover tab
    SYNVideosRootViewController *videosRootViewController = [[SYNVideosRootViewController alloc] initWithViewId:@"Videos"];
    videosRootViewController.tabViewController = [[SYNCategoriesTabViewController alloc] init];
    UINavigationController *videosRootNavigationViewController = [[UINavigationController alloc] initWithRootViewController: videosRootViewController];
    videosRootNavigationViewController.navigationBarHidden = TRUE;
    videosRootNavigationViewController.view.autoresizesSubviews = TRUE;
    videosRootNavigationViewController.view.frame = CGRectMake (0, 0, 1024, 686);
    
    
    // Search tab
    SYNVideosRootViewController *searchRootViewController = [[SYNVideosRootViewController alloc] initWithViewId:@"Videos"];
    searchRootViewController.tabViewController = [[SYNSearchTabViewController alloc] init];
    UINavigationController *searchRootNavigationViewController = [[UINavigationController alloc] initWithRootViewController: searchRootViewController];
    searchRootNavigationViewController.navigationBarHidden = TRUE;
    searchRootNavigationViewController.view.autoresizesSubviews = TRUE;
    searchRootNavigationViewController.view.frame = CGRectMake (0, 0, 1024, 686);
    
    // My Rockpack tab
    SYNYouRootViewController *youRootViewController = [[SYNYouRootViewController alloc] initWithViewId:@"You"];
    UINavigationController *youRootRootNavigationViewController = [[UINavigationController alloc] initWithRootViewController: youRootViewController];
    youRootRootNavigationViewController.navigationBarHidden = TRUE;
    youRootRootNavigationViewController.view.autoresizesSubviews = TRUE;
    youRootRootNavigationViewController.view.frame = CGRectMake (0, 0, 1024, 686);
    
    // Friends tab
    SYNFriendsRootViewController *friendsRootViewController = [[SYNFriendsRootViewController alloc] initWithViewId:@"Friends"];
    // TODO: Nest Friends Bar
    // Using new array syntax
    self.viewControllers = @[homeRootNavigationViewController,
                             channelsRootNavigationViewController,
                             videosRootNavigationViewController,
                             youRootRootNavigationViewController,
                             friendsRootViewController];
    
    self.searchViewController = searchRootNavigationViewController;

    
    // Set initial
    
    [self setSelectedIndex:2];
    
    
    
    
    // Set initial state
    self.didNotSwipeMessageInbox = TRUE;
    self.didNotSwipeShareMenu = TRUE;
    
    
    
    
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
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
	
    
    
    if(_selectedIndex == newSelectedIndex)
        return;
    
    
    _selectedIndex = newSelectedIndex;
    
    
    
    for (UIButton* tabButton in self.tabsViewContainer.subviews)
        tabButton.selected = NO;

    if(_selectedIndex < 0 || _selectedIndex > self.tabsViewContainer.subviews.count)
        return;
    
    
    UIButton* toButton = (UIButton *)self.tabsViewContainer.subviews[_selectedIndex];
    toButton.selected = TRUE;
    
    
    UIViewController *toViewController = (UIViewController*)self.viewControllers[_selectedIndex];
    
    
    
    [self performChangeFromController:_selectedViewController toController:toViewController animated:YES];
    
    
}



-(void)performChangeFromController:(UIViewController*)fromViewController toController:(UIViewController*)toViewController animated:(BOOL)animated
{
    
    [self.containerView addSubview:toViewController.view];
    
    if (animated)
    {
        self.view.userInteractionEnabled = NO;
        self.tabsViewContainer.userInteractionEnabled = NO;
      
        toViewController.view.alpha = 0.0f;
        
        [UIView animateWithDuration: kTabAnimationDuration
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^{
             fromViewController.view.alpha = 0.0f;
             toViewController.view.alpha = 1.0f;
                             
         } completion: ^(BOOL finished) {
             
             fromViewController.view.alpha = 0.0f;
             [fromViewController.view removeFromSuperview];
             self.view.userInteractionEnabled = YES;
             self.tabsViewContainer.userInteractionEnabled = YES;
             
         }];
    }
    else
    {
        [fromViewController.view removeFromSuperview];
        
    }
    
    _selectedViewController = toViewController;
    
}



// Use the tag index of the button (100 - 103) to calculate the button index

- (IBAction) tabButtonPressed: (UIButton *) sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNoteTabPressed object:self];
    
	[self setSelectedIndex: sender.tag - kBottomTabIndexOffset
                  animated: YES];
}


- (IBAction) recordAction: (UIButton*) button
{
    button.selected = !button.selected;
}


- (void) popoverControllerDidDismissPopover: (UIPopoverController *) popoverController
{
	// Any cleanup
    // self.notificationsButton.selected = FALSE;
}






- (void) popCurrentViewController: (id) sender
{
    UINavigationController *navVC = (UINavigationController *)self.selectedViewController;
    
    SYNAbstractViewController *abstractVC = (SYNAbstractViewController *)navVC.topViewController;
    
    [abstractVC animatedPopViewController];
}




-(void) showSearchViewControllerWithTerm:(NSString*)term
{
    [self performChangeFromController:self.selectedViewController toController:self.searchViewController animated:YES];
}

@end
