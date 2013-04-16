//
//  SYNYoutTubeVideoViewController.m
//  rockpack
//
//  Created by Nick Banks on 15/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "NSIndexPath+Arithmetic.h"
#import "NSString+Timecode.h"
#import "SYNAppDelegate.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNVideoPlaybackViewController.h"
#import "UIFont+SYNFont.h"
#import <CoreData/CoreData.h>
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/CoreAnimation.h>

@interface SYNVideoPlaybackViewController () <UIWebViewDelegate>

@property (nonatomic, assign) BOOL autoPlay;
@property (nonatomic, assign) BOOL currentVideoViewedFlag;
@property (nonatomic, assign) BOOL playFlag;
@property (nonatomic, assign) CGRect requestedFrame;
@property (nonatomic, assign) NSTimeInterval currentDuration;
@property (nonatomic, assign, getter = isNextVideoWebViewReadyToPlay) BOOL nextVideoWebViewReadyToPlay;
@property (nonatomic, strong) CABasicAnimation *placeholderBottomLayerAnimation;
@property (nonatomic, strong) CABasicAnimation *placeholderMiddleLayerAnimation;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSIndexPath *currentSelectedIndexPath;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *sourceId;
@property (nonatomic, strong) NSTimer *bufferMonitoringTimer;
@property (nonatomic, strong) NSTimer *shuttleBarUpdateTimer;
@property (nonatomic, strong) UIButton *shuttleBarPlayPauseButton;
@property (nonatomic, strong) UIButton *videoPlayButton;
@property (nonatomic, strong) UIImageView *videoPlaceholderBottomImageView;
@property (nonatomic, strong) UIImageView *videoPlaceholderMiddleImageView;
@property (nonatomic, strong) UIImageView *videoPlaceholderTopImageView;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIProgressView *bufferingProgressView;
@property (nonatomic, strong) UISlider *shuttleSlider;
@property (nonatomic, strong) UIView *videoPlaceholderView;
@property (nonatomic, strong) UIWebView *currentVideoWebView;
@property (nonatomic, strong) UIWebView *nextVideoWebView;

@end


@implementation SYNVideoPlaybackViewController

@synthesize currentVideoInstance;

#pragma mark - Initialization

- (id) initWithFrame: (CGRect) frame
{
    if ((self = [super init]))
    {
        self.requestedFrame = frame;
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
    
    // Create an UIWebView with exactly the same dimensions and background colour as our view
    self.currentVideoWebView = [self createNewVideoWebView];
}


- (void) viewDidDisappear: (BOOL) animated
{
    [self stopBufferMonitoringTimer];
    [self stopShuttleBarUpdateTimer];
    
    [self stopVideoInWebView: self.currentVideoWebView];
    self.currentVideoWebView = nil;
    self.nextVideoWebView = nil;
    
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


- (UIWebView *) createNewVideoWebView
{
    UIWebView *newVideoWebView = [[UIWebView alloc] initWithFrame: self.view.bounds];

    newVideoWebView.backgroundColor = self.view.backgroundColor;
	newVideoWebView.opaque = NO;
    newVideoWebView.alpha = 0.0f;
    newVideoWebView.autoresizingMask = UIViewAutoresizingNone;
    
    // Stop the user from scrolling the webview
    newVideoWebView.scrollView.scrollEnabled = false;
    newVideoWebView.scrollView.bounces = false;
    
    // Set the webview delegate so that we can received events from the JavaScript
    newVideoWebView.delegate = self;
    
    // Enable airplay button on webview player
    newVideoWebView.mediaPlaybackAllowsAirPlay = YES;
    
    [self.view insertSubview: newVideoWebView
                belowSubview: self.shuttleBarView];

    return newVideoWebView;
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


- (UIButton *) createVideoPlayButton
{
    UIButton *newVideoPlayButton;
      
    newVideoPlayButton = [UIButton buttonWithType: UIButtonTypeCustom];
    newVideoPlayButton.frame = self.view.bounds;
    newVideoPlayButton.backgroundColor = [UIColor clearColor];
    
    [newVideoPlayButton setImage: [UIImage imageNamed: @"ButtonLargeVideoPanelPlay.png"]
                        forState: UIControlStateNormal];
    
    newVideoPlayButton.alpha = 1.0f;

    
    [self.view addSubview: newVideoPlayButton];
    return newVideoPlayButton;
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

- (void) incrementVideoIndexPath
{
//    self.currentSelectedIndexPath = [self nextIndexPath: self.currentSelectedIndexPath];
    self.currentSelectedIndexPath = [self.currentSelectedIndexPath nextIndexPathUsingFetchedResultsController: self.fetchedResultsController];
}


- (void) decrementVideoIndexPath
{
    self.currentSelectedIndexPath = [self.currentSelectedIndexPath previousIndexPathUsingFetchedResultsController: self.fetchedResultsController];
}


- (NSIndexPath *) nextVideoIndexPath
{
    NSIndexPath *index = nil;
    
    // Don't bother incrementing index if we only have a single video
    if (self.isUsingPlaylist)
    {
        // make sure we wrap around at the end of the video playlist
        index = [self.currentSelectedIndexPath nextIndexPathUsingFetchedResultsController: self.fetchedResultsController];
    }
    
    return index;
}


- (NSIndexPath *) previousVideoIndexPath
{
    NSIndexPath *index = nil;
    
    // Don't bother incrementing index if we only have a single video
    if (self.isUsingPlaylist)
    {
        // make sure we wrap around at the end of the video playlist
        index = [self.currentSelectedIndexPath previousIndexPathUsingFetchedResultsController: self.fetchedResultsController];
    }
    
    return index;
}


- (void) setPlaylistWithFetchedResultsController: (NSFetchedResultsController *) fetchedResultsController
                               selectedIndexPath: (NSIndexPath *) selectedIndexPath
                                        autoPlay: (BOOL) autoPlay
{
    // Init our ivars
    self.source = nil;
    self.sourceId = nil;
    self.fetchedResultsController = fetchedResultsController;
    self.currentSelectedIndexPath = selectedIndexPath;
    self.autoPlay = autoPlay;
    
    [self loadCurrentVideoWebView];
}


// Returns true if we have a playlist
- (BOOL) isUsingPlaylist
{
    return self.fetchedResultsController ? TRUE : FALSE;
}


- (void) playVideoInWebView: (UIWebView *) webView
{
    [webView stringByEvaluatingJavaScriptFromString: @"player.playVideo();"];
    
    if (self.currentVideoWebView == webView)
    {
        self.playFlag = TRUE;
    }
}


- (void) playVideoAtIndex: (NSIndexPath *) newIndexPath
{
    // If we are already at this index, but not playing, then play
    if ([newIndexPath isEqual: self.currentSelectedIndexPath] == TRUE)
    {
        if (!self.isPlaying)
        {
            [self playVideoInWebView: self.currentVideoWebView];
            self.playFlag = TRUE;
        }
    }
    else
    {
        // OK, we are not currently playing this index, so segue to the next video
        [self fadeOutVideoPlayerInWebView: self.currentVideoWebView];
        self.currentSelectedIndexPath = newIndexPath;
        [self loadCurrentVideoWebView];
    }
    
}


- (void) pauseVideoInWebView: (UIWebView *) webView
{
    [webView stringByEvaluatingJavaScriptFromString: @"player.pauseVideo();"];
    
    if (self.currentVideoWebView == webView)
    {
        self.playFlag = FALSE;
    }
}


- (void) stopVideoInWebView: (UIWebView *) webView
{
    [webView stringByEvaluatingJavaScriptFromString: @"player.stopVideo();"];
    
    if (self.currentVideoWebView == webView)
    {
        self.playFlag = FALSE;
    }
}


- (void) loadNextVideo
{
    [self incrementVideoIndexPath];
    [self loadCurrentVideoWebView];
}

- (void) loadPreviousVideo
{
    [self decrementVideoIndexPath];
    [self loadCurrentVideoWebView];
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
    // Make sure we don't receive any shuttle bar or buffer update timer events until we have loaded the new video
    [self stopShuttleBarUpdateTimer];
    [self stopBufferMonitoringTimer];
    
    // Reset shuttle slider
    self.shuttleSlider.value = 0.0f;
    
    // And time value
    self.currentTimeLabel.text = [NSString timecodeStringFromSeconds: 0.0f];
}


- (void) loadCurrentVideoWebView
{
    [self resetPlayerAttributes];
    
    // Assume that we just have a single video as opposed to a playlist
    
    NSString *currentSource = self.source;
    NSString *currentSourceId = self.sourceId;
    
    self.currentVideoViewedFlag = FALSE;
    
    // But if we do have a playlist, then load up the source and sourceId for the current video index
    if (self.isUsingPlaylist)
    {
        VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: self.currentSelectedIndexPath];
        currentSource = videoInstance.video.source;
        currentSourceId = videoInstance.video.sourceId;
    }
    
    [self loadWebView: self.currentVideoWebView
           withSource: currentSource
             sourceId: currentSourceId];
}

- (void) loadNextVideoWebView
{
    // Assume that we just have a single video as opposed to a playlist
    NSString *nextSource = self.source;
    NSString *nextSourceId = self.sourceId;
    
    // But if we do have a playlist, then load up the source and sourceId for the current video index
    if (self.isUsingPlaylist)
    {
        VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: self.nextVideoIndexPath];
        nextSource = videoInstance.video.source;
        nextSourceId = videoInstance.video.sourceId;
    }
    
    [self loadWebView: self.nextVideoWebView
           withSource: nextSource
             sourceId: nextSourceId];
}


- (void) loadWebView: (UIWebView *) webView
          withSource: (NSString *) source
            sourceId: (NSString *) sourceId
{
    if ([source isEqualToString: @"youtube"])
    {
        [self loadWebViewWithIFramePlayer: webView
                           usingYouTubeId: sourceId];
    }
    else if ([source isEqualToString: @"vimeo"])
    {
        [self loadWebViewWithIFrame: webView
                       usingVimeoId: sourceId];
    }
    else
    {
        // AssertOrLog(@"Unknown video source type");
        DebugLog(@"WARNING: No Source! ");
    }
}


- (void) loadWebViewWithIFramePlayer: (UIWebView *) webView
                      usingYouTubeId: (NSString *) sourceId
{
    NSError *error = nil;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource: @"YouTubeIFramePlayer"
                                                         ofType: @"html"];
    
    NSString *templateHTMLString = [NSString stringWithContentsOfFile: fullPath
                                                             encoding: NSUTF8StringEncoding
                                                                error: &error];
    
    
    CGAffineTransform savedTransform = self.view.transform;
    self.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
    
    NSString *iFrameHTML = [NSString stringWithFormat: templateHTMLString, (int) self.view.frame.size.width, (int) self.view.frame.size.height, sourceId];
    
    self.view.transform = savedTransform;
    
    [webView loadHTMLString: iFrameHTML
                    baseURL: [NSURL URLWithString: @"http://www.youtube.com"]];
    
    // Required to work correctly
    webView.mediaPlaybackRequiresUserAction = FALSE;
}


// Support for Vimeo player
// TODO: We need to support http://player.vimeo.com/video/VIDEO_ID?api=1&player_id=vimeoplayer
// See http://developer.vimeo.com/player/js-api
- (void) loadWebViewWithIFrame: (UIWebView *) webView
                  usingVimeoId: (NSString *) sourceId
{
    NSString *parameterString = @"";
    
    NSError *error = nil;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource: @"VimeoIFramePlayer"
                                                         ofType: @"html"];
    
    NSString *templateHTMLString = [NSString stringWithContentsOfFile: fullPath
                                                             encoding: NSUTF8StringEncoding
                                                                error: &error];
    
    NSString *iFrameHTML = [NSString stringWithFormat: templateHTMLString, sourceId, parameterString, self.view.frame.size.width, self.view.frame.size.height];
    
    [webView loadHTMLString: iFrameHTML
                         baseURL: nil];
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
                if (webView == self.currentVideoWebView)
                {
                    [self handleCurrentYouTubePlayerEventNamed: actionName
                                                     eventData: actionData];
                }
                else
                {
                    [self handleNextYouTubePlayerEventNamed: actionName
                                                  eventData: actionData];
                }
            }
            else
            {
                if (webView == self.currentVideoWebView)
                {
                    [self handleCurrentVimeoPlayerEventNamed: actionName
                                                   eventData: actionData];
                }
                else
                {
                    [self handleNextVimeoPlayerEventNamed: actionName
                                                eventData: actionData];
                }
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
{
//    DebugLog (@"*** Current YTPlayer: %@ : %@", actionName, actionData);
    
    if ([actionName isEqualToString: @"ready"])
    {
        // We don't actually get any events until we 'play' the video
        // The next stage is unstarted, so if not autoplay then pause the video
        [self playVideoInWebView: self.currentVideoWebView];
    }
    else if ([actionName isEqualToString: @"stateChange"])
    {
        // Now handle the different state changes
        if ([actionData isEqualToString: @"unstarted"])
        {
            // As we have already called the play method in onReady, we should pause it here if not autoplaying
            if (self.autoPlay == FALSE)
            {
                [self pauseVideoInWebView: self.currentVideoWebView];
                [self fadeUpPlayButton];
            }
        }
        else if ([actionData isEqualToString: @"ended"])
        {
            [self resetPlayerAttributes];
            [self stopVideoInWebView: self.currentVideoWebView];
            [self swapVideoWebViews];
        }
        else if ([actionData isEqualToString: @"playing"])
        {
            [self fadeOutPlayButton];
            [self fadeUpVideoPlayerInWebView: self.currentVideoWebView];
            [self startBufferMonitoringTimer];
            
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
            [self stopShuttleBarUpdateTimer];
            [self stopBufferMonitoringTimer];
            [self fadeUpPlayButton];
        }
        else if ([actionData isEqualToString: @"buffering"])
        {
        }
        else if ([actionData isEqualToString: @"cued"])
        {
            
        }
        else
        {
            AssertOrLog(@"Unexpected YTPlayer state change");
        }
    }
    else if ([actionName isEqualToString: @"playbackQuality"])
    {
        NSLog (@"!!!!!!!!!! Quality: %@", actionData);
    }
    else if ([actionName isEqualToString: @"playbackRateChange"])
    {
        
    }
    else if ([actionName isEqualToString: @"error"])
    {
        
    }
    else if ([actionName isEqualToString: @"apiChange"])
    {
        
    }
    else if ([actionName isEqualToString: @"sizeChange"])
    {
        NSLog (@"!!!!!!!!!! Size change: %@", actionData);
    }
    else
    {
        AssertOrLog(@"Unexpected YTPlayer event");
    }
}


// Handle all the events for the fore
- (void) handleNextYouTubePlayerEventNamed: (NSString *) actionName
                                    eventData: (NSString *) actionData
{
//    DebugLog (@"++++ Next YTPlayer: %@ : %@", actionName, actionData);
    
    if ([actionName isEqualToString: @"ready"])
    {
        // We don't actually get any events until we 'play' the video
        // The next stage is unstarted, so if not autoplay then pause the video
        [self playVideoInWebView: self.nextVideoWebView];
    }
    else if ([actionName isEqualToString: @"stateChange"])
    {
        // Now handle the different state changes
        if ([actionData isEqualToString: @"unstarted"])
        {
            DebugLog (@"--- Next video ready to play");
            self.nextVideoWebViewReadyToPlay = TRUE;
        }
        else if ([actionData isEqualToString: @"ended"])
        {
        }
        else if ([actionData isEqualToString: @"playing"])
        {
        }
        else if ([actionData isEqualToString: @"paused"])
        {
        }
        else if ([actionData isEqualToString: @"buffering"])
        {
            [self pauseVideoInWebView: self.nextVideoWebView];
        }
        else if ([actionData isEqualToString: @"cued"])
        {
            
        }
        else
        {
            AssertOrLog(@"Unexpected YTPlayer state change");
        }
    }
    else if ([actionName isEqualToString: @"playbackQuality"])
    {
        
    }
    else if ([actionName isEqualToString: @"playbackRateChange"])
    {
        
    }
    else if ([actionName isEqualToString: @"error"])
    {
        
    }
    else if ([actionName isEqualToString: @"apiChange"])
    {
        
    }
    else
    {
        AssertOrLog(@"Unexpected next YTPlayer event");
    }
}


- (void) handleCurrentVimeoPlayerEventNamed: (NSString *) actionName
                           eventData: (NSString *) actionData
{
    
}

- (void) handleNextVimeoPlayerEventNamed: (NSString *) actionName
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

- (void) startBufferMonitoringTimer
{
    [self.bufferMonitoringTimer invalidate];
    
    self.bufferMonitoringTimer = [NSTimer scheduledTimerWithTimeInterval: kBufferMonitoringTimerInterval
                                                                  target: self
                                                                selector: @selector(monitorBufferLevel)
                                                                userInfo: nil
                                                                 repeats: YES];
}


- (void) stopBufferMonitoringTimer
{
    [self.bufferMonitoringTimer invalidate], self.bufferMonitoringTimer = nil;
}


- (void) monitorBufferLevel
{
    float bufferLevel = [self videoLoadedFraction];
    NSLog (@"Buffer level %f", bufferLevel);
    // If we have a full buffer for the current video and are not already trying to buffer the next video
    // then start to preload the next video
    if (bufferLevel == 1.0f)
    {
        if (self.nextVideoWebView == nil)
        {
            DebugLog (@"*** Buffer full");
            [self precacheNextVideo];
        }
        else
        {
           [self stopBufferMonitoringTimer]; 
        }
    }
}


- (void) updateShuttleBarProgress
{
    NSTimeInterval currentTime = self.currentTime;
    
    // Update current time label
    self.currentTimeLabel.text = [NSString timecodeStringFromSeconds: currentTime];
    
    // Calculate the currently viewed percentage
    float viewedPercentage = currentTime / self.currentDuration;
    
    // and slider
    self.shuttleSlider.value = viewedPercentage;
    
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


- (void) updateTimeFromSlider: (UISlider *) slider
{
    [self setCurrentTime: slider.value * self.currentDuration];
}


- (void) togglePlayPause
{
    if (self.playFlag == TRUE)
    {

        [self.shuttleBarPlayPauseButton setImage: [UIImage imageNamed: @"ButtonShuttleBarPlay.png"]
                                        forState: UIControlStateNormal];
        
        [self pauseVideoInWebView: self.currentVideoWebView];
    }
    else
    {
        [self.shuttleBarPlayPauseButton setImage: [UIImage imageNamed: @"ButtonShuttleBarPause.png"]
                                        forState: UIControlStateNormal];
        
        [self playVideoInWebView: self.currentVideoWebView];
    }
}


- (void) precacheNextVideo
{
    [self stopBufferMonitoringTimer];
    
    // This flag is set to true when we get the unstarted event from the next video player
    // indicating that it has buffered and ready to play
    self.nextVideoWebViewReadyToPlay = FALSE;
    self.nextVideoWebView = [self createNewVideoWebView];
    
    [self loadNextVideoWebView];
}


#pragma mark - View animations

- (void) swapVideoWebViews
{
    self.currentVideoViewedFlag = FALSE;
    
    if (self.nextVideoWebViewReadyToPlay == FALSE)
    {
        // TODO: Need to handle this case
//        DebugLog(@"*** Next video not ready");
    }
    else
    {
//        DebugLog(@"*** Next video ready");
        UIWebView *oldVideoWebView = self.currentVideoWebView;
        self.currentVideoWebView = self.nextVideoWebView;
        self.nextVideoWebView = nil;
        
        // Start our new view playing
        [self playVideoInWebView: self.currentVideoWebView];
        
        // Now fade out our old video view
        [self fadeOutVideoPlayerInWebView: oldVideoWebView];
        [oldVideoWebView removeFromSuperview];
    }
}

- (IBAction) userTouchedPlay: (id) sender
{
    [self playVideoInWebView: self.currentVideoWebView];
}


// Fades up the video player, fading out any placeholder
- (void) fadeUpVideoPlayerInWebView: (UIWebView *) webView
{
    [self fadeOutPlayButton];
    [self animateVideoPlaceholder: NO];
    
    // Tweaked this as the QuickTime logo seems to appear otherwise
    [UIView animateWithDuration: 0.0f
                          delay: 0.1f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^ {
                         webView.alpha = 1.0;
                     }
                     completion: nil];
}

// Fades out the video player, fading in any placeholder
- (void) fadeOutVideoPlayerInWebView: (UIWebView *) webView
{
//    [self fadeOutPlayButton];
    [self animateVideoPlaceholder: YES];
    
    // We need to remove immediately, as returns to start immediately
    webView.alpha = 0.0f;
}

// Fades up the play button (enabling it when fully opaque)
- (void) fadeUpPlayButton
{
    [UIView animateWithDuration: 0.25f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^ {
                         self.videoPlayButton.alpha = 1.0f;
                     }
                     completion: ^(BOOL finished) {
                         self.videoPlayButton.enabled = TRUE;
                     }];
}


// Fades out the play button (disabling it immediately)
- (void) fadeOutPlayButton
{
    self.videoPlayButton.enabled = FALSE;
    
    [UIView animateWithDuration: 0.25f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^ {
                         self.videoPlayButton.alpha = 0.0f;
                     }
                     completion: nil];
}


- (VideoInstance*) currentVideoInstance
{
    return (VideoInstance*)[self.fetchedResultsController objectAtIndexPath:self.currentSelectedIndexPath];
}

@end
