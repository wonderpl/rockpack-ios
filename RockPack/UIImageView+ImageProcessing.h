//
//  UIImageView+ImageProcessing.h
//  rockpack
//
//  Created by Nick Banks on 01/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKNetworkKit.h"

@class MKNetworkEngine;
@class MKNetworkOperation;

@interface UIImageView (ImageProcessing)

+ (void) setDefaultEngine2: (MKNetworkEngine*) engine;

- (MKNetworkOperation*) setAsynchronousImageFromURL: (NSURL*) url
                                   placeHolderImage: (UIImage*) image;

- (MKNetworkOperation*) setAsynchronousImageFromURL: (NSURL*) url
                                   placeHolderImage: (UIImage*) image
                                        usingEngine: (MKNetworkEngine*) imageCacheEngine
                                          animation: (BOOL) yesOrNo;

- (MKNetworkOperation*) setAsynchronousImageFromURL: (NSURL*) url
                                   placeHolderImage: (UIImage*) image
                                         monochrome: (BOOL) isMonochrome;


- (void) setAsynchronousImageFromURL: (NSURL*) url
                   completionHandler: (MKNKImageBlock) completionHandler
                        errorHandler: (MKNKResponseErrorBlock) errorHandler;

@end
