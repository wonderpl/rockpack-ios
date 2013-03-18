//
//  SYNLoginFormTextField.m
//  rockpack
//
//  Created by Michael Michailidis on 15/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNLoginFormTextField.h"

@implementation SYNLoginFormTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)drawPlaceholderInRect:(CGRect)rect
{
    [[UIColor darkGrayColor] setFill];
    [[self placeholder] drawInRect:rect withFont:self.font];
    
}

@end
