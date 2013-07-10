//
//  SYNYouTubePlayer.m
//  rockpack
//
//  Created by Nick Banks on 10/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNYouTubeVideoPlayer.h"

@implementation SYNYouTubeVideoPlayer

static UIWebView* _youTubeVideoWebViewInstance;

- (UIWebView *) videoWebViewInstance
{
    return _youTubeVideoWebViewInstance;
}

- (void) setVideoWebViewInstance: (UIWebView *) webView
{
    _youTubeVideoWebViewInstance = webView;
}

// Create YouTube specific webview, based on common setup
- (UIWebView *) createVideoWebView
{
    NSError *error = nil;
    
    // Create a new web view and set up common paramenters
    UIWebView *newYouTubeWebView = [self createWebView];
    
    // Get HTML from documents directory (as opposed to the bundle), so that we can update it
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent: @"YouTubeIFramePlayer.html"];
    
    NSString *templateHTMLString = [NSString stringWithContentsOfFile: fullPath
                                                             encoding: NSUTF8StringEncoding
                                                                error: &error];
    
    NSString *iFrameHTML = [NSString stringWithFormat: templateHTMLString,
                            (int) self.videoWidth,
                            (int) self.videoHeight];
    
    [newYouTubeWebView loadHTMLString: iFrameHTML
                              baseURL: [NSURL URLWithString: @"http://www.youtube.com"]];
    
    return newYouTubeWebView;
}


@end
