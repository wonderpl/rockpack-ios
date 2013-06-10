//
//  SYNAccountSettingOtherTableViewCell.m
//  rockpack
//
//  Created by Kish Patel on 05/06/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNAccountSettingOtherTableViewCell.h"

@implementation SYNAccountSettingOtherTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected)
    {
        self.backgroundColor = [UIColor colorWithWhite:(247.0/255.0) alpha:(1.0)];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    else
    {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if(highlighted)
    {
        self.backgroundColor = [UIColor clearColor];
        
    }
    else
    {
        self.backgroundColor = [UIColor colorWithWhite:(247.0/255.0) alpha:(1.0)];
        self.textLabel.backgroundColor = [UIColor clearColor];
    }
}

- (void) layoutSubviews {
    [super layoutSubviews];
    CGRect tableCellFrame = self.textLabel.frame;
    tableCellFrame.size.width += 30.0;
    tableCellFrame.origin.y = 2.0;
    self.textLabel.frame = tableCellFrame;
    self.textLabel.backgroundColor = [UIColor clearColor];
    
}


@end
