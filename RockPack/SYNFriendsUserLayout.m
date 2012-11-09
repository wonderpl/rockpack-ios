//
//  SYNWallpackCarouselUserLayout.m
//  rockpack
//
//  Created by Nick Banks on 07/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNFriendsUserLayout.h"
#import "SYNUserCollectionViewLayoutAttributes.h"

@implementation SYNFriendsUserLayout

+ (Class) layoutAttributesClass
{
    return [SYNUserCollectionViewLayoutAttributes class];
}

- (CGSize)collectionViewContentSize
{
    return [self collectionView].frame.size;
}

@end
