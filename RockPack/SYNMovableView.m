//
//  SYNMovableView.m
//  rockpack
//
//  Created by Nick Banks on 19/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNMovableView.h"

@interface SYNMovableView ()

@property (nonatomic, assign) CGPoint touchStart;

@end

@implementation SYNMovableView

- (void) touchesBegan: (NSSet *) touches
            withEvent: (UIEvent *) event
{
    self.touchStart = [[touches anyObject] locationInView: self];
}

- (void) touchesMoved: (NSSet *) touches
            withEvent: (UIEvent *) event
{
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    
    self.center = CGPointMake(self.center.x + touchPoint.x - self.touchStart.x,
                              self.center.y + touchPoint.y - self.touchStart.y);
}

@end

