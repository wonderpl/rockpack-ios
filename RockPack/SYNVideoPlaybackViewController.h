//
//  SYNYoutTubeVideoViewController.h
//  rockpack
//
//  Created by Nick Banks on 15/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "GAITrackedViewController.h"
#import "Video.h"
#import "VideoInstance.h"
#import <UIKit/UIKit.h>

typedef void (^SYNVideoIndexUpdater)(int);

// Forward declarations
@class SYNVideoPlaybackViewController;

@interface SYNVideoPlaybackViewController : GAITrackedViewController

@property (nonatomic, assign, readonly) NSTimeInterval currentTime;
@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, strong) UIView *shuttleBarView;
@property (nonatomic, strong) VideoInstance* currentVideoInstance;
@property (nonatomic, strong) UIButton *shuttleBarMaxMinButton;

+ (SYNVideoPlaybackViewController*) sharedInstance;

// Initialisation
- (void) updateWithFrame: (CGRect) frame
            indexUpdater: (SYNVideoIndexUpdater) indexUpdater;

- (void) setPlaylist: (NSArray *) playlistArray
       selectedIndex: (int) selectedIndex
            autoPlay: (BOOL) autoPlay;

// Player control
- (void) playVideoAtIndex: (int) index;
- (void) loadNextVideo;
- (void) resetShuttleBarFrame;

@end
