//
//  UIImage+Resize.m
//  rockpack
//
//  Created by Nick Banks on 11/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

+ (UIImage*) imageWithImage: (UIImage*) image
			   scaledToSize: (CGSize) newSize
{
	UIGraphicsBeginImageContext( newSize );
	[image drawInRect: CGRectMake(0, 0, newSize.width, newSize.height)];
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}

@end
