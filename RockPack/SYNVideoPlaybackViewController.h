//
//  SYNYoutTubeVideoViewController.h
//  rockpack
//
//  Created by Nick Banks on 15/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "GAITrackedViewController.h"
#import "Video.h"
#import "VideoInstance.h"
#import <UIKit/UIKit.h>

typedef void (^SYNVideoIndexUpdater)(int);

// Forward declarations
@class SYNVideoPlaybackViewController;

@interface SYNVideoPlaybackViewController : GAITrackedViewController

@property (nonatomic, strong) UIView *shuttleBarView;
@property (nonatomic, strong) UIButton *shuttleBarMaxMinButton;

// Singleton
+ (SYNVideoPlaybackViewController*) sharedInstance;

// Initialisation
- (void) updateWithFrame: (CGRect) frame
          channelCreator: (NSString *) channelCreator
            indexUpdater: (SYNVideoIndexUpdater) indexUpdater;

- (void) setPlaylist: (NSArray *) playlistArray
       selectedIndex: (int) selectedIndex
            autoPlay: (BOOL) autoPlay;

- (void) updateChannelCreator: (NSString *) channelCreator;

// Player control
- (void) playVideoAtIndex: (int) index;
- (void) resetShuttleBarFrame;
- (void) playIfVideoActive;
- (void) pauseIfVideoActive;

@end
