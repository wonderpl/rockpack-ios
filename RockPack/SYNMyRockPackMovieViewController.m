//
//  SYNMyRockPackMovieViewController.m
//  rockpack
//
//  Created by Nick Banks on 27/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNAppDelegate.h"
#import "SYNMyRockPackMovieViewController.h"
#import <MediaPlayer/MediaPlayer.h>


@interface SYNMyRockPackMovieViewController ()

@property (nonatomic, strong) NSURL *videoURL;

@property (nonatomic, strong) MPMoviePlayerController *mainVideoPlayer;

@end


@implementation SYNMyRockPackMovieViewController

- (id) initWithVideoURL: (NSURL *) videoURL
{
	
	if ((self = [super init]))
    {
		self.videoURL = videoURL;
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

    self.mainVideoPlayer = [[MPMoviePlayerController alloc] initWithContentURL: self.videoURL];
    
    self.mainVideoPlayer.shouldAutoplay = NO;
    [self.mainVideoPlayer prepareToPlay];
    
    // TODO: Hardcoded size for now, but need to find a way to get correct window size (and orientation!)
//    SYNAppDelegate *delegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[self.mainVideoPlayer view] setFrame: CGRectMake (0, 0, 1024, 642)]; // Frame must match parent view
    
    [self.view addSubview: [self.mainVideoPlayer view]];
        
    [self.mainVideoPlayer pause];
}

- (void) viewWillDisappear: (BOOL) animated
{
    // Remember to kill any video that might be active
    [self.mainVideoPlayer pause];
    self.mainVideoPlayer = nil;
    
    [super viewWillDisappear: animated];
}

@end
