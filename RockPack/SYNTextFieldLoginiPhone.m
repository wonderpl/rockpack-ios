//
//  SYNTestFieldLoginiPhone.m
//  rockpack
//
//  Created by Nick Banks on 06/06/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNTextFieldLoginiPhone.h"

@implementation SYNTextFieldLoginiPhone

- (CGRect) placeholderRectForBounds: (CGRect) bounds
{
    return CGRectOffset( bounds, 0,  2);
}

- (CGRect) editingRectForBounds: (CGRect) bounds
{
    bounds.size.width -= 25;
    return CGRectOffset( bounds, 0, 0);
}

- (CGRect) textRectForBounds: (CGRect) bounds
{
    bounds.size.width -= 25;
    return CGRectOffset( bounds , 0 , 2);
}
@end
