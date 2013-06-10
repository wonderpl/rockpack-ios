//
//  SYNDeletionWobbleLayout.m
//  rockpack
//
//  Created by Nick Banks on 01/05/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNDeletionWobbleLayout.h"
#import "SYNDeletionWobbleLayoutAttributes.h" 


@implementation SYNDeletionWobbleLayout

+ (SYNDeletionWobbleLayout*) layoutWithItemSize: (CGSize) itemSize
                        minimumInterItemSpacing: (CGFloat) minSpace
                             minimumLineSpacing: (CGFloat) lineSpace
                                scrollDirection: (UICollectionViewScrollDirection) scrollDirection
                                   sectionInset: (UIEdgeInsets) insets
{
    SYNDeletionWobbleLayout *standardFlowLayout = [[SYNDeletionWobbleLayout alloc] init];
    
    standardFlowLayout.itemSize = itemSize;
    standardFlowLayout.minimumInteritemSpacing = minSpace;
    standardFlowLayout.minimumLineSpacing = lineSpace;
    standardFlowLayout.scrollDirection = scrollDirection;
    standardFlowLayout.sectionInset = insets;
    
    return standardFlowLayout;
}


- (id) init
{
    if ((self = [super init]))
    {
        // Any setup goes here
    }
    
    return self;
}




- (BOOL) isDeletionModeOn
{
    if ([[self.collectionView.delegate class] conformsToProtocol: @protocol(SYNDeletionWobbleLayoutDelegate)])
    {
        return [(id)self.collectionView.delegate isDeletionModeActiveForCollectionView: self.collectionView
                                                                                layout: self]; 
    }
    
    return NO;
}


+ (Class) layoutAttributesClass
{
    return [SYNDeletionWobbleLayoutAttributes class];
}


- (SYNDeletionWobbleLayoutAttributes *) layoutAttributesForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNDeletionWobbleLayoutAttributes *attributes = (SYNDeletionWobbleLayoutAttributes *)[super layoutAttributesForItemAtIndexPath: indexPath];
    
    if (self.isDeletionModeOn)
    {
        attributes.deleteButtonHidden = NO;
    }
    else
    {
        attributes.deleteButtonHidden = YES;
    }
    
    return attributes;
}


- (NSArray *) layoutAttributesForElementsInRect: (CGRect) rect
{
    NSArray *attributesArrayInRect = [super layoutAttributesForElementsInRect: rect];
    
    for (SYNDeletionWobbleLayoutAttributes *attribs in attributesArrayInRect)
    {
        if (self.isDeletionModeOn)
        {
            attribs.deleteButtonHidden = NO;
        }
        else
        {
            attribs.deleteButtonHidden = YES;
        }
    }
    
    return attributesArrayInRect;
}

@end
