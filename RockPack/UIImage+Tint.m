//
//  UIImage+Tint.m
//  rockpack
//
//  Created by Nick Banks on 20/08/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "UIImage+Tint.h"

@implementation UIImage (Tint)

- (UIImage *) tintedImageUsingColor: (UIColor *) tintColor
{
    UIGraphicsBeginImageContext(self.size);
    CGRect drawRect = CGRectMake(0, 0, self.size.width, self.size.height);
    [self drawInRect: drawRect];
    [tintColor set];
    UIRectFillUsingBlendMode(drawRect, kCGBlendModeSourceAtop);
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tintedImage;
}

@end
