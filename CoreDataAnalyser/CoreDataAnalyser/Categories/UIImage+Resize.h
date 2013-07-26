//
//  UIImage+Resize.h
//  rockpack
//
//  Created by Nick Banks on 11/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resize)

+ (UIImage*) imageWithImage: (UIImage*) image
			   scaledToSize: (CGSize) newSize;

- (NSData*) jpegDataForResizedImageWithMaxDimension: (CGFloat) maxDimension;

+ (UIImage*) scaleAndRotateImage: (UIImage*) image
                     withMaxSize: (int) newSize;

@end
