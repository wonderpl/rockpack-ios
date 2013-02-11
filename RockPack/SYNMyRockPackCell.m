//
//  SYNMyRockpackCell.m
//  rockpack
//
//  Created by Nick Banks on 21/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNMyRockpackCell.h"

@implementation SYNMyRockpackCell

- (id) initWithFrame: (CGRect) frame
{
    if ((self = [super initWithFrame: frame]))
    {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed: @"SYNMyRockpackCell"
                                                              owner: self
                                                            options: nil];
        
        if ([arrayOfViews count] < 1)
        {
            return nil;
        }
        
        if (![arrayOfViews[0] isKindOfClass: [UICollectionViewCell class]])
        {
            return nil;
        }
        
        self = arrayOfViews[0];
    }
    
    return self;
}

@end
