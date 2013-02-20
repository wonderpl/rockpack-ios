//
//  SYNYoutTubeVideoViewController.m
//  rockpack
//
//  Created by Nick Banks on 15/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#define kVideoBackgroundColour [UIColor blackColor]

#import "SYNVideoPlaybackViewController.h"

@interface SYNVideoPlaybackViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *videoWebView;
@property (nonatomic, strong) NSString *sourceId;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSArray *playlist;
@property (nonatomic, assign) int videoWidth;
@property (nonatomic, assign) int videoHeight;

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


- (id) initWithPlaylist: (NSArray *) playlist
                  width: (int) width
                 height: (int) height
               autoPlay: (BOOL) autoPlay
{
    if ((self = [super init]))
    {
        [self setupWithPlaylist: playlist];
    }
    
    return self;
}


- (void) setupWithSource: (NSString *) source
                sourceId: (NSString *) sourceId
{
    self.source = source;
    self.sourceId = sourceId;
    self.playlist = nil;
}


- (void) setupWithPlaylist: (NSArray *) playlist
{
    self.source = nil;
    self.sourceId = nil;
    self.playlist = playlist;
}


#pragma mark - View lifecyle

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
    
    [self loadWebViewWithPlayerWithSource: self.source
                                 sourceId: self.sourceId];
    
//    [self loadWebViewWithJSAPIUsingYouTubeId: self.sourceId
//                                       width: self.videoWidth
//                                      height: self.videoHeight];
}


#pragma mark - Source / Playlist management

- (void) replaceCurrentSourceOrPlaylistWithSource: (NSString *) source
                                         sourceId: (NSString *) sourceId;
{
    [self setupWithSource: source
                 sourceId: sourceId];
}


- (void) replaceCurrentSourceOrPlaylistWithPlaylist: (NSArray *) playlist
{
    [self setupWithPlaylist: playlist];
}


// Returns true if we have a playlist
- (BOOL) isPlaylist
{
    return self.playlist ? TRUE : FALSE;
}


- (void) play
{
    [self.videoWebView stringByEvaluatingJavaScriptFromString: @"player.playVideo();"];
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
    
}

- (void) loadPreviousVideo
{
    
}

- (void) seekInCurrentVideoToTime: (int) seconds
{
    
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
- (int) playlistIndex
{
    return [[self.videoWebView stringByEvaluatingJavaScriptFromString: @"getPlaylistIndex();"] intValue];
}


#pragma mark - Video playback HTML creation

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
    
    // If we have an event from the player, then handle it
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
    
}

- (void) handleVimeoPlayerEventNamed: (NSString *) actionName
                           eventData: (NSString *) actionData
{
    
}


@end
