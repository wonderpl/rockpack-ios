//
//  SYNFeedMessagesView.m
//  rockpack
//
//  Created by Michael Michailidis on 30/05/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNFeedMessagesView.h"
#import "UIFont+SYNFont.h"
#import "SYNDeviceManager.h"

@interface SYNFeedMessagesView ()
{
    BOOL _isIPhone;
}

    @property UILabel* messageLabel;

@end

@implementation SYNFeedMessagesView


- (id) initWithMessage:(NSString*)message
{
    
    
    if (self = [super init]) {
        
        _isIPhone = [[SYNDeviceManager sharedInstance] isIPhone];
        // Label
        
        UIFont* fontToUse = [UIFont rockpackFontOfSize: _isIPhone?13.0f:20.0];
        
        CGRect labelFrame = CGRectZero;
        
        UILabel* label = [[UILabel alloc] initWithFrame:labelFrame];
        label.font = fontToUse;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        
        if(_isIPhone)
        {
            label.numberOfLines = 0;
        }
        _messageLabel = label;
        
        // BG
        self.backgroundColor = [UIColor colorWithWhite:0.333f alpha:0.4f];

        
        // Add
        [self addSubview:label];
        
        [self setMessage:message];
        
    }
    return self;
}

-(void)setMessage:(NSString*)newMessage
{
    if (_isIPhone)
    {
        self.messageLabel.frame = CGRectMake(0.0f, 0.0f, 260.0f, 300.0f);
    }
    
    self.messageLabel.text = [newMessage uppercaseString];
    [self.messageLabel sizeToFit];

    CGRect mainFrame = CGRectMake(0.0, 0.0, self.messageLabel.frame.size.width + 40.0, self.messageLabel.frame.size.height + 30.0);
    
    self.messageLabel.center = CGPointMake(mainFrame.size.width * 0.5, mainFrame.size.height * 0.5 + 4.0);
    self.messageLabel.frame = CGRectIntegral(self.messageLabel.frame);
    
    self.frame = mainFrame;
    

}

+ (id) withMessage: (NSString*) message
{
    return [[self alloc] initWithMessage: message];
}

@end
