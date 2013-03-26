//
//  SYNUserItemView.m
//  rockpack
//
//  Created by Michael Michailidis on 26/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNUserItemView.h"

@implementation SYNUserItemView

- (id)initWithTitle:(NSString*)name andFrame:(CGRect)frame
{
    self = [super initWithTitle:name andFrame:frame];
    if (self) {
        
        self.numberLabel.center = CGPointMake(self.numberLabel.center.x, 50.0);
        self.numberLabel.frame = CGRectIntegral(self.numberLabel.frame);
        
        self.nameLabel.center = CGPointMake(self.nameLabel.center.x, 75.0);
        self.nameLabel.frame = CGRectIntegral(self.nameLabel.frame);
    }
    return self;
}



@end
