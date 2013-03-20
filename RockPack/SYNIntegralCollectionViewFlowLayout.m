//
//  SYNIntegralCollectionFlowLayout.m
//  rockpack
//
//  Created by Nick Banks on 30/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//
//  Solution #1 Inspired by...
//  
//  https://gist.github.com/4546014.git

#import "SYNIntegralCollectionViewFlowLayout.h"

@implementation SYNIntegralCollectionViewFlowLayout




//  Solution #2 Inspired by...
//
//  https://gist.github.com/4075682.git

- (NSArray *) layoutAttributesForElementsInRect: (CGRect) rect
{
    NSArray *attributes = [super layoutAttributesForElementsInRect: rect];
    
    NSMutableArray *newAttributes = [NSMutableArray arrayWithCapacity:attributes.count];
    
    for (UICollectionViewLayoutAttributes *attribute in attributes)
    {
        if (attribute.frame.origin.x + attribute.frame.size.width <= self.collectionViewContentSize.width)
        {
            [newAttributes addObject:attribute];
        }
        
        // Also include this to ensure that we don't have fractional offsets
        attribute.frame = CGRectIntegral(attribute.frame);
    }
    return newAttributes;
}

@end