//
//  UIColor+SYNColor.h
//  RockPack
//
//  Created by Nick Banks on 15/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (SYNColor)

+ (UIColor *) rockpackTitleColor;
+ (UIColor *) rockpackSubtitleColor;
+ (UIColor *) rockpackBlueColor;
+ (UIColor *) rockpackLogoColor;
+ (UIColor *) rockpacLedColor;
+ (UIColor *) rockpacTurcoiseColor;
+ (UIColor *) rockpackHeaderSubtitleColor;

+ (UIColor *) rockpackBackgroundGrayColor;

+ (UIColor *) rockpacAggregateTextLight;
+ (UIColor *) rockpacAggregateTextBold;

+ (UIColor *) colorWithHex:(NSInteger)hex;

@end
