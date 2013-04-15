//
//  SYNBackButtonControl.h
//  rockpack
//
//  Created by Michael Michailidis on 12/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNBackButtonControl : UIControl {
    UIButton* overButton;
    UIImageView* arrowImageView;
    UIView* titleBGView;
    UILabel* titleLabel;
}

+(id)backButton;
-(void)setBackTitle:(NSString*)backTitle;

@end
