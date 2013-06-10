//
//  SYNNetworkErrorView.h
//  rockpack
//
//  Created by Michael Michailidis on 22/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNNetworkErrorView : UIView {

}


+(id)errorView;

-(void)setText:(NSString*)text;
-(void)setIconImage:(UIImage*)image;
-(void)setCenterVerticalOffset:(CGFloat)centerYOffset;
-(CGFloat)height;

@end
