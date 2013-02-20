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
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <QuartzCore/QuartzCore.h>

@interface SYNBottomTabViewController () <UIGestureRecognizerDelegate,
                                          UIPopoverControllerDelegate,
                                          UITextViewDelegate>

@property (nonatomic, assign) BOOL didNotSwipeMessageInbox;
@property (nonatomic, assign) BOOL didNotSwipeShareMenu;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, assign) double lowPassResults;
@property (nonatomic, assign, getter = isShowingBackButton) BOOL showingBackButton;
@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, strong) AVAudioRecorder *avRecorder;
@property (nonatomic, strong) IBOutlet UIButton *cancelSearchButton;
@property (nonatomic, strong) IBOutlet UIButton *messageInboxButton;
@property (nonatomic, strong) IBOutlet UIButton *notificationsButton;
@property (nonatomic, strong) IBOutlet UIButton *recordButton;
@property (nonatomic, strong) IBOutlet UIButton *writeMessageButton;
@property (nonatomic, strong) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) IBOutlet UIImageView *recordButtonGlowImageView;
@property (nonatomic, strong) IBOutlet UILabel *numberOfMessagesLabel;
@property (nonatomic, strong) IBOutlet UILabel *numberOfNotificationsLabel;
@property (nonatomic, strong) IBOutlet UITextField *searchTextField;
@property (nonatomic, strong) IBOutlet UITextView *messagePlaceholderTextView;
@property (nonatomic, strong) IBOutlet UITextView *messageTextView;
@property (nonatomic, strong) IBOutlet UIView *messageInboxView;
@property (nonatomic, strong) IBOutlet UIView *shareMenuView;
@property (nonatomic, strong) IBOutlet UIView *topButtonView;
@property (nonatomic, strong) NSTimer *levelTimer;
@property (nonatomic, strong) UIPopoverController *actionButtonPopover;
@property (nonatomic, strong) UISwipeGestureRecognizer *messageInboxSwipeLeftRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *shareMenuSwipeLeftRecognizer;
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
    SYNHomeRootViewController *homeRootViewController = [[SYNHomeRootViewController alloc] init];
    UINavigationController *homeRootNavigationViewController = [[UINavigationController alloc] initWithRootViewController: homeRootViewController];
    homeRootNavigationViewController.navigationBarHidden = TRUE;
    homeRootNavigationViewController.view.autoresizesSubviews = TRUE;
    homeRootNavigationViewController.view.frame = CGRectMake (0, 0, 1024, 784);
    
    // Channels tab
    SYNChannelsRootViewController *channelsRootViewController = [[SYNChannelsRootViewController alloc] init];
    channelsRootViewController.tabViewController = [[SYNCategoriesTabViewController alloc] init];
    UINavigationController *channelsRootNavigationViewController = [[UINavigationController alloc] initWithRootViewController: channelsRootViewController];
    channelsRootNavigationViewController.navigationBarHidden = TRUE;
    channelsRootNavigationViewController.view.autoresizesSubviews = TRUE;
    channelsRootNavigationViewController.view.frame = CGRectMake (0, 0, 1024, 686);
    
    // Discover tab
    SYNVideosRootViewController *videosRootViewController = [[SYNVideosRootViewController alloc] init];
    videosRootViewController.tabViewController = [[SYNCategoriesTabViewController alloc] init];
    UINavigationController *videosRootNavigationViewController = [[UINavigationController alloc] initWithRootViewController: videosRootViewController];
    videosRootNavigationViewController.navigationBarHidden = TRUE;
    videosRootNavigationViewController.view.autoresizesSubviews = TRUE;
    videosRootNavigationViewController.view.frame = CGRectMake (0, 0, 1024, 686);
    
    
    // Search tab
    SYNVideosRootViewController *searchRootViewController = [[SYNVideosRootViewController alloc] init];
    searchRootViewController.tabViewController = [[SYNSearchTabViewController alloc] init];
    UINavigationController *searchRootNavigationViewController = [[UINavigationController alloc] initWithRootViewController: videosRootViewController];
    searchRootNavigationViewController.navigationBarHidden = TRUE;
    searchRootNavigationViewController.view.autoresizesSubviews = TRUE;
    searchRootNavigationViewController.view.frame = CGRectMake (0, 0, 1024, 686);
    
    // My Rockpack tab
    SYNYouRootViewController *youRootViewController = [[SYNYouRootViewController alloc] init];
    UINavigationController *youRootRootNavigationViewController = [[UINavigationController alloc] initWithRootViewController: youRootViewController];
    youRootRootNavigationViewController.navigationBarHidden = TRUE;
    youRootRootNavigationViewController.view.autoresizesSubviews = TRUE;
    youRootRootNavigationViewController.view.frame = CGRectMake (0, 0, 1024, 686);
    
    // Friends tab
    SYNFriendsRootViewController *friendsRootViewController = [[SYNFriendsRootViewController alloc] init];
    // TODO: Nest Friends Bar
    // Using new array syntax
    self.viewControllers = @[homeRootNavigationViewController,
                             channelsRootNavigationViewController,
                             videosRootNavigationViewController,
                             youRootRootNavigationViewController,
                             friendsRootViewController];

    _selectedIndex = NSNotFound;
    
    self.selectedViewController = videosRootNavigationViewController;
    
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
                                                                     action: @selector(slideMessageInboxRight:)];
    
    [self.swipeRightRecognizer setDirection: UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer: self.swipeRightRecognizer];
    
    // We need this to check that we can swipe
    self.swipeRightRecognizer.delegate = self;
    
    // Left swipe on message inbox
    self.messageInboxSwipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget: self
                                                                    action: @selector(slideMessageInboxLeft:)];
    
    [self.messageInboxSwipeLeftRecognizer setDirection: UISwipeGestureRecognizerDirectionLeft];
    [self.messageInboxView addGestureRecognizer: self.messageInboxSwipeLeftRecognizer];
    
    // Left swipe on share menu 
    self.shareMenuSwipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget: self
                                                                                     action: @selector(slideShareMenuLeft:)];
    
    [self.shareMenuSwipeLeftRecognizer setDirection: UISwipeGestureRecognizerDirectionLeft];
    [self.shareMenuView addGestureRecognizer: self.shareMenuSwipeLeftRecognizer];
    
    // Set initial state
    self.messageInboxView.userInteractionEnabled = TRUE;
    self.didNotSwipeMessageInbox = TRUE;
    self.didNotSwipeShareMenu = TRUE;
    
    // Setup number of messages number font in title bar
    self.numberOfMessagesLabel.font = [UIFont boldRockpackFontOfSize: 17.0f];
    
    // Setup number of messages number font in title bar
    self.numberOfNotificationsLabel.font = [UIFont boldRockpackFontOfSize: 17.0f];
    
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
        
        // We need to see if we need to hide/show the back button for the new view controller
        
        if ([toViewController isKindOfClass: [UINavigationController class]] && [[(UINavigationController *)toViewController viewControllers] count] > 1)
        {
            [self showBackButton];
        }
        else
        {
            [self hideBackButton];
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


#pragma mark - Side menu gesture handlers

// Swipe rockie-talkie off screen
- (void) slideMessageInboxLeft: (UISwipeGestureRecognizer *) swipeGesture
{
    if (!self.didNotSwipeMessageInbox)
    {
        self.didNotSwipeMessageInbox = TRUE;
        
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
             CGRect messageInboxViewFrame = self.messageInboxView.frame;
             messageInboxViewFrame.origin.x = -495;
             self.messageInboxView.frame =  messageInboxViewFrame;

         }
                         completion: ^(BOOL finished)
         {
             // Set the button to the appropriate state
             self.messageInboxButton.selected = FALSE;
         }];
    }
}


// Swipe rockie-talkie onto screen
- (void) slideMessageInboxRight: (UISwipeGestureRecognizer *) swipeGesture
{
    if (self.didNotSwipeMessageInbox)
    {
        self.didNotSwipeMessageInbox = FALSE;
        
        if (self.didNotSwipeShareMenu == FALSE)
        {
            [self slideShareMenuLeft: nil];
        }

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
             CGRect messageInboxViewFrame = self.messageInboxView.frame;
             messageInboxViewFrame.origin.x = 0;
             self.messageInboxView.frame =  messageInboxViewFrame;
             
         }
                         completion: ^(BOOL finished)
         {
             // Set the button to the appropriate state
             self.messageInboxButton.selected = TRUE;
         }];
    }
}

- (void) toggleShareMenu
{
    if (self.didNotSwipeShareMenu == TRUE)
    {
        [self slideShareMenuRight: nil];
    }
    else
    {
        [self slideShareMenuLeft: nil];
    }
}

// Swipe rockie-talkie off screen
- (void) slideShareMenuLeft: (UISwipeGestureRecognizer *) swipeGesture
{
    if (!self.didNotSwipeShareMenu)
    {
        self.didNotSwipeShareMenu = TRUE;
        
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
             CGRect shareMenuViewFrame = self.shareMenuView.frame;
             shareMenuViewFrame.origin.x = -495;
             self.shareMenuView.frame =  shareMenuViewFrame;
             
         }
                         completion: ^(BOOL finished)
         {
             // Set the button to the appropriate state
//             self.messageInboxButton.selected = FALSE;
         }];
    }
}


// Swipe rockie-talkie onto screen
- (void) slideShareMenuRight: (UISwipeGestureRecognizer *) swipeGesture
{
    if (self.didNotSwipeShareMenu)
    {
        self.didNotSwipeShareMenu = FALSE;
        
        if (self.didNotSwipeMessageInbox == FALSE)
        {
            [self slideMessageInboxLeft: nil];
        }
        
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
             CGRect shareMenuViewFrame = self.shareMenuView.frame;
             shareMenuViewFrame.origin.x = 0;
             self.shareMenuView.frame =  shareMenuViewFrame;
             
         }
                         completion: ^(BOOL finished)
         {
             // Set the button to the appropriate state
//             self.messageInboxButton.selected = TRUE;
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


- (IBAction) userTouchedInboxButton: (UIButton*) button
{
    button.selected = !button.selected;
    
    if (button.selected)
    {
        // Need to slide rockie talkie out
        [self slideMessageInboxRight: nil];
    }
    else
    {
        // Need to slide rockie talkie back in
        [self slideMessageInboxLeft: nil];
    }
}

- (IBAction) userTouchedNotificationButton: (UIButton*) button
{
    button.selected = !button.selected;
    
    if (button.selected)
    {
        SYNActivityPopoverViewController *actionPopoverController = [[SYNActivityPopoverViewController alloc] init];
        // Need show the popover controller
        self.actionButtonPopover = [[UIPopoverController alloc] initWithContentViewController: actionPopoverController];
        self.actionButtonPopover.popoverContentSize = CGSizeMake(320, 166);
        self.actionButtonPopover.delegate = self;
        
        [self.actionButtonPopover presentPopoverFromRect: button.frame
                                                  inView: self.view
                                permittedArrowDirections: UIPopoverArrowDirectionUp
                                                animated: YES];
    }
    else
    {
        // Need to hide the popover controller
        [self.actionButtonPopover dismissPopoverAnimated: YES];
    }
}

- (void) popoverControllerDidDismissPopover: (UIPopoverController *) popoverController
{
	// Any cleanup
    self.notificationsButton.selected = FALSE;
}

// Keep just in case hold to record is back in fashion again
//- (IBAction) recordTouchDown
//{
//    [self startRecording];
//}
//
//
//- (IBAction) recordTouchUp
//{
//    [self endRecording];
//}

- (IBAction) toggleRecording
{
    if (self.isRecording)
    {
        self.isRecording = FALSE;
        [self endRecording];
    }
    else
    {
        self.isRecording = TRUE;
        [self startRecording];
    }
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
    if (self.messageInboxButton.selected == TRUE && gestureRecognizer == self.swipeRightRecognizer)
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

#pragma mark - Back button handling

- (void) showBackButton
{
    if (self.topButtonView.frame.origin.x < 0)
    {
        [UIView animateWithDuration: 0.25f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^
         {
             CGRect containerViewFrame = self.topButtonView.frame;
             containerViewFrame.origin.x += 75;
             self.topButtonView.frame = containerViewFrame;
         }
                         completion: ^(BOOL finished)
         {
             self.showingBackButton = TRUE;
         }];
    }
}


- (void) hideBackButton
{
    // Only hide if  already visible
    if (self.topButtonView.frame.origin.x >= 0)
    {
        [UIView animateWithDuration: 0.25f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^
         {
             CGRect containerViewFrame = self.topButtonView.frame;
             containerViewFrame.origin.x -= 75;
             self.topButtonView.frame = containerViewFrame;
         }
         completion: ^(BOOL finished)
         {
             self.showingBackButton = FALSE;
         }];
    }
}

- (IBAction) popCurrentViewController: (id) sender
{
    UINavigationController *navVC = (UINavigationController *)self.selectedViewController;
    
    SYNAbstractViewController *abstractVC = (SYNAbstractViewController *)navVC.topViewController;
    
    [abstractVC animatedPopViewController];
}


@end
