//
//  SYNBottomTabViewController.m
//  RockPack
//
//  Created by Nick Banks on 13/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNBottomTabViewController.h"
#import "SYNWallPackViewController.h"
#import "SYNDiscoverViewController.h"
#import "SYNMyRockPackViewController.h"
#import "SYNFriendsViewController.h"
#import "AppContants.h"

@interface SYNBottomTabViewController ()

@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, weak) UIViewController *selectedViewController;
@property (nonatomic, assign) NSUInteger selectedIndex;

@end

@implementation SYNBottomTabViewController

@synthesize selectedIndex = _selectedIndex;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Setup our four sub-viewcontrollers, one for each tab
    SYNWallPackViewController *wallPackViewController = [[SYNWallPackViewController alloc] init];
    SYNDiscoverViewController *discoverViewController = [[SYNDiscoverViewController alloc] init];
    SYNMyRockPackViewController *myRockPackViewController = [[SYNMyRockPackViewController alloc] init];
    SYNFriendsViewController *friendsViewController = [[SYNFriendsViewController alloc] init];
    
    // Using new array syntax
    self.viewControllers = @[wallPackViewController, discoverViewController, myRockPackViewController, friendsViewController];

    _selectedIndex = NSNotFound;
    
    self.selectedViewController = wallPackViewController;
    
    // Now fade in gracefully from splash screen (do this here as opposed to the app delegate so that the orientation is known)
    UIImageView *splashView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 1024, 748)];
    splashView.image = [UIImage imageNamed:  @"Default-Landscape.png"];
	[self.view addSubview: splashView];
    
    [UIView animateWithDuration: kSplashAnimationDuration
                          delay: kSplashViewDuration
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         splashView.alpha = 0.0f;
     }
                     completion: ^(BOOL finished)
     {
         splashView.alpha = 0.0f;
         [splashView removeFromSuperview];
     }];
}


- (void) setViewControllers: (NSArray *) newViewControllers
{
	NSAssert([newViewControllers count] >= 2, @"MHTabBarController requires at least two view controllers");
    
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
		_selectedIndex = newIndex;
	else if (newIndex < [_viewControllers count])
		_selectedIndex = newIndex;
	else
		_selectedIndex = 0;
    
	// Add the new child view controllers.
	for (UIViewController *viewController in _viewControllers)
	{
		[self addChildViewController: viewController];
		[viewController didMoveToParentViewController: self];
	}
}


- (void) setSelectedIndex: (NSUInteger) newSelectedIndex
{
	[self setSelectedIndex: newSelectedIndex
                  animated: NO];
}


- (void) setSelectedIndex: (NSUInteger) newSelectedIndex
                 animated: (BOOL) animated
{
	NSAssert(newSelectedIndex < [self.viewControllers count], @"View controller index out of bounds");
    
	if (![self isViewLoaded])
	{
		_selectedIndex = newSelectedIndex;
	}
	else if (_selectedIndex != newSelectedIndex)
	{
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
		else if (fromViewController == nil)  // don't animate
		{
            //			toViewController.view.frame = self.view.bounds;
			[self.view addSubview: toViewController.view];
		}
		else if (animated)
		{
			self.view.userInteractionEnabled = NO;
            
			[self transitionFromViewController: fromViewController
                              toViewController: toViewController
                                      duration: 0.3
                                       options: UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionCurveEaseOut
                                    animations: ^
             {
                 fromViewController.view.alpha = 0.0f;
                 toViewController.view.alpha = 1.0f;
             }
                                    completion: ^(BOOL finished)
             {
                 fromViewController.view.alpha = 0.0f;
                 toViewController.view.alpha = 1.0f;
                 [fromViewController.view removeFromSuperview];
                 self.view.userInteractionEnabled = YES;
             }];
		}
		else  // not animated
		{
			[fromViewController.view removeFromSuperview];
			[self.view addSubview: toViewController.view];
		}
	}
}


- (UIViewController *) selectedViewController
{
	if (self.selectedIndex != NSNotFound)
    {
		return self.viewControllers [self.selectedIndex];
    }
	else
    {
		return nil;
    }
}


- (void) setSelectedViewController: (UIViewController *) newSelectedViewController
{
	[self setSelectedViewController: newSelectedViewController
                           animated: NO];
}


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
	[self setSelectedIndex: sender.tag - kBottomTabIndexOffset
                  animated: YES];
}



@end
