//
//  UIInterpolatingMotionEffect+DualAxis.h
//  rockpack
//
//  Created by Nick Banks on 24/08/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//


#ifdef __IPHONE_7_0

@interface UIInterpolatingMotionEffect (DualAxis)

+ (UIMotionEffectGroup *) dualAxisMotionEffectWithMaxDisplacement: (CGFloat) displacement;

@end

#endif
