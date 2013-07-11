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


// Create a UIWebView with a Vimeo player loaded into it
// See http://developer.vimeo.com/player/js-api
- (UIWebView *) createVideoWebView
{
    // Create a new web view and set up common paramenters
    UIWebView *newVimeoVideoWebView = [self createWebView];

    // Now load the vimeo player into the view we have just set up
    [self  loadVideoWebView: newVimeoVideoWebView];
    
    return newVimeoVideoWebView;
}


// Actually load the Vimeo player into the UIWebView
- (void) loadVideoWebView: (UIWebView *) videoWebView
{
    NSError *error = nil;
    
    // Get HTML from documents directory (as opposed to the bundle), so that we can update it
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent: @"VimeoIFramePlayer.html"];
    
    NSString *templateHTMLString = [NSString stringWithContentsOfFile: fullPath
                                                             encoding: NSUTF8StringEncoding
                                                                error: &error];
    
    NSString *iFrameHTML = [NSString stringWithFormat: templateHTMLString, (int) self.videoWidth, (int) self.videoHeight];
    
    [videoWebView loadHTMLString: iFrameHTML
                         baseURL: nil];
    
    // FIXME: Do we need to do this
//    [self.currentVideoWebView loadHTMLString: iFrameHTML
//                                     baseURL: [NSURL URLWithString: @"http://www.youtube.com"]];
    
    videoWebView.delegate = self;
}

- (void) playVideoWithSourceId: (NSString *) sourceId
{
    //    DebugLog(@"*** Playing: Load video command sent");
    self.notYetPlaying = TRUE;
    self.recordedVideoView = FALSE;
    self.pausedByUser = NO;
    
    SYNAppDelegate* appDelegate = UIApplication.sharedApplication.delegate;
    // Check to see if our JS is loaded
    NSString *availability = [self.videoWebViewInstance stringByEvaluatingJavaScriptFromString: @"checkPlayerAvailability();"];
    if ([availability isEqualToString: @"true"] && appDelegate.playerUpdated == FALSE)
    {
        // Our JS is loaded
        NSString *loadString = [NSString stringWithFormat: @"player.loadVideoById('%@');", sourceId];
        
        [self startVideoStallDetectionTimer];
        
        [self.videoWebViewInstance stringByEvaluatingJavaScriptFromString: loadString];
        
        self.playFlag = TRUE;
        
        [self.shuttleBarPlayPauseButton setImage: [UIImage imageNamed: @"ButtonShuttleBarPause.png"]
                                        forState: UIControlStateNormal];
    }
    else
    {
        // Something unloaded our JS, so use different approach
        // Reload out webview and load the new video when we get an event to say that the player is ready
        self.hasReloadedWebView = TRUE;
        self.sourceIdToReload = sourceId;
        appDelegate.playerUpdated = FALSE;
        
        // Now re-load the vimeo player into the existing web view
        [self loadVideoWebView: newVimeoVideoWebView];
    }
}


- (void) playVideo
{
    if ([self.view superview])
    {
        self.pausedByUser = NO;
        [self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.playVideo();"];
        self.playFlag = TRUE;
    }
    else
    {
        [self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.stopVideo();"];
        self.playFlag = FALSE;;
    }
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
    
    return (playingValue == 1) ? TRUE : FALSE;
}

- (BOOL) isPlayingOrBuffering
{
    int playingValue = [[self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.getPlayerState();"] intValue];
    
    return ((playingValue == 1) || (playingValue == 3)) ? TRUE : FALSE;
}

- (BOOL) isPaused
{
    int playingValue = [[self.currentVideoWebView stringByEvaluatingJavaScriptFromString: @"player.getPlayerState();"] intValue];
    
    return (playingValue == 2) ? TRUE : FALSE;
}


- (void) handlePlayerEvent: (NSString *) actionName
                 eventData: (NSString *) actionData
{
    //    DebugLog (@"actionname = %@, actiondata = %@", actionName, actionData);
    
    if ([actionName isEqualToString: @"ready"])
    {
        // If the user moved away from the original player page, then we should have already detected this
        // so we need to start playing again when we have loaded
        if (self.hasReloadedWebView == TRUE)
        {
            self.hasReloadedWebView = FALSE;
            
            NSString *loadString = [NSString stringWithFormat: @"player.loadVideoById('%@', '0', '%@');", self.sourceIdToReload, self.videoQuality];
            [self.currentVideoWebView stringByEvaluatingJavaScriptFromString: loadString];
            
            self.playFlag = TRUE;
            
            [self.shuttleBarPlayPauseButton setImage: [UIImage imageNamed: @"ButtonShuttleBarPause.png"]
                                            forState: UIControlStateNormal];
        }
    }
    else if ([actionName isEqualToString: @"stateChange"])
    {
        // Now handle the different state changes
      if ([actionData isEqualToString: @"ended"])
        {
            DebugLog (@"*** Ended: Stopping - Fading out player & Loading next video");
            self.percentageViewed = 1.0f;
            [self stopShuttleBarUpdateTimer];
            [self stopVideoStallDetectionTimer];
            [self stopVideo];
            [self resetPlayerAttributes];
            [self loadNextVideo];
        }
        else if ([actionData isEqualToString: @"playing"])
        {
            [self stopVideoStallDetectionTimer];
            
            DebugLog(@"*** Playing: Starting - Fading up player");
            // If we are playing then out shuttle / pause / play cycle is over
            self.shuttledByUser = TRUE;
            self.notYetPlaying = FALSE;
            
            // Now cache the duration of this video for use in the progress updates
            self.currentDuration = self.duration;
            
            if (self.currentDuration > 0.0f)
            {
                self.fadeUpScheduled = FALSE;
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
                [self stopVideoStallDetectionTimer];
                DebugLog (@"*** Paused: Paused by user");
            }
        }
        else
        {
            AssertOrLog(@"Unexpected Vimeo state change");
        }
    }
    else
    {
        AssertOrLog(@"Unexpected Vimeo event");
    }
}





@end
