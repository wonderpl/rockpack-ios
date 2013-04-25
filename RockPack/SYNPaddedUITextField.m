//
//  SYNPaddedUITextField.m
//  rockpack
//
//  Created by Michael Michailidis on 21/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNPaddedUITextField.h"

@implementation SYNPaddedUITextField

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds
{
    return [self getRectUniversal:bounds];
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [self getRectUniversal:bounds];
}

-(CGRect)getRectUniversal:(CGRect)bounds
{
    if(self.leftView) {
        return CGRectInset( bounds , self.leftView.frame.size.width , 10 );
    } else {
        return CGRectInset( bounds , 10 , 10 );
    }
    
}

@end
