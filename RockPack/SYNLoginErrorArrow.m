//
//  SYNLoginErrorArrow.m
//  rockpack
//
//  Created by Michael Michailidis on 13/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNLoginErrorArrow.h"
#import "UIFont+SYNFont.h"

@implementation SYNLoginErrorArrow

- (id)initWithDefault
{
    self = [super init];
    if (self) {
        backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LoginError.png"]];
        [self addSubview:backgroundImageView];
        
        self.frame = backgroundImageView.frame;
        
        CGRect labelFrame = self.frame;
        labelFrame.origin.x += 30.0;
        labelFrame.size.width -= 30.0;
        labelFrame.origin.y += 5.0;
        labelFrame.size.height -= 5.0;
        messageLabel = [[UILabel alloc] initWithFrame:labelFrame];
        
        messageLabel.font = [UIFont rockpackFontOfSize:13.0];
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.textAlignment = NSTextAlignmentLeft;
        
        [self addSubview:messageLabel];
        
        
        
        
        
    }
    return self;
}

-(void)setMessage:(NSString *)message
{
    messageLabel.text = message;
}

+(id)withMessage:(NSString*)message
{
    SYNLoginErrorArrow* instance = [[SYNLoginErrorArrow alloc] initWithDefault];
    
    [instance setMessage:message];
    
    return instance;
}
@end
