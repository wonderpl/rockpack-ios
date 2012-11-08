//
//  SYNUserCollectionViewLayoutAttributes.m
//  rockpack
//
//  Created by Nick Banks on 08/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNUserCollectionViewLayoutAttributes.h"

@implementation SYNUserCollectionViewLayoutAttributes

- (id) init
{
    if ((self = [super init]))
    {
        self.userDefinedCenter = CGPointMake(0.0f, 0.0f);
    }
    
    return self;
}

@end
