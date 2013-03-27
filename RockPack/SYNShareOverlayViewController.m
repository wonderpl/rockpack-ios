//
//  SYNShareOverlayViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 21/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNShareOverlayViewController.h"

#import "UIFont+SYNFont.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface SYNShareOverlayViewController () <UITextViewDelegate>


@property (nonatomic, assign) BOOL isRecording;


@property (nonatomic, strong) NSTimer *levelTimer;
@property (nonatomic, strong) AVAudioRecorder *avRecorder;
@property (nonatomic, strong) IBOutlet UIImageView *recordButtonGlowImageView;

@property (nonatomic, strong) IBOutlet UITextView *messageTextView;

@end

@implementation SYNShareOverlayViewController

-(id)init
{
    self = [super initWithNibName:@"SYNShareOverlayViewController" bundle:nil];
    if (self) {
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.messageTextView.font = [UIFont rockpackFontOfSize: 15.0f];
    self.messageTextView.delegate = self;
    
}

#pragma mark - Voice Recording Methods

- (IBAction) toggleRecording: (UIButton *) recordButton
{
    recordButton.selected = !recordButton.selected;
    
    if (self.isRecording)
    {
        self.isRecording = FALSE;
        [self endRecording];
    }
    else
    {
        self.isRecording = TRUE;
        [self startRecording];
    }
}


- (void) startRecording
{
    // Show button 'volume glow'
    self.recordButtonGlowImageView.hidden = FALSE;
    
    AVAudioSession *avSession = [AVAudioSession sharedInstance];
	
	[avSession setCategory: AVAudioSessionCategoryPlayAndRecord
					 error: nil];
	
	[avSession setActive: YES
				   error: nil];
    
    // Don't actually make a real recording (send to /dev/null)
    NSURL *url = [NSURL fileURLWithPath: @"/dev/null"];
    
    // Mono, 44.1kHz should be fine
  	NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    
  	NSError *error;
    
  	self.avRecorder = [[AVAudioRecorder alloc] initWithURL: url
                                                  settings: settings
                                                     error: &error];
    
  	if (self.avRecorder)
    {
  		[self.avRecorder prepareToRecord];
  		self.avRecorder.meteringEnabled = YES;
  		[self.avRecorder record];
        
		self.levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.03
                                                           target: self
                                                         selector: @selector(levelTimerCallback:)
                                                         userInfo: nil
                                                          repeats: YES];
  	}
    else
    {
  		DebugLog(@"%@", [error description]);
    }
}


- (void) endRecording
{
    [self.avRecorder pause];
    self.avRecorder = nil;
    [self.levelTimer invalidate], self.levelTimer = nil;
    
    // Show button 'volume glow' and reset it's scale
    self.recordButtonGlowImageView.hidden = TRUE;
    [self.recordButtonGlowImageView setTransform: CGAffineTransformMakeScale(1.0f, 1.0f)];
}


- (void) levelTimerCallback: (NSTimer *) timer
{
    [self.avRecorder updateMeters];
    
    // Convert from dB to linear
	double averagePowerForChannel = pow(10, (0.05 * [self.avRecorder averagePowerForChannel: 0]));
    
    DebugLog (@"Power %f", averagePowerForChannel);
    
    // And clip to 0 > x > 1
    if (averagePowerForChannel < 0.0)
    {
        averagePowerForChannel = 0.0f;
    }
    else if (averagePowerForChannel > 1.0)
    {
        averagePowerForChannel = 1.0f;
    }
    
    // Adjust size of glow, Adding 1 for the scale factor
    double scaleFactor = 1.0f + averagePowerForChannel;
    
    [self.recordButtonGlowImageView setTransform: CGAffineTransformMakeScale(scaleFactor, scaleFactor)];
}



- (IBAction) writeMessage: (UIButton *) button
{
    button.selected = !button.selected;
    
    if (button.selected)
    {
        [self.messageTextView becomeFirstResponder];
    }
    else
    {
        [self.messageTextView resignFirstResponder];
    }
}

@end
