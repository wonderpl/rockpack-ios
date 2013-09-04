//
//  SYNOneToOneFriendCell.m
//  rockpack
//
//  Created by Michael Michailidis on 04/09/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNOneToOneFriendCell.h"
#import "UIFont+SYNFont.h"

@implementation SYNOneToOneFriendCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont boldRockpackFontOfSize:13.0f];
        self.textLabel.textColor = [UIColor blackColor];
        self.detailTextLabel.font = [UIFont rockpackFontOfSize:12.0f];
        self.detailTextLabel.textColor = [UIColor grayColor];
    }
    return self;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(10.0f, 10.0f, 30.0f, 30.0f);
    self.textLabel.frame = CGRectMake(50.0f, 10.0f, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
    self.detailTextLabel.frame = CGRectMake(50.0f, 28.0f, self.detailTextLabel.frame.size.width, self.detailTextLabel.frame.size.height);
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
  
    
    

}

@end
