//
//  SYNNetworkErrorView.h
//  rockpack
//
//  Created by Michael Michailidis on 22/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNNetworkErrorView : UIView {
    UILabel* errorLabel;
    UIImageView* wifiImageView;
}


+(id)errorView;

-(void)setText:(NSString*)text;
-(CGFloat)height;

@end
