//
//  SYNBottomTabViewController.m
//  RockPack
//
//  Created by Nick Banks on 13/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "AudioToolbox/AudioToolbox.h"
#import "SYNBottomTabViewController.h"
#import "SYNDiscoverTopTabViewController.h"
#import "SYNFriendsViewController.h"
#import "SYNMyRockPackViewController.h"
#import "SYNWallPackTopTabViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNBottomTabViewController ()

@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, weak) UIViewController *selectedViewController;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, strong) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) IBOutlet UIView *rockieTalkiePanel;
@property (nonatomic, strong) IBOutlet UIButton *cancelSearchButton;
@property (nonatomic, strong) IBOutlet UITextField *searchField;
@property (nonatomic, assign) BOOL didNotSwipe;

@end

@implementation SYNBottomTabViewController

@synthesize selectedIndex = _selectedIndex;

// Initialise all the elements common to all 4 tabs

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Setup our four sub-viewcontrollers, one for each tab
    SYNWallPackTopTabViewController *wallPackViewController = [[SYNWallPackTopTabViewController alloc] init];
    SYNDiscoverTopTabViewController *discoverViewController = [[SYNDiscoverTopTabViewController alloc] init];
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
    
    // Add swipe recoginisers for Rockie-Talkie
    // Right swipe
    UISwipeGestureRecognizer *swipeRightRecognizer;
    swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget: self
                                                                     action: @selector(swipeRockieTalkieRight:)];
    
    [swipeRightRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.rockieTalkiePanel addGestureRecognizer: swipeRightRecognizer];
    
    // Left swipe
    UISwipeGestureRecognizer *swipeLeftRecognizer;
    swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget: self
                                                                    action: @selector(swipeRockieTalkieLeft:)];
    
    [swipeLeftRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.rockieTalkiePanel addGestureRecognizer: swipeLeftRecognizer];
    
    // Set initial state
    self.rockieTalkiePanel.userInteractionEnabled = TRUE;
    self.didNotSwipe = TRUE;
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(selectMyRockPackTab)
                                                 name: @"SelectMyRockPackTab"
                                               object: nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    // Start on discovery screenNewSlideIn
    self.selectedIndex = 1;
}

#pragma mark - Tab & Container switching mechanism

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
		_selectedIndex = 0;
    
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
//			[self.view addSubview: toViewController.view];
            [self.view insertSubview: toViewController.view aboveSubview: self.backgroundImageView];
		}
		else if (animated)
		{
			self.view.userInteractionEnabled = NO;
//            toViewController.view.alpha = 0.0f;
//            [self.view insertSubview: toViewController.view aboveSubview: self.backgroundImageView];
//			[self transitionFromViewController: fromViewController
//                              toViewController: toViewController
//                                      duration: kTabAnimationDuration
//                                       options: UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionCurveEaseOut
//                                    animations: ^
//             {
//                 fromViewController.view.alpha = 0.0f;
//                 toViewController.view.alpha = 1.0f;
//             }
//                                    completion: ^(BOOL finished)
//             {
//                 fromViewController.view.alpha = 0.0f;
//                 toViewController.view.alpha = 1.0f;
//                 [fromViewController.view removeFromSuperview];
//                 self.view.userInteractionEnabled = YES;
//             }];
            
            // Set new alpha to 0
            toViewController.view.alpha = 0.0f;
            
            [self.view insertSubview: toViewController.view aboveSubview: self.backgroundImageView];

            [UIView animateWithDuration: kTabAnimationDuration
                                  delay: 0.0f
                                options: UIViewAnimationOptionCurveEaseInOut
                             animations: ^
                                         {
                                             fromViewController.view.alpha = 0.0f;
                                             toViewController.view.alpha = 1.0f;
                                         }
                             completion: ^(BOOL finished)
                                         {
                                             fromViewController.view.alpha = 0.0f;
                                             [fromViewController.view removeFromSuperview];
                                             self.view.userInteractionEnabled = YES;
                                         }];
		}
		else  // not animated
		{
			[fromViewController.view removeFromSuperview];
//			[self.view addSubview: toViewController.view];
            [self.view insertSubview: toViewController.view aboveSubview: self.backgroundImageView];
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
    self.searchField.text = @"";
    
	[self setSelectedIndex: sender.tag - kBottomTabIndexOffset
                  animated: YES];
}


#pragma mark - Rockie-Talkie gesture handlers

-(void) swipeRockieTalkieLeft: (UISwipeGestureRecognizer *) swipeGesture
{
    if (self.didNotSwipe)
    {
        self.didNotSwipe = FALSE;
        
#ifdef SOUND_ENABLED
        // Play a suitable sound
        NSString *soundPath = [[NSBundle mainBundle] pathForResource: @"NewSlideOut"
                                                               ofType: @"aif"];
        
        NSURL *soundURL = [NSURL fileURLWithPath: soundPath];
        SystemSoundID sound;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
        AudioServicesPlaySystemSound(sound);
#endif
        
        // Animate the view out onto the screen
        [UIView animateWithDuration: kRockieTalkieAnimationDuration
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^
         {
             CGRect rockieTalkiePanelFrame = self.rockieTalkiePanel.frame;
             rockieTalkiePanelFrame.origin.x = 425;
             self.rockieTalkiePanel.frame =  rockieTalkiePanelFrame;

         }
                         completion: ^(BOOL finished)
         {
             CGRect rockieTalkiePanelFrame = self.rockieTalkiePanel.frame;
             rockieTalkiePanelFrame.origin.x = 425;
             self.rockieTalkiePanel.frame =  rockieTalkiePanelFrame;
         }];
    }
}


- (void) swipeRockieTalkieRight: (UISwipeGestureRecognizer *) swipeGesture
{
    if (!self.didNotSwipe)
    {
        self.didNotSwipe = TRUE;

#ifdef SOUND_ENABLED
        // Play a suitable sound
        NSString *soundPath = [[NSBundle mainBundle] pathForResource: @"NewSlideIn"
                                                              ofType: @"aif"];
        
        NSURL *soundURL = [NSURL fileURLWithPath: soundPath];
        SystemSoundID sound;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
        AudioServicesPlaySystemSound(sound);
#endif
        
        // Animate the view out onto the screen
        [UIView animateWithDuration: kRockieTalkieAnimationDuration
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^
         {
             CGRect rockieTalkiePanelFrame = self.rockieTalkiePanel.frame;
             rockieTalkiePanelFrame.origin.x = 884;
             self.rockieTalkiePanel.frame =  rockieTalkiePanelFrame;
             
         }
                         completion: ^(BOOL finished)
         {
             CGRect rockieTalkiePanelFrame = self.rockieTalkiePanel.frame;
             rockieTalkiePanelFrame.origin.x = 884;
             self.rockieTalkiePanel.frame =  rockieTalkiePanelFrame;
         }];
    }
}

- (IBAction) clearSearchField: (id) sender
{
    self.searchField.text = @"";
    
    [self.searchField resignFirstResponder];
}

- (IBAction) recordAction: (UIButton*) button
{
    button.selected = !button.selected;
}

- (void) selectMyRockPackTab
{
    [self setSelectedIndex: 2];
}

@end
