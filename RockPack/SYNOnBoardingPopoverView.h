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

+ (id)withMessage:(NSString*)message
         withSize:(CGSize)size
      andFontSize:(CGFloat)fontSize
       pointingTo:(CGRect)pointRect
    withDirection:(PointingDirection)direction;

- (id)initWithMessage:(NSString*)message
             withSize:(CGSize)size
          andFontSize:(CGFloat)fontSize
           pointingTo:(CGRect)pointRect
        withDirection:(PointingDirection)direction;

@property (nonatomic) PointingDirection direction;
@property (nonatomic) CGRect pointRect;
@property (nonatomic, strong) UIButton* okButton;

@end
