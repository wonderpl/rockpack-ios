//
//  SYNCautionMessageView.m
//  rockpack
//
//  Created by Michael Michailidis on 25/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCautionMessageView.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>
#import "SYNDeviceManager.h"

#define CAUTION_VIEW_WIDTH 320.0
#define CAUTION_TITLE_FONT_SIZE 17.0
#define CAUTION_MESSAGE_FONT_SIZE 13.0
#define CAUTION_BUTTON_FONT_SIZE 14.0
#define CAUTION_BUTTONS_Y 104.0

@implementation SYNCautionMessageView

@synthesize titleLabel;
@synthesize messageLabel;

- (id)initWithCaution:(SYNCaution*)caution
{
    
    UIImage* bgImage = [UIImage imageNamed:@"PanelPrivateAlert"];
    if(!bgImage)
        return nil;
    
    if (self = [super initWithFrame:CGRectMake(0.0, 0.0, CAUTION_VIEW_WIDTH, bgImage.size.height)]) {
        
        
        self.caution = caution;
        
        self.userInteractionEnabled = YES;
        
        self.backgroundColor = [UIColor colorWithPatternImage:bgImage];
        
        UIFont* titleFontToUse = [UIFont boldRockpackFontOfSize:CAUTION_TITLE_FONT_SIZE];
        UIFont* messageFontToUse = [UIFont rockpackFontOfSize:CAUTION_MESSAGE_FONT_SIZE];
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin; // center
        
        // == title label == //
        CGRect titleFrame = self.frame;
        titleFrame.origin.y = 25.0;
        titleFrame.size.height = [caution.title sizeWithFont:titleFontToUse].height;
        self.titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = titleFontToUse;
        titleLabel.text = caution.title;
        
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.layer.shadowColor = [[UIColor whiteColor] CGColor];
        titleLabel.layer.shadowOffset = CGSizeMake(0.0, 0.5);
        titleLabel.layer.shadowRadius = 0.5;
        titleLabel.layer.shadowOpacity = 0.5;
        titleLabel.layer.masksToBounds = NO;
        titleLabel.backgroundColor = [UIColor clearColor];
        
        [self addSubview:titleLabel];
        
        // == main label == //
        
        NSLineBreakMode wordWrappingMode = NSLineBreakByWordWrapping;
        CGRect messageFrame = self.frame;
        messageFrame.origin.x = 20.0;
        messageFrame.origin.y = 48.0;
        messageFrame.size.width -= 40.0;
        messageFrame.size.height = [caution.message sizeWithFont:messageFontToUse
                                               constrainedToSize:self.frame.size
                                                   lineBreakMode:wordWrappingMode].height;
        
        NSLog(@"%f", messageFrame.size.height);
        
        self.messageLabel = [[UILabel alloc] initWithFrame:messageFrame];
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.font = messageFontToUse;
        messageLabel.numberOfLines = 3;
        messageLabel.lineBreakMode = wordWrappingMode;
        
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.layer.shadowColor = [[UIColor colorWithRed:(128.0/255.0) green:(32.0/255.0) blue:(39.0/255.0) alpha:(1.0)] CGColor];
        messageLabel.layer.shadowOffset = CGSizeMake(0.0, 1.0);
        messageLabel.layer.shadowRadius = 0.5;
        messageLabel.layer.shadowOpacity = 0.5;
        messageLabel.backgroundColor = [UIColor clearColor];
        
        messageLabel.text = caution.message;
        
        [self addSubview:messageLabel];
        
        // == buttons == //
        
        if(caution.actionButtonTitle)
        {
            UIImage* actionButtonImage = [UIImage imageNamed:@"ButtonPrivateLeft"];
            UIImage* actionButtonImageHighlighted = [UIImage imageNamed:@"ButtonPrivateLeftHighlighted"];
            self.actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            
            self.actionButton.frame = CGRectMake(20.0, CAUTION_BUTTONS_Y, actionButtonImage.size.width, actionButtonImage.size.height);
            [self.actionButton setBackgroundImage:actionButtonImage forState:UIControlStateNormal];
            [self.actionButton setBackgroundImage:actionButtonImageHighlighted forState:UIControlStateHighlighted];
            //set text label
            [self.actionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.actionButton setTitleEdgeInsets:UIEdgeInsetsMake(4.0, 0.0, 0.0, 0.0)];
            self.actionButton.titleLabel.font = [UIFont boldRockpackFontOfSize:CAUTION_BUTTON_FONT_SIZE];
            [self.actionButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.actionButton setTitle:self.caution.actionButtonTitle forState:UIControlStateNormal];
            [self.actionButton addTarget:self
                                  action:@selector(buttonPressed:)
                        forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:self.actionButton];
        }
        
        
        // -- passing the skip button image is not mandatory since it is mostly standard -- //
        UIImage* skipButtonImage = [UIImage imageNamed:@"ButtonPrivateRight"];
        UIImage* skipButtonImageHighlighted = [UIImage imageNamed:@"ButtonPrivateRightHighlighted"];
        self.skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.skipButton.frame = CGRectMake(self.actionButton.frame.origin.x + self.actionButton.frame.size.width + 10.0,
                                           CAUTION_BUTTONS_Y, skipButtonImage.size.width, skipButtonImage.size.height);
        [self.skipButton setBackgroundImage:skipButtonImage forState:UIControlStateNormal];
        [self.skipButton setBackgroundImage:skipButtonImageHighlighted forState:UIControlStateHighlighted];
        [self.skipButton setTitleEdgeInsets:UIEdgeInsetsMake(4.0, 0.0, 0.0, 0.0)];
        
        // check wether it has been set by the user
        [self.skipButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.skipButton.titleLabel.font = [UIFont boldRockpackFontOfSize:CAUTION_BUTTON_FONT_SIZE];
        [self.skipButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        if(caution.skipButtonTitle)
            [self.skipButton setTitle:self.caution.skipButtonTitle forState:UIControlStateNormal];
        else
            [self.skipButton setTitle:@"SKIP" forState:UIControlStateNormal];
        
        [self.skipButton addTarget:self
                            action:@selector(buttonPressed:)
                  forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.skipButton];
        
        // add effects
        
        self.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
        self.layer.shadowOffset = CGSizeMake(0.0, 3.0);
        self.layer.shadowRadius = 3.0;
        self.layer.shadowOpacity = 0.4;
        
        
    }
    return self;
}

-(void)buttonPressed:(UIButton*)button
{
    if(button == self.actionButton)
    {
        if(self.caution.action)
            self.caution.action();
        
    }
    else if(button == self.skipButton)
    {
        if(self.caution.skip)
            self.caution.skip();
        
        
    }
    
    // hide and remove the view in all cases
    CGRect cautionMessageFrame = self.frame;
    cautionMessageFrame.origin.y = -cautionMessageFrame.size.height; // hide it
    
    [UIView animateWithDuration:0.4 animations:^{
        self.frame = cautionMessageFrame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


-(void) presentInView:(UIView*)containerView
{
    
    
    CGRect cautionMessageFrame = self.frame;
    cautionMessageFrame.origin.y = -cautionMessageFrame.size.height; // hide it
    cautionMessageFrame.origin.x = ([[SYNDeviceManager sharedInstance] currentScreenWidth] * 0.5) - (cautionMessageFrame.size.width * 0.5); // center it
    self.frame = CGRectIntegral(cautionMessageFrame);
    
    
    
    [containerView addSubview:self];
    
    
    
    // animate down
    cautionMessageFrame.origin.y = 0.0;
    
    
    [UIView animateWithDuration:0.4 animations:^{
        self.frame = cautionMessageFrame;
    }];
}


+ (id) withCaution:(SYNCaution*)caution
{
    return [[self alloc] initWithCaution:caution];
}

@end
