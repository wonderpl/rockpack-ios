//
//  UIImage+Monochrome.m
//  rockpack
//
//  Created by Nick Banks on 16/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "UIImage+Monochrome.h"

static char const * const ObjectKey = "MonochromeImage";

@implementation UIImage (Monochrome)

- (UIImage *) monochromeImage
{
    return objc_getAssociatedObject(self, ObjectKey);
}


- (void) setMonochromeImage: (UIImage *) monochromeImage
{
    objc_setAssociatedObject(self, ObjectKey, monochromeImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
