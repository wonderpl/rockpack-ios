//
//  SYNDeletionWobbleLayoutAttributes.m
//  rockpack
//
//  Created by Nick Banks on 01/05/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNDeletionWobbleLayoutAttributes.h"

@implementation SYNDeletionWobbleLayoutAttributes

- (id) copyWithZone: (NSZone *) zone
{
    SYNDeletionWobbleLayoutAttributes *attributes = [super copyWithZone: zone];
    attributes.deleteButtonHidden = _deleteButtonHidden;
    
    return attributes;
}

@end
