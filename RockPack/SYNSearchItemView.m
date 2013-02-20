//
//  SYNSearchItemView.m
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchItemView.h"
#import "UIFont+SYNFont.h"
#import "UIColor+SYNColor.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNSearchItemView ()

@property (nonatomic, strong) UILabel* numberLabel;
@property (nonatomic, strong) UILabel* nameLabel;
@property (nonatomic, strong) UIImageView* bottomGlowImageView;
@property (nonatomic, strong) NSArray* labels;

@end



@implementation SYNSearchItemView



- (id)initWithTitle:(NSString*)name andFrame:(CGRect)frame
{
    
    if (self = [super initWithFrame:frame]) {
        
        
        // Number Label
        
        UIFont* numberFontToUse = [UIFont rockpackFontOfSize: 14.0f];
        CGSize numberLabelSize = [@"100" sizeWithFont:numberFontToUse];
    
        self.numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, numberLabelSize.height)];
        self.numberLabel.font = numberFontToUse;
        self.numberLabel.text = @"";
        self.numberLabel.textAlignment = NSTextAlignmentCenter;
        self.numberLabel.textColor = [UIColor whiteColor];
        self.numberLabel.userInteractionEnabled = NO;
        self.numberLabel.backgroundColor = [UIColor clearColor];
        self.numberLabel.center = CGPointMake(self.numberLabel.center.x, 20.0);
        [self addSubview:self.numberLabel];
        
        
        // Name Label
        
        UIFont* nameFontToUse = [UIFont rockpackFontOfSize: 13.0f];
        CGSize nameLabelSize = [name sizeWithFont:nameFontToUse];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, nameLabelSize.height)];
        self.nameLabel.font = numberFontToUse;
        self.nameLabel.text = name;
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.userInteractionEnabled = NO;
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.center = CGPointMake(self.nameLabel.center.x, 60.0);
        [self addSubview:self.nameLabel];
        
        
        // Glow
        
        self.bottomGlowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SearchTabHeaderGlow.png"]];
        self.bottomGlowImageView.center = CGPointMake(self.frame.size.width*0.5, self.bottomGlowImageView.center.y);
        self.bottomGlowImageView.hidden = YES;
        self.bottomGlowImageView.userInteractionEnabled = NO;
        [self addSubview:self.bottomGlowImageView];
        
        // register labels in array
        
        self.labels = @[self.numberLabel, self.nameLabel];
        
    }
    return self;
}


-(void)setNumberOfItems:(NSInteger)noi
{
    self.numberLabel.text = [NSString stringWithFormat:@"%i", noi];

}

-(void)makeHighlightedWithImage:(BOOL)withImage
{
    
    if(withImage)
    {
        UIImage* pressedImage = [UIImage imageNamed:@"SearchTabHeaderSelected.png"];
        self.backgroundColor = [UIColor colorWithPatternImage:pressedImage];
    }
    
    
    UIColor *color = [UIColor rockpackBlueColor];
    
    for (UILabel* label in self.labels)
    {
        
        label.textColor = color;
        label.layer.shadowColor = [color CGColor];
        label.layer.shadowRadius = 7.0f;
        label.layer.shadowOpacity = 1.0;
        label.layer.shadowOffset = CGSizeZero;
        label.layer.masksToBounds = NO;
        
    }
    
    
    
    // TODO: See what can be done with the animations
    
    if(withImage)
    {
        self.bottomGlowImageView.alpha = 0.0;
        self.bottomGlowImageView.hidden = NO;
        self.bottomGlowImageView.alpha = 1.0;
    }
    
    
    [UIView animateWithDuration:0.3 animations:^{
        
    }];
    
    
    
    
}


-(void)makeFaded
{
    self.backgroundColor = [UIColor clearColor];
    
    for (UILabel* label in self.labels)
    {
        
        label.textColor = [UIColor lightGrayColor];
        label.layer.shadowColor = [[UIColor clearColor] CGColor];
        label.textColor = [UIColor lightGrayColor];
        label.layer.shadowColor = [[UIColor clearColor] CGColor];
        
        
        
    }
    
    self.bottomGlowImageView.hidden = YES;
    
    
}
-(void)makeStandard
{
    self.backgroundColor = [UIColor clearColor];
    
    for (UILabel* label in self.labels)
    {
        
        label.textColor = [UIColor whiteColor];
        label.layer.shadowColor = [[UIColor clearColor] CGColor];
        label.textColor = [UIColor whiteColor];
        label.layer.shadowColor = [[UIColor clearColor] CGColor];
        
    }
    
    self.bottomGlowImageView.hidden = YES;
    
    
}



@end
