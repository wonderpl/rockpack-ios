//
//  SYNYoutTubeVideoViewController.m
//  rockpack
//
//  Created by Nick Banks on 15/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#define kVideoBackgroundColour [UIColor blackColor]
#define kBufferMonitoringTimerInterval 1.0f

#import "SYNVideoPlaybackViewController.h"
#import "VideoInstance.h"
#import "Video.h"

@interface SYNVideoPlaybackViewController () <UIWebViewDelegate>

@property (nonatomic, assign) BOOL autoPlay;
@property (nonatomic, assign, getter = isNextVideoWebViewReadyToPlay) BOOL nextVideoWebViewReadyToPlay;
@property (nonatomic, assign) CGRect requestedFrame;
@property (nonatomic, assign) int videoIndex;
@property (nonatomic, strong) NSArray *videoInstanceArray;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *sourceId;
@property (nonatomic, strong) NSTimer *bufferMonitoringTimer;
@property (nonatomic, strong) UIButton *videoPlayButton;
@property (nonatomic, strong) UIImageView *currentVideoPlaceholderImageView;
@property (nonatomic, strong) UIWebView *currentVideoWebView;
@property (nonatomic, strong) UIWebView *nextVideoWebView;

@end


@implementation SYNVideoPlaybackViewController

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

    // Start off by making our view transparent
    self.view.backgroundColor = [UIColor clearColor];
    
//    [self.largeVideoPanelView insertSubview: self.videoPlaybackViewController.view
//                               aboveSubview: self.videoPlaceholderImageView];
    
    self.currentVideoPlaceholderImageView = [self createNewVideoPlaceholderImageView];
    
    // Create an UIWebView with exactly the same dimensions and background colour as our view
    self.currentVideoWebView = [self createNewVideoWebView];
    [self.view addSubview: self.currentVideoWebView];
    
    // We don't have a 'next' web view at the moment (not strictly necessary to nil here, but just to show logic)
    self.nextVideoWebView = nil;
    
    // Add button that can be used to play video (if not autoplaying)
    self.videoPlayButton = [self createVideoPlayButton];
    [self.view addSubview: self.videoPlayButton];
}


- (UIWebView *) createNewVideoWebView
{
    UIWebView *newVideoWebView;
    
    newVideoWebView = [[UIWebView alloc] initWithFrame: self.view.bounds];
    newVideoWebView.backgroundColor = self.view.backgroundColor;
	newVideoWebView.opaque = NO;
    
    // Stop the user from scrolling the webview
    newVideoWebView.scrollView.scrollEnabled = false;
    newVideoWebView.scrollView.bounces = false;
    
    // Set the webview delegate so that we can received events from the JavaScript
    newVideoWebView.delegate = self;

    return newVideoWebView;
}


- (UIImageView *) createNewVideoPlaceholderImageView
{
    UIImageView *newVideoPlaceholderImageView;
    
    newVideoPlaceholderImageView = [[UIImageView alloc] initWithFrame: self.view.bounds];
    newVideoPlaceholderImageView.backgroundColor = [UIColor clearColor];
	newVideoPlaceholderImageView.opaque = NO;
    
    // Initially, the webview will be hidden (until playback starts)
    newVideoPlaceholderImageView.alpha = 0.0f;
    
    return newVideoPlaceholderImageView;
}

- (UIButton *) createVideoPlayButton
{
    UIButton *newVideoPlayButton;
    
    newVideoPlayButton = [UIButton buttonWithType: UIButtonTypeCustom];
    newVideoPlayButton.frame = self.view.bounds;
    newVideoPlayButton.backgroundColor = [UIColor clearColor];
    
    [newVideoPlayButton setImage: [UIImage imageNamed: @"ButtonLargeVideoPanelPlay.png"]
                        forState: UIControlStateNormal];
    
    [newVideoPlayButton addTarget: self
                           action: @selector(clearVideoQueue)
                 forControlEvents: UIControlEventTouchUpInside];
    
    newVideoPlayButton.alpha = 1.0f;
//    newVideoPlayButton.enabled = FALSE;
    
    return newVideoPlayButton;
}


#pragma mark - Source / Playlist management

- (void) incrementVideoIndex
{
    self.videoIndex = self.nextVideoIndex;
}


- (void) decrementVideoIndex
{
    self.videoIndex = self.previousVideoIndex;
}

- (int) nextVideoIndex
{
    int index = 0;
    
    // Don't bother incrementing index if we only have a single video
    if (self.isUsingPlaylist)
    {
        // make sure we wrap around at the end of the video playlist
        index = (self.videoIndex + 1) % self.videoInstanceArray.count;
    }
    
    return index;
}


- (int) previousVideoIndex
{
    int index = 0;
    
    // Don't bother incrementing index if we only have a single video
    if (self.isUsingPlaylist)
    {
        // make sure we wrap around at the end of the video playlist
        index = self.videoIndex - 1;
        
        if (index< 0)
        {
            index = self.videoInstanceArray.count - 1;
        }
    }
    
    return index;
}


- (void) setVideoWithSource: (NSString *) source
                   sourceId: (NSString *) sourceId
                   autoPlay: (BOOL) autoPlay
{
    // Reset index
    self.videoIndex = 0;
    
    // Set autoplay
    self.autoPlay = autoPlay;
    
    // set sources
    self.source = source;
    self.sourceId = sourceId;
    self.videoInstanceArray = nil;
    
    [self loadCurrentVideoWebView];
}


- (void) setPlaylistWithVideoInstanceArray: (NSArray *) videoInstanceArray
                                  autoPlay: (BOOL) autoPlay
{
    // Reset index
    self.videoIndex = 0;
    
    // Set autoplay
    self.autoPlay = autoPlay;
    
    // Set playlist
    self.source = nil;
    self.sourceId = nil;
    self.videoInstanceArray = videoInstanceArray;
    
    [self loadCurrentVideoWebView];
}


// Returns true if we have a playlist
- (BOOL) isUsingPlaylist
{
    return self.videoInstanceArray ? TRUE : FALSE;
}


- (void) play
{
    [self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.playVideo();"];
}

- (void) playVideoAtIndex: (int) index
{
    // If we are already at this index, but not playing, then play
    if (index == self.videoIndex)
    {
        if (!self.isPlaying)
        {
            [self play];
        }
    }
    else
    {
        // OK, we are not currently playing this index, so segue to the next video
        self.videoIndex = index;
        
        [self loadCurrentVideoWebView];
    }
}


- (void) pause
{
    [self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.pauseVideo();"];
}


- (void) stop
{
    [self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.stopVideo();player.clearVideo();"];
}


- (void) loadNextVideo
{
    [self incrementVideoIndex];
    [self loadCurrentVideoWebView];
}

- (void) loadPreviousVideo
{
    [self decrementVideoIndex];
    [self loadCurrentVideoWebView];
}

- (void) seekInCurrentVideoToTime: (NSTimeInterval) seconds
{
    NSString *js = [NSString stringWithFormat: @"player.stopVideo(%lf, TRUE);", seconds];
    [self.currentVideoWebView stringByEvaluatingJavaScriptFromString: js];
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


// Get a number between 0 and 1 that indicated how much of the video has been buffered
// Can use this to display a video loading progress indicator
- (float) videoLoadedFraction
{
        return [[self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.getVideoLoadedFraction();"] floatValue];
}


// Index of currently playing video (if using a playlist)
- (BOOL) isPlaying
{
    return ([[self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.getPlayerState();"] intValue] == 1)
            ? TRUE : FALSE;
}


#pragma mark - Video playback HTML creation

- (void) loadCurrentVideoWebView
{
    // Assume that we just have a single video as opposed to a playlist
    NSString *currentSource = self.source;
    NSString *currentSourceId = self.sourceId;
    
    // But if we do have a playlist, then load up the source and sourceId for the current video index
    if (self.isUsingPlaylist)
    {
        VideoInstance *videoInstance = (VideoInstance *) self.videoInstanceArray[self.videoIndex];
        currentSource = videoInstance.video.source;
        currentSourceId = videoInstance.video.sourceId;
    }
    
    [self loadWebView: self.currentVideoWebView
           withSource: currentSource
             sourceId: currentSourceId];
}


- (void) loadWebView: (UIWebView *) webView
          withSource: (NSString *) source
            sourceId: (NSString *) sourceId
{
    if ([source isEqualToString: @"youtube"])
    {
        [self loadWebViewWithJSAPI: webView
                    usingYouTubeId: sourceId];
    }
    else if ([source isEqualToString: @"vimeo"])
    {
        [self loadWebViewWithIFrame: webView
                       usingVimeoId: sourceId];
    }
    else
    {
        AssertOrLog(@"Unknown video source type");
    }
}


// Support for YouTube JavaScript player
- (void) loadWebViewWithJSAPI: (UIWebView *) webView
               usingYouTubeId: (NSString *) sourceId
{
    NSError *error = nil;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource: @"YouTubeJSAPIPlayer"
                                                         ofType: @"html"];
    
    NSString *templateHTMLString = [NSString stringWithContentsOfFile: fullPath
                                                             encoding: NSUTF8StringEncoding
                                                                error: &error];
    
    NSString *iFrameHTML = [NSString stringWithFormat: templateHTMLString, (int) self.view.frame.size.width, (int) self.view.frame.size.height, sourceId];
    
    [webView loadHTMLString: iFrameHTML
                    baseURL: [NSURL URLWithString: @"http://www.youtube.com"]];
    
    // Not sure if this makes any difference
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
    DebugLog(@"YouTube webview failed to load - %@", [error description]);
}


#pragma mark - JavaScript player handlers

- (void) handleCurrentYouTubePlayerEventNamed: (NSString *) actionName
                                    eventData: (NSString *) actionData
{
    NSLog (@"*** Current YTPlayer: %@ : %@", actionName, actionData);
    
    if ([actionName isEqualToString: @"ready"])
    {

    }
    else if ([actionName isEqualToString: @"stateChange"])
    {
        // Now handle the different state changes
        if ([actionData isEqualToString: @"unstarted"])
        {
            if (self.autoPlay == TRUE)
            {
                [self play];
            }
            else
            {
                [self fadeUpPlayButton];
            }
        }
        else if ([actionData isEqualToString: @"ended"])
        {
            NSTimeInterval currentTime = self.currentTime;
            NSLog (@"%lf", currentTime);
            [self stopBufferMonitoringTimer];
            [self stop];

//            [self loadNextVideo];
        }
        else if ([actionData isEqualToString: @"playing"])
        {
            [self fadeOutPlayButton];
            [self fadeUpVideoPlayer];
            [self startBufferMonitoringTimer];
        }
        else if ([actionData isEqualToString: @"paused"])
        {
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
        AssertOrLog(@"Unexpected YTPlayer event");
    }
}


// Handle all the events for the fore
- (void) handleNextYouTubePlayerEventNamed: (NSString *) actionName
                                    eventData: (NSString *) actionData
{
    NSLog (@"++++ Next YTPlayer: %@ : %@", actionName, actionData);
    
    if ([actionName isEqualToString: @"ready"])
    {
        
    }
    else if ([actionName isEqualToString: @"stateChange"])
    {
        // Now handle the different state changes
        if ([actionData isEqualToString: @"unstarted"])
        {
            NSLog (@"--- Next video ready to play");
            self.nextVideoWebViewReadyToPlay = FALSE;
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

- (void) startBufferMonitoringTimer
{
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
    
    NSLog (@"Buffer Level %f", bufferLevel);
    
    // If we have a full buffer for the current video and are not already trying to buffer the next video
    // then start to preload the next video
    if (bufferLevel == 1.0f && self.nextVideoWebView == nil)
    {
        [self precacheNextVideo];
    }
}


- (void) precacheNextVideo
{
    // This flag is set to true when we get the unstarted event from the next video player
    // indicating that it has buffered and ready to play
    self.nextVideoWebViewReadyToPlay = FALSE;
    self.nextVideoWebView = [self createNewVideoWebView];
}

- (void) swapVideoWebViews
{
    if (self.isNextVideoWebViewReadyToPlay)
    {
        [UIView animateWithDuration: 0.25f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^
         {
             self.currentVideoWebView.alpha = 0.0f;
             self.nextVideoWebView.alpha = 1.0f;
         }
         completion: ^(BOOL finished)
         {
             self.currentVideoWebView = self.nextVideoWebView;
             self.nextVideoWebView = nil;
         }];
    }    
}

- (IBAction) userTouchedPlay: (id) sender
{
    [self play];
}


// Fades up the video player, fading out any placeholder
- (void) fadeUpVideoPlayer
{
    [self fadeOutPlayButton];
    
    [UIView animateWithDuration: 0.25f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         
         
         // Contract thumbnail view
         self.currentVideoWebView.alpha = 1.0;
         self.currentVideoPlaceholderImageView.alpha = 0.0f;
     }
                     completion: ^(BOOL finished)
     {
     }];
}

// Fades up the play button (enabling it when fully opaque)
- (void) fadeUpPlayButton
{
    [UIView animateWithDuration: 0.25f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         self.videoPlayButton.alpha = 1.0f;
     }
                     completion: ^(BOOL finished)
     {
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
                     animations: ^
     {
         self.videoPlayButton.alpha = 0.0f;
     }
                     completion: ^(BOOL finished)
     {
     }];
}

@end
