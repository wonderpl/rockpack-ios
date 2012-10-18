//
//  SYNDiscoverTopTabViewController.m
//  RockPack
//
//  Created by Nick Banks on 16/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppContants.h"
#import "AudioToolbox/AudioToolbox.h"
#import "SYNDiscoverTopTabViewController.h"
#import "UIFont+SYNFont.h"
#import <MediaPlayer/MediaPlayer.h>

@interface SYNDiscoverTopTabViewController ()

@property (nonatomic, strong) IBOutlet UIView *videoPlaceholderView;
@property (nonatomic, strong) IBOutlet UIView *largeVideoPanelView;
@property (nonatomic, strong) MPMoviePlayerController *mainVideoPlayer;
@property (nonatomic, strong) IBOutlet UILabel *maintitle;
@property (nonatomic, strong) IBOutlet UILabel *subtitle;
@property (nonatomic, strong) IBOutlet UILabel *packIt;
@property (nonatomic, strong) IBOutlet UILabel *rockIt;
@property (nonatomic, strong) IBOutlet UILabel *packItNumber;
@property (nonatomic, strong) IBOutlet UILabel *rockItNumber;

@end

@implementation SYNDiscoverTopTabViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.maintitle.font = [UIFont boldRockpackFontOfSize: 24.0f];
    self.subtitle.font = [UIFont rockpackFontOfSize: 17.0f];
    self.packIt.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.rockIt.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.packItNumber.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.rockItNumber.font = [UIFont boldRockpackFontOfSize: 20.0f];
}

- (void) viewWillAppear:(BOOL)animated
{

    
    NSURL *videoURL = [NSURL fileURLWithPath: [[NSBundle mainBundle]
                                               pathForResource: @"MonstersUniversityTeaser"
                                               ofType: @"mp4"] isDirectory: NO];
    
    self.mainVideoPlayer = [[MPMoviePlayerController alloc] initWithContentURL: videoURL];
    
    self.mainVideoPlayer.shouldAutoplay = NO;
    [self.mainVideoPlayer prepareToPlay];
    
    [[self.mainVideoPlayer view] setFrame: [self.videoPlaceholderView bounds]]; // Frame must match parent view
    
    [self.videoPlaceholderView addSubview: [self.mainVideoPlayer view]];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self.mainVideoPlayer pause];
}

- (void) setSelectedIndex: (NSUInteger) newSelectedIndex
                 animated: (BOOL) animated
{
    if (newSelectedIndex != NSNotFound)
    {
        [self highlightTab: newSelectedIndex];
    }
}

- (IBAction) toggleButton: (id)sender
{
    UIButton* button = (UIButton*)sender;
    button.selected = !button.selected;
}

#pragma mark - Large video view gesture handler

- (IBAction) swipeLargeVideoViewLeft: (UISwipeGestureRecognizer *) swipeGesture
{       
    // Play a suitable sound
    NSString *soundPath = [[NSBundle mainBundle] pathForResource: @"RockieTalkie_Slide_In"
                                                          ofType: @"aif"];
    
    NSURL *soundURL = [NSURL fileURLWithPath: soundPath];
    SystemSoundID sound;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
    AudioServicesPlaySystemSound(sound);
    
    // Animate the view out onto the screen
    [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         CGRect largeVideoPanelFrame = self.largeVideoPanelView.frame;
         largeVideoPanelFrame.origin.x = -1024;
         self.largeVideoPanelView.frame =  largeVideoPanelFrame;
         
     }
                     completion: ^(BOOL finished)
     {
         CGRect largeVideoPanelFrame = self.largeVideoPanelView.frame;
         largeVideoPanelFrame.origin.x = -1024;
         self.largeVideoPanelView.frame =  largeVideoPanelFrame;
     }];
}


#pragma mark - Large video view open animation

- (void) animateLargeVideoViewRight
{
    // Play a suitable sound
    NSString *soundPath = [[NSBundle mainBundle] pathForResource: @"RockieTalkie_Slide_Out"
                                                          ofType: @"aif"];
    
    NSURL *soundURL = [NSURL fileURLWithPath: soundPath];
    SystemSoundID sound;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
    AudioServicesPlaySystemSound(sound);
    
    // Animate the view out onto the screen
    [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         CGRect largeVideoPanelFrame = self.largeVideoPanelView.frame;
         largeVideoPanelFrame.origin.x = 0;
         self.largeVideoPanelView.frame =  largeVideoPanelFrame;
         
     }
                     completion: ^(BOOL finished)
     {
         CGRect largeVideoPanelFrame = self.largeVideoPanelView.frame;
         largeVideoPanelFrame.origin.x = 0;
         self.largeVideoPanelView.frame =  largeVideoPanelFrame;
     }];
}

@end
