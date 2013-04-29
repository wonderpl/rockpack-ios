//
//  SYNSideNavigationIphoneCell.m
//  rockpack
//
//  Created by Mats Trovik on 29/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSideNavigationIphoneCell.h"
#import "UIFont+SYNFont.h"

@interface SYNSideNavigationIphoneCell ()

@property (nonatomic,weak)UIImageView* backgroundImageView;
@property (nonatomic,strong)UIColor* defaultColor;
@property (nonatomic,strong)UIColor* selectedColor;
@property (nonatomic,strong)UIColor* defaultShadowColor;
@property (nonatomic,strong)UIColor* selectedShadowColor;
@end

@implementation SYNSideNavigationIphoneCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.defaultColor = [UIColor colorWithRed: (40.0/255.0)
                                            green: (45.0/255.0)
                                             blue: (51.0/255.0)
                                            alpha: (1.0)];
        self.defaultShadowColor = [UIColor colorWithWhite:1.0 alpha:0.8];
        self.selectedColor = [UIColor colorWithWhite:1.0 alpha:1.0f];
        self.selectedShadowColor = [UIColor colorWithWhite:1.0 alpha:0.2];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.font = [UIFont rockpackFontOfSize:18];
        self.textLabel.textColor = self.defaultColor;
        self.textLabel.shadowColor = self.defaultShadowColor;
        self.textLabel.shadowOffset = CGSizeMake(0.0f,1.0f);
        self.textLabel.backgroundColor = [UIColor clearColor];
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.frame];
        self.backgroundView = imageView;
        self.backgroundImageView = imageView;
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGPoint center = self.textLabel.center;
    center.y += 4.0f;
    self.textLabel.center = center;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if(selected)
    {
        self.backgroundImageView.image = [UIImage imageNamed:@"NavSelected"];
        self.textLabel.textColor = self.selectedColor;
        self.textLabel.shadowColor = self.selectedShadowColor;
        if(self.accessoryType == UITableViewCellAccessoryDisclosureIndicator)
        {
            UIImageView* arrow = (UIImageView*)self.accessoryView;
            arrow.image =[UIImage imageNamed: @"NavArrowSelected"];
        }
    }
    else
    {
        self.backgroundImageView.image = [UIImage imageNamed:@"NavDefault"];
        self.textLabel.textColor = self.defaultColor;
        self.textLabel.shadowColor = self.defaultShadowColor;
        if(self.accessoryType == UITableViewCellAccessoryDisclosureIndicator)
        {
            UIImageView* arrow = (UIImageView*)self.accessoryView;
            arrow.image =[UIImage imageNamed: @"NavArrow"];
        }
    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if(highlighted)
    {
        self.backgroundImageView.image = [UIImage imageNamed:@"NavHighlighted"];
    }
    else
    {
        self.backgroundImageView.image = [UIImage imageNamed:@"NavDefault"];
    }
}

@end
