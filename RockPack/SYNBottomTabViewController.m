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
#import "SYNBottomTabViewController.h"
#import "SYNChannelsTopTabViewController.h"
#import "SYNDiscoverTopTabViewController.h"
#import "SYNFriendsViewController.h"
#import "SYNHomeTopTabViewController.h"
#import "SYNMovableView.h"
#import "SYNMyRockpackViewController.h"
#import "SYNVideoDB.h"
#import "SYNVideoDownloadEngine.h"
#import "UIFont+SYNFont.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <QuartzCore/QuartzCore.h>

@interface SYNBottomTabViewController () <UIGestureRecognizerDelegate,
                                          UITextViewDelegate>

@property (nonatomic, assign) BOOL didNotSwipe;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, assign) double lowPassResults;
@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, strong) AVAudioRecorder *avRecorder;
@property (nonatomic, strong) IBOutlet UIButton *cancelSearchButton;
@property (nonatomic, strong) IBOutlet UIButton *recordButton;
@property (nonatomic, strong) IBOutlet UIButton *rockieTalkieButton;
@property (nonatomic, strong) IBOutlet UIButton *writeMessageButton;
@property (nonatomic, strong) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) IBOutlet UIImageView *recordButtonGlowImageView;
@property (nonatomic, strong) IBOutlet UILabel *numberOfMessagesLabel;
@property (nonatomic, strong) IBOutlet UITextField *searchTextField;
@property (nonatomic, strong) IBOutlet UITextView *messagePlaceholderTextView;
@property (nonatomic, strong) IBOutlet UITextView *messageTextView;
@property (nonatomic, strong) IBOutlet UIView *rightSwipeOverlayView;
@property (nonatomic, strong) IBOutlet UIView *rockieTalkiePanelView;
@property (nonatomic, strong) NSTimer *levelTimer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeLeftRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRightRecognizer;
@property (nonatomic, weak) UIViewController *selectedViewController;
@property (strong, nonatomic) MKNetworkOperation *downloadOperation;
@property (strong, nonatomic) SYNVideoDownloadEngine *downloadEngine;
@property (weak, nonatomic) IBOutlet UIView *navControllerPlaceholderView;

@end

@implementation SYNBottomTabViewController

@synthesize selectedIndex = _selectedIndex;

// Initialise all the elements common to all 4 tabs

#pragma mark - View lifecycle
 	

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Wallpack tab
    SYNHomeTopTabViewController *wallPackViewController = [[SYNHomeTopTabViewController alloc] init];
    
    // Channels tab
    SYNChannelsTopTabViewController *channelsViewController = [[SYNChannelsTopTabViewController alloc] init];
    UINavigationController *channelsRootNavigationViewController = [[UINavigationController alloc] initWithRootViewController: channelsViewController];
    channelsRootNavigationViewController.navigationBarHidden = TRUE;
    channelsRootNavigationViewController.view.autoresizesSubviews = TRUE;
    channelsRootNavigationViewController.view.frame = CGRectMake (0, 0, 1024, 686);

    // Discover tab 
    SYNDiscoverTopTabViewController *discoverViewController = [[SYNDiscoverTopTabViewController alloc] init];
    
    // My Rockpack tab
    SYNMyRockpackViewController *myRockpackViewController = [[SYNMyRockpackViewController alloc] init];
    UINavigationController *myRockpackRootNavigationViewController = [[UINavigationController alloc] initWithRootViewController: myRockpackViewController];
    myRockpackRootNavigationViewController.navigationBarHidden = TRUE;
    myRockpackRootNavigationViewController.view.autoresizesSubviews = TRUE;
    myRockpackRootNavigationViewController.view.frame = CGRectMake (0, 0, 1024, 686);
    
    // Friends tab
    SYNFriendsViewController *friendsViewController = [[SYNFriendsViewController alloc] init];
    
    // Using new array syntax
    self.viewControllers = @[wallPackViewController,
                             channelsRootNavigationViewController,
                             discoverViewController,
                             myRockpackRootNavigationViewController,
                             friendsViewController];

    _selectedIndex = NSNotFound;
    
    self.selectedViewController = discoverViewController;
    
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
    self.swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget: self
                                                                     action: @selector(swipeRockieTalkieRight:)];
    
    [self.swipeRightRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer: self.swipeRightRecognizer];
    
    // We need this to check that we can swipe
    self.swipeRightRecognizer.delegate = self;
    
    // Left swipe
    self.swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget: self
                                                                    action: @selector(swipeRockieTalkieLeft:)];
    
    [self.swipeLeftRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.rockieTalkiePanelView addGestureRecognizer: self.swipeLeftRecognizer];
    
    // Set initial state
    self.rockieTalkiePanelView.userInteractionEnabled = TRUE;
    self.didNotSwipe = TRUE;
    
    // Setup number of messages number font in title bar
    self.numberOfMessagesLabel.font = [UIFont boldRockpackFontOfSize: 17.0f];
    
    // Setup rockie-talkie message view
    self.messageTextView.font = [UIFont rockpackFontOfSize: 15.0f];
    self.messageTextView.delegate = self;
    
    // Placeholder for rockie-talkie message view to show message only when no text in main view
    self.messagePlaceholderTextView.font = [UIFont rockpackFontOfSize: 15.0f];
    
    self.backgroundImageView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundGeneric"]];
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
//            toViewController.view.frame = self.navControllerPlaceholderView.bounds;
            
            [self.view insertSubview: toViewController.view aboveSubview: self.backgroundImageView];
		}
		else if (animated)
		{
			self.view.userInteractionEnabled = NO;
            
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
    self.searchTextField.text = @"";
    
	[self setSelectedIndex: sender.tag - kBottomTabIndexOffset
                  animated: YES];
}


#pragma mark - Rockie-Talkie gesture handlers

// Swipe rockie-talkie off screen
- (void) swipeRockieTalkieLeft: (UISwipeGestureRecognizer *) swipeGesture
{
    if (!self.didNotSwipe)
    {
        self.didNotSwipe = TRUE;
        
        // Stop recording
        [self endRecording];
    
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
             CGRect rockieTalkiePanelFrame = self.rockieTalkiePanelView.frame;
             rockieTalkiePanelFrame.origin.x = -495;
             self.rockieTalkiePanelView.frame =  rockieTalkiePanelFrame;

         }
                         completion: ^(BOOL finished)
         {
             // Set the button to the appropriate state
             self.rockieTalkieButton.selected = FALSE;
         }];
    }
}


// Swipe rockie-talkie onto screen
- (void) swipeRockieTalkieRight: (UISwipeGestureRecognizer *) swipeGesture
{
    if (self.didNotSwipe)
    {
        self.didNotSwipe = FALSE;

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
             CGRect rockieTalkiePanelFrame = self.rockieTalkiePanelView.frame;
             rockieTalkiePanelFrame.origin.x = 0;
             self.rockieTalkiePanelView.frame =  rockieTalkiePanelFrame;
             
         }
                         completion: ^(BOOL finished)
         {
             // Set the button to the appropriate state
             self.rockieTalkieButton.selected = TRUE;
         }];
    }
}


- (IBAction) clearSearchField: (id) sender
{
    self.searchTextField.text = @"";
    
    [self.searchTextField resignFirstResponder];
}


- (IBAction) recordAction: (UIButton*) button
{
    button.selected = !button.selected;
}


- (IBAction) rockieTalkieAction: (UIButton*) button
{
    button.selected = !button.selected;
    
    if (button.selected)
    {
        // Need to slide rockie talkie out
        [self swipeRockieTalkieRight: nil];
    }
    else
    {
        // Need to slide rockie talkie back in
        [self swipeRockieTalkieLeft: nil];
    }
}


- (IBAction) recordTouchDown
{
    [self startRecording];
}


- (IBAction) recordTouchUp
{
    [self endRecording];
}


#pragma mark - Rockie-talkie recording actions

- (void) startRecording
{
    // Show button 'volume glow'
    self.recordButtonGlowImageView.hidden = FALSE;
    
    AVAudioSession *avSession = [AVAudioSession sharedInstance];
	
	[avSession setCategory: AVAudioSessionCategoryPlayAndRecord
					 error: nil];
	
	[avSession setActive: YES
				   error: nil];
    
    // Don't actually make a real recording (send to /dev/null)
    NSURL *url = [NSURL fileURLWithPath: @"/dev/null"];
    
    // Mono, 44.1kHz should be fine
  	NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    
  	NSError *error;
    
  	self.avRecorder = [[AVAudioRecorder alloc] initWithURL: url
                                                settings: settings
                                                   error: &error];
    
  	if (self.avRecorder)
    {
  		[self.avRecorder prepareToRecord];
  		self.avRecorder.meteringEnabled = YES;
  		[self.avRecorder record];
        
		self.levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.03
                                                           target: self
                                                         selector: @selector(levelTimerCallback:)
                                                         userInfo: nil
                                                          repeats: YES];
  	}
    else
    {
  		DebugLog(@"%@", [error description]);
    }
}


- (void) endRecording
{
    [self.avRecorder pause];
    self.avRecorder = nil;
    [self.levelTimer invalidate], self.levelTimer = nil;
    
    // Show button 'volume glow' and reset it's scale
    self.recordButtonGlowImageView.hidden = TRUE;
    [self.recordButtonGlowImageView setTransform: CGAffineTransformMakeScale(1.0f, 1.0f)];
}


- (void) levelTimerCallback: (NSTimer *) timer
{
    [self.avRecorder updateMeters];
    
    // Convert from dB to linear
	double averagePowerForChannel = pow(10, (0.05 * [self.avRecorder averagePowerForChannel: 0]));
    
    DebugLog (@"Power %f", averagePowerForChannel);
    
    // And clip to 0 > x > 1
    if (averagePowerForChannel < 0.0)
    {
        averagePowerForChannel = 0.0f;
    }
    else if (averagePowerForChannel > 1.0)
    {
        averagePowerForChannel = 1.0f;
    }
    
    // Adjust size of glow, Adding 1 for the scale factor
    double scaleFactor = 1.0f + averagePowerForChannel;

    [self.recordButtonGlowImageView setTransform: CGAffineTransformMakeScale(scaleFactor, scaleFactor)];
}

#pragma mark - TextView delegate methods

- (void) textViewDidChange: (UITextView *) textView
{
    if (self.messageTextView.text.length == 0)
    {
        self.messagePlaceholderTextView.hidden = NO;
    }
    else
    {
        self.messagePlaceholderTextView.hidden = YES;
    }
}

- (BOOL) textView: (UITextView *) textView
         shouldChangeTextInRange: (NSRange) range
         replacementText: (NSString *) text
{
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
    }
    
    return YES;
}


- (void) textViewDidBeginEditing: (UITextView *) textView
{
    [textView setText: @""];
}


- (void) textViewDidEndEditing: (UITextView * )textView
{
    self.writeMessageButton.selected = FALSE;
    
#ifdef SOUND_ENABLED
    // Play a suitable sound
    NSString *soundPath = [[NSBundle mainBundle] pathForResource: @"Mail Sent"
                                                          ofType: @"aif"];
    
    NSURL *soundURL = [NSURL fileURLWithPath: soundPath];
    SystemSoundID sound;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
    AudioServicesPlaySystemSound(sound);
#endif
}

#pragma mark - Write message actions

- (IBAction) writeMessage: (UIButton *) button
{
    button.selected = !button.selected;
    
    if (button.selected)
    {
        [self.messageTextView becomeFirstResponder];
    }
    else
    {
        [self.messageTextView resignFirstResponder];
    }
}


#pragma mark - Gesture recognizers

- (BOOL) gestureRecognizer: (UIGestureRecognizer *) gestureRecognizer
        shouldReceiveTouch: (UITouch *) touch
{
    if (self.rockieTalkieButton.selected == TRUE && gestureRecognizer == self.swipeRightRecognizer)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}


- (BOOL) gestureRecognizerShouldBegin: (UIGestureRecognizer *) gestureRecognizer
{
    if ([SYNMovableView allowDragging]  == TRUE && gestureRecognizer == self.swipeRightRecognizer)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
