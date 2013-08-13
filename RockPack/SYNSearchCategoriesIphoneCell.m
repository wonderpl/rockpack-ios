//
//  SYNSearchCategoriesIphoneCell.m
//  rockpack
//
//  Created by Michael Michailidis on 13/08/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchCategoriesIphoneCell.h"

@implementation SYNSearchCategoriesIphoneCell
@synthesize separatorView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    
    if (self) {
        
        
        self.textLabel.shadowColor = [UIColor colorWithRed: 1.0f
                                                     green: 1.0f
                                                      blue: 1.0f
                                                     alpha: 0.75f];
        
        self.textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        
        
        self.backgroundColor = [UIColor clearColor];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.accessoryType = UITableViewCellAccessoryNone;
        
        self.contentView.backgroundColor = [UIColor clearColor];
        
        self.separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.frame.size.height - 2.0f, self.frame.size.width, 2.0f)];
        
        
        UIView* viewGrayLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.separatorView.frame.size.width, 1.0f)];
        viewGrayLine.backgroundColor = [UIColor colorWithRed:(229.0f/255.0f) green:(229.0f/255.0f) blue:(229.0f/255.0f) alpha:1.0f];
        
        [self.separatorView addSubview:viewGrayLine];
        
        UIView* viewWhiteLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 1.0f, self.separatorView.frame.size.width, 1.0f)];
        viewWhiteLine.backgroundColor = [UIColor whiteColor];
        
        [self.separatorView addSubview:viewWhiteLine];
        
        [self addSubview:self.separatorView];
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIImageView* arrow = (UIImageView*)self.accessoryView;
        arrow.image =[UIImage imageNamed: @"NavArrowSelected"];
        
    }
    
    
    return self;
}



-(void)layoutSubviews
{
    
    [super layoutSubviews];
    
    CGRect newFrame = self.textLabel.frame;
    
    newFrame.size.width = 250.0f;
    newFrame.origin.x = 20.0f;
    newFrame.origin.y += 6.0f;
    
    self.textLabel.frame = newFrame;
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    

}

@end
