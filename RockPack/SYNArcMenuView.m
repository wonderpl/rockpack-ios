//
//  SYNArcMenuView.m
//  rockpack
//
//  Created by Nick Banks on 12/08/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//
//
//  Based on https://github.com/levey/AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 Levey & Other Contributors. All rights reserved.

#import "SYNArcMenuView.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const kSYNArcMenuDefaultNearRadius = 110.0f;
static CGFloat const kSYNArcMenuDefaultEndRadius = 120.0f;
static CGFloat const kSYNArcMenuDefaultFarRadius = 140.0f;
static CGFloat const kSYNArcMenuDefaultStartPointX = 160.0;
static CGFloat const kSYNArcMenuDefaultStartPointY = 240.0;
static CGFloat const kSYNArcMenuDefaultTimeOffset = 0.036f;
static CGFloat const kSYNArcMenuDefaultRotateAngle = 0.0;
static CGFloat const kSYNArcMenuDefaultMenuWholeAngle = M_PI * 2;
static CGFloat const kSYNArcMenuDefaultExpandRotation = M_PI;
static CGFloat const kSYNArcMenuDefaultCloseRotation = M_PI * 2;
static CGFloat const kSYNArcMenuDefaultAnimationDuration = 0.5f;
static CGFloat const kSYNArcMenuStartMenuDefaultAnimationDuration = 0.3f;

static CGPoint RotateCGPointAroundCenter(CGPoint point, CGPoint center, float angle)
{
    CGAffineTransform translation = CGAffineTransformMakeTranslation(center.x, center.y);
    CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
    CGAffineTransform transformGroup = CGAffineTransformConcat(CGAffineTransformConcat(CGAffineTransformInvert(translation), rotation), translation);
    
    return CGPointApplyAffineTransform(point, transformGroup);
}

@interface SYNArcMenuView ()

@property (nonatomic, copy) NSArray *menusArray;
@property (nonatomic, getter = isExpanding) BOOL expanding;
@property (nonatomic, getter = isAnimating) BOOL animating;
@property (nonatomic, strong) SYNArcMenuItem *startButton;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) int flag;

@end


@implementation SYNArcMenuView

@synthesize expanding = _expanding;

#pragma mark - Initialization & Cleaning up
- (id) initWithFrame: (CGRect) frame
           startItem: (SYNArcMenuItem *) startItem
         optionMenus: (NSArray *) menuArray
{
    if ((self = [super initWithFrame: frame]))
    {
        self.backgroundColor = [UIColor clearColor];
        
        self.nearRadius = kSYNArcMenuDefaultNearRadius;
        self.endRadius = kSYNArcMenuDefaultEndRadius;
        self.farRadius = kSYNArcMenuDefaultFarRadius;
        self.timeOffset = kSYNArcMenuDefaultTimeOffset;
        self.rotateAngle = kSYNArcMenuDefaultRotateAngle;
        self.menuWholeAngle = kSYNArcMenuDefaultMenuWholeAngle;
        self.startPoint = CGPointMake(kSYNArcMenuDefaultStartPointX, kSYNArcMenuDefaultStartPointY);
        self.expandRotation = kSYNArcMenuDefaultExpandRotation;
        self.closeRotation = kSYNArcMenuDefaultCloseRotation;
        self.animationDuration = kSYNArcMenuDefaultAnimationDuration;
        
        self.menusArray = menuArray;
        
        // assign startItem to "Add" Button.
        self.startButton = startItem;
        self.startButton.delegate = (id<SYNArcMenuItemDelegate>) self;
        self.startButton.center = self.startPoint;
        [self addSubview: _startButton];
    }
    
    return self;
}


#pragma mark - Getters & Setters

- (void) setStartPoint: (CGPoint) point
{
    _startPoint = point;
    self.startButton.center = point;
}


#pragma mark - images

- (void) setImage: (UIImage *) image
{
    self.startButton.image = image;
}


- (UIImage *) image
{
    return self.startButton.image;
}


- (void) setHighlightedImage: (UIImage *) highlightedImage
{
    self.startButton.highlightedImage = highlightedImage;
}


- (UIImage *) highlightedImage
{
    return self.startButton.highlightedImage;
}


- (void) setContentImage: (UIImage *) contentImage
{
    self.startButton.contentImageView.image = contentImage;
}


- (UIImage *) contentImage
{
    return self.startButton.contentImageView.image;
}


- (void) setHighlightedContentImage: (UIImage *) highlightedContentImage
{
    self.startButton.contentImageView.highlightedImage = highlightedContentImage;
}


- (UIImage *) highlightedContentImage
{
    return self.startButton.contentImageView.highlightedImage;
}


#pragma mark - UIView's methods

- (BOOL) pointInside: (CGPoint) point
           withEvent: (UIEvent *) event
{
    // if the menu is animating, prevent touches
    if (self.isAnimating)
    {
        return NO;
    }
    
    // if the menu state is expanding, everywhere can be touch
    // otherwise, only the add button are can be touch
    if (self.isExpanding == YES)
    {
        return YES;
    }
    else
    {
        return CGRectContainsPoint(self.startButton.frame, point);
    }
}


- (void) touchesBegan: (NSSet *) touches
            withEvent: (UIEvent *) event
{
    self.expanding = !self.isExpanding;
}


#pragma mark - SYNArcMenuItem delegates

- (void) arcMenuItemTouchesBegan: (SYNArcMenuItem *) item
{
    if (self.startButton == item)
    {
        self.expanding = !self.isExpanding;
    }
}


- (void) arcMenuItemTouchesEnd: (SYNArcMenuItem *) item
{
    // exclude the "add" button
    if (self.startButton == item)
    {
        return;
    }
    
    // blowup the selected menu button
    CAAnimationGroup *blowup = [self blowupAnimationAtPoint: item.center];
    
    [item.layer addAnimation: blowup
                      forKey: @"blowup"];
    
    item.center = item.startPoint;
    
    // shrink other menu buttons
    for (int i = 0; i < self.menusArray.count; i++)
    {
        SYNArcMenuItem *otherItem = self.menusArray [i];
        
        CAAnimationGroup *shrink = [self shrinkAnimationAtPoint: otherItem.center];
        
        if (otherItem.tag == item.tag)
        {
            continue;
        }
        
        [otherItem.layer addAnimation: shrink
                               forKey: @"shrink"];
        
        otherItem.center = otherItem.startPoint;
    }
    
    self.expanding = NO;
    
    if ([self.delegate respondsToSelector: @selector(arcMenu:didSelectIndex:)])
    {
        [self.delegate arcMenu: self didSelectIndex: item.tag - 1000];
    }
}


#pragma mark - Instant methods

- (void) setMenusArray: (NSArray *) menusArray
{
    if (self.menusArray == menusArray)
    {
        return;
    }
    
    _menusArray = [menusArray copy];
    
    // clean subviews
    for (UIView *v in self.subviews)
    {
        if (v.tag >= 1000)
        {
            [v removeFromSuperview];
        }
    }
}


- (void) setMenu
{
    int count = self.menusArray.count;
    
    for (int i = 0; i < count; i++)
    {
        SYNArcMenuItem *item = self.menusArray[i];
        item.tag = 1000 + i;
        item.startPoint = self.startPoint;
        
        // avoid overlap
        if (self.menuWholeAngle >= M_PI * 2)
        {
            self.menuWholeAngle = self.menuWholeAngle - self.menuWholeAngle / count;
        }
        
        CGPoint endPoint = CGPointMake(self.startPoint.x + self.endRadius * sinf(i * self.menuWholeAngle / (count - 1)), self.startPoint.y - self.endRadius * cosf(i * self.menuWholeAngle / (count - 1)));
        
        item.endPoint = RotateCGPointAroundCenter(endPoint, self.startPoint, self.rotateAngle);
        
        CGPoint nearPoint = CGPointMake(self.startPoint.x + self.nearRadius * sinf(i * self.menuWholeAngle / (count - 1)), self.startPoint.y - self.nearRadius * cosf(i * self.menuWholeAngle / (count - 1)));
        
        item.nearPoint = RotateCGPointAroundCenter(nearPoint, self.startPoint, self.rotateAngle);
        
        CGPoint farPoint = CGPointMake(self.startPoint.x + self.farRadius * sinf(i * self.menuWholeAngle / (count - 1)), self.startPoint.y - self.farRadius * cosf(i * self.menuWholeAngle / (count - 1)));
        
        item.farPoint = RotateCGPointAroundCenter(farPoint, self.startPoint, self.rotateAngle);
        item.center = item.startPoint;
        
        // The images are actually double-size, so scale them down
        item.transform = CGAffineTransformMakeScale(0.5, 0.5);
        
        item.delegate = (id<SYNArcMenuItemDelegate>) self;
        
        [self insertSubview: item
               belowSubview: self.startButton];
    }
}


- (BOOL) isExpanding
{
    return _expanding;
}


- (void) setExpanding: (BOOL) expanding
{
    if (expanding)
    {
        [self setMenu];
    }
    
    _expanding = expanding;
    
    // expand or close animation
    if (!self.timer)
    {
        self.flag = self.isExpanding ? 0 : (self.menusArray.count - 1);
        SEL selector = self.isExpanding ? @selector(expandMenu) : @selector(closeMenu);
        
        // Adding timer to runloop to make sure UI event won't block the timer from firing
        self.timer = [NSTimer timerWithTimeInterval: self.timeOffset
                                             target: self
                                           selector: selector
                                           userInfo: nil
                                            repeats: YES];
        
        [[NSRunLoop currentRunLoop] addTimer: self.timer
                                     forMode: NSRunLoopCommonModes];
        self.animating = YES;
    }
}


#pragma mark - Private methods

- (void) expandMenu
{
    if (self.flag == self.menusArray.count)
    {
        self.animating = NO;
        [self.timer invalidate];
        self.timer = nil;
        
        return;
    }
    
    int tag = 1000 + self.flag;
    SYNArcMenuItem *item = (SYNArcMenuItem *) [self viewWithTag: tag];
    
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath: @"transform.rotation.z"];
    
    rotateAnimation.values = @[@(self.expandRotation), @(0.0f)];
    rotateAnimation.duration = self.animationDuration;
    rotateAnimation.keyTimes = @[@(0.3f), @(0.4f)];
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath: @"position"];
    positionAnimation.duration = self.animationDuration;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.startPoint.x, item.startPoint.y);
    CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
    CGPathAddLineToPoint(path, NULL, item.nearPoint.x, item.nearPoint.y);
    CGPathAddLineToPoint(path, NULL, item.endPoint.x, item.endPoint.y);
    positionAnimation.path = path;
    CGPathRelease(path);
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects: positionAnimation, rotateAnimation, nil];
    animationgroup.duration = self.animationDuration;
    animationgroup.fillMode = kCAFillModeForwards;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseIn];
    animationgroup.delegate = self;
    
    if (self.flag == self.menusArray.count - 1)
    {
        [animationgroup setValue: @"firstAnimation"
                          forKey: @"id"];
    }
    
    [item.layer addAnimation: animationgroup
                      forKey: @"Expand"];
    
    item.center = item.endPoint;
    
    self.flag++;
}


- (void) closeMenu
{
    if (self.flag == -1)
    {
        self.animating = NO;
        [self.timer invalidate];
        self.timer = nil;
        
        return;
    }
    
    int tag = 1000 + self.flag;
    SYNArcMenuItem *item = (SYNArcMenuItem *) [self viewWithTag: tag];
    
    // Rotation animation
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath: @"transform.rotation.z"];
    
    rotateAnimation.values = @[@(0.0f), @(self.closeRotation), @(0.0f)];
    rotateAnimation.duration = self.animationDuration;
    rotateAnimation.keyTimes = @[@(0.0f), @(0.4f), @(0.5f)];
    
    // Position animation
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath: @"position"];
    
    positionAnimation.duration = self.animationDuration;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.endPoint.x, item.endPoint.y);
    CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
    CGPathAddLineToPoint(path, NULL, item.startPoint.x, item.startPoint.y);
    positionAnimation.path = path;
    CGPathRelease(path);
    
    // Animation
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects: positionAnimation, rotateAnimation, nil];
    animationgroup.duration = self.animationDuration;
    animationgroup.fillMode = kCAFillModeForwards;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseIn];
    animationgroup.delegate = self;
    
    if (self.flag == 0)
    {
        [animationgroup setValue: @"lastAnimation"
                          forKey: @"id"];
    }
    
    [item.layer
     addAnimation: animationgroup
     forKey: @"Close"];
    item.center = item.startPoint;
    
    self.flag--;
}


- (void) animationDidStop: (CAAnimation *) animation
                 finished: (BOOL) hasFinished
{
    if ([[animation valueForKey: @"id"] isEqual: @"lastAnimation"])
    {
        if (self.delegate && [self.delegate respondsToSelector: @selector(arcMenuDidFinishAnimationClose:)])
        {
            [self.delegate arcMenuDidFinishAnimationClose: self];
        }
    }
    
    if ([[animation valueForKey: @"id"] isEqual: @"firstAnimation"])
    {
        if (self.delegate && [self.delegate respondsToSelector: @selector(arcMenuDidFinishAnimationOpen:)])
        {
            [self.delegate arcMenuDidFinishAnimationOpen: self];
        }
    }
}


- (CAAnimationGroup *) blowupAnimationAtPoint: (CGPoint) point
{
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath: @"position"];
    
    positionAnimation.values = [NSArray arrayWithObjects: [NSValue valueWithCGPoint: point], nil];
    
    positionAnimation.keyTimes = @[@(0.3f)];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath: @"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D: CATransform3DMakeScale(3, 3, 1)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath: @"opacity"];
    opacityAnimation.toValue = @(0.0f);
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    
    animationgroup.animations = @[positionAnimation, scaleAnimation, opacityAnimation];
    
    animationgroup.duration = self.animationDuration;
    animationgroup.fillMode = kCAFillModeForwards;
    
    return animationgroup;
}


- (CAAnimationGroup *) shrinkAnimationAtPoint: (CGPoint) point
{
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath: @"position"];
    
    positionAnimation.values = [NSArray arrayWithObjects: [NSValue valueWithCGPoint: point], nil];
    positionAnimation.keyTimes = @[@(0.3f)];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath: @"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D: CATransform3DMakeScale(.01, .01, 1)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath: @"opacity"];
    opacityAnimation.toValue = @(0.0f);
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    
    animationgroup.animations = @[positionAnimation, scaleAnimation, opacityAnimation];
    
    animationgroup.duration = self.animationDuration;
    animationgroup.fillMode = kCAFillModeForwards;
    
    return animationgroup;
}


@end
