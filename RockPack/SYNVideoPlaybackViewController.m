//
//  SYNYoutTubeVideoViewController.m
//  rockpack
//
//  Created by Nick Banks on 15/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#define kVideoBackgroundColour [UIColor blackColor]

#import "SYNVideoPlaybackViewController.h"
#import "VideoInstance.h"
#import "Video.h"

@interface SYNVideoPlaybackViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *videoWebView;
@property (nonatomic, strong) NSString *sourceId;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSArray *videoInstanceArray;
@property (nonatomic, assign) int videoIndex;
@property (nonatomic, assign) int videoWidth;
@property (nonatomic, assign) int videoHeight;
@property (nonatomic, assign) BOOL autoPlay;

@end


@implementation SYNVideoPlaybackViewController

#pragma mark - Initialization

- (id) initWithSource: (NSString *) source
             sourceId: (NSString *) sourceId
                width: (int) width
               height: (int) height
             autoPlay: (BOOL) autoPlay
{
    if ((self = [super init]))
    {
        [self setupWithSource: source
                     sourceId: sourceId];
    }
    
    return self;
}


- (id) initWithVideoInstances: (NSArray *) videoInstanceArray
                        width: (int) width
                       height: (int) height
                     autoPlay: (BOOL) autoPlay
{
    if ((self = [super init]))
    {
        [self setupWithVideoInstanceArray: videoInstanceArray];
    }
    
    return self;
}


- (void) setupWithSource: (NSString *) source
                sourceId: (NSString *) sourceId
{
    // Reset index
    self.videoIndex = 0;
    
    // set sources
    self.source = source;
    self.sourceId = sourceId;
    self.videoInstanceArray = nil;
}


- (void) setupWithVideoInstanceArray: (NSArray *) videoInstanceArray
{
    // Reset index
    self.videoIndex = 0;
    
    // Set playlist
    self.source = nil;
    self.sourceId = nil;
    self.videoInstanceArray = videoInstanceArray;
}


#pragma mark - View lifecyle

// Manually create our view
- (void) loadView
{
    // Create a view of the appropriate size (clear at this stage)
    self.view = [[UIView alloc] initWithFrame: CGRectMake (0, 0, self.videoWidth, self.videoHeight)];
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    // Start off by making our view transparent
    self.view.backgroundColor = kVideoBackgroundColour;
    self.view.alpha = 0.0f;
    
    // Create an UIWebView with exactly the same dimensions and background colour as our view
    self.videoWebView = [[UIWebView alloc] initWithFrame: self.view.bounds];
    self.videoWebView.backgroundColor = self.view.backgroundColor;
	self.videoWebView.opaque = NO;
    
    // Stop the user from scrolling the webview
    self.videoWebView.scrollView.scrollEnabled = false;
    self.videoWebView.scrollView.bounces = false;
    
    // Set the webview delegate so that we can received events from the JavaScript
    self.videoWebView.delegate = self;
    
    [self.view addSubview: self.videoWebView];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [self loadWebViewWithCurrentVideo];
}


#pragma mark - Source / Playlist management

- (void) incrementVideoIndex
{
    // Don't bother incrementing index if we only have a single video
    if (self.isUsingPlaylist)
    {
        // make sure we wrap around at the end of the video playlist
        self.videoIndex = (self.videoIndex + 1) % self.videoInstanceArray.count;
    }
}


- (void) decrementVideoIndex
{
    // Don't bother incrementing index if we only have a single video
    if (self.isUsingPlaylist)
    {
        // make sure we wrap around at the end of the video playlist
        self.videoIndex -= 1;
        
        if (self.videoIndex < 0)
        {
            self.videoIndex = self.videoInstanceArray.count - 1;
        }
    }
}


- (void) replaceCurrentSourceOrPlaylistWithSource: (NSString *) source
                                         sourceId: (NSString *) sourceId
                                         autoPlay: (BOOL) autoPlay
{
    [self setupWithSource: source
                 sourceId: sourceId];
}


- (void) replaceCurrentSourceOrPlaylistWithPlaylist: (NSArray *) videoInstanceArray
                                           autoPlay: (BOOL) autoPlay
{
    [self setupWithVideoInstanceArray: videoInstanceArray];
}


// Returns true if we have a playlist
- (BOOL) isUsingPlaylist
{
    return self.videoInstanceArray ? TRUE : FALSE;
}


- (void) play
{
    [self.videoWebView stringByEvaluatingJavaScriptFromString: @"player.playVideo();"];
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
        
        [self loadWebViewWithCurrentVideo];
    }
}


- (void) pause
{
    [self.videoWebView stringByEvaluatingJavaScriptFromString: @"player.pauseVideo();"];
}


- (void) stop
{
    [self.videoWebView stringByEvaluatingJavaScriptFromString: @"player.stopVideo();"];
}


- (void) loadNextVideo
{
    [self incrementVideoIndex];
    [self loadWebViewWithCurrentVideo];
}

- (void) loadPreviousVideo
{
    [self decrementVideoIndex];
    [self loadWebViewWithCurrentVideo];
}

- (void) seekInCurrentVideoToTime: (int) seconds
{
    NSString *js = [NSString stringWithFormat: @"player.stopVideo(%d, TRUE);", seconds];
    [self.videoWebView stringByEvaluatingJavaScriptFromString: js];
}


#pragma mark - Properties

// Get the duration of the current video
- (NSTimeInterval) duration
{
    return [[self.videoWebView stringByEvaluatingJavaScriptFromString: @"player.getDuration();"] doubleValue];
}


// Get the playhead time of the current video
- (NSTimeInterval) currentTime
{
    return [[self.videoWebView stringByEvaluatingJavaScriptFromString: @"player.getCurrentTime();"] doubleValue];
}


// Get a number between 0 and 1 that indicated how much of the video has been buffered
// Can use this to display a video loading progress indicator
- (float) videoLoadedFraction
{
        return [[self.videoWebView stringByEvaluatingJavaScriptFromString: @"player.getVideoLoadedFraction();"] floatValue];
}


// Index of currently playing video (if using a playlist)
- (BOOL) isPlaying
{
    return ([[self.videoWebView stringByEvaluatingJavaScriptFromString: @"player.getPlayerState();"] intValue] == 1)
            ? TRUE : FALSE;
}


#pragma mark - Video playback HTML creation

- (void) loadWebViewWithCurrentVideo
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
}


- (void) loadWebViewWithPlayerWithSource: (NSString *) source
                                sourceId: (NSString *) sourceId
{
    if ([source isEqualToString: @"youtube"])
    {
        [self loadWebViewWithJSAPIUsingYouTubeId: sourceId];
    }
    else if ([source isEqualToString: @"vimeo"])
    {
        [self loadWebViewWithIFrameUsingVimeoId: sourceId];
    }
    else
    {
        AssertOrLog(@"Unknown video source type");
    }
}


// Support for YouTube JavaScript player
- (void) loadWebViewWithJSAPIUsingYouTubeId: (NSString *) sourceId
{
    NSError *error = nil;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource: @"YouTubeJSAPIPlayer"
                                                         ofType: @"html"];
    
    NSString *templateHTMLString = [NSString stringWithContentsOfFile: fullPath
                                                             encoding: NSUTF8StringEncoding
                                                                error: &error];
    
    NSString *iFrameHTML = [NSString stringWithFormat: templateHTMLString, self.videoWidth, self.videoHeight, sourceId];
    
    [self.videoWebView loadHTMLString: iFrameHTML
                              baseURL: [NSURL URLWithString: @"http://www.youtube.com"]];
    
    // Not sure if this makes any difference
    self.videoWebView.mediaPlaybackRequiresUserAction = FALSE;
}


// Support for Vimeo player
// TODO: We need to support http://player.vimeo.com/video/VIDEO_ID?api=1&player_id=vimeoplayer
// See http://developer.vimeo.com/player/js-api
- (void) loadWebViewWithIFrameUsingVimeoId: (NSString *) sourceId
{
    NSString *parameterString = @"";
    
    NSError *error = nil;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource: @"VimeoIFramePlayer"
                                                         ofType: @"html"];
    
    NSString *templateHTMLString = [NSString stringWithContentsOfFile: fullPath
                                                             encoding: NSUTF8StringEncoding
                                                                error: &error];
    
    NSString *iFrameHTML = [NSString stringWithFormat: templateHTMLString, sourceId, parameterString, self.videoWidth, self.videoHeight];
    
    [self.videoWebView loadHTMLString: iFrameHTML
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
                [self handleYouTubePlayerEventNamed: actionName
                                          eventData: actionData];
            }
            else
            {
                [self handleVimeoPlayerEventNamed: actionName
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
    DebugLog(@"YouTube webview failed to load - %@", [error description]);
}


#pragma mark - JavaScript player handlers

- (void) handleYouTubePlayerEventNamed: (NSString *) actionName
                             eventData: (NSString *) actionData
{
    if ([actionName isEqualToString: @"ready"])
    {
        NSLog (@"*** YTPlayer: Ready");
    }
    else if ([actionName isEqualToString: @"stateChange"])
    {
        // Now handle the different state changes
        if ([actionData isEqualToString: @"unstarted"])
        {
            
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
        AssertOrLog(@"Unexpected YTPlayer event");
    }
}

- (void) handleVimeoPlayerEventNamed: (NSString *) actionName
                           eventData: (NSString *) actionData
{
    
}


@end
