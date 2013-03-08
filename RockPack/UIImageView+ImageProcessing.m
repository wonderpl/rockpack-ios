//
//  UIImageView+ImageProcessing.m
//  rockpack
//
//  Created by Nick Banks on 01/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "UIImageView+ImageProcessing.h"
#import <objc/runtime.h>

static MKNetworkEngine *DefaultEngine2;
static char imageFetchOperationKey2;

const float kFromCacheAnimationDuration2 = 0.1f;
const float kFreshLoadAnimationDuration2 = 0.35f;

@interface UIImageView ()
@property (strong, nonatomic) MKNetworkOperation *imageFetchOperation2;
@end

@implementation UIImageView (ImageProcessing)

-(MKNetworkOperation*) imageFetchOperation2 {
    
    return (MKNetworkOperation*) objc_getAssociatedObject(self, &imageFetchOperationKey2);
}

-(void) setImageFetchOperation2:(MKNetworkOperation *)imageFetchOperation2
{
    objc_setAssociatedObject(self, &imageFetchOperationKey2, imageFetchOperation2, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void) setDefaultEngine2: (MKNetworkEngine*) engine
{
    DefaultEngine2 = engine;
}

- (MKNetworkOperation*) setAsynchronousImageFromURL: (NSURL*) url
                                   placeHolderImage: (UIImage*) image
{
    return [self setAsynchronousImageFromURL: url
                            placeHolderImage: image
                                 usingEngine: nil
                                   animation: NO];
}

- (MKNetworkOperation*) setAsynchronousImageFromURL: (NSURL*) url
                                   placeHolderImage: (UIImage*) image
                                         monochrome: (BOOL) isMonochrome
{
    return [self setAsynchronousImageFromURL: url
                            placeHolderImage: image
                                 usingEngine: nil
                                   animation: NO];
}

- (MKNetworkOperation*) setAsynchronousImageFromURL: (NSURL*) url
                                   placeHolderImage: (UIImage*) image
                                        usingEngine: (MKNetworkEngine*) imageCacheEngine
                                          animation: (BOOL) yesOrNo
{
    
    if (image) self.image = image;
    [self.imageFetchOperation2 cancel];
    if(!imageCacheEngine) imageCacheEngine = DefaultEngine2;
    
    if(imageCacheEngine)
    {
        self.imageFetchOperation2 = [imageCacheEngine imageAtURL: url
                                                            size: self.frame.size
                                               completionHandler: ^(UIImage *fetchedImage, NSURL *url, BOOL isInCache)
                                     {
                                         if (!isInCache)
                                         {
                                             [UIView transitionWithView: self.superview
                                                               duration: kFromCacheAnimationDuration2
                                                                options: UIViewAnimationOptionTransitionCrossDissolve animations: ^
                                              {
                                                      self.image = fetchedImage;
                                              }
                                              completion: nil];
                                         }
                                         else
                                         {
                                            self.image = fetchedImage;
                                         }
                                     }
                                     errorHandler:^(MKNetworkOperation *completedOperation, NSError *error)
                                     {
                                         DebugLog(@"%@", error);
                                     }];
    }
    else
    {
        DebugLog(@"No default engine found and imageCacheEngine parameter is null");
    }
    
    return self.imageFetchOperation2;
}

// Much more flexible version
- (void) setAsynchronousImageFromURL: (NSURL*) url
                   completionHandler: (MKNKImageBlock) completionHandler
                        errorHandler: (MKNKResponseErrorBlock) errorHandler
{
    [self.imageFetchOperation2 cancel];
    
    self.imageFetchOperation2 = [DefaultEngine2 imageAtURL: url
                                                      size: self.frame.size
                                         completionHandler: completionHandler
                                              errorHandler: errorHandler];
}


@end
