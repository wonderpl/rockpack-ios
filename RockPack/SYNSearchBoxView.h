//
//  SYNSearchBoxView.h
//  rockpack
//
//  Created by Michael Michailidis on 30/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNSearchBoxView : UIView {
    UIView* backgroundPanel;
    UIView* grayPanel;
    CGFloat initialPanelHeight;
}
@property (nonatomic, strong) UITextField* searchTextField;

-(void)resizeForHeight:(CGFloat)height;

+(id)searchBoxView;

@end
