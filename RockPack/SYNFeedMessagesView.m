//
//  SYNFeedMessagesView.m
//  rockpack
//
//  Created by Michael Michailidis on 30/05/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNFeedMessagesView.h"
#import "UIFont+SYNFont.h"

@implementation SYNFeedMessagesView


- (id) initWithMessage:(NSString*)message
{
    
    
    if (self = [super init]) {
        
        
        // Label
        
        message = [message uppercaseString];
        
        UIFont* fontToUse = [UIFont rockpackFontOfSize:20.0];
        
        CGRect labelFrame = CGRectZero;
        labelFrame.size = [message sizeWithFont:fontToUse];
        
        UILabel* label = [[UILabel alloc] initWithFrame:labelFrame];
        label.font = fontToUse;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.text = message;
        label.textAlignment = NSTextAlignmentCenter;
        
        
        
        // BG
        
        CGRect mainFrame = CGRectMake(0.0, 0.0, labelFrame.size.width + 40.0, labelFrame.size.height + 30.0);
        
        UIView* bg = [[UIView alloc] initWithFrame:mainFrame];
        bg.backgroundColor = [UIColor darkGrayColor];
        bg.alpha = 0.4;
        
        
        
        // Align
        
        label.center = CGPointMake(mainFrame.size.width * 0.5, mainFrame.size.height * 0.5 + 4.0);
        label.frame = CGRectIntegral(label.frame);
        
        
        // Add
        
        [self addSubview:bg];
        [self addSubview:label];
        
        self.frame = mainFrame;
        
    }
    return self;
}

+ (id) withMessage: (NSString*) message
{
    return [[self alloc] initWithMessage: message];
}

@end
