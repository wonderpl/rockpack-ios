//
//  SYNAccountSettingTableViewCell.m
//  rockpack
//
//  Created by Michael Michailidis on 18/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAccountSettingTableViewCell.h"
#import "UIFont+SYNFont.h"

@implementation SYNAccountSettingTableViewCell
@synthesize timeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 20.0)];
        self.timeLabel.font = [UIFont rockpackFontOfSize:12.0];
        self.timeLabel.textAlignment = NSTextAlignmentLeft;
        self.timeLabel.textColor = [UIColor grayColor];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.timeLabel];
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
