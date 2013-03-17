//
//  SYNPassthroughView.m
//  rockpack
//
//  Created by Nick Banks on 09/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//
//  Special view that allows passthough of touches (intended for mainly transparent overly views)
//

#import "SYNPassthroughView.h"

@implementation SYNPassthroughView

-(BOOL) pointInside: (CGPoint) point
          withEvent: (UIEvent *) event
{
    for (UIView *view in self.subviews)
    {
        if (!view.hidden && view.userInteractionEnabled && [view pointInside: [self convertPoint: point toView: view] withEvent: event])
        {
            return YES;
        }
    }
    
    return NO;
}



@end
