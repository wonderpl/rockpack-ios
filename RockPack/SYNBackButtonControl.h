//
//  SYNBackButtonControl.h
//  rockpack
//
//  Created by Michael Michailidis on 12/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNBackButtonControl : UIControl {
    UIButton* button;
    UIView* titleBGView;
    UILabel* titleLabel;
    UITapGestureRecognizer* recogniser;
}
@property (nonatomic, readonly) UIButton* button;
+(id)backButton;
-(void)setBackTitle:(NSString*)backTitle;

@end
