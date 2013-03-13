//
//  SYNLoginErrorArrow.h
//  rockpack
//
//  Created by Michael Michailidis on 13/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNLoginErrorArrow : UIView {
    UIImageView* backgroundImageView;
    UILabel* messageLabel;
}


-(void)setMessage:(NSString*)message;
-(id)initWithDefault;
+(id)withMessage:(NSString*)message;
@end
