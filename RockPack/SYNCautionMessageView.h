//
//  SYNCautionMessageView.h
//  rockpack
//
//  Created by Michael Michailidis on 25/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNCaution.h"

@interface SYNCautionMessageView : UIView

- (id) initWithCaution:(SYNCaution*)caution;
+ (id) withCaution:(SYNCaution*)caution;

@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* messageLabel;

@property (nonatomic, strong) UIButton* skipButton;
@property (nonatomic, strong) UIButton* actionButton;

@property (nonatomic, strong) SYNCaution* caution;

-(void) presentInView:(UIView*)container;


@end
