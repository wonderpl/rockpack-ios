//
//  SYNVideoViewerThumbnailLayout.m
//  rockpack
//
//  Created by Nick Banks on 01/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNVideoViewerThumbnailLayout.h"
#import "SYNVideoViewerThumbnailLayoutAttributes.h"

@implementation SYNVideoViewerThumbnailLayout


+ (Class) layoutAttributesClass
{
    return [SYNVideoViewerThumbnailLayoutAttributes class];
}

- (BOOL) shouldInvalidateLayoutForBoundsChange: (CGRect) newBounds
{
    return YES;
}


#pragma mark - Attribute logic

- (void) applyLayoutAttributes: (UICollectionViewLayoutAttributes *) layoutAttributes
{
    if ([layoutAttributes.indexPath isEqual: self.selectedItemIndexPath])
    {
        [(SYNVideoViewerThumbnailLayoutAttributes *) layoutAttributes setHighlighted: YES];
    }
}


- (UICollectionViewLayoutAttributes *) layoutAttributesForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNVideoViewerThumbnailLayoutAttributes *layoutAttributes = (SYNVideoViewerThumbnailLayoutAttributes *)[super layoutAttributesForItemAtIndexPath: indexPath];
    
    // We use this to distinguish between cells, supplementary views and decoration views
    switch (layoutAttributes.representedElementCategory)
    {
        case UICollectionElementCategoryCell:
        {
            // Perform out logic if we are a cell
            [self applyLayoutAttributes: layoutAttributes];
        }
            break;
            
        default:
            // Ignore everything else for now
            DebugLog(@"Something else");
            break;
    }
    
    return layoutAttributes;
}

- (NSArray *) layoutAttributesForElementsInRect: (CGRect) rect
{
    NSArray *layoutAttributesArray = [super layoutAttributesForElementsInRect: rect];
    
    for (SYNVideoViewerThumbnailLayoutAttributes *layoutAttributes in layoutAttributesArray)
    {
        switch (layoutAttributes.representedElementCategory)
        {
            case UICollectionElementCategoryCell:
            {
                // Perform out logic if we are a cell
                [self applyLayoutAttributes: layoutAttributes];
            }
                break;
                
            default:
                // Ignore everything else for now
                DebugLog(@"Something else");
                break;
        }
    }
    
    return layoutAttributesArray;
}


@end
