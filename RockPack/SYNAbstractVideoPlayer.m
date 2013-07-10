//
//  SYNAbstractVideoPlayer.m
//  rockpack
//
//  Created by Nick Banks on 10/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAbstractVideoPlayer.h"

@implementation SYNAbstractVideoPlayer

// Generic singleton to allow it to be used by the derived classes
+ (id) sharedInstance
{
    static id _sharedInstance = nil;
    
    if (!_sharedInstance)
    {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            _sharedInstance = [[self alloc] init];
        });
    }
    
    return _sharedInstance;
}

- (id) init
{
    if ((self = [super init]))
    {
        // Create the static instances of our webviews
        self.videoWebViewInstance = [self createVideoWebView];
    }
    
    return self;
}



- (CGFloat) videoWidth
{
    CGFloat width = 320.0f;
    
    if (IS_IPAD)
    {
#ifdef USE_HIRES_PLAYER
        width = 1280.0f;
#else
        width = 739.0f;
#endif
    }
    
    return width;
}


- (CGFloat) videoHeight
{
    CGFloat height = 180.0f;
    
    if (IS_IPAD)
    {
#ifdef USE_HIRES_PLAYER
        height = 768.0f;
#else
        height = 416.0f;
#endif
    }
    
    return height;
}


// Common setup for all video web views
- (UIWebView *) createWebView
{
    UIWebView *newWebViewInstance = [[UIWebView alloc] initWithFrame: CGRectMake (0, 0, self.videoWidth, self.videoHeight)];
    
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
    
#ifdef USE_HIRES_PLAYER
    // If we are on the iPad then we need to super-size the webview so that we can scale down again
    if (IS_IPAD)
    {
        newYouTubeWebView.transform = CGAffineTransformMakeScale(739.0f/1280.0f, 739.0f/1280.0f);
    }
#endif
    
    return newWebViewInstance;
}

#pragma mark - UIWebViewDelegate

// This is where we dectect events from the JS and the youtube player
- (BOOL) webView: (UIWebView *) webView
         shouldStartLoadWithRequest: (NSURLRequest *) request
         navigationType: (UIWebViewNavigationType) navigationType
{
    //    DebugLog(@"-----%@", request.debugDescription);
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
    DebugLog(@"Webview failed to load - %@", [error description]);
}


#pragma mark - Abstract methods

// Abstract functions declared in subclasses (shouldn't be called)
- (UIWebView *) videoWebViewInstance
{
    AssertOrLog(@"Shouldn't be calling abstract superclass");
    return nil;
}

- (void) setVideoWebViewInstance: (UIWebView *) webView
{
    AssertOrLog(@"Shouldn't be calling abstract superclass");
}

- (UIWebView *) createVideoWebView
{
    AssertOrLog(@"Shouldn't be calling abstract superclass");
    return nil;
}
#pragma mark - Properties

// Get the duration of the current video
- (NSTimeInterval) duration
{
    AssertOrLog(@"Shouldn't be calling abstract superclass");
    return 0.0f;
}


// Get the playhead time of the current video
- (NSTimeInterval) currentTime
{
    AssertOrLog(@"Shouldn't be calling abstract superclass");
    return 0.0f;
}

// Get the playhead time of the current video
- (void) setCurrentTime: (NSTimeInterval) newTime
{
    AssertOrLog(@"Shouldn't be calling abstract superclass");
}


// Get a number between 0 and 1 that indicated how much of the video has been buffered
// Can use this to display a video loading progress indicator
- (float) videoLoadedFraction
{
    AssertOrLog(@"Shouldn't be calling abstract superclass");
    return 0.0f;
}


// Index of currently playing video (if using a playlist)
- (BOOL) isPlaying
{
    AssertOrLog(@"Shouldn't be calling abstract superclass");
    return FALSE;
}


- (BOOL) isPlayingOrBuffering
{
    AssertOrLog(@"Shouldn't be calling abstract superclass");
    return FALSE;
}


- (BOOL) isPaused
{
    AssertOrLog(@"Shouldn't be calling abstract superclass");
    return FALSE;
}


- (void) handlePlayerEvent: (NSString *) actionName
                 eventData: (NSString *) actionData
{
     AssertOrLog(@"Shouldn't be calling abstract superclass");
}




@end
