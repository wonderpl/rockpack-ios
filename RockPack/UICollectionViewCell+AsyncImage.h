//
//  UICollectionViewCell+AsyncImage.h
//  rockpack
//
//  Created by Nick Banks on 17/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MKNetworkOperation;

@interface UICollectionViewCell (AsyncImage)

- (void) loadAndCacheImageInView: (UIImageView *) imageView
                   withURLString: (NSString*) imageURLString
        andImageLoadingOperation: (MKNetworkOperation *) imageLoadingOperation;

@end
