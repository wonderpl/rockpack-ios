//
//  SYNVideoViewThumbnailLayoutAttributes.m
//  rockpack
//
//  Created by Nick Banks on 01/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNVideoViewerThumbnailLayoutAttributes.h"

@implementation SYNVideoViewerThumbnailLayoutAttributes

// We need to implement this custom copy, otherwise our new attribute will not be copied correctly
- (id) copyWithZone: (NSZone *) zone;
{
    SYNVideoViewerThumbnailLayoutAttributes *newCopy = [super copyWithZone: zone];
	newCopy.highlighted = self.isHighlighted;
    return(newCopy);
}


- (NSString *) description
{
    return([NSString stringWithFormat:@"%@ (Highlighted = %@)", [super description], self.isHighlighted ? @"YES" : @"NO"]);
}


@end
