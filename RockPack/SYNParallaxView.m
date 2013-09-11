//
//  SYNParallaxView.m
//  rockpack
//
//  Created by Nick Banks on 24/08/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#ifdef __IPHONE_7_0

#import "SYNParallaxView.h"
#import "UIImage+ImageEffects.h"
#import "UIInterpolatingMotionEffect+DualAxis.h"

@interface SYNParallaxView ()
{
    BOOL _needsUpdateBackground;
    BOOL _isRenderingBackground;
    
    UIView *_backgroundView;
    BOOL _backgroundViewHasImage;
    
    UIMotionEffect *_motionEffect;
    UIMotionEffect *_backgroundMotionEffect;
}

@end


@implementation SYNParallaxView

static const CGFloat kFLDownscaleFactorDefault = 8.0f;
static const CGFloat kFLBlurRadiusDefault = 30.0f;
static const CGFloat kFLSaturationDeltaFactorDefault = 1.8f;
static const NSTimeInterval kFLFadeInDurationDefault = 0.15;
static UIColor *kFLBackgroundTintColorDefault;

+ (void) initialize
{
    kFLBackgroundTintColorDefault = [UIColor colorWithWhite: 1.0
                                                      alpha: 0.3];
}


- (id) initWithFrame: (CGRect) frame
{
    self = [super initWithFrame: frame];
    
    if (self)
    {
        [self setupBackground];
        
        _downscaleFactor = kFLDownscaleFactorDefault;
        _blurRadius = kFLBlurRadiusDefault;
        _saturationDeltaFactor = kFLSaturationDeltaFactorDefault;
        _backgroundTintColor = kFLBackgroundTintColorDefault;
        
        self.backgroundColor = self.backgroundTintColor;
    }
    
    return self;
}


- (id) initWithCoder: (NSCoder *) aDecoder
{
    _downscaleFactor = kFLDownscaleFactorDefault;
    _blurRadius = kFLBlurRadiusDefault;
    _saturationDeltaFactor = kFLSaturationDeltaFactorDefault;
    _backgroundTintColor = kFLBackgroundTintColorDefault;
    
    self = [super initWithCoder: aDecoder];
    
    if (self)
    {
        [self _setupBackground];
        
        self.backgroundColor = self.backgroundTintColor;
    }
    
    return self;
}


- (void) setupBackground
{
    self.layer.masksToBounds = YES;
    _backgroundView = [[UIImageView alloc] initWithFrame: self.bounds];
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview: _backgroundView];
    [self sendSubviewToBack: _backgroundView];
    
    [self updateBackgroundFrame];
    [self _updateBackgroundContentsRect];
}


- (void) setFrame: (CGRect) frame
{
    [super setFrame: frame];
    
    [self _updateBackgroundContentsRect];
}


- (void) setBounds: (CGRect) bounds
{
    [super setBounds: bounds];
    
    [self _updateBackgroundContentsRect];
}


- (void) setCenter: (CGPoint) center
{
    [super setCenter: center];
    
    [self _updateBackgroundContentsRect];
}


- (void) setSnapshottedView: (UIView *) snapshottedView
{
    _snapshottedView = snapshottedView;
    
    [self updateBackgroundDeferredIfPossible];
}


- (void) setSnapshotContents: (UIImage *) snapshotContents
{
    _snapshotContents = snapshotContents;
    
    [self updateBackgroundDeferredIfPossible];
}


- (void) setMotionEffectDisplacement: (CGFloat) motionEffectDisplacement
{
    _motionEffectDisplacement = motionEffectDisplacement;
    
    if (_motionEffect != nil)
    {
        [self removeMotionEffect: _motionEffect];
    }
    
    if (_backgroundMotionEffect != nil)
    {
        [self removeMotionEffect: _backgroundMotionEffect];
    }
    
    [self updateBackgroundFrame];
    
    if (motionEffectDisplacement != 0.0f)
    {
        _motionEffect = [UIInterpolatingMotionEffect bidirectionalCenterMotionEffectAttachedToView: self
                                                                                     withAmplitude: motionEffectDisplacement];
        
        _backgroundMotionEffect = [UIInterpolatingMotionEffect bidirectionalCenterMotionEffectAttachedToView: _backgroundView
                                                                                               withAmplitude: -motionEffectDisplacement];
    }
}


- (void) setDownscaleFactor: (CGFloat) downscaleFactor
{
    if (downscaleFactor < 1.0f)
    {
        downscaleFactor = 1.0f;
    }
    
    _downscaleFactor = downscaleFactor;
}


- (void) setBackgroundTintColor: (UIColor *) backgroundTintColor
{
    _backgroundTintColor = backgroundTintColor;
    
    self.backgroundColor = backgroundTintColor;
}


- (void) setNeedsUpdateBackground
{
    _needsUpdateBackground = YES;
    [self updateBackgroundDeferredIfPossible];
}


- (void) invalidateBackground
{
    _backgroundView.layer.contents = nil;
    _backgroundViewHasImage = NO;
    [self setNeedsUpdateBackground];
}


- (void) didMoveToWindow
{
    [super didMoveToWindow];
    
    if (self.needsUpdateBackground)
    {
        [self updateBackgroundDeferredIfPossible];
    }
}


- (void) updateBackgroundDeferredIfPossible
{
    if (_isRenderingBackground)
    {
        return;
    }
    
    if (self.snapshotContents != nil)
    {
        // no need to defer the rendering - we already have the snapshot contents
        [self _renderBackground];
    }
    else if (self.snapshottedView.window != nil)
    {
        if (self.shouldRenderImmediately)
        {
            // client code knows that no delay is necessary
            [self _renderBackground];
        }
        else
        {
            // a small delay is added so that snapshotted view is already rendered by the time we request a snapshot
            [self performSelector: @selector(_renderBackground)
                       withObject: nil
                       afterDelay: 0.01];
        }
    }
}


- (void) _renderBackground
{
    if (_isRenderingBackground)
    {
        NSLog(@"_renderBackground method called while already rendering background.");
    }
    
    UIView *snapshottedView = self.snapshottedView;
    
    if (self.snapshotContents == nil)
    {
        if (snapshottedView == nil)
        {
            NSLog(@"Can't render background without snapshotted view.");
            return;
        }
        
        if (snapshottedView.window == nil)
        {
            NSLog(@"Can't render snapshot view if it's not inside a window.");
            return;
        }
    }
    
    _needsUpdateBackground = NO;
    _isRenderingBackground = YES;
    
    // use snapshot contents property if it's set, or take view's snapshot otherwise
    UIImage *snapshot = self.snapshotContents;
    CGFloat downscaleFactor = self.downscaleFactor;
    
    if (snapshot == nil)
    {
        CGSize imageSize = snapshottedView.bounds.size;
        imageSize.width = (int) (imageSize.width / downscaleFactor);
        imageSize.height = (int) (imageSize.height / downscaleFactor);
        
        UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0);
        BOOL success = [snapshottedView drawViewHierarchyInRect: CGRectMake(0, 0, imageSize.width, imageSize.height)];
        
        if (!success)
        {
            DDLogWarn(@"Failed to draw view hierarchy!");
        }
        
        snapshot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *outputImage = [snapshot applyBlurWithRadius: _blurRadius / downscaleFactor
                                                   tintColor: _backgroundTintColor
                                       saturationDeltaFactor: _saturationDeltaFactor
                                                   maskImage: nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _isRenderingBackground = NO;
            
            _backgroundView.layer.contents = (__bridge id) (outputImage.CGImage);
            
            if (!_backgroundViewHasImage && !self.shouldRenderImmediately)
            {
                // show background view non-instantly if it didn't have an image
                _backgroundView.alpha = 0.0f;
                [UIView animateWithDuration: 0.15
                                 animations: ^{
                                     _backgroundView.alpha = 1.0f;
                                 }];
            }
            
            _backgroundViewHasImage = YES;
            
            [self _updateBackgroundContentsRect];
            
            // make the next render if it was scheduled
            if (_needsUpdateBackground)
            {
                [self _renderBackground];
            }
        });
    });
}


- (void) updateBackgroundFrame
{
    CGFloat motionEffectAmplitude = fabsf(self.motionEffectAmplitude);
    CGSize ownSize = self.bounds.size;
    
    _backgroundView.frame = CGRectMake(-motionEffectAmplitude, -motionEffectAmplitude, ownSize.width + motionEffectAmplitude * 2, ownSize.height + motionEffectAmplitude * 2);
    
    [self updateBackgroundContentsRect];
}


- (void) updateBackgroundContentsRect
{
    CGRect backgroundViewRelativeFrame = [self.snapshottedView
                                          convertRect: _backgroundView.frame
                                          fromView: self];
    CGSize snapshottedViewSize = (self.snapshotContents != nil ? self.snapshotContents.size : self.snapshottedView.bounds.size);
    
    if (snapshottedViewSize.width == 0.0f || snapshottedViewSize.height == 0.0f)
    {
        return;
    }
    
    _backgroundView.layer.contentsRect = CGRectMake(backgroundViewRelativeFrame.origin.x / snapshottedViewSize.width, backgroundViewRelativeFrame.origin.y / snapshottedViewSize.height, backgroundViewRelativeFrame.size.width / snapshottedViewSize.width, backgroundViewRelativeFrame.size.height / snapshottedViewSize.height);
}

@end

#endif
