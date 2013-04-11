//
//  SYNRefreshButton.m
//  rockpack
//
//  Created by Michael Michailidis on 11/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNRefreshButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation SYNRefreshButton


- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    
    if (self) {
       
        
        UIImageView* bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
        [self addSubview:bg];
        
        
        image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
        [self addSubview:image];
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = bg.frame;
        [self addSubview:button];
        
        
    }
    
    return self;
}

#pragma mark - UIControl Methods

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [button addTarget:target action:action forControlEvents:controlEvents];
}

- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [button removeTarget:target action:action forControlEvents:controlEvents];
}

- (NSArray *)actionsForTarget:(id)target forControlEvent:(UIControlEvents)controlEvent
{
    return [button actionsForTarget:target forControlEvent:controlEvent];
}


#pragma mark - Animation Methods

- (void) spinRefreshButton: (BOOL) spin
{
    if (spin)
    {
        
        [CATransaction begin];
        [CATransaction setValue: (id) kCFBooleanTrue
                         forKey: kCATransactionDisableActions];
        
        CGRect frame = image.frame;
        image.layer.anchorPoint = CGPointMake(0.5, 0.5);
        image.layer.position = CGPointMake(frame.origin.x + 0.5 * frame.size.width, frame.origin.y + 0.5 * frame.size.height);
        [CATransaction commit];
        
        [CATransaction begin];
        [CATransaction setValue: (id)kCFBooleanFalse forKey: kCATransactionDisableActions];
        
        [CATransaction setValue: [NSNumber numberWithFloat:2.0] forKey: kCATransactionAnimationDuration];
        
        CABasicAnimation *animation;
        animation = [CABasicAnimation animationWithKeyPath: @"transform.rotation.z"];
        animation.fromValue = [NSNumber numberWithFloat: 0.0];
        animation.toValue = [NSNumber numberWithFloat: 2 * M_PI];
        animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
        animation.delegate = self;
        [image.layer addAnimation: animation forKey: @"rotationAnimation"];
        [CATransaction commit];
    }
    else
    {
        
        [image.layer removeAllAnimations];
    }
    
}

- (void) animationDidStop: (CAAnimation *) theAnimation finished: (BOOL) finished
{
	if (finished)
	{
		[self spinRefreshButton: TRUE];
	}
}

@end
