//
//  SYNChannelCollectionBackgroundView.m
//  rockpack
//
//  Created by Nick Banks on 05/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNChannelCollectionBackgroundView.h"

@implementation SYNChannelCollectionBackgroundView

- (id) initWithFrame: (CGRect) frame
{
    if ((self = [super initWithFrame:frame]))
    {
        // Simply set the background colour to 60% Black
        self.backgroundColor = [UIColor colorWithRed: 0.0f
                                               green: 0.0f
                                                blue: 0.0f
                                               alpha: 0.6f];
    }
    
    return self;
}

@end
