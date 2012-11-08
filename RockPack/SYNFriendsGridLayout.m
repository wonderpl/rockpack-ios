//
//  SYNFriendsGridLayout.m
//  rockpack
//
//  Created by Nick Banks on 07/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNFriendsGridLayout.h"
#import "SYNUserCollectionViewLayoutAttributes.h"

@implementation SYNFriendsGridLayout

+ (Class) layoutAttributesClass
{
    return [SYNUserCollectionViewLayoutAttributes class];
}

- (id) init
{
    if ((self = [super init]))
    {
        self.itemSize = CGSizeMake(198, 177);
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.minimumLineSpacing = -115.0;
    }
    
    return self;
}

- (BOOL) shouldInvalidateLayoutForBoundsChange: (CGRect) oldBounds
{
    return YES;
}

@end
