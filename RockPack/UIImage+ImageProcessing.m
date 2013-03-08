//
//  UIImage+ImageProcessing.m
//  rockpack
//
//  Created by Nick Banks on 01/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "UIImage+ImageProcessing.h"

@implementation UIImage (ImageProcessing)

- (UIImage *) imageBlackAndWhite
{
    CIImage *beginImage = [CIImage imageWithCGImage: self.CGImage];
    
    CIImage *output = [CIFilter filterWithName: @"CIColorMonochrome"
                                 keysAndValues: kCIInputImageKey, beginImage, @"inputIntensity", [NSNumber numberWithFloat:1.0], @"inputColor", [[CIColor alloc] initWithColor: [UIColor whiteColor]], nil].outputImage;
    
    CIContext *context = [CIContext contextWithOptions: nil];
    CGImageRef cgiimage = [context createCGImage: output
                                        fromRect: output.extent];
    
    UIImage *newImage = [UIImage imageWithCGImage: cgiimage];
    
    CGImageRelease(cgiimage);
    
    return newImage;
}

- (CGImageRef) imageBlackAndWhite2: (UIColor *) whiteColour
{
    CIImage *beginImage = [CIImage imageWithCGImage: self.CGImage];
    
    CIImage *output = [CIFilter filterWithName: @"CIColorMonochrome"
                                 keysAndValues: kCIInputImageKey, beginImage,
                       @"inputIntensity", [NSNumber numberWithFloat:1.0],
                       @"inputColor", [[CIColor alloc] initWithColor: whiteColour], nil].outputImage;
    
    CIContext *context = [CIContext contextWithOptions: nil];
    CGImageRef cgiimage = [context createCGImage: output
                                        fromRect: output.extent];
    
    return cgiimage;
}

@end
