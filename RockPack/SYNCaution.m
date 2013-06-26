//
//  SYNCaution.m
//  rockpack
//
//  Created by Michael Michailidis on 25/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCaution.h"

@implementation SYNCaution

@synthesize title, message, actionButtonTitle, skipButtonTitle;

-(id)initWithTitle:(NSString*)_title andMessage:(NSString*)_message
{
    if(self = [super init])
    {
        self.title = _title;
        self.message = _message;
        
        
        
    }
    return self;
}

-(void)addButtonWithTitle:(NSString*)_buttonTitle andCallbackBlock:(CautionCallbackBlock)_actionBlock
{
    self.actionButtonTitle = _buttonTitle;
    self.action = _actionBlock;
}

-(void)addSkipButtonTitle:(NSString*)_buttonTitle andCallbackBlock:(CautionCallbackBlock)_skipBlock
{
    self.skipButtonTitle = _buttonTitle;
    self.skip = _skipBlock;
}

+(id)withMessage:(NSString*)_message actionTitle:(NSString*)_actionTitle andCallback:(CautionCallbackBlock)_callbackBlock
{
    SYNCaution* c = [SYNCaution withTitle:NSLocalizedString(@"channel_created_succesfully", nil) andMessage:_message];
    c.actionButtonTitle = _actionTitle;
    c.action = _callbackBlock;
    return c;
}

+(id)withTitle:(NSString*)_title andMessage:(NSString*)_message
{
    return [[self alloc] initWithTitle:_title andMessage:_message];
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"Caution %p (title: %@, message: %@)", &self, self.title, self.message];
}

@end
