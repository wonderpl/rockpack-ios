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
    
    [self.view insertSubview: [self.mainVideoPlayer view] atIndex: 0];
        
    [self.mainVideoPlayer pause];
}

- (void) viewWillDisappear: (BOOL) animated
{
    // Remember to kill any video that might be active
    [self.mainVideoPlayer pause];
    self.mainVideoPlayer = nil;
    
    [super viewWillDisappear: animated];
}

- (IBAction) popCurrentView: (id) sender
{
//	[self.navigationController popViewControllerAnimated: YES];
    
    UIViewController *parentVC = self.navigationController.viewControllers[0];
    parentVC.view.alpha = 0.0f;
    
    [self.navigationController popViewControllerAnimated: NO];

    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         // Contract thumbnail view
         self.view.alpha = 0.0f;
         parentVC.view.alpha = 1.0f;
         
     }
                     completion: ^(BOOL finished)
     {
     }];
}

@end
