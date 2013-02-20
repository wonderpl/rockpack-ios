//
//  SYNYoutTubeVideoViewController.h
//  rockpack
//
//  Created by Nick Banks on 15/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

// Forward declaration for
@class SYNVideoPlaybackViewController;

// Define our event callback delegate
@protocol SYNYouTubeVideoViewControllerDelegate

- (void) youTubeVideoViewController: (SYNVideoPlaybackViewController *) viewController
               didReceiveEventNamed: (NSString *) eventName
                          eventData: (NSString *) eventData;

@end

// Interfeace
@interface SYNVideoPlaybackViewController : UIViewController

@property (nonatomic, weak) id<SYNYouTubeVideoViewControllerDelegate> delegate;

// Initialisation
- (id) initWithSource: (NSString *) source
             sourceId: (NSString *) sourceId
                width: (int) width 
               height: (int) height
             autoPlay: (BOOL) autoPlay;

- (id) initWithPlaylist: (NSArray *) playlist
                width: (int) width
               height: (int) height
             autoPlay: (BOOL) autoPlay;

- (void) replaceCurrentSourceOrPlaylistWithSource: (NSString *) source
                                         sourceId: (NSString *) sourceId;

- (void) replaceCurrentSourceOrPlaylistWithPlaylist: (NSArray *) playlist;


// Player control
- (void) play;
- (void) pause;
- (void) stop;
- (void) loadNextVideo;
- (void) loadPreviousVideo;
- (void) seekInCurrentVideoToTime: (int) seconds;

// Player properties
@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, assign, readonly) NSTimeInterval currentTime;
@property (nonatomic, assign, readonly) float bufferLoadedFraction;

@end
