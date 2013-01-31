//
//  SYNBottomTabViewController.h
//  RockPack
//
//  Created by Nick Banks on 13/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNAbstractViewController.h"

@interface SYNBottomTabViewController : SYNAbstractViewController 

@property (nonatomic, strong, readonly) UIButton *messageInboxButton;

- (void) slideMessageInboxLeft: (UISwipeGestureRecognizer *) swipeGesture;
- (void) slideMessageInboxRight: (UISwipeGestureRecognizer *) swipeGesture;
- (void) slideShareMenuLeft: (UISwipeGestureRecognizer *) swipeGesture;
- (void) slideShareMenuRight: (UISwipeGestureRecognizer *) swipeGesture;
- (void) toggleShareMenu;
- (void) showBackButton;
- (void) hideBackButton;

@end
