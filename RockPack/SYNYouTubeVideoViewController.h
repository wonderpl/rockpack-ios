//
//  SYNYoutTubeVideoViewController.h
//  rockpack
//
//  Created by Nick Banks on 15/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

// Forward declaration for
@class SYNYouTubeVideoViewController;

// Define our event callback delegate
@protocol SYNYouTubeVideoViewControllerDelegate

- (void) youTubeVideoViewController: (SYNYouTubeVideoViewController *) viewController
               didReceiveEventNamed: (NSString *) eventName
                          eventData: (NSString *) eventData;

@end

// Interfeace
@interface SYNYouTubeVideoViewController : UIViewController

@property (nonatomic, weak) id<SYNYouTubeVideoViewControllerDelegate> delegate;

// Initialisation
- (id) initWithVideoId: (NSString *) videoId
                 width: (int) width
                height: (int) height
              autoPlay: (BOOL) autoPlay;

- (id) initWithPlaylist: (NSArray *) playlist
                  width: (int) width
                 height: (int) height
               autoPlay: (BOOL) autoPlay;

// Player control
- (void) play;
- (void) pause;
- (void) stop;

// Player properties
@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, assign, readonly) NSTimeInterval currentTime;
@property (nonatomic, assign, readonly) float bufferLoadedFraction;

@end
