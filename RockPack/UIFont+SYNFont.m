//
//  UIFont+SYNFont.m
//  RockPack
//
//  Created by Nick Banks on 15/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "UIFont+SYNFont.h"

@implementation UIFont (SYNFont)

+ (UIFont *) rockpackFontOfSize: (CGFloat) fontSize
{
    return [UIFont fontWithName: @"DINNextLTPro-Regular"
                           size: fontSize];
}


+ (UIFont *) boldRockpackFontOfSize: (CGFloat) fontSize
{
    return [UIFont fontWithName: @"DINNextLTPro-Bold"
                           size: fontSize];
}


+ (UIFont *) mediumRockpackFontOfSize: (CGFloat) fontSize
{
    return [UIFont fontWithName: @"DINNextLTPro-Medium"
                           size: fontSize];
}

@end
