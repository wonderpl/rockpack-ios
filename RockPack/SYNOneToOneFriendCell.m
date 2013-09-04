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
        
        CGRect svFrame = CGRectMake(0.0, 0.0f, 0.0f, 2.0f);
        self.customSeparatorView = [[UIView alloc] initWithFrame:svFrame];
        svFrame.size.height = 1.0f;
        UIView* blackLineView = [[UIView alloc] initWithFrame:svFrame];
        blackLineView.backgroundColor = [UIColor darkGrayColor];
        svFrame.origin.y = 1.0f;
        UIView* whiteLineView = [[UIView alloc] initWithFrame:svFrame];
        whiteLineView.backgroundColor = [UIColor lightGrayColor];
        
        [self.customSeparatorView addSubview:blackLineView];
        [self.customSeparatorView addSubview:whiteLineView];
        [self addSubview:self.customSeparatorView];
        
        
    }
    return self;
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(10.0f, 10.0f, 30.0f, 30.0f);
    self.textLabel.frame = CGRectMake(50.0f, 10.0f, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
    self.detailTextLabel.frame = CGRectMake(50.0f, 28.0f, self.detailTextLabel.frame.size.width, self.detailTextLabel.frame.size.height);
    self.customSeparatorView.frame = CGRectMake(10.0f, self.frame.size.height - 2.0f, self.frame.size.width - 20.0f, 2.0f);
    float posY = 0.0f;
    for (UIView* lineView in self.customSeparatorView.subviews) {
        CGRect lFrame = lineView.frame;
        lFrame.origin.y = posY;
        lFrame.origin.x = 0.0f;
        lFrame.size = self.customSeparatorView.frame.size;
        lineView.frame = lFrame;
        posY += 1.0f;
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
  
    
    

}

@end
