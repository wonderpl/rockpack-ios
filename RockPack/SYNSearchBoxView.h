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
@property (nonatomic, strong) IBOutlet UITextField* searchTextField;

//iPhone specific
@property (weak, nonatomic) IBOutlet UIButton *integratedCloseButton;

-(void)resizeForHeight:(CGFloat)height;

+(id)searchBoxView;

//iPhone specific
/**
	move the close button onscreen and resize the text box.
 
    not animated, wrap in UIView animaiton call to animate
 */
-(void)revealCloseButton;

/**
 move the close button offscreen and resize the text box.
 
 not animated, wrap in UIView animaiton call to animate
 */
-(void)hideCloseButton;

@end
