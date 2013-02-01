//
//  UICollectionViewCell+AsyncImage.m
//  rockpack
//
//  Created by Nick Banks on 17/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAppDelegate.h"
#import "SYNNetworkEngine.h"
#import "UICollectionViewCell+AsyncImage.h"
#import "UIImageView+MKNetworkKitAdditions.h"
#import <QuartzCore/QuartzCore.h>

@implementation UICollectionViewCell (AsyncImage)

- (void) loadAndCacheImageInView: (UIImageView *) imageView
                   withURLString: (NSString*) imageURLString
        andImageLoadingOperation: (MKNetworkOperation *) imageLoadingOperation
{
    SYNAppDelegate *appDelegate = UIApplication.sharedApplication.delegate;
    
    imageLoadingOperation = [appDelegate.networkEngine imageAtURL: [NSURL URLWithString: imageURLString]
                                                             size: imageView.frame.size
                                                completionHandler: ^(UIImage *fetchedImage, NSURL *url, BOOL isInCache)
     {
         if([imageURLString isEqualToString: [url absoluteString]])
         {
             if (isInCache)
             {
                 imageView.image = fetchedImage;
             }
             else
             {
                 [UIView transitionWithView: self.contentView
                                   duration: 0.4f
                                    options: UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                                 animations: ^
                  {
                      imageView.image = fetchedImage;
                  }
                                 completion: nil];
             }
         }
     }
    errorHandler:^(MKNetworkOperation *completedOperation, NSError *error)
     {
         imageView.image = nil;;
     }];
}


- (void) loadAndCacheImageWithAntialiasingInView: (UIImageView *) imageView
                                   withURLString: (NSString*) imageURLString
                        andImageLoadingOperation: (MKNetworkOperation *) imageLoadingOperation
{
    SYNAppDelegate *appDelegate = UIApplication.sharedApplication.delegate;
    
    imageLoadingOperation = [appDelegate.networkEngine imageAtURL: [NSURL URLWithString: imageURLString]
                                                             size: imageView.frame.size
                                                completionHandler: ^(UIImage *fetchedImage, NSURL *url, BOOL isInCache)
                             {
                                 if([imageURLString isEqualToString: [url absoluteString]])
                                 {
                                     if (isInCache)
                                     {
                                         imageView.image = fetchedImage;
                                     }
                                     else
                                     {
                                         [UIView transitionWithView: self.contentView
                                                           duration: 0.4f
                                                            options: UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                                                         animations: ^
                                          {
                                              // Crafty aliasing fix
                                              UIImage *image = fetchedImage;
                                              
//                                                imageView.image = fetchedImage;
                                              CGRect imageRect = CGRectMake( 0 , 0 , fetchedImage.size.width + 4 , fetchedImage.size.height + 4 );
                                              UIGraphicsBeginImageContext(imageRect.size);
                                              [fetchedImage drawInRect: CGRectMake(imageRect.origin.x + 2, imageRect.origin.y + 2, imageRect.size.width - 4, imageRect.size.height - 4)];
                                              CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationHigh);
                                              image = UIGraphicsGetImageFromCurrentImageContext();
                                              UIGraphicsEndImageContext();
                                              
                                              imageView.image = fetchedImage;

                                              imageView.layer.shouldRasterize = YES;
                                              imageView.layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;
                                              imageView.clipsToBounds = NO;
                                              imageView.layer.masksToBounds = NO;
                                              
                                              // End of clever jaggie reduction
                                          }
                                                         completion: nil];
                                     }
                                 }
                             }
                                                     errorHandler:^(MKNetworkOperation *completedOperation, NSError *error)
                             {
                                 imageView.image = nil;;
                             }];
}

@end
