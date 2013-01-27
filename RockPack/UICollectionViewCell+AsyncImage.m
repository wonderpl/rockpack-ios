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

@end
