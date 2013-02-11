//
//  SYNTextView.m
//  rockpack
//
//  Created by Nick Banks on 28/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//
// Hack to make UITextFields with custom fonts work correctly

#import "SYNTextField.h"

@implementation SYNTextField

- (CGRect) placeholderRectForBounds: (CGRect) bounds
{
    return CGRectOffset(bounds, 0, 4);
}

- (CGRect) editingRectForBounds: (CGRect) bounds
{
    return CGRectOffset(bounds, 0, 3);
}

- (CGRect) textRectForBounds: (CGRect) bounds
{
    return CGRectOffset(bounds, 0, 6);
}

@end
