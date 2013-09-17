//
//  SYNNoChannelsMessageView.m
//  rockpack
//
//  Created by Kish Patel on 17/09/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNNoChannelsMessageView.h"
#import "UIFont+SYNFont.h"

@interface SYNNoChannelsMessageView ()

@property (nonatomic, strong) UILabel* messageLabel;

@end

@implementation SYNNoChannelsMessageView

+ (id) withMessage: (NSString*) message
{
    return [[self alloc] initWithMessage: message];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithMessage: (NSString*) message
{
    if (self = [super init])
    {
        UIFont* fontToUse = [UIFont rockpackFontOfSize: IS_IPHONE ? 18.0f : 18.0f ];
        
        CGRect labelFrame = CGRectZero;
        
        UILabel* label = [[UILabel alloc] initWithFrame: labelFrame];
        label.font = fontToUse;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithWhite:170.0f/255.0f alpha:1.0f];
        label.textAlignment = NSTextAlignmentCenter;
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0.0f, 1.0f);
        
        label.numberOfLines = 0;
        
        self.messageLabel = label;
        
        // BG
        self.backgroundColor = [UIColor clearColor];
        
        // Add
        [self addSubview: label];
        
        [self setMessage: message];
        
    }
    
    return self;
}


- (void) setMessage: (NSString*) newMessage
{
    if (IS_IPHONE)
    {
        self.messageLabel.frame = CGRectMake(0.0f, 0.0f, 260.0f, 300.0f);
    }
    
    self.messageLabel.text = newMessage;
    [self.messageLabel sizeToFit];
    
    self.frame = [self returnMainFrame];
    
    self.messageLabel.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5 + 4.0);
    self.messageLabel.frame = CGRectIntegral(self.messageLabel.frame);
}

- (CGRect) returnMainFrame
{
    CGRect mainFrame = CGRectMake(0.0, 0.0, self.messageLabel.frame.size.width + 40.0, self.messageLabel.frame.size.height + 30.0);
    
    return mainFrame;
}

@end
