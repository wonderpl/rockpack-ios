//
//  UIInterpolatingMotionEffect+DualAxis.m
//  rockpack
//
//  Created by Nick Banks on 24/08/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#ifdef __IPHONE_7_0

#import "UIInterpolatingMotionEffect+DualAxis.h"

@implementation UIInterpolatingMotionEffect (DualAxis)

+ (UIMotionEffectGroup *) dualAxisMotionEffectWithMaxDisplacement: (CGFloat) displacement
{
    if (displacement == 0.0f)
    {
        return nil;
    }
    
    UIInterpolatingMotionEffect *horizontalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath: @"center.x"
                                                                                                    type: UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalEffect.minimumRelativeValue = @(-displacement);
    horizontalEffect.maximumRelativeValue = @(displacement);
    
    UIInterpolatingMotionEffect *verticalEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath: @"center.y"
                                                                                                  type: UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalEffect.minimumRelativeValue = @(-displacement);
    verticalEffect.maximumRelativeValue = @(displacement);
    
    UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
    group.motionEffects = @[ horizontalEffect, verticalEffect ];

    return group;
}

@end

#endif
