//
//  SYNChannelHeaderView.m
//  rockpack
//
//  Created by Nick Banks on 04/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "UIFont+SYNFont.h"
#import "SYNChannelHeaderView.h"

@implementation SYNChannelHeaderView

- (id) initWithFrame: (CGRect) frame
{
    if ((self = [super initWithFrame: frame]))
    {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed: @"SYNChannelHeaderView"
                                                              owner: self
                                                            options: nil];
        
        if ([arrayOfViews count] < 1)
        {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex: 0] isKindOfClass: [UICollectionViewCell class]])
        {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex: 0];
    }
    
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.subtitleLabel.font = [UIFont rockpackFontOfSize: 17.0f];
}

@end
