//
//  SYNMyRockPackMovieViewController.m
//  rockpack
//
//  Created by Nick Banks on 27/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNAppDelegate.h"
#import "SYNMyRockpackMovieViewController.h"
#import "Video.h"
#import <MediaPlayer/MediaPlayer.h>


@interface SYNMyRockpackMovieViewController ()

@property (nonatomic, strong) MPMoviePlayerController *mainVideoPlayerController;
@property (nonatomic, strong) Video *video;

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

    self.mainVideoPlayerController = [[MPMoviePlayerController alloc] initWithContentURL: self.video.localVideoURL];
    
    self.mainVideoPlayerController.shouldAutoplay = NO;
    [self.mainVideoPlayerController prepareToPlay];
    
    // TODO: Hardcoded size for now, but need to find a way to get correct window size (and orientation!)
    [[self.mainVideoPlayerController view] setFrame: CGRectMake (0, 44, 1024, 642)]; // Frame must match parent view
    
    [self.view insertSubview: self.mainVideoPlayerController.view atIndex: 0];
        
    [self.mainVideoPlayerController pause];
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
    [self.mainVideoPlayerController.view removeFromSuperview];
    
//    self.mainVideoPlayer = nil;
    
    [super viewWillDisappear: animated];
}





@end
