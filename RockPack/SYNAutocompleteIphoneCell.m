//
//  SYNAutocompleteIphoneCell.m
//  rockpack
//
//  Created by Mats Trovik on 01/05/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNAutocompleteIphoneCell.h"
#import "UIFont+SYNFont.h"

@interface SYNAutocompleteIphoneCell ()

@property (nonatomic,weak)UIImageView* backgroundImageView;
@property (nonatomic,strong)UIColor* defaultColor;
@property (nonatomic,strong)UIColor* selectedColor;
@property (nonatomic,strong)UIColor* defaultShadowColor;
@property (nonatomic,strong)UIColor* selectedShadowColor;

@end

@implementation SYNAutocompleteIphoneCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        
        self.defaultColor = [UIColor colorWithRed: (106.0f / 255.0)
                                            green: (114.0f / 255.0)
                                             blue: (122.0f / 255.0)
                                            alpha: (1.0)];
        
        
        self.defaultShadowColor = [UIColor colorWithWhite:1.0 alpha:1.0f];
        self.selectedColor = [UIColor colorWithWhite:1.0 alpha:1.0f];
        self.selectedShadowColor = [UIColor colorWithWhite:1.0 alpha:0.2];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.font = [UIFont rockpackFontOfSize:14];
        
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
    CGRect newFrame = self.textLabel.frame;
    newFrame.size.width = 250.0f;
    newFrame.origin.x = 20.0f;
    newFrame.origin.y += 4.0f;
    
    self.textLabel.frame = newFrame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if(selected)
    {
        self.backgroundImageView.image = [UIImage imageNamed:@"NavSelected"];
        self.textLabel.textColor = self.selectedColor;
        self.textLabel.shadowColor = self.selectedShadowColor;
    }
    else
    {
        self.backgroundImageView.image = [UIImage imageNamed:@"NavDefault"];
        self.textLabel.textColor = self.defaultColor;
        self.textLabel.shadowColor = self.defaultShadowColor;
    }
}




@end
