//
//  SYNWallpackCarouselVerticalLayout.m
//  RockPack
//
//  Created by Nick Banks on 16/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNWallpackCarouselVerticalLayout.h"

#define ITEM_SIZE 200.0

#define ACTIVE_DISTANCE 200

@implementation SYNWallpackCarouselVerticalLayout

- (id) init
{
    if ((self = [super init]))
    {
        self.itemSize = CGSizeMake(ITEM_SIZE, ITEM_SIZE);
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        //        self.sectionInset = UIEdgeInsetsMake(200, 0.0, 200, 0.0);
        self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.minimumLineSpacing = -115.0;
    }
    
    return self;
}

- (BOOL) shouldInvalidateLayoutForBoundsChange: (CGRect) oldBounds
{
    return YES;
}

- (NSArray*) layoutAttributesForElementsInRect: (CGRect) rect
{
    NSArray* array = [super layoutAttributesForElementsInRect: rect];
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    
    for (UICollectionViewLayoutAttributes* attributes in array)
    {
        if (CGRectIntersectsRect(attributes.frame, rect))
        {
            CGFloat distance = CGRectGetMidY(visibleRect) - attributes.center.y;
            CGFloat normalizedDistance = distance / ACTIVE_DISTANCE;
            if (ABS(distance) < ACTIVE_DISTANCE)
            {
                CGFloat zoom = 0.5 + ((1 - ABS(normalizedDistance)) / 2);
                attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1.0);
                attributes.zIndex = 1000 - ABS(distance);
            }
            else
            {
                //                attributes.transform3D = CATransform3DMakeScale(0.5, 0.5, 1.0);
                attributes.hidden = TRUE;
            }
        }
    }
    return array;
}


- (CGPoint) targetContentOffsetForProposedContentOffset: (CGPoint) proposedContentOffset
                                  withScrollingVelocity: (CGPoint) velocity
{
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.y + (CGRectGetHeight(self.collectionView.bounds) / 2.0);
    
    CGRect targetRect = CGRectMake(0.0, proposedContentOffset.y, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSArray* array = [super layoutAttributesForElementsInRect:targetRect];
    
    for (UICollectionViewLayoutAttributes* layoutAttributes in array)
    {
        CGFloat itemHorizontalCenter = layoutAttributes.center.y;
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment))
        {
            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
        }
    }
    return CGPointMake(proposedContentOffset.x, proposedContentOffset.y + offsetAdjustment);
}

@end

