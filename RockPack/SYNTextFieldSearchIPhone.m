//
//  SYNTextFieldSearchIPhone.m
//  rockpack
//
//  Created by Nick Banks on 06/06/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNTextFieldSearchIPhone.h"

@implementation SYNTextFieldSearchIPhone

- (CGRect) placeholderRectForBounds: (CGRect) bounds
{
    return CGRectOffset( bounds, 0,  4);
}

- (CGRect) editingRectForBounds: (CGRect) bounds
{
    return CGRectOffset( bounds, 0, 2);
}

- (CGRect) textRectForBounds: (CGRect) bounds
{
    return CGRectOffset( bounds, 0, 4);
}

@end
