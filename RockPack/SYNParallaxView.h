//
//  SYNParallaxView.h
//  rockpack
//
//  Created by Nick Banks on 24/08/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//
//  Adapted from code by Vlas Voloshin on 6/20/13.
//  Copyright (c) 2013 Lodoss. All rights reserved.
//

#ifdef __IPHONE_7_0

#import <UIKit/UIKit.h>

@interface SYNParallaxView : UIView

// View that is snapshotted to be used as receiver's blurred background.
// This view's hierarchy should not include receiver as this would lead to receiver being included in the snapshot.
@property (nonatomic, strong) UIView *snapshottedView;

// Image used instead of rendering `snapshottedView` for increased performance, or nil.
@property (nonatomic, strong) UIImage *snapshotContents;

// Maximum deviation of view's bidirectional center motion effect.
// Positive values make view look "floating" above, while negative ones make it appear lower. Default value: 0.
@property (nonatomic, assign) CGFloat motionEffectDisplacement;

// Downscale factor applied when taking a snapshot. Higher values mean smaller snapshots, and hence - higher performance.
// Default value is 8, minimum value is 1.
@property (nonatomic, assign) CGFloat downscaleFactor;

// Radius of blur applied to view background, with minimum of 0. Default value: 30.
@property (nonatomic, assign) CGFloat blurRadius;

// Saturation factor applied to view background, with minimum of 0 (full desaturation) and normal value of 0 (no desaturation).  Default value: 1.8.
@property (nonatomic, assign) CGFloat saturationDeltaFactor;

// Tint color applied to view background. Default value: white, 30% opaque.
@property (nonatomic, strong) UIColor *backgroundTintColor;

// Defines that blurred view should render its `snapshottedView` immediately.
// Set it to YES if you know that contents of `snapshottedView` will already be available at render server by the time background is invalidated.
@property (nonatomic, assign) BOOL shouldRenderImmediately;

// Marks the view as needing an update of its background. Update is performed asynchronously and might take some time.
- (void) setNeedsUpdateBackground;

// Invalidates blurred background image and removes it, calling `setNeedsUpdateBackground` afterward to redraw it.
- (void) invalidateBackground;

@end

#endif
