//
//  SYNYoutTubeVideoViewController.m
//  rockpack
//
//  Created by Nick Banks on 15/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#define kVideoBackgroundColour [UIColor blackColor]
#define kBufferMonitoringTimerInterval 1.0f

#import "NSIndexPath+Arithmetic.h"
#import "SYNVideoPlaybackViewController.h"
#import <CoreData/CoreData.h>

@interface SYNVideoPlaybackViewController () <UIWebViewDelegate>

@property (nonatomic, assign) BOOL autoPlay;
@property (nonatomic, assign) CGRect requestedFrame;
@property (nonatomic, strong) NSIndexPath *currentSelectedIndexPath;
@property (nonatomic, assign, getter = isNextVideoWebViewReadyToPlay) BOOL nextVideoWebViewReadyToPlay;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *sourceId;
@property (nonatomic, strong) NSTimer *bufferMonitoringTimer;
@property (nonatomic, strong) UIButton *videoPlayButton;
@property (nonatomic, strong) UIImageView *currentVideoPlaceholderImageView;
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

    // Start off by making our view transparent
    self.view.backgroundColor = kVideoBackgroundColour;
    
    // Use for placeholder
//    [self.largeVideoPanelView insertSubview: self.videoPlaybackViewController.view
//                               aboveSubview: self.videoPlaceholderImageView];
    
    self.currentVideoPlaceholderImageView = [self createNewVideoPlaceholderImageView];
    
    // Create an UIWebView with exactly the same dimensions and background colour as our view
    self.currentVideoWebView = [self createNewVideoWebView];
    
    // Add button that can be used to play video (if not autoplaying)
    self.videoPlayButton = [self createVideoPlayButton];

//    self.view.autoresizesSubviews = YES;
//    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}


- (void) viewDidDisappear:(BOOL)animated
{
    [self stopVideoInWebView: self.currentVideoWebView];
    self.currentVideoWebView = nil;
    self.nextVideoWebView = nil;
    
    [super viewDidDisappear: animated];
}

- (void) animateToFrame: (CGRect) frame
{
    [UIView transitionWithView: self.view
                      duration: 10.0f
                       options: UIViewAnimationOptionLayoutSubviews
                    animations: ^
     {
         self.view.bounds = CGRectMake (0, 0, frame.size.width, frame.size.height);
//         self.currentVideoWebView.frame = self.view.bounds;
         //self.nextVideoWebView.frame = CGRectMake (0, 0, frame.size.width, frame.size.height);
     }
                    completion: ^(BOOL b)
     {
     }];
}


- (UIWebView *) createNewVideoWebView
{
    UIWebView *newVideoWebView;
    
    newVideoWebView = [[UIWebView alloc] initWithFrame: self.view.bounds];
    newVideoWebView.backgroundColor = self.view.backgroundColor;
	newVideoWebView.opaque = NO;
    newVideoWebView.alpha = 0.0f;
    newVideoWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    newVideoWebView.autoresizesSubviews = YES;
    newVideoWebView.scalesPageToFit = YES;
    
    // Stop the user from scrolling the webview
    newVideoWebView.scrollView.scrollEnabled = false;
    newVideoWebView.scrollView.bounces = false;
    
    // Set the webview delegate so that we can received events from the JavaScript
    newVideoWebView.delegate = self;
    
    // Enable airplay button on webview player
    newVideoWebView.mediaPlaybackAllowsAirPlay = YES;
    
    [self.view insertSubview: newVideoWebView
                aboveSubview: self.currentVideoPlaceholderImageView];

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
                           action: @selector(userTouchedPlay:)
                 forControlEvents: UIControlEventTouchUpInside];
    
    newVideoPlayButton.alpha = 1.0f;

    
    [self.view addSubview: newVideoPlayButton];
    return newVideoPlayButton;
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


- (void) setVideoWithSource: (NSString *) source
                   sourceId: (NSString *) sourceId
                   autoPlay: (BOOL) autoPlay
{
    // Init out ivars
    self.source = source;
    self.sourceId = sourceId;
    self.fetchedResultsController = nil;
    self.currentSelectedIndexPath = nil;
    self.autoPlay = autoPlay;
    
    [self loadCurrentVideoWebView];
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
}


- (void) playVideoAtIndex: (NSIndexPath *) newIndexPath
{
    // If we are already at this index, but not playing, then play
    if ([newIndexPath isEqual: self.currentSelectedIndexPath] == TRUE)
    {
        if (!self.isPlaying)
        {
            [self playVideoInWebView: self.currentVideoWebView];
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
}


- (void) stopVideoInWebView: (UIWebView *) webView
{
    [webView stringByEvaluatingJavaScriptFromString: @"player.stopVideo();"];
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

//YouTubeIFramePlayer

// Support for YouTube JavaScript player
- (void) loadWebViewWithIFramePlayer: (UIWebView *) webView
               usingYouTubeId: (NSString *) sourceId
{
    NSError *error = nil;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource: @"YouTubeIFramePlayer"
                                                         ofType: @"html"];
    
    NSString *templateHTMLString = [NSString stringWithContentsOfFile: fullPath
                                                             encoding: NSUTF8StringEncoding
                                                                error: &error];
    
    NSString *iFrameHTML = [NSString stringWithFormat: templateHTMLString, (int) self.view.frame.size.width, (int) self.view.frame.size.height, sourceId];
    
//    [webView loadHTMLString: iFrameHTML
//                    baseURL: [NSURL URLWithString: @"http://www.youtube.com"]];
    
    [webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: @"http://www.synchromation.com"]]];
    
    webView.alpha = 1.0f;
    
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
//    DebugLog(@"YouTube webview failed to load - %@", [error description]);
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
            [self stopBufferMonitoringTimer];
            [self stopVideoInWebView: self.currentVideoWebView];
            [self swapVideoWebViews];
        }
        else if ([actionData isEqualToString: @"playing"])
        {
            [self fadeOutPlayButton];
            [self fadeUpVideoPlayerInWebView: self.currentVideoWebView];
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
    
    // If we have a full buffer for the current video and are not already trying to buffer the next video
    // then start to preload the next video
    if (bufferLevel == 1.0f && self.nextVideoWebView == nil)
    {
        DebugLog (@"*** Buffer full");
        [self precacheNextVideo];
    }
}


- (void) precacheNextVideo
{
    // This flag is set to true when we get the unstarted event from the next video player
    // indicating that it has buffered and ready to play
    self.nextVideoWebViewReadyToPlay = FALSE;
    self.nextVideoWebView = [self createNewVideoWebView];
    
    [self loadNextVideoWebView];
}


#pragma mark - View animations

- (void) swapVideoWebViews
{
    if (self.nextVideoWebViewReadyToPlay == FALSE)
    {
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
    
    // Tweaked this as the QuickTime logo seems to appear otherwise
    [UIView animateWithDuration: 0.0f
                          delay: 0.1f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         
         
         // Contract thumbnail view
         webView.alpha = 1.0;
     }
                     completion: ^(BOOL finished)
     {
     }];
}

// Fades up the video player, fading out any placeholder
- (void) fadeOutVideoPlayerInWebView: (UIWebView *) webView
{
    [self fadeOutPlayButton];
    
    // We need to remove immediately, as returns to start immediately
    webView.alpha = 0.0f;
//    [webView removeFromSuperview];
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

-(VideoInstance*)currentVideoInstance
{
    return (VideoInstance*)[self.fetchedResultsController objectAtIndexPath:self.currentSelectedIndexPath];
}

@end
