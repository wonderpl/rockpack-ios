//
//  SYNFriendsViewController.m
//  RockPack
//
//  Created by Nick Banks on 13/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNFriendsViewController.h"
#import "SYNMovableView.h"
#import "SYNCaptureSessionManager.h"

@interface SYNFriendsViewController ()

@property (nonatomic, strong) SYNCaptureSessionManager *captureManager;
@property (nonatomic, strong) IBOutlet UIView *cameraPreview;

@end

@implementation SYNFriendsViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.captureManager = [[SYNCaptureSessionManager alloc] init];
    
	[[self captureManager] addVideoInput];
    
	[[self captureManager] addVideoPreviewLayer];
	CGRect layerRect = self.cameraPreview.layer.bounds;
	[[[self captureManager] previewLayer] setBounds: layerRect];
	[[[self captureManager] previewLayer] setPosition: CGPointMake(CGRectGetMidX(layerRect),
                                                                  CGRectGetMidY(layerRect))];
    
	[self.cameraPreview.layer addSublayer: self.captureManager.previewLayer];
    

}

- (IBAction) toggleCameraButton: (UIButton *) cameraButton
{
    // Flip the state
    cameraButton.selected = !cameraButton.isSelected;
    
    // Start or stop the video overlay (as appropriate)
    if (cameraButton.selected)
    {
        [[self.captureManager captureSession] startRunning];
    }
    else
    {
       [[self.captureManager captureSession] stopRunning];
    }
}

- (IBAction) toggleGridButton: (UIButton *) gridButton
{
    gridButton.selected = !gridButton.isSelected; 
}

@end
