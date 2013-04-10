//
//  SYNNotificationsTableViewCell.m
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNNotificationsTableViewCell.h"
#import "UIFont+SYNFont.h"

@implementation SYNNotificationsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont rockpackFontOfSize:18.0];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (void) layoutSubviews {
//    [super layoutSubviews];
//    CGRect tableCellFrame = self.textLabel.frame;
//    tableCellFrame.size.width += 30.0;
//    tableCellFrame.origin.y = 6.0;
//    self.textLabel.frame = tableCellFrame;
//}

@end
