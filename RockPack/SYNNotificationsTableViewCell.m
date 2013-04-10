//
//  SYNNotificationsTableViewCell.m
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNNotificationsTableViewCell.h"

@implementation SYNNotificationsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect tableCellFrame = self.textLabel.frame;
    tableCellFrame.size.width += 30.0;
    tableCellFrame.origin.y = 6.0;
    self.textLabel.frame = tableCellFrame;
}

@end
