//
//  SYNOnBoardingPopoverView.h
//  rockpack
//
//  Created by Michael Michailidis on 12/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppConstants.h"


@interface SYNOnBoardingPopoverView : UIView

- (id)initWithMessage:(NSString*)message
           pointingTo:(CGPoint)point
        withDirection:(PointingDirection)direction;

+ (id)withMessage:(NSString*)message
       pointingTo:(CGPoint)point
    withDirection:(PointingDirection)direction;

@property (nonatomic, strong) UIView* backgroundView;
@property (nonatomic, strong) UIView* panelView;
@property (nonatomic, strong) UIButton* okButton;

@end
