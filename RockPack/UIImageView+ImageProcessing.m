//
//  UIImageView+ImageProcessing.m
//  rockpack
//
//  Created by Nick Banks on 01/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "MKNetworkKit.h"
#import "UIImageView+ImageProcessing.h"
#import "UIImage+ImageProcessing.h"
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
                                   animation: NO
                                  monochrome: NO];
}

- (MKNetworkOperation*) setAsynchronousImageFromURL: (NSURL*) url
                                   placeHolderImage: (UIImage*) image
                                         monochrome: (BOOL) isMonochrome
{
    return [self setAsynchronousImageFromURL: url
                            placeHolderImage: image
                                 usingEngine: nil
                                   animation: NO
                                  monochrome: isMonochrome];
}

- (MKNetworkOperation*) setAsynchronousImageFromURL: (NSURL*) url
                                   placeHolderImage: (UIImage*) image
                                        usingEngine: (MKNetworkEngine*) imageCacheEngine
                                          animation: (BOOL) yesOrNo
                                         monochrome: (BOOL) isMonochrome
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
                                                  if (isMonochrome)
                                                  {
                                                      self.image = [fetchedImage imageBlackAndWhite];
                                                  }
                                                  else
                                                  {
                                                      self.image = fetchedImage;
                                                  }
                                              }
                                                             completion: ^(BOOL b)
                                              {
                                              }];
                                         }
                                         else
                                         {
                                             if (isMonochrome)
                                             {
                                                 self.image = [fetchedImage imageBlackAndWhite];
                                             }
                                             else
                                             {
                                                 self.image = fetchedImage;
                                             }
                                         }
                                     } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
                                         
                                         DLog(@"%@", error);
                                     }];
    } else {
        
        DLog(@"No default engine found and imageCacheEngine parameter is null")
    }
    
    return self.imageFetchOperation2;
}

@end
