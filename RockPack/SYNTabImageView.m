//
//  SYNTabImageView.m
//  RockPack
//
//  Created by Nick Banks on 14/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNTabImageView.h"

@interface SYNTabImageView ()

@property (nonatomic, strong) TabTouchHandler touchHandler;

@end

@implementation SYNTabImageView

- (id) initWithFrame: (CGRect) frame
        touchHandler: (TabTouchHandler) touchHandler
{
    self = [super initWithFrame: frame];
    
    if (self)
    {
        self.touchHandler = touchHandler;
    }
    return self;
}


- (void) touchesBegan: (NSSet *) touches
            withEvent: (UIEvent *) event
{
    CGPoint touchPoint = CGPointMake(0.0f, 0.0f);
    
    if (touches.count == 1)
    {
        touchPoint = [touches.anyObject locationInView: self];
    }
    
    self.touchHandler(touchPoint);
}

@end
