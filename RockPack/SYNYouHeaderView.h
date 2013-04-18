//
//  SYNYouHeaderView.h
//  rockpack
//
//  Created by Michael Michailidis on 18/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
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
-(void)setTitle:(NSString *)title andNumber:(NSInteger)number;

-(void)setBackgroundImage:(UIImage*)backgroundImage;

@end
