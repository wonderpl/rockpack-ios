//
//  SYNTextFieldLogin.m
//  rockpack
//
//  Created by Nick Banks on 06/06/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNTextFieldLogin.h"

@implementation SYNTextFieldLogin

- (CGRect) placeholderRectForBounds: (CGRect) bounds
{
    return CGRectOffset( bounds, 10,  4);
}

- (CGRect) editingRectForBounds: (CGRect) bounds
{
    bounds.size.width -= 35;
    return CGRectOffset( bounds, 10, 2);
}

- (CGRect) textRectForBounds: (CGRect) bounds
{
    bounds.size.width -= 35;
    return CGRectOffset( bounds , 10 , 4 );
}

@end
