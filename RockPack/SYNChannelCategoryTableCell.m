//
//  SYNChannelCategoryTableCell.m
//  rockpack
//
//  Created by Mats Trovik on 24/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNChannelCategoryTableCell.h"
#import "UIFont+SYNFont.h"

@implementation SYNChannelCategoryTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)layoutSubviews
{
    self.titleLabel.font = [UIFont rockpackFontOfSize:self.titleLabel.font.pointSize];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if(selected)
    {
        self.titleLabel.textColor = [UIColor colorWithRed:32.0f/255.0f green:195.0f/255.0f blue:226.0f/255.0f alpha:1.0f];
        self.backgroundImage.image = [UIImage imageNamed:@"SubCategorySlideSelected"];
    }
    else
    {
        self.titleLabel.textColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
        self.backgroundImage.image = [UIImage imageNamed:@"SubCategorySlide"];
    }
    
}

@end
