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

// We need to be able to determine whether any of our views is being dragged

static BOOL canDrag = TRUE;

+ (BOOL) allowDragging
{
    NSLog (@"canDrag %d", canDrag);
    return canDrag;
}

- (void) touchesBegan: (NSSet *) touches
            withEvent: (UIEvent *) event
{
    canDrag = FALSE;
    self.touchStart = [[touches anyObject] locationInView: self];
}

- (void) touchesEnded: (NSSet *) touches
            withEvent: (UIEvent *) event
{
    canDrag = TRUE;
}

- (void) touchesMoved: (NSSet *) touches
            withEvent: (UIEvent *) event
{
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    
    self.center = CGPointMake(self.center.x + touchPoint.x - self.touchStart.x,
                              self.center.y + touchPoint.y - self.touchStart.y);
}

@end

