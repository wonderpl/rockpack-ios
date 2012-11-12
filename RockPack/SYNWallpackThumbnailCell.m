//
//  SYNWallpackCell.m
//  rockpack
//
//  Created by Nick Banks on 12/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNWallpackThumbnailCell.h"
#import "UIFont+SYNFont.h"

@implementation SYNWallpackThumbnailCell


- (id) initWithFrame: (CGRect) frame
{
    if ((self = [super initWithFrame: frame]))
    {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed: @"SYNWallpackThumbnailCell"
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
    
    self.title.font = [UIFont boldRockpackFontOfSize: 16.0f];
    self.price.font = [UIFont boldRockpackFontOfSize: 27.0f];
}

@end
