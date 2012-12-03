//
//  SYNVideoThumbnailRegularCell.m
//  rockpack
//
//  Created by Nick Banks on 03/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "UIFont+SYNFont.h"
#import "SYNVideoThumbnailRegularCell.h"

@implementation SYNVideoThumbnailRegularCell

- (id) initWithFrame: (CGRect) frame
{
    if ((self = [super initWithFrame: frame]))
    {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed: @"SYNVideoThumbnailRegularCell"
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
    
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: 17.0f];
    self.subtitleLabel.font = [UIFont rockpackFontOfSize: 15.0f];
    self.rockItNumber.font = [UIFont boldRockpackFontOfSize: 17.0f];
    self.addItButton.enabled = TRUE;
    self.addItButton.hidden = FALSE;
    self.shareItButton.enabled = FALSE;
    self.shareItButton.hidden = TRUE;
}


@end
