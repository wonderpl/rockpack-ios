//
//  UIColor+SYNColor.m
//  RockPack
//
//  Created by Nick Banks on 15/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "UIColor+SYNColor.h"

@implementation UIColor (SYNColor)


+ (UIColor *) rockpackTitleColor
{
    return [UIColor colorWithRed: 1.0f green: 1.0f blue: 1.0f alpha: 1.0f];
}

+ (UIColor *) rockpackLogoColor
{
    return [UIColor colorWithRed: 29.0f/255.0f green: 194.0f/255.0f blue: 224.0f/255.0f alpha: 1.0f];
}


+ (UIColor *) rockpackSubtitleColor
{
    return [UIColor colorWithRed: 185.0f/255.0f green: 207.0f/255.0f blue: 216.0f/255.0f alpha: 1.0f];
}


+ (UIColor *) rockpackBlueColor
{
    return [UIColor colorWithRed: 36.0f/255.0f green: 202.0f/255.0f blue: 229.0f/255.0f alpha: 1.0f];
}

+ (UIColor *) rockpacTurcoiseColor
{
    return [UIColor colorWithRed: 179.0f/255.0f green: 207.0f/255.0f blue: 213.0f/255.0f alpha: 1.0f];
}

+ (UIColor *) rockpacLedColor
{
    return [UIColor colorWithRed: 45.0f/255.0f green: 53.0f/255.0f blue: 58.0f/255.0f alpha: 1.0f];
}


+ (UIColor *) rockpacAggregateTextLight
{
    return [UIColor colorWithRed: 170.0f/255.0f green: 170.0f/255.0f blue: 170.0f/255.0f alpha: 1.0f];
}

+ (UIColor *) rockpacAggregateTextBold
{
    return [UIColor colorWithRed: 40.0f/255.0f green: 45.0f/255.0f blue: 51.0f/255.0f alpha: 1.0f];
}


//For most text on Header bar on You Tab
+ (UIColor *) rockpackHeaderSubtitleColor
{
    return [UIColor colorWithRed: 146.0f/255.0f green: 169.0f/255.0f blue: 174.0f/255.0f alpha: 1.0f];
}

+ (UIColor *) colorWithHex:(NSInteger)hex
{
    return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:1.0];
}

@end
