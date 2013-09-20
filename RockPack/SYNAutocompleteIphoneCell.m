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
@synthesize separatorView;
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
        
        self.separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.frame.size.height - 2.0f, self.frame.size.width, 2.0f)];
        
        
        UIView* viewGrayLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.separatorView.frame.size.width, 1.0f)];
        viewGrayLine.backgroundColor = [UIColor colorWithRed:(229.0f/255.0f) green:(229.0f/255.0f) blue:(229.0f/255.0f) alpha:1.0f];
        
        [self.separatorView addSubview:viewGrayLine];
        
        UIView* viewWhiteLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 1.0f, self.separatorView.frame.size.width, 1.0f)];
        viewWhiteLine.backgroundColor = [UIColor whiteColor];
        
        [self.separatorView addSubview:viewWhiteLine];
        
        [self addSubview:self.separatorView];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.textLabel.font = [UIFont rockpackFontOfSize:14.0f];
        self.textLabel.textColor = self.defaultColor;
        self.textLabel.shadowColor = self.defaultShadowColor;
        self.textLabel.shadowOffset = CGSizeMake(0.0f,1.0f);
        self.textLabel.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

-(void)layoutSubviews
{
    
    [super layoutSubviews];
    
    CGRect newFrame = self.textLabel.frame;
    
    newFrame.size.width = 250.0f;
    
    newFrame.origin.x = 52.0f;
    newFrame.origin.y += 4.0f;
    
    self.textLabel.frame = newFrame;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if(selected)
    {
        if(IS_IOS_7_OR_GREATER)
            self.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"NavSelected"]];
        else
            self.backgroundColor = [UIColor whiteColor];
        self.textLabel.textColor = self.selectedColor;
        self.textLabel.shadowColor = self.selectedShadowColor;
    }
    else
    {
        if(IS_IOS_7_OR_GREATER)
            self.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"NavSeleNavDefaultcted"]];
        else
            self.backgroundColor = [UIColor whiteColor];
        self.textLabel.textColor = self.defaultColor;
        self.textLabel.shadowColor = self.defaultShadowColor;
    }
}




@end
