//
//  SYNVimeoVideoPlayer.m
//  rockpack
//
//  Created by Nick Banks on 10/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNVimeoVideoPlayer.h"


@implementation SYNVimeoVideoPlayer

static UIWebView* _vimeoVideoWebViewInstance;

- (UIWebView *) videoWebViewInstance
{
    return _vimeoVideoWebViewInstance;
}

- (void) setVideoWebViewInstance: (UIWebView *) webView
{
    _vimeoVideoWebViewInstance = webView;
}


// Support for Vimeo player
// TODO: We need to support http://player.vimeo.com/video/VIDEO_ID?api=1&player_id=vimeoplayer
// See http://developer.vimeo.com/player/js-api
- (UIWebView *) createVideoWebView
{
    NSError *error = nil;
    
    // Create a new web view and set up common paramenters
    UIWebView *newVimeoVideoWebView = [self createWebView];
    
    NSString *parameterString = @"";

    NSString *fullPath = [[NSBundle mainBundle] pathForResource: @"VimeoIFramePlayer"
                                                         ofType: @"html"];
    
    NSString *templateHTMLString = [NSString stringWithContentsOfFile: fullPath
                                                             encoding: NSUTF8StringEncoding
                                                                error: &error];
    
    NSString *iFrameHTML = [NSString stringWithFormat: templateHTMLString,
                            parameterString,
                            (int) self.videoWidth,
                            (int) self.videoHeight];
    
    [newVimeoVideoWebView loadHTMLString: iFrameHTML
                                 baseURL: nil];
    
    return newVimeoVideoWebView;
}


@end
