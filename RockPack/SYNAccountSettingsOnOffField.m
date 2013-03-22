//
//  SYNAccountSettingsOnOffField.m
//  rockpack
//
//  Created by Michael Michailidis on 21/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAccountSettingsOnOffField.h"
#import "UIFont+SYNFont.h"

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"


@implementation SYNAccountSettingsOnOffField

- (id)initWithFrame:(CGRect)frame andString:(NSString*)value
{
    
    UIFont *rockpackFont = [UIFont boldRockpackFontOfSize:20];
    CGSize measure = [value sizeWithFont:rockpackFont];
    
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, measure.width, measure.height)];
        self.textField.text = value;
        self.textField.font = rockpackFont;
        self.textField.backgroundColor = [UIColor clearColor];
        self.textField.textColor = [UIColor whiteColor];
        self.textField.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.textField];
        
        self.onOffSwitch = [[UISwitch alloc] init];
        CGRect onOffFrame = self.onOffSwitch.frame;
        onOffFrame.origin.x = self.frame.size.width - onOffFrame.size.width;
        self.onOffSwitch.frame = onOffFrame;
        [self.onOffSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.onOffSwitch];
        
        CGRect selfFrame = self.frame;
        selfFrame.size.height = onOffFrame.size.height;
        self.frame = selfFrame;
        
        self.textField.center = CGPointMake(self.textField.center.x, self.onOffSwitch.center.y);
        self.textField.frame = CGRectIntegral(self.textField.frame);
        
    }
    return self;
}

-(void)switchToggled:(UISwitch*)switchComponent
{
    [target performSelector:action withObject:self];
}

-(void)addTarget:(id)atarget action:(SEL)anaction
{
    target = atarget;
    action = anaction;
}


@end
