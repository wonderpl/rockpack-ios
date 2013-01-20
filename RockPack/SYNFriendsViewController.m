//
//  SYNFriendsViewController.m
//  RockPack
//
//  Created by Nick Banks on 13/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "SYNCaptureSessionManager.h"
#import "SYNFriendsViewController.h"
#import "SYNMovableView.h"

@interface SYNFriendsViewController ()

@property (nonatomic, strong) SYNCaptureSessionManager *captureManager;

@end

@implementation SYNFriendsViewController

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.captureManager = [[SYNCaptureSessionManager alloc] init];
    
	[self.captureManager addVideoInput];
	[self.captureManager addVideoPreviewLayer];
    
//	CGRect layerRect = self.cameraPreview.layer.bounds;
//	self.captureManager.previewLayer.bounds = layerRect;
//	self.captureManager.previewLayer.position = CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect));
//    
//	[self.cameraPreview.layer addSublayer: self.captureManager.previewLayer];
    

}


//- (IBAction) toggleCameraButton: (UIButton *) cameraButton
//{
//    // Flip the state
//    cameraButton.selected = !cameraButton.isSelected;
//    
//    // Start or stop the video overlay (as appropriate)
//    if (cameraButton.selected)
//    {
//        self.cameraPreview.hidden = FALSE;
//        [self.captureManager.captureSession startRunning];
//        
//        [UIView animateWithDuration: kCameraPreviewAnimationDuration
//                              delay: 0.0f
//                            options: UIViewAnimationOptionCurveEaseInOut
//                         animations: ^
//         {
//             // Contract thumbnail view
//             self.cameraPreview.alpha = 1.0f;
//             
//         }
//                         completion: ^(BOOL finished)
//         {
//         }];
//    }
//    else
//    {
//        [self.captureManager.captureSession stopRunning];
//        [UIView animateWithDuration: kCameraPreviewAnimationDuration
//                              delay: 0.0f
//                            options: UIViewAnimationOptionCurveEaseInOut
//                         animations: ^
//         {
//             // Contract thumbnail view
//             self.cameraPreview.alpha = 0.0f;
//             
//         }
//                         completion: ^(BOOL finished)
//         {
//             self.cameraPreview.hidden = TRUE;
//         }];
//    }
//}


- (IBAction) toggleGridButton: (UIButton *) gridButton
{
    gridButton.selected = !gridButton.isSelected; 
}

@end
