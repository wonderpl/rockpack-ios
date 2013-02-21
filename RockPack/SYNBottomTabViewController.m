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

@interface SYNBottomTabViewController () <UIPopoverControllerDelegate,
                                          UITextViewDelegate>

@property (nonatomic) BOOL didNotSwipeMessageInbox;
@property (nonatomic, assign) BOOL didNotSwipeShareMenu;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, assign) double lowPassResults;
@property (nonatomic, assign, getter = isShowingBackButton) BOOL showingBackButton;
@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, strong) UIViewController* searchViewController;
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

@property (nonatomic, weak) UIViewController *selectedViewController;
@property (strong, nonatomic) MKNetworkOperation *downloadOperation;
@property (strong, nonatomic) SYNVideoDownloadEngine *downloadEngine;

@end

@implementation SYNBottomTabViewController

@synthesize selectedIndex = _selectedIndex;

// Initialise all the elements common to all 4 tabs

#pragma mark - View lifecycle
 	
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Wallpack tab
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
    SYNVideosRootViewController *searchRootViewController = [[SYNVideosRootViewController alloc] initWithViewId:@"Search"];
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
	
    if(newSelectedIndex > [self.viewControllers count]) {
        DebugLog(@"Selected index %i is out of bounds", newSelectedIndex);
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
    else if (fromViewController == nil)  // don't animate
    {
        [self.view insertSubview: toViewController.view aboveSubview: self.backgroundImageView];
    }
    
    
    [self performChangeFromController:fromViewController toController:toViewController animated:animated];
    
    
    // We need to see if we need to hide/show the back button for the new view controller
    
    if ([toViewController isKindOfClass: [UINavigationController class]] &&
        [[(UINavigationController *)toViewController viewControllers] count] > 1) {
        
        //[self showBackButton];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNoteBackButtonShow object:self];
    }
    else
    {
        //[self hideBackButton];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNoteBackButtonShow object:self];
    }
}


-(void)performChangeFromController:(UIViewController*)fromViewController toController:(UIViewController*)toViewController animated:(BOOL)animated
{
    if (animated)
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
        [self.view insertSubview: toViewController.view aboveSubview: self.backgroundImageView];
    }
}


// Return the currently selected view controller

- (UIViewController *) selectedViewController
{
	if (self.selectedIndex != NSNotFound)
        return self.viewControllers [self.selectedIndex];
    
	return nil;
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

- (IBAction) recordAction: (UIButton*) button
{
    button.selected = !button.selected;
}


- (void) popoverControllerDidDismissPopover: (UIPopoverController *) popoverController
{
	// Any cleanup
    self.notificationsButton.selected = FALSE;
}



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





- (void) popCurrentViewController: (id) sender
{
    UINavigationController *navVC = (UINavigationController *)self.selectedViewController;
    
    SYNAbstractViewController *abstractVC = (SYNAbstractViewController *)navVC.topViewController;
    
    [abstractVC animatedPopViewController];
}




-(void) showSearchViewController
{
    UIViewController *fromViewController = self.selectedViewController;
    if(fromViewController == nil) {
        return;
    }
    UIViewController *toViewController = self.searchViewController;
    
    [self performChangeFromController:fromViewController toController:toViewController animated:YES];
}

@end
