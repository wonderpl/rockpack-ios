//
//  SYNNetworkErrorView.m
//  rockpack
//
//  Created by Michael Michailidis on 22/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNNetworkErrorView.h"
#import "SYNDeviceManager.h"
#import "UIFont+SYNFont.h"
#import "SYNDeviceManager.h"

@implementation SYNNetworkErrorView


- (id)init
{
    UIImage* bgImage = [UIImage imageNamed:@"BarNetwork"];
    CGRect finalFrame = CGRectMake(0.0,
                                   [[SYNDeviceManager sharedInstance] currentScreenHeight],
                                   [[SYNDeviceManager sharedInstance] currentScreenWidth],
                                   bgImage.size.height);
    
    
    self = [super initWithFrame:finalFrame];
    if (self) {
        
        
        // BG
        
        self.backgroundColor = [UIColor colorWithPatternImage:bgImage];
        
        // Error Label
        
        errorLabel = [[UILabel alloc] initWithFrame:self.frame];
        errorLabel.textColor = [UIColor colorWithRed:(223.0/255.0) green:(244.0/255.0) blue:(1.0) alpha:(1.0)];
        errorLabel.font = [UIFont rockpackFontOfSize:20.0];
        errorLabel.backgroundColor = [UIColor clearColor];
        
        [self addSubview:errorLabel];
        
        
        // Wifi Icon
        
        wifiImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconNetwork"]];
        wifiImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:wifiImageView];
        
        [self setText:@"Network Error"];
        
        self.autoresizesSubviews = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        
    }
    return self;
}

+(id)errorView
{
    return [[self alloc] init];
}


-(void)setText:(NSString *)text
{
    NSString* capsText = [text uppercaseString];
    CGSize textSize = [capsText sizeWithFont:errorLabel.font];
    
    CGRect labelFrame = errorLabel.frame;
    labelFrame.size = textSize;
    errorLabel.frame = labelFrame;
    
    errorLabel.center = CGPointMake(self.frame.size.width * 0.5, 32.0);
    errorLabel.frame = CGRectIntegral(errorLabel.frame);
    
    errorLabel.text = capsText;
    
    CGRect wifiFrame = wifiImageView.frame;
    wifiFrame.origin.x = errorLabel.frame.origin.x - wifiFrame.size.width - 10.0;
    wifiImageView.frame = wifiFrame;
    wifiImageView.center = CGPointMake(wifiImageView.center.x, self.frame.size.height * 0.5);
    wifiImageView.frame = CGRectIntegral(wifiImageView.frame);
    
    
}

-(CGFloat)height
{
    return self.frame.size.height;
}
@end
