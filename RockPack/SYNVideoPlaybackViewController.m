//
//  SYNYoutTubeVideoViewController.m
//  rockpack
//
//  Created by Nick Banks on 15/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "NSString+Timecode.h"
#import "SYNAppDelegate.h"
#import "SYNDeviceManager.h"
#import "SYNMasterViewController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNVideoPlaybackViewController.h"
#import "UIFont+SYNFont.h"
#import <CoreData/CoreData.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/CoreAnimation.h>
#import "NSObject+Blocks.h"
#import "SYNDeviceManager.h"

@interface SYNVideoPlaybackViewController () <UIWebViewDelegate>

@property (nonatomic, assign) BOOL autoPlay;
@property (nonatomic, assign) BOOL firstTimePlay;
@property (nonatomic, assign) BOOL currentVideoViewedFlag;
@property (nonatomic, assign) BOOL disableTimeUpdating;
@property (nonatomic, assign) BOOL fadeOutScheduled;
@property (nonatomic, assign) BOOL playFlag;
@property (nonatomic, assign) BOOL shuttledByUser;
@property (nonatomic, assign) CGRect requestedFrame;
@property (nonatomic, assign) NSTimeInterval currentDuration;
@property (nonatomic, assign) int currentSelectedIndex;
@property (nonatomic, strong) CABasicAnimation *placeholderBottomLayerAnimation;
@property (nonatomic, strong) CABasicAnimation *placeholderMiddleLayerAnimation;
@property (nonatomic, strong) NSArray *videoInstanceArray;
@property (nonatomic, strong) NSTimer *shuttleBarUpdateTimer;
@property (nonatomic, strong) SYNVideoIndexUpdater indexUpdater;
@property (nonatomic, strong) UIButton *shuttleBarPlayPauseButton;
@property (nonatomic, strong) UIImageView *videoPlaceholderBottomImageView;
@property (nonatomic, strong) UIImageView *videoPlaceholderMiddleImageView;
@property (nonatomic, strong) UIImageView *videoPlaceholderTopImageView;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIProgressView *bufferingProgressView;
@property (nonatomic, strong) UISlider *shuttleSlider;
@property (nonatomic, strong) UIView *videoPlaceholderView;
@property (nonatomic, strong) UIWebView *currentVideoWebView;

@end


@implementation SYNVideoPlaybackViewController

@synthesize currentVideoInstance;

#pragma mark - Initialization

static UIWebView* youTubeVideoWebViewInstance;
static UIWebView* vimeoideoWebViewInstance;

// Create the static instances of our webviews
+ (void) initialize
{
    youTubeVideoWebViewInstance = [SYNVideoPlaybackViewController createNewYouTubeWebView];
    
#ifdef ENABLE_VIMEO_PLAYER
    vimeoideoWebViewInstance = [SYNVideoPlaybackViewController createNewVimeoWebView];
#endif
}


// Common setup for all video web views
+ (UIWebView *) createNewVideoWebView
{
    UIWebView *newWebViewInstance = [[UIWebView alloc] initWithFrame: CGRectMake (0,
                                                                                  0,
                                                                                  [SYNVideoPlaybackViewController videoWidth],
                                                                                  [SYNVideoPlaybackViewController videoHeight])];
    
    newWebViewInstance.opaque = NO;
    newWebViewInstance.alpha = 0.0f;
    newWebViewInstance.autoresizingMask = UIViewAutoresizingNone;
    
    // Stop the user from scrolling the webview
    newWebViewInstance.scrollView.scrollEnabled = false;
    newWebViewInstance.scrollView.bounces = false;
    
    // Enable airplay button on webview player
    newWebViewInstance.mediaPlaybackAllowsAirPlay = YES;
    
    // Required for autoplay
    newWebViewInstance.allowsInlineMediaPlayback = YES;
    
    // Required to work correctly
    newWebViewInstance.mediaPlaybackRequiresUserAction = FALSE;
    
    return newWebViewInstance;
}


// Create YouTube specific webview, based on common setup
+ (UIWebView *) createNewYouTubeWebView
{
    UIWebView *newYouTubeWebView = [SYNVideoPlaybackViewController createNewVideoWebView];
    
    NSError *error = nil;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource: @"YouTubeIFramePlayer"
                                                         ofType: @"html"];
    
    NSString *templateHTMLString = [NSString stringWithContentsOfFile: fullPath
                                                             encoding: NSUTF8StringEncoding
                                                                error: &error];
    
    NSString *iFrameHTML = [NSString stringWithFormat: templateHTMLString,
                                                       (int) [SYNVideoPlaybackViewController videoWidth],
                                                       (int) [SYNVideoPlaybackViewController videoHeight]];
    
    [newYouTubeWebView loadHTMLString: iFrameHTML
                              baseURL: [NSURL URLWithString: @"http://www.youtube.com"]];

    return newYouTubeWebView;
}


// Support for Vimeo player
// TODO: We need to support http://player.vimeo.com/video/VIDEO_ID?api=1&player_id=vimeoplayer
// See http://developer.vimeo.com/player/js-api
// Create YouTube specific webview, based on common setup
+ (UIWebView *) createNewVimeoWebView
{
    UIWebView *newVimeoVideoWebView = [SYNVideoPlaybackViewController createNewVideoWebView];
    
    NSString *parameterString = @"";
    
    NSError *error = nil;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource: @"VimeoIFramePlayer"
                                                         ofType: @"html"];
    
    NSString *templateHTMLString = [NSString stringWithContentsOfFile: fullPath
                                                             encoding: NSUTF8StringEncoding
                                                                error: &error];
    
    NSString *iFrameHTML = [NSString stringWithFormat: templateHTMLString,
                                                       parameterString,
                                                       (int) [SYNVideoPlaybackViewController videoWidth],
                                                       (int) [SYNVideoPlaybackViewController videoHeight]];
    
    [newVimeoVideoWebView loadHTMLString: iFrameHTML
                                 baseURL: nil];
    
    return newVimeoVideoWebView;
}


+ (CGFloat) videoWidth
{
    CGFloat width = 320.0f;
    
    if ([SYNDeviceManager.sharedInstance isIPad])
    {
        width = 739.0f;
    }
    return width;
}


+ (CGFloat) videoHeight
{
    CGFloat height = 180.0f;
    
    if ([SYNDeviceManager.sharedInstance isIPad])
    {
        height = 416.0f;
    }
    
    return height;
}


- (NSString *) videoQuality
{
    // Based on empirical evidence (Youtube app), determine the appropriate quality level based on device and connectivity
    BOOL isIpad = [[SYNDeviceManager sharedInstance] isIPad];
    SYNAppDelegate* appDelegate = UIApplication.sharedApplication.delegate;
    SYNMasterViewController *masterViewController = (SYNMasterViewController*)appDelegate.masterViewController;
    NSString *suggestedQuality;
    
    if ([masterViewController.reachability currentReachabilityStatus] == ReachableViaWiFi)
    {
        if (isIpad)
        {
            suggestedQuality = @"hd720";
        }
        else
        {
            suggestedQuality = @"medium";
        }
    }
    else if ([masterViewController.reachability currentReachabilityStatus] == ReachableViaWWAN)
    {
        // Connected via cellular network
        if (isIpad)
        {
            suggestedQuality = @"medium";
        }
        else
        {
            suggestedQuality = @"small";
        }
    }
    else if ([masterViewController.reachability currentReachabilityStatus] == NotReachable)
    {
        // Not currently connected
        suggestedQuality = @"default";
    }
    else
    {
        suggestedQuality = @"default";
    }
    
    return suggestedQuality;
}



- (id) initWithFrame: (CGRect) frame
        indexUpdater: (SYNVideoIndexUpdater) indexUpdater;
{
    if ((self = [super init]))
    {
        self.requestedFrame = frame;
        self.indexUpdater = indexUpdater;
    }
    
    return self;
}


#pragma mark - View lifecyle

// Manually create our view

- (void) viewDidLoad
{
    [super viewDidLoad];

    // Make sure we set the desired frame at this point
    self.view.frame = self.requestedFrame;
    
    self.view.clipsToBounds = YES;

    // Start off by making our view transparent
    self.view.backgroundColor = kVideoBackgroundColour;
    
    // Create view containing animated subviews for the animated placeholder (displayed whilst video is loading)
    self.videoPlaceholderView = [self createNewVideoPlaceholderView];
    
    // Start animation
    [self animateVideoPlaceholder: YES];
    
    self.shuttleBarView = [self createShuttleBarView];
    
    // Setup our web views
    youTubeVideoWebViewInstance.frame = self.view.bounds;
    youTubeVideoWebViewInstance.backgroundColor = self.view.backgroundColor;
    
    // Set the webview delegate so that we can received events from the JavaScript
    youTubeVideoWebViewInstance.delegate = self;
    
#ifdef ENABLE_VIMEO_PLAYER
    // Now we know our frame size, update the pre-created webview with size and colour
    vimeoVideoWebViewInstance.frame = self.view.bounds;
    vimeoVideoWebViewInstance.backgroundColor = self.view.backgroundColor;
    
    // Set the webview delegate so that we can received events from the JavaScript
    vimeoVideoWebViewInstance.delegate = self;
#endif
    
    // Default to using YouTube player for now
    self.currentVideoWebView = youTubeVideoWebViewInstance;
    
    [self.view insertSubview: self.currentVideoWebView
                belowSubview: self.shuttleBarView];
}


- (void) viewDidDisappear: (BOOL) animated
{
    [self stopShuttleBarUpdateTimer];
    [self stopVideo];
    self.currentVideoWebView = nil;
    
    [super viewDidDisappear: animated];
}


- (UIView *) createShuttleBarView
{
    // Create out shuttle bar view at the bottom of our video view
    CGRect shuttleBarFrame = self.view.frame;
    shuttleBarFrame.size.height = kShuttleBarHeight;
    shuttleBarFrame.origin.x = 0.0f;
    shuttleBarFrame.origin.y = self.view.frame.size.height - kShuttleBarHeight;
    UIView *shuttleBarView = [[UIView alloc] initWithFrame: shuttleBarFrame];
    
    // Add transparent background view
    UIView *shuttleBarBackgroundView = [[UIView alloc] initWithFrame: shuttleBarView.bounds];
    shuttleBarBackgroundView.alpha = 0.5f;
    shuttleBarBackgroundView.backgroundColor = [UIColor blackColor];
    [shuttleBarView addSubview: shuttleBarBackgroundView];
    
    // Add play/pause button
    self.shuttleBarPlayPauseButton = [UIButton buttonWithType: UIButtonTypeCustom];
    
    // Set this subview to appear slightly offset from the left-hand side
    self.shuttleBarPlayPauseButton.frame = CGRectMake(0, 0, kShuttleBarButtonWidth, kShuttleBarHeight);
    
    [self.shuttleBarPlayPauseButton setImage: [UIImage imageNamed: @"ButtonShuttleBarPause.png"]
                                    forState: UIControlStateNormal];
    
    [self.shuttleBarPlayPauseButton addTarget: self
                                       action: @selector(togglePlayPause)
                             forControlEvents: UIControlEventTouchUpInside];
    
    self.shuttleBarPlayPauseButton.backgroundColor = [UIColor clearColor];
    [shuttleBarView addSubview: self.shuttleBarPlayPauseButton];
    
    // Add time labels
    self.currentTimeLabel = [self createTimeLabelAtXPosition: kShuttleBarButtonWidth
                                               textAlignment: NSTextAlignmentRight];
    
    self.currentTimeLabel.text =  [NSString timecodeStringFromSeconds: 0.0f];
    
    [shuttleBarView addSubview: self.currentTimeLabel];
    
    self.durationLabel = [self createTimeLabelAtXPosition: self.view.frame.size.width - kShuttleBarTimeLabelWidth - kShuttleBarButtonWidth
                                            textAlignment: NSTextAlignmentLeft];
    
    self.durationLabel.text =  [NSString timecodeStringFromSeconds: 0.0f];
    
    [shuttleBarView addSubview: self.durationLabel];
    
    // Add shuttle slider
    // Set custom slider track images
    CGFloat sliderOffset = kShuttleBarButtonWidth + kShuttleBarTimeLabelWidth + kShuttleBarSliderOffset;
    
    UIImage *sliderBackgroundImage = [UIImage imageNamed: @"ShuttleBarPlayerBar.png"];
    
    UIImageView *sliderBackgroundImageView = [[UIImageView alloc] initWithFrame: CGRectMake(sliderOffset+2, 17, shuttleBarFrame.size.width - 2 - (2 * sliderOffset), 10)];
    
    sliderBackgroundImageView.image = [sliderBackgroundImage resizableImageWithCapInsets: UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
    [shuttleBarView addSubview: sliderBackgroundImageView];
    
    // Add the progress bar over the background, but underneath the slider
    self.bufferingProgressView = [[UIProgressView alloc] initWithFrame: CGRectMake(sliderOffset+1, 17, shuttleBarFrame.size.width - (2 * sliderOffset), 10)];
    UIImage *progressImage = [[UIImage imageNamed: @"ShuttleBarBufferBar.png"] resizableImageWithCapInsets: UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];
    // Note: this image needs to be exactly the same size at the left hand-track bar, or the bar will only display as a line
	UIImage *shuttleSliderRightTrack = [[UIImage imageNamed: @"ShuttleBarRemainingBar.png"] resizableImageWithCapInsets: UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];

    self.bufferingProgressView.progressImage = progressImage;
    self.bufferingProgressView.trackImage = shuttleSliderRightTrack;
    self.bufferingProgressView.progress = 0.0f;
    [shuttleBarView addSubview: self.bufferingProgressView];
    
    self.shuttleSlider = [[UISlider alloc] initWithFrame: CGRectMake(sliderOffset, 9, shuttleBarFrame.size.width - (2 * sliderOffset), 25)];
    
    UIImage *shuttleSliderLeftTrack = [[UIImage imageNamed: @"ShuttleBarProgressBar.png"] resizableImageWithCapInsets: UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f)];

       
    [self.shuttleSlider setMinimumTrackImage: shuttleSliderLeftTrack
                                    forState: UIControlStateNormal];
	
	[self.shuttleSlider setMaximumTrackImage: shuttleSliderRightTrack
                                    forState: UIControlStateNormal];
	
	// Custom slider thumb image
    [self.shuttleSlider setThumbImage: [UIImage imageNamed: @"ShuttleBarSliderThumb.png"]
                             forState: UIControlStateNormal];
        
    self.shuttleSlider.value = 0.0f;

    [self.shuttleSlider addTarget: self
                           action: @selector(updateTimeFromSlider:)
                 forControlEvents: UIControlEventValueChanged];
    
    [shuttleBarView addSubview: self.shuttleSlider];
    
    // Add AirPlay button
    // This is a crafty (apple approved) hack, where we set the showVolumeSlider parameter to NO, so only the AirPlay symbol gets shown
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    volumeView.frame = CGRectMake(self.view.frame.size.width - kShuttleBarButtonWidth + 18, 12, 25, kShuttleBarHeight);
    [volumeView setShowsVolumeSlider: NO];
    [volumeView sizeToFit];
    volumeView.backgroundColor = [UIColor clearColor];
    [shuttleBarView addSubview: volumeView];
    
    [self.view addSubview: shuttleBarView];
    
    return shuttleBarView;
}


- (UILabel *) createTimeLabelAtXPosition: (CGFloat) xPosition
                           textAlignment: (NSTextAlignment) textAlignment
{
    CGRect timeLabelFrame = self.view.frame;
    timeLabelFrame.size.height = kShuttleBarHeight - 4;
    timeLabelFrame.size.width = kShuttleBarTimeLabelWidth;
    timeLabelFrame.origin.x = xPosition;
    timeLabelFrame.origin.y = 4;

    UILabel *timeLabel = [[UILabel alloc] initWithFrame: timeLabelFrame];
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.textAlignment = textAlignment;
    timeLabel.font = [UIFont boldRockpackFontOfSize: 12.0f];
    timeLabel.backgroundColor = [UIColor clearColor];
    
    return timeLabel;
}


- (UIView *) createNewVideoPlaceholderView
{
    self.videoPlaceholderTopImageView = [self createNewVideoPlaceholderImageView: @"PlaceholderVideoTop.png"];
    self.videoPlaceholderMiddleImageView = [self createNewVideoPlaceholderImageView: @"PlaceholderVideoMiddle.png"];
    self.videoPlaceholderBottomImageView = [self createNewVideoPlaceholderImageView: @"PlaceholderVideoBottom.png"];
    
    // Pop them in a view to keep them together
    UIView *videoPlaceholderView = [[UIView alloc] initWithFrame: self.view.bounds];
    
    [videoPlaceholderView addSubview: self.videoPlaceholderBottomImageView];
    [videoPlaceholderView addSubview: self.videoPlaceholderMiddleImageView];
    [videoPlaceholderView addSubview: self.videoPlaceholderTopImageView];
    
    [self.view addSubview: videoPlaceholderView];

    return videoPlaceholderView;
}


- (UIImageView *) createNewVideoPlaceholderImageView: (NSString *) imageName
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame: self.view.bounds];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.backgroundColor = [UIColor clearColor];
    imageView.image = [UIImage imageNamed: imageName];
    
    return imageView;
}


#pragma mark - Placeholder Animation

- (void) animateVideoPlaceholder: (BOOL) animate
{
    if (animate == TRUE)
    {
        // Start the animations
        [self spinBottomPlaceholderImageView];
        [self spinMiddlePlaceholderImageView];
    }
    else
    {
        // Stop the animations
        [self.videoPlaceholderMiddleImageView.layer removeAllAnimations];
        [self.videoPlaceholderMiddleImageView.layer removeAllAnimations];
    }
}


- (void) spinMiddlePlaceholderImageView
{
    self.placeholderMiddleLayerAnimation = [self spinView: self.videoPlaceholderMiddleImageView
                                                 duration: kMiddlePlaceholderCycleTime
                                                clockwise: TRUE
                                                     name: kMiddlePlaceholderIdentifier];
}


- (void) spinBottomPlaceholderImageView
{
    self.placeholderBottomLayerAnimation = [self spinView: self.videoPlaceholderBottomImageView
                                                 duration: kBottomPlaceholderCycleTime
                                                clockwise: FALSE
                                                     name: kBottomPlaceholderIdentifier];
}


// Setup the placeholder spinning animation
- (CABasicAnimation *) spinView: (UIView *) placeholderView
                       duration: (float) cycleTime
                      clockwise: (BOOL) clockwise
                           name: (NSString *) name
{
    CABasicAnimation *animation;
    
	[CATransaction begin];
    
	[CATransaction setValue: (id) kCFBooleanTrue
					 forKey: kCATransactionDisableActions];
	
	CGRect frame = [placeholderView frame];
	placeholderView.layer.anchorPoint = CGPointMake(0.5, 0.5);
	placeholderView.layer.position = CGPointMake(frame.origin.x + 0.5 * frame.size.width, frame.origin.y + 0.5 * frame.size.height);
	[CATransaction commit];
	
	[CATransaction begin];
    
	[CATransaction setValue: (id)kCFBooleanFalse
					 forKey: kCATransactionDisableActions];
	
    // Set duration of spin
	[CATransaction setValue: [NSNumber numberWithFloat: cycleTime]
                     forKey: kCATransactionAnimationDuration];
	
	animation = [CABasicAnimation animationWithKeyPath: @"transform.rotation.z"];
    
    // We need to use set an explict key, as the animation is copied and not the same in the callback
    [animation setValue: name
                 forKey: @"name"];
    
    // Alter to/from to change spin direction
    if (clockwise)
    {
        animation.fromValue = [NSNumber numberWithFloat: 0.0];
        animation.toValue = [NSNumber numberWithFloat: 2 * M_PI];
    }
    else
    {
        animation.fromValue = [NSNumber numberWithFloat: 2 * M_PI];
        animation.toValue = [NSNumber numberWithFloat: 0.0f];
    }

	animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
	animation.delegate = self;
    
	[placeholderView.layer addAnimation: animation
                                 forKey: @"rotationAnimation"];
	
	[CATransaction commit];
    
    return animation;
}


// Restarts the spin animation on the button when it ends. Again, this is
// largely irrelevant now that the audio is loaded from a local file.

- (void) animationDidStop: (CAAnimation *) animation
                 finished: (BOOL) finished
{
	if (finished)
	{
        if ([[animation valueForKey: @"name"] isEqualToString: kMiddlePlaceholderIdentifier])
        {
            [self spinMiddlePlaceholderImageView];
        }
        else
        {
            [self spinBottomPlaceholderImageView];
        }
	}
}


#pragma mark - Source / Playlist management

- (VideoInstance*) currentVideoInstance
{
    return (VideoInstance*)self.videoInstanceArray [self.currentSelectedIndex];
}


- (void) incrementVideoIndex
{
    // Calculate new index, wrapping around if necessary
    self.currentSelectedIndex = (self.currentSelectedIndex + 1) % self.videoInstanceArray.count;
}


- (void) decrementVideoIndex
{
    // Calculate new index
    self.currentSelectedIndex = self.currentSelectedIndex -  1;
    
    // wrap around if necessary
    if (self.currentSelectedIndex < 0)
    {
        self.currentSelectedIndex = self.videoInstanceArray.count - 1;
    }
}


- (int) nextVideoIndex
{
    return (self.currentSelectedIndex + 1) % self.videoInstanceArray.count;
}


- (int) previousVideoIndex
{
    int index = self.currentSelectedIndex -  1;
        
    // wrap around if necessary
    if (index < 0)
    {
        index = self.videoInstanceArray.count - 1;
    }
    
    return index;
}


- (void) setPlaylist: (NSArray *) playlistArray
       selectedIndex: (int) selectedIndex
            autoPlay: (BOOL) autoPlay;
{
    self.videoInstanceArray = playlistArray;
    self.currentSelectedIndex = selectedIndex;
    self.autoPlay = autoPlay;
    
    [self loadCurrentVideoWebView];
}


#pragma mark - YouTube player support

- (void) playYouTubeVideoWithSourceId: (NSString *) sourceId
{
    NSString *loadString = [NSString stringWithFormat: @"player.stopVideo(); player.clearVideo(); player.setPlaybackQuality('%@'); player.loadVideoById('%@'); ", self.videoQuality, sourceId];
    [self.currentVideoWebView stringByEvaluatingJavaScriptFromString: loadString];
    self.playFlag = TRUE;
}


- (void) playVideo
{
    [self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.playVideo();"];
    self.playFlag = TRUE;
}


- (void) playVideoAtIndex: (int) index
{
    // If we are already at this index, but not playing, then play
    if (index == self.currentSelectedIndex)
    {
        if (!self.isPlaying)
        {
            // If we are not currently playing, then start playing
            [self playVideo];
            self.playFlag = TRUE;
        }
        else
        {
            // If we were already playing then restart the currentl video
            [self setCurrentTime: 0.0f];
        }
    }
    else
    {
        // OK, we are not currently playing this index, so segue to the next video
        [self fadeOutVideoPlayer];
        self.currentSelectedIndex = index;
        [self loadCurrentVideoWebView];
    }
}


- (void) pauseVideo
{
    [self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.pauseVideo();"];
    
    self.playFlag = FALSE;
}


- (void) stopVideo
{
    [self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.stopVideo();"];
    
    self.playFlag = FALSE;
}


- (void) loadNextVideo
{
    [self incrementVideoIndex];
    [self loadCurrentVideoWebView];
    
    // Call index updater block
    self.indexUpdater(self.currentSelectedIndex);
}


#pragma mark - Properties

// Get the duration of the current video
- (NSTimeInterval) duration
{
    return [[self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.getDuration();"] doubleValue];
}


// Get the playhead time of the current video
- (NSTimeInterval) currentTime
{
    return [[self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.getCurrentTime();"] doubleValue];
}

// Get the playhead time of the current video
- (void) setCurrentTime: (NSTimeInterval) newTime
{
    NSString *callString = [NSString stringWithFormat: @"player.seekTo(%f);", newTime];
    [self.currentVideoWebView stringByEvaluatingJavaScriptFromString: callString];
}


// Get a number between 0 and 1 that indicated how much of the video has been buffered
// Can use this to display a video loading progress indicator
- (float) videoLoadedFraction
{
    return [[self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.getVideoLoadedFraction();"] floatValue];
}


// Index of currently playing video (if using a playlist)
- (BOOL) isPlaying
{
    int playingValue = [[self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.getPlayerState();"] intValue];
    
    NSLog (@"playstate: %d" , playingValue);
    return (playingValue == 1) ? TRUE : FALSE;
}


#pragma mark - Video playback HTML creation

- (void) resetPlayerAttributes
{
    // Used to determine if a pause event is caused by shuttling or the user touching the pause button
    self.shuttledByUser = TRUE;
    
    // Make sure we don't receive any shuttle bar or buffer update timer events until we have loaded the new video
    [self stopShuttleBarUpdateTimer];
    
    // Reset shuttle slider
    self.shuttleSlider.value = 0.0f;
    
    // Reset progress view
    self.bufferingProgressView.progress = 0.0f;
    
    // And time value
    self.currentTimeLabel.text = [NSString timecodeStringFromSeconds: 0.0f];
}


- (void) loadCurrentVideoWebView
{
    [self resetPlayerAttributes];
    
    self.currentVideoViewedFlag = FALSE;

    VideoInstance *videoInstance = self.videoInstanceArray [self.currentSelectedIndex];
    
    NSString *currentSource = videoInstance.video.source;
    NSString *currentSourceId = videoInstance.video.sourceId;
    
    if ([currentSource isEqualToString: @"youtube"])
    {
        [self playYouTubeVideoWithSourceId: currentSourceId];
    }
    else if ([currentSource isEqualToString: @"vimeo"])
    {
        // TODO: Add Vimeo support here
    }
    else
    {
        // AssertOrLog(@"Unknown video source type");
        DebugLog(@"WARNING: No Source! ");
    }
}


#pragma mark - UIWebViewDelegate

// This is where we dectect events from the JS and the youtube player
- (BOOL) webView: (UIWebView *) webView
         shouldStartLoadWithRequest: (NSURLRequest *) request
         navigationType: (UIWebViewNavigationType) navigationType
{
    NSString *scheme = request.URL.scheme;
    
    // If we have an event from one of our players (as opposed to something else)
    if ([scheme isEqualToString: @"ytplayer"] || [scheme isEqualToString: @"vimeoplayer"])
    {
        // Split the URL up into it's componenents
        NSArray *components = request.URL.pathComponents;
        
        if (components.count > 1)
        {
            NSString *actionName = components[1];
            NSString *actionData = nil;
            
            if (components.count > 2)
            {
                actionData = components[2];
            }
            
            // Call our handler functions
            if ([scheme isEqualToString: @"ytplayer"])
            {
                    [self handleCurrentYouTubePlayerEventNamed: actionName
                                                     eventData: actionData];
            }
            else
            {
                    [self handleCurrentVimeoPlayerEventNamed: actionName
                                                   eventData: actionData];
            }
        }
        
        return NO;
    }
    else
    {
        // Just pass throught the load
        return YES;
    }
}


// If something went wrong, then log the error
- (void) webView: (UIWebView *) webView
         didFailLoadWithError: (NSError *) error
{
    // TODO: We should have some sort of error handling here
    DebugLog(@"YouTube webview failed to load - %@", [error description]);
}


#pragma mark - JavaScript player handlers

- (void) handleCurrentYouTubePlayerEventNamed: (NSString *) actionName
                                    eventData: (NSString *) actionData
{    if ([actionName isEqualToString: @"ready"])
    {
        DebugLog (@"++++++++++ Player ready - player ready");
        // We don't actually get any events until we 'play' the video
        // The next stage is unstarted, so if not autoplay then pause the video
        [self loadCurrentVideoWebView];
    }
    else if ([actionName isEqualToString: @"stateChange"])
    {
        // Now handle the different state changes
        if ([actionData isEqualToString: @"unstarted"])
        {
            // As we have already called the play method in onReady, we should pause it here if not autoplaying
            if (self.autoPlay == FALSE)
            {
                DebugLog (@"*** Unstarted: Autoplay false - attempting to pause");
                [self pauseVideo];
            }
            else
            {
                DebugLog (@"*** Unstarted: Assuming autoplay - no action taken");
            }
        }
        else if ([actionData isEqualToString: @"ended"])
        {
            DebugLog (@"*** Ended: Stopping - Fading out player & Loading next video");
            [self stopShuttleBarUpdateTimer];
            [self stopVideo];
            [self resetPlayerAttributes];
            [self loadNextVideo];
        }
        else if ([actionData isEqualToString: @"playing"])
        {
            DebugLog (@"++++++++++ Playing: Starting - Fading up player");
            
            // If we are playing then out shuttle / pause / play cycle is over
            self.shuttledByUser = TRUE;
            self.firstTimePlay = TRUE;
            
            [self fadeUpVideoPlayer];
            
            // Now cache the duration of this video for use in the progress updates
            self.currentDuration = self.duration;
            
            if (self.currentDuration > 0.0f)
            {
                // Only start if we have a valid duration
                [self startShuttleBarUpdateTimer];
                self.durationLabel.text = [NSString timecodeStringFromSeconds: self.currentDuration];
            }
        }
        else if ([actionData isEqualToString: @"paused"])
        {
            if (self.shuttledByUser == TRUE && self.playFlag == TRUE)
            {
                DebugLog (@"*** Paused: Paused by shuttle and should be playing? - Attempting to play");
                [self playVideo];
            }
            else
            {
                DebugLog (@"*** Paused: Paused by user");
            }
        }
        else if ([actionData isEqualToString: @"buffering"])
        {
            if (self.firstTimePlay == TRUE)
            {
                DebugLog (@"*** Buffering: Normal buffering - No action taken");
                self.firstTimePlay = FALSE;
            }
            else
            {
                // Should already be playing so try to restart
                DebugLog (@"*** Buffering: Buffering after play - Retrying play");
                [self playVideo];
            }

        }
        else if ([actionData isEqualToString: @"cued"])
        {
            DebugLog (@"*** Cued: No action taken");        }
        else
        {
            AssertOrLog(@"Unexpected YTPlayer state change");
        }
    }
    else if ([actionName isEqualToString: @"playbackQuality"])
    {
        DebugLog (@"!!!!!!!!!! Quality: %@", actionData);
    }
    else if ([actionName isEqualToString: @"playbackRateChange"])
    {
        DebugLog (@"!!!!!!!!!! Playback Rate change");
    }
    else if ([actionName isEqualToString: @"error"])
    {
        DebugLog (@"!!!!!!!!!! Error");
    }
    else if ([actionName isEqualToString: @"apiChange"])
    {
        DebugLog (@"!!!!!!!!!! API change");
    }
    else if ([actionName isEqualToString: @"sizeChange"])
    {
        DebugLog (@"!!!!!!!!!! Size change");
    }
    else
    {
        AssertOrLog(@"Unexpected YTPlayer event");
    }
}


- (void) handleCurrentVimeoPlayerEventNamed: (NSString *) actionName
                           eventData: (NSString *) actionData
{
    
}


- (void) startShuttleBarUpdateTimer
{
    [self.shuttleBarUpdateTimer invalidate];
    
    // Schedule the timer on a different runloop so that we continue to get updates even when scrolling collection views etc.
    self.shuttleBarUpdateTimer = [NSTimer timerWithTimeInterval: kShuttleBarUpdateTimerInterval
                                                       target: self
                                                     selector: @selector(updateShuttleBarProgress)
                                                     userInfo: nil
                                                      repeats: YES];
    
    [[NSRunLoop mainRunLoop] addTimer: self.shuttleBarUpdateTimer forMode: NSRunLoopCommonModes];
}


- (void) stopShuttleBarUpdateTimer
{
    [self.shuttleBarUpdateTimer invalidate], self.shuttleBarUpdateTimer = nil;
}


- (void) updateShuttleBarProgress
{
    float bufferLevel = [self videoLoadedFraction];
    NSLog (@"Buffer level %f", bufferLevel);
    
    // Update the progress bar under our slider
    self.bufferingProgressView.progress = bufferLevel;
    
    // Only update the shuttle if we are playing (this should stop the shuttle bar jumping to zero
    // just after a user shuttle event)
    
    NSTimeInterval currentTime = self.currentTime;
    
    // Update current time label
    self.currentTimeLabel.text = [NSString timecodeStringFromSeconds: currentTime];
    
    // Calculate the currently viewed percentage
    float viewedPercentage = currentTime / self.currentDuration;
    
    // and slider
    if (self.disableTimeUpdating == FALSE)
    {
        self.shuttleSlider.value = viewedPercentage;
        
        // We should also check to see if we are in the last 0.5 seconds of a video, and if so, trigger a fadeout
        if ((self.currentDuration - self.currentTime) < 0.5f)
        {
            DebugLog(@"*** In end zone");
            
            if (self.fadeOutScheduled == FALSE)
            {
                self.fadeOutScheduled = TRUE;
                
                __weak typeof(self) weakSelf = self;
                
                [self performBlock: ^{
                    if (weakSelf.fadeOutScheduled == TRUE)
                    {
                        weakSelf.fadeOutScheduled = FALSE;
                        
                        [weakSelf fadeOutVideoPlayer];
                        DebugLog(@"***** Fadeout");
                    }
                    else
                    {
                        DebugLog(@"***** Failed to re-trigger fadeout");
                    }
                }
                        afterDelay: 0.0f
             cancelPreviousRequest: YES];
            }
        }
    }
    
    // Now, if we have viewed more than kPercentageThresholdForView%, then mark as viewed
    if (viewedPercentage > kPercentageThresholdForView && self.currentVideoViewedFlag == FALSE)
    {
        // Don't mark as viewed again
        self.currentVideoViewedFlag = TRUE;
        
        SYNAppDelegate* appDelegate = UIApplication.sharedApplication.delegate;
        
        // Update the star/unstar status on the server
        [appDelegate.oAuthNetworkEngine recordActivityForUserId: appDelegate.currentOAuth2Credentials.userId
                                                         action: @"view"
                                                videoInstanceId: self.currentVideoInstance.uniqueId
                                              completionHandler: ^(NSDictionary *responseDictionary)
         {
             DebugLog(@"View action successful");
         }
                                                   errorHandler: ^(NSDictionary* errorDictionary)
         {
             DebugLog(@"View action failed");
         }];
    }
}


#pragma mark - User interaction

- (void) togglePlayPause
{
    if (self.playFlag == TRUE)
    {
        // Reset our shuttling flag
        self.shuttledByUser = FALSE;
        
        [self.shuttleBarPlayPauseButton setImage: [UIImage imageNamed: @"ButtonShuttleBarPlay.png"]
                                        forState: UIControlStateNormal];
        
        [self pauseVideo];
    }
    else
    {
        [self.shuttleBarPlayPauseButton setImage: [UIImage imageNamed: @"ButtonShuttleBarPause.png"]
                                        forState: UIControlStateNormal];
        
        [self playVideo];
    }
}


- (void) updateTimeFromSlider: (UISlider *) slider
{
    // Indicate that a pause event may be caused by the user shuttling
    self.shuttledByUser = TRUE;
    self.disableTimeUpdating = TRUE;
    
    // Only re-enable our upating after a certain period (to stop slider jumping)
    [self performBlock: ^{
        self.disableTimeUpdating = FALSE;
    }
            afterDelay: 1.0f
 cancelPreviousRequest: YES];

    float newTime = slider.value * self.currentDuration;
    
    [self setCurrentTime: newTime];
    self.currentTimeLabel.text = [NSString timecodeStringFromSeconds: newTime];
}


#pragma mark - View animations

// Fades up the video player, fading out any placeholder
- (void) fadeUpVideoPlayer
{
    // Tweaked this as the QuickTime logo seems to appear otherwise
    [UIView animateWithDuration: 0.5f
                          delay: 1.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^ {
                         self.currentVideoWebView.alpha = 1.0f;
                         self.videoPlaceholderView.alpha = 0.0f;
                     }
                     completion: ^(BOOL completed) {
                     }];
}


// Fades out the video player, fading in any placeholder
- (void) fadeOutVideoPlayer
{    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^ {
                         self.currentVideoWebView.alpha = 0.0f;
                         self.videoPlaceholderView.alpha = 1.0f;
                     }
                     completion: nil];
}

@end
