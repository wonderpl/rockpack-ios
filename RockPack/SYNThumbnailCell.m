//
//  SYNThumbnailCell.m
//  rockpack
//
//  Created by Nick Banks on 18/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNThumbnailCell.h"
#import "UIFont+SYNFont.h"

@implementation SYNThumbnailCell

- (id) initWithFrame: (CGRect) frame
{
    if ((self = [super initWithFrame: frame]))
    {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed: @"SYNThumbnailCell"
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
    
    self.maintitle.font = [UIFont boldRockpackFontOfSize: 17.0f];
    self.subtitle.font = [UIFont rockpackFontOfSize: 15.0f];
    self.packItNumber.font = [UIFont boldRockpackFontOfSize: 17.0f];
    self.rockItNumber.font = [UIFont boldRockpackFontOfSize: 17.0f];
}


@end
