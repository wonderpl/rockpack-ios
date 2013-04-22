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

@implementation SYNNetworkErrorView

@synthesize errorLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        self.errorLabel = [[UILabel alloc] initWithFrame:frame];
        self.errorLabel.textColor = [UIColor redColor];
        self.errorLabel.font = [UIFont rockpackFontOfSize:18.0];
        self.errorLabel.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.errorLabel];
    }
    return self;
}

+(id)errorView
{
    return [[self alloc] initWithFrame:CGRectMake(0.0, 0.0, [[SYNDeviceManager sharedInstance] currentScreenWidth], 50.0)];
}

@end
