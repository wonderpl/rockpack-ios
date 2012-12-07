//
//  SYNThumbnailCell.m
//  rockpack
//
//  Created by Nick Banks on 18/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNVideoThumbnailCell.h"
#import "UIFont+SYNFont.h"

@interface SYNVideoThumbnailCell ()

@property (nonatomic, strong) IBOutlet UIImageView *highlightedBackgroundView;
@property (nonatomic, strong) IBOutlet UIImageView *backgroundView;

@end

@implementation SYNVideoThumbnailCell

- (id) initWithFrame: (CGRect) frame
{
    if ((self = [super initWithFrame: frame]))
    {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed: @"SYNVideoThumbnailCell"
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
    self.addItButton.enabled = TRUE;
    self.addItButton.hidden = FALSE;
    self.shareItButton.enabled = FALSE;
    self.shareItButton.hidden = TRUE;
    self.highlightedBackgroundView.hidden = TRUE;
}


- (void) setHighlighted: (BOOL) highlighted
{
    if (highlighted)
    {
        self.highlightedBackgroundView.hidden = FALSE;
    }
    else
    {
        self.highlightedBackgroundView.hidden = TRUE;
    }
}

- (void) setThirdButtonType: (int) buttonType
{
    switch (buttonType)
    {
        case kShowShareButton:
            self.addItButton.enabled = FALSE;
            self.addItButton.hidden = TRUE;
            self.shareItButton.enabled = TRUE;
            self.shareItButton.hidden = FALSE;
            break;
         
        case kShowAddButton:
        default:
            self.addItButton.enabled = TRUE;
            self.addItButton.hidden = FALSE;
            self.shareItButton.enabled = FALSE;
            self.shareItButton.hidden = TRUE;
            break;
    }
}


@end
