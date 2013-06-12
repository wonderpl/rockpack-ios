//
//  SYNOnBoardingPopoverView.m
//  rockpack
//
//  Created by Michael Michailidis on 12/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOnBoardingPopoverView.h"
#import "SYNDeviceManager.h"
#import "UIFont+SYNFont.h"

#import <QuartzCore/QuartzCore.h>




@implementation SYNOnBoardingPopoverView

+(id)withMessage:(NSString*)message
      pointingTo:(CGRect)pointRect
   withDirection:(PointingDirection)direction
{
    return [[self alloc] initWithMessage:(NSString*)message pointingTo:(CGRect)pointRect withDirection:(PointingDirection)direction];
}

- (id)initWithMessage:(NSString*)message
           pointingTo:(CGRect)pointRect
        withDirection:(PointingDirection)direction
{
    
    
    if (self = [super init]) {
        
        
        
        
        self.pointRect = pointRect;
        
        if(CGRectEqualToRect(self.pointRect, CGRectZero))
        {
            self.direction = PointingDirectionNone;
        }
        else
        {
            self.direction = direction;
        }
        
        // panel view
        CGRect panelRect = CGRectMake(0.0, 0.0, 400.0, 220.0);
        
        self.frame = panelRect;
        
        self.backgroundColor = [UIColor colorWithRed:(11.0/255.0) green:(166.0/255.0) blue:(171.0/255.0) alpha:(1.0)];
        
        
        // text view
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 100.0)];
        label.font = [UIFont rockpackFontOfSize:20.0];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 3;
        label.textColor = [UIColor whiteColor];
        label.text = message;
        
        CGRect centerRect = label.frame;
        centerRect.origin.x = self.frame.size.width * 0.5 - label.frame.size.width * 0.5;
        centerRect.origin.y = 20.0;
        label.frame = CGRectIntegral(centerRect);
        
        label.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
        label.layer.shadowOffset = CGSizeMake(0.0, 2.0);
        
        [self addSubview:label];
        
        
        
        // buttom
        
        self.okButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.okButton.frame = CGRectMake(0.0, 0.0, 100.0, 30.0);
        
        self.okButton.center = CGPointMake(self.center.x, 180.0);
        self.okButton.frame = CGRectIntegral(self.okButton.frame);
        
        [self addSubview:self.okButton];
        
        
        // orient
        
        
        
    }
    return self;
}



@end
