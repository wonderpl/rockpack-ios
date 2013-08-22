//
//  SYNTouchGestureRecognizer.m
//  rockpack
//
//  Created by Nick Banks on 20/08/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNTouchGestureRecognizer.h"

@implementation SYNTouchGestureRecognizer

#pragma mark - Initialization


- (id) init
{
    if ((self = [super init]))
    {
        // Don't have any custom stuff yet
    }
    
    return self;
}


- (id) initWithTarget: (id) target action: (SEL) action
{
    if (self = [super initWithTarget: target
                              action: action])
    {
        // Don't have any custom stuff yet
    }
    
    return self;
}


#pragma mark - Co-operation

// Required so that the other gesture recognizers act in parallel
- (BOOL) canPreventGestureRecognizer: (UIGestureRecognizer *) preventedGestureRecognizer
{
    return NO;
}


#pragma mark - Subclassed methods (conforming to UIGestureRecognizerSubclass.h)


- (void) touchesBegan: (NSSet *) touches
            withEvent: (UIEvent *) event
{
    [super touchesBegan: touches
              withEvent: event];
    
    self.state = UIGestureRecognizerStateBegan;
}


- (void) touchesEnded: (NSSet *) touches
            withEvent: (UIEvent *) event
{
    [super touchesEnded: touches
              withEvent: event];
    
    self.state = UIGestureRecognizerStateEnded;
}


- (void) touchesCancelled: (NSSet *) touches
                withEvent: (UIEvent *) event
{
    [super touchesCancelled: touches
                  withEvent: event];
    
    self.state = UIGestureRecognizerStateCancelled;
}

@end
