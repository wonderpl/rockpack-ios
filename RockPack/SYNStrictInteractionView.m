//
//  SYNStrictInteractionView.m
//  rockpack
//
//  Created by Michael Michailidis on 03/09/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNStrictInteractionView.h"

@implementation SYNStrictInteractionView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    for (UIView *subview in self.subviews)
    {
        if(subview.hidden)
            continue;
        
        CGPoint pointInSubview = [subview convertPoint:point fromView:self];
        if ([subview pointInside:pointInSubview withEvent:event])
        {
            
            return YES;
        }
    }
    
    return NO;
}



@end
