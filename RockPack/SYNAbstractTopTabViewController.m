//
//  SYNAbstractTopTabViewController.m
//  RockPack
//
//  Created by Nick Banks on 14/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppContants.h"
#import "SYNAbstractTopTabViewController.h"
#import "SYNTabImageView.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNAbstractTopTabViewController ()

@property (nonatomic, strong) SYNTabImageView *topTabView;
@property (nonatomic, strong) UIImageView *topTabHighlightedView;
@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, weak) UIViewController *selectedViewController;
@property (nonatomic, assign) NSUInteger selectedIndex;

@end

@implementation SYNAbstractTopTabViewController

@synthesize selectedIndex = _selectedIndex;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    _selectedIndex = NSNotFound;
    
    // Underlying (unselected) tab images
    self.topTabView = [[SYNTabImageView alloc] initWithFrame: CGRectMake (0, 33, 1024, 65)
                                                touchHandler: ^(CGPoint touchPoint)
                                                              {
                                                                  [self tabButtonTouched: touchPoint];
                                                              }];
    
    self.topTabView.contentMode  = UIViewContentModeLeft;
    self.topTabView.image = [UIImage imageNamed: @"TabTop.png"];
    self.topTabView.userInteractionEnabled = YES;
    
    [self.view addSubview: self.topTabView];
    
    // Highlighted tab images to craftily overlay (by using a superview to clip)
    self.topTabHighlightedView = [[UIImageView alloc] initWithFrame: CGRectMake (0, 0, 1024, 65)];
    self.topTabHighlightedView.contentMode  = UIViewContentModeLeft;
    self.topTabHighlightedView.image = [UIImage imageNamed: @"TabTopHighlighted.png"];
}


// Highlight selected tab by revealing a portion of the hightlight image corresponing to the active tab

- (void) highlightTab: (int) tabIndex
{
    CGFloat tabWidth = 1024.0f / kTopTabCount;
    
    // Work our where to show our highlight
    float startX = tabIndex * tabWidth;

    UIView *containerView = [[UIImageView alloc] initWithFrame: CGRectMake (startX , 33, tabWidth, 65)];

    // Update the meter view width
    CGRect tabBounds = self.topTabHighlightedView.frame;
    tabBounds.origin.x = - startX;
    self.topTabHighlightedView.frame = tabBounds;
    
    containerView.clipsToBounds = YES;
    [containerView addSubview: self.topTabHighlightedView];
    [self.view addSubview: containerView];
}

// Add the four tab view controllers as sub-view controllers of this view controller

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
		_selectedIndex = NSNotFound;
    
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
			fromViewController = self.selectedViewController;
		}
        
		_selectedIndex = newSelectedIndex;
        
		if (_selectedIndex != NSNotFound)
		{
			[self highlightTab: newSelectedIndex];
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
                                      duration: kTabAnimationDuration
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
                 self.topTabView.userInteractionEnabled = YES;
             }];
		}
		else  // not animated
		{
			[fromViewController.view removeFromSuperview];
			[self.view addSubview: toViewController.view];
		}
	}
}


// Return the currently selected view controller

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


// Set the selected tab of a particular view controller (with no animation)

- (void) setSelectedViewController: (UIViewController *) newSelectedViewController
{
	[self setSelectedViewController: newSelectedViewController
                           animated: NO];
}


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
	[self setSelectedIndex: sender.tag - kBottomTabIndexOffset
                  animated: YES];
}

- (IBAction) tabButtonTouched: (CGPoint) touchPoint
{
    CGFloat tabWidth = 1024.0f / kTopTabCount;
    
    int tab = trunc(touchPoint.x / tabWidth);
    
    self.topTabView.userInteractionEnabled = NO;
    
	[self setSelectedIndex: tab
                  animated: YES];
}

@end
