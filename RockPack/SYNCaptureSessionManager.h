//
//  SYNCaptureSessionManager.h
//  rockpack
//
//  Created by Nick Banks on 07/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

@interface SYNCaptureSessionManager : NSObject

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;

- (void) addVideoPreviewLayer;
- (void) addVideoInput;

@end
