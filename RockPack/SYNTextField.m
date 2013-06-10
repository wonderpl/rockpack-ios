//
//  SYNTextField.m
//  rockpack
//
//  Created by Nick Banks on 06/06/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//
//  Bodge for custom font alignment in UITextFields

#import "SYNTextField.h"

@implementation SYNTextField

- (CGRect) placeholderRectForBounds: (CGRect) bounds
{
    return CGRectOffset( bounds, 0,  3);
}

- (CGRect) editingRectForBounds: (CGRect) bounds
{
    return CGRectOffset( bounds, 0, 0);
}

- (CGRect) textRectForBounds: (CGRect) bounds
{
    return CGRectOffset( bounds , 0 , 3 );
}

@end
