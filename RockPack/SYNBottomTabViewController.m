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
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, assign) double lowPassResults;
@property (nonatomic, assign, getter = isShowingBackButton) BOOL showingBackButton;
@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, strong) UIViewController* searchViewController;

@property (nonatomic, strong) IBOutlet UIButton *recordButton;
@property (nonatomic, strong) IBOutlet UIButton *writeMessageButton;

@property (nonatomic, strong) IBOutlet UITextView *messagePlaceholderTextView;

@property (nonatomic, strong) IBOutlet UIView* containerView;

@property (nonatomic, strong) UIPopoverController *actionButtonPopover;

@property (nonatomic, weak) UIViewController *selectedViewController;
@property (strong, nonatomic) MKNetworkOperation *downloadOperation;
@property (strong, nonatomic) SYNVideoDownloadEngine *downloadEngine;

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

    _selectedIndex = NSNotFound;
    
    self.selectedViewController = videosRootNavigationViewController;
    
    
    
    
    // Set initial state
    self.didNotSwipeMessageInbox = TRUE;
    self.didNotSwipeShareMenu = TRUE;
    
    
    
    // Placeholder for rockie-talkie message view to show message only when no text in main view
    self.messagePlaceholderTextView.font = [UIFont rockpackFontOfSize: 15.0f];
    
    
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

- (void) setSelectedIndex: (NSUInteger) newSelectedIndex
{
	[self setSelectedIndex: newSelectedIndex
                  animated: NO];
}


// Set the selected tab (with animation if required)

- (void) setSelectedIndex: (NSUInteger) newSelectedIndex
                 animated: (BOOL) animated
{
	
    if(newSelectedIndex > [self.viewControllers count]) {
        DebugLog(@"WARNING: Selected index %i is out of bounds", newSelectedIndex);
        return;
    }
    
	if (![self isViewLoaded]) {
		_selectedIndex = newSelectedIndex;
        return;
	}
    
    if(_selectedIndex == newSelectedIndex) {
        return;
    }
    
    UIViewController *fromViewController;
    UIViewController *toViewController;
    
    if (_selectedIndex != NSNotFound)
    {
        UIButton *fromButton = (UIButton *)[self.view viewWithTag: kBottomTabIndexOffset + _selectedIndex];
        fromButton.selected = FALSE;
        fromViewController = self.selectedViewController;
    }
    
    _selectedIndex = newSelectedIndex;
    
    UIButton *toButton;
    if (_selectedIndex != NSNotFound)
    {
        toButton = (UIButton *)[self.view viewWithTag: kBottomTabIndexOffset + _selectedIndex];
        toButton.selected = TRUE;
        toViewController = self.selectedViewController;
    }
    
    if (toViewController == nil)  // don't animate
    {
        [fromViewController.view removeFromSuperview];
    }
    
    
    [self performChangeFromController:fromViewController toController:toViewController animated:animated];
    
    
    // We need to see if we need to hide/show the back button for the new view controller
    
    if ([toViewController isKindOfClass: [UINavigationController class]] &&
        [[(UINavigationController *)toViewController viewControllers] count] > 1) {
        
        //[self showBackButton];
        //[[NSNotificationCenter defaultCenter] postNotificationName:kNoteBackButtonShow object:self];
    }
    else
    {
        //[self hideBackButton];
        //[[NSNotificationCenter defaultCenter] postNotificationName:kNoteBackButtonShow object:self];
    }
}


-(void)performChangeFromController:(UIViewController*)fromViewController toController:(UIViewController*)toViewController animated:(BOOL)animated
{
    
    [self.containerView addSubview:toViewController.view];
    
    if (animated)
    {
        self.view.userInteractionEnabled = NO;
      
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
             
         }];
    }
    else
    {
        [fromViewController.view removeFromSuperview];
        
    }
    
}


// Return the currently selected view controller

- (UIViewController *) selectedViewController
{
	if (self.selectedIndex != NSNotFound)
        return self.viewControllers [self.selectedIndex];
    
	return nil;
}





#pragma mark - Tab Selection

// Set the selected tab of a particular view controller (with animation if required)

- (void) setSelectedViewController: (UIViewController *) newSelectedViewController
                          animated: (BOOL) animated;
{
	NSUInteger index = [self.viewControllers indexOfObject: newSelectedViewController];
    
	if (index != NSNotFound)
    {
		[self setSelectedIndex: index
                      animated: animated];
    }
}


// Use the tag index of the button (100 - 103) to calculate the button index

- (IBAction) tabButtonPressed: (UIButton *) sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNoteTabPressed object:self];
    
	[self setSelectedIndex: sender.tag - kBottomTabIndexOffset
                  animated: YES];
}

// Set the selected tab of a particular view controller (with no animation)

- (void) setSelectedViewController: (UIViewController *) newSelectedViewController
{
	[self setSelectedViewController: newSelectedViewController
                           animated: NO];
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
