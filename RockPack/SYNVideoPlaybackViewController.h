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
@protocol SYNVideoPlaybackViewControllerDelegate

- (void) videoPlaybackViewController: (SYNVideoPlaybackViewController *) viewController
                didReceiveEventNamed: (NSString *) eventName
                           eventData: (NSString *) eventData;

@end

// Interfeace
@interface SYNVideoPlaybackViewController : UIViewController

@property (nonatomic, weak) id<SYNVideoPlaybackViewControllerDelegate> delegate;

// Initialisation
- (id) initWithFrame: (CGRect) frame;

- (void) setVideoWithSource: (NSString *) source
                   sourceId: (NSString *) sourceId
                   autoPlay: (BOOL) autoPlay;

- (void) setPlaylistWithVideoInstanceArray: (NSArray *) videoInstanceArray
                              currentIndex: (int) currentIndex
                                  autoPlay: (BOOL) autoPlay;


// Player control
- (void) playVideoAtIndex: (int) index;
- (void) loadNextVideo;
- (void) loadPreviousVideo;

// Player properties
@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, assign, readonly) NSTimeInterval currentTime;

@end
