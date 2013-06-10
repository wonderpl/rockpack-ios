//
//  SYNYouHeaderView.h
//  rockpack
//
//  Created by Michael Michailidis on 18/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNYouHeaderView : UIView {
    UILabel* label;
    UIView* textCompositeView;
    UILabel* numberLabel;
    UIImageView* backgroundImageView;
}

@property (nonatomic, readonly) CGFloat currentHeight;
@property (nonatomic, readonly) CGFloat currentWidth;

+(id)headerViewForWidth:(CGFloat)width;
-(void)setTitle:(NSString *)title andTotalCount:(NSInteger)number;

-(void)setBackgroundImage:(UIImage*)backgroundImage;

-(void)setFontSize:(CGFloat)pointSize;

-(void) setColorsForText:(UIColor*)textColor parentheses:(UIColor*)parenthesesColor number:(UIColor*)numberColor;
@end
