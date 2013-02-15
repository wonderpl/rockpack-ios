//
//  SYNYoutTubeVideoViewController.m
//  rockpack
//
//  Created by Nick Banks on 15/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#define kVideoBackgroundColour [UIColor blackColor]

#import "SYNYouTubeVideoViewController.h"

@interface SYNYouTubeVideoViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *videoWebView;
@property (nonatomic, strong) NSString *videoId;
@property (nonatomic, assign) int videoWidth;
@property (nonatomic, assign) int videoHeight;

@end

//[self loadWebViewWithJSAPIUsingYouTubeId: self.videoInstance.video.sourceId
//                                   width: 740
//                                  height: 416];


@implementation SYNYouTubeVideoViewController 

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
    
    [self loadWebViewWithJSAPIUsingYouTubeId: self.videoId
                                       width: self.videoWidth
                                      height: self.videoHeight];
}


#pragma mark - Actions

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


#pragma mark - Helpers

- (void) loadWebViewWithJSAPIUsingYouTubeId: (NSString *) videoId
                                      width: (int) width
                                     height: (int) height
{
    NSError *error = nil;
    NSString *fullPath = [[NSBundle mainBundle] pathForResource: @"YouTubeJSAPIPlayer"
                                                         ofType: @"html"];
    
    NSString *templateHTMLString = [NSString stringWithContentsOfFile: fullPath
                                                             encoding: NSUTF8StringEncoding
                                                                error: &error];
    
    NSString *iFrameHTML = [NSString stringWithFormat: templateHTMLString, width, height, videoId];
    
    [self.videoWebView loadHTMLString: iFrameHTML
                              baseURL: [NSURL URLWithString: @"http://www.youtube.com"]];
    
    // Not sure if this makes any difference
    self.videoWebView.mediaPlaybackRequiresUserAction = FALSE;
}


#pragma mark - UIWebViewDelegate

// This is where we dectect events from the JS and the youtube player
- (BOOL) webView: (UIWebView *) webView
         shouldStartLoadWithRequest: (NSURLRequest *) request
         navigationType: (UIWebViewNavigationType) navigationType
{
    // If we have an event from the player, then handle it
    if ([[request URL].scheme isEqualToString: @"ytplayer"])
    {
        // Split the URL up into it's componenents
        NSArray *components = [[request URL] pathComponents];
        
        if ([components count] > 1)
        {
            NSString *actionName = components[1];
            NSString *actionData = nil;
            
            if ([components count] > 2)
            {
                actionData = components[2];
            }
            
            // Call our delegate
            [self.delegate youTubeVideoViewController: self
                                 didReceiveEventNamed: actionName
                                            eventData: actionData];
        }
        
        return NO;
    }
    else
    {
        // Just pass throught lthe load
        return YES;
    }
}


// If something went wrong, then log the error
- (void) webView: (UIWebView *) webView
         didFailLoadWithError: (NSError *) error
{
    DebugLog(@"YouTube webview failed to load - %@", [error description]);
}


@end
