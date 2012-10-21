//
//  SYNSelection.m
//  rockpack
//
//  Created by Nick Banks on 21/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNSelection.h"

@interface SYNSelection ()

@property (nonatomic, assign) int index;
@property (nonatomic, assign) int offset;

@end

@implementation SYNSelection

- (id) initWithIndex: (int) index
           andOffset: (int) offset
{
    if ((self = [super init]))
    {
        self.index = index;
        self.offset = offset;
    }
    
    return self;
}

@end
