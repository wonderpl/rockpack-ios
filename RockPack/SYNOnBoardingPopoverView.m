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

+ (id)withMessage:(NSString*)message
         withSize:(CGSize)size
      andFontSize:(CGFloat)fontSize
       pointingTo:(CGRect)pointRect
    withDirection:(PointingDirection)direction
{
    return [[self alloc] initWithMessage:message
                                withSize:size
                             andFontSize:fontSize
                              pointingTo:pointRect
                           withDirection:direction];
}

- (id)initWithMessage:(NSString*)message
             withSize:(CGSize)size
          andFontSize:(CGFloat)fontSize
           pointingTo:(CGRect)pointRect
        withDirection:(PointingDirection)direction
{
    
    
    if (self = [super initWithFrame:CGRectMake(0.0, 0.0, size.width, size.height)]) {
        
        self.pointRect = pointRect;
        
        if(CGRectEqualToRect(self.pointRect, CGRectZero))
        {
            self.direction = PointingDirectionNone;
        }
        else
        {
            self.direction = direction;
        }
        
       
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        self.backgroundColor = [UIColor colorWithRed:(11.0/255.0) green:(166.0/255.0) blue:(171.0/255.0) alpha:(1.0)];
        
        
        // text view
        
        CGRect labelRect = self.frame;
        labelRect.origin.x = 15.0;
        labelRect.origin.y = 15.0;
        labelRect.size.width -= 30.0;
        
        
        
        
        UILabel* label = [[UILabel alloc] init];
        label.font = [UIFont rockpackFontOfSize:fontSize];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 3;
        label.textColor = [UIColor whiteColor];
        label.text = message;
        
        label.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
        label.layer.shadowOffset = CGSizeMake(0.0, 2.0);
        
        CGSize textSize = [message sizeWithFont:label.font
                                       forWidth:labelRect.size.width
                                  lineBreakMode:label.lineBreakMode];
        
        labelRect.size.height = textSize.height * label.numberOfLines;
        
        label.frame = labelRect;
        
        [self addSubview:label];
        
        
        
        // buttom
        
        self.okButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        CGRect buttonRect = self.okButton.frame;
        buttonRect.size = CGSizeMake(100.0, 30.0);
        buttonRect.origin.x = self.frame.size.width * 0.5 - buttonRect.size.width * 0.5;
        buttonRect.origin.y = labelRect.origin.y + labelRect.size.height + 10.0;
        self.okButton.frame = CGRectIntegral(buttonRect);
        
        [self addSubview:self.okButton];
        
        
        // orient
        
        
        
    }
    return self;
}



@end
