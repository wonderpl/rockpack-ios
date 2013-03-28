//
//  SYNUserItemView.m
//  rockpack
//
//  Created by Michael Michailidis on 26/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNUserItemView.h"
#import "UIColor+SYNColor.h"

@implementation SYNUserItemView

- (id)initWithTitle:(NSString*)name andFrame:(CGRect)frame
{
    self = [super initWithTitle:name andFrame:frame];
    if (self) {
        
        self.numberLabel.center = CGPointMake(self.numberLabel.center.x, 50.0);
        self.numberLabel.frame = CGRectIntegral(self.numberLabel.frame);
        
        self.nameLabel.center = CGPointMake(self.nameLabel.center.x, 75.0);
        self.nameLabel.frame = CGRectIntegral(self.nameLabel.frame);
    }
    return self;
}

-(void)makeHighlightedWithImage:(BOOL)withImage
{
    
    if(withImage)
    {
        UIImage* pressedImage = [UIImage imageNamed:@"BarHeaderYouSelected.png"];
        self.backgroundColor = [UIColor colorWithPatternImage:pressedImage];
    }
    
    
    for (UILabel* label in self.labels)
    {
        
        label.textColor = [UIColor rockpackBlueColor];
        //        label.layer.shadowColor = [color CGColor];
        //        label.layer.shadowRadius = 7.0f;
        //        label.layer.shadowOpacity = 1.0;
        //        label.layer.shadowOffset = CGSizeZero;
        //        label.layer.masksToBounds = NO;
    }
    
    // TODO: See what can be done with the animations
    
    if(withImage)
    {
        self.bottomGlowImageView.alpha = 0.0;
        self.bottomGlowImageView.hidden = NO;
        self.bottomGlowImageView.alpha = 1.0;
    }
}



@end
