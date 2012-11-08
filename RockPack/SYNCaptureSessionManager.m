//
//  SYNCaptureSessionManager.m
//  rockpack
//
//  Created by Nick Banks on 07/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNCaptureSessionManager.h"

@implementation SYNCaptureSessionManager

- (id) init
{
	if ((self = [super init]))
    {
		self.captureSession = [[AVCaptureSession alloc] init];
	}
    
	return self;
}


- (void) addVideoPreviewLayer
{
	self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession: [self captureSession]];
	self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.orientation =  AVCaptureVideoOrientationLandscapeRight;
    
}


- (void) addVideoInput
{
	AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeVideo];
    
	if (videoDevice)
    {
		NSError *error;
		AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice: videoDevice
                                                                              error: &error];
		if (!error)
        {
			if ([[self captureSession] canAddInput: videoIn])
            {
				[[self captureSession] addInput: videoIn];
            }
			else
            {
				NSLog(@"Couldn't add video input");
            }
		}
		else
        {
			NSLog(@"Couldn't create video input");
        }
	}
	else
    {
		NSLog(@"Couldn't create video capture device");
    }
}


- (void) dealloc
{
	[[self captureSession] stopRunning];
    
	self.previewLayer = nil;
	self.captureSession = nil;
}

@end
