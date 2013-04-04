//
//  SYNChannelFooterMoreView.m
//  rockpack
//
//  Created by Michael Michailidis on 04/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNChannelFooterMoreView.h"

@implementation SYNChannelFooterMoreView

- (id) initWithFrame: (CGRect) frame
{
    if ((self = [super initWithFrame: frame]))
    {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed: @"SYNChannelFooterMoreView"
                                                              owner: self
                                                            options: nil];
        
        if ([arrayOfViews count] < 1)
        {
            return nil;
        }
        
        if (![arrayOfViews[0] isKindOfClass: [SYNChannelFooterMoreView class]])
        {
            return nil;
        }
        
        self = arrayOfViews[0];
    }
    
    return self;
}

@end
