//
//  UIImage+Resize.h
//  rockpack
//
//  Created by Nick Banks on 11/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resize)

+ (UIImage*) imageWithImage: (UIImage*) image
			   scaledToSize: (CGSize) newSize;

@end
