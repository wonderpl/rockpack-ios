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


#define STD_PADDING_DISTANCE 20.0

@implementation SYNOnBoardingPopoverView

+(id)withMessage:(NSString*)message
      pointingTo:(CGPoint)point
   withDirection:(PointingDirection)direction
{
    return [[self alloc] initWithMessage:(NSString*)message pointingTo:(CGPoint)point withDirection:(PointingDirection)direction];
}

- (id)initWithMessage:(NSString*)message
           pointingTo:(CGPoint)point
        withDirection:(PointingDirection)direction
{
    CGSize screenSize = [[SYNDeviceManager sharedInstance] currentScreenSize];
    CGRect screenFrame = CGRectMake(0.0, 0.0, screenSize.width, screenSize.height);
    
    if (self = [super initWithFrame:screenFrame]) {
        
        // background view
        
        
        self.backgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.backgroundView.backgroundColor = [UIColor darkGrayColor];
        self.backgroundView.alpha = 0.3;
        [self addSubview:self.backgroundView];
        
        
        // panel view
        CGRect panelRect = CGRectMake(0.0, 0.0, 400.0, 220.0);
        
        self.panelView = [[UIView alloc] initWithFrame:panelRect];
        self.panelView.backgroundColor = [UIColor colorWithRed:(11.0/255.0) green:(166.0/255.0) blue:(171.0/255.0) alpha:(1.0)];
        
        
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
        centerRect.origin.x = self.panelView.frame.size.width * 0.5 - label.frame.size.width * 0.5;
        centerRect.origin.y = 20.0;
        label.frame = CGRectIntegral(centerRect);
        
        label.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
        label.layer.shadowOffset = CGSizeMake(0.0, 2.0);
        
        [self.panelView addSubview:label];
        
        
        [self addSubview:self.panelView];
        
        
        // buttom
        
        self.okButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.okButton.frame = CGRectMake(0.0, 0.0, 100.0, 30.0);
        [self.okButton addTarget:self action:@selector(okButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        self.okButton.center = CGPointMake(self.panelView.center.x, 180.0);
        self.okButton.frame = CGRectIntegral(self.okButton.frame);
        
        [self.panelView addSubview:self.okButton];
        
        
        // orient
        
        CGRect panelFrame = self.panelView.frame;
        
        switch (direction) {
                
            case PointingDirectionNone: // center in view
                panelFrame.origin.y = self.frame.size.height * 0.5 - panelFrame.size.height * 0.5;
                panelFrame.origin.x = self.frame.size.width * 0.5 - panelFrame.size.width * 0.5;
                break;
                
            case PointingDirectionUp:
                panelFrame.origin.y = point.y + panelFrame.size.height + STD_PADDING_DISTANCE;
                panelFrame.origin.x = point.x - panelFrame.size.width + STD_PADDING_DISTANCE;
                break;
                
            case PointingDirectionDown:
                panelFrame.origin.y = point.y - panelFrame.size.height - STD_PADDING_DISTANCE;
                panelFrame.origin.x = point.x - panelFrame.size.width + STD_PADDING_DISTANCE;
                break;
                
            case PointingDirectionLeft:
                panelFrame.origin.y = point.y - STD_PADDING_DISTANCE;
                panelFrame.origin.x = point.x + panelFrame.size.width + STD_PADDING_DISTANCE;
                break;
                
            case PointingDirectionRight:
                panelFrame.origin.y = point.y - STD_PADDING_DISTANCE;
                panelFrame.origin.x = point.x - panelFrame.size.width - STD_PADDING_DISTANCE;
                break;
                
        }
        
        self.panelView.frame = panelFrame;
        
    }
    return self;
}

-(void)okButtonPressed
{
    // remove automatically
    [UIView animateWithDuration:0.3 animations:^{
        self.panelView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }];
}


@end
