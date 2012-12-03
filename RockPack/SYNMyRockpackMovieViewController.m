//
//  SYNMyRockPackMovieViewController.m
//  rockpack
//
//  Created by Nick Banks on 27/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNAppDelegate.h"
#import "SYNMyRockpackMovieViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Video.h"


@interface SYNMyRockpackMovieViewController ()

@property (nonatomic, strong) Video *video;
@property (nonatomic, strong) MPMoviePlayerController *mainVideoPlayer;

@end


@implementation SYNMyRockpackMovieViewController

- (id) initWithVideo: (Video *) video
{
	
	if ((self = [super init]))
    {
		self.video = video;
	}
    
	return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];

    self.mainVideoPlayer = [[MPMoviePlayerController alloc] initWithContentURL: self.video.localVideoURL];
    
    self.mainVideoPlayer.shouldAutoplay = NO;
    [self.mainVideoPlayer prepareToPlay];
    
    // TODO: Hardcoded size for now, but need to find a way to get correct window size (and orientation!)
//    SYNAppDelegate *delegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[self.mainVideoPlayer view] setFrame: CGRectMake (0, 0, 1024, 642)]; // Frame must match parent view
    
    [self.view insertSubview: self.mainVideoPlayer.view atIndex: 0];
        
    [self.mainVideoPlayer pause];
}

// Don't call these here as called when going full-screen

- (void) viewWillDisappear: (BOOL) animated
{
    // Don't call these here as called when going full-screen
    // Remember to kill any video that might be active
//        self.mainVideoPlayer.view.hidden = TRUE;
//    [self.mainVideoPlayer pause];
//
//    self.mainVideoPlayer.view.hidden = TRUE;
    [self.mainVideoPlayer.view removeFromSuperview];
    
//    self.mainVideoPlayer = nil;
    
    [super viewWillDisappear: animated];
}





@end
