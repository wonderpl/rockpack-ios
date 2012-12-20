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

@property (nonatomic, strong, readonly) UIButton *rockieTalkieButton;

- (void) swipeRockieTalkieLeft: (UISwipeGestureRecognizer *) swipeGesture;
- (void) swipeRockieTalkieRight: (UISwipeGestureRecognizer *) swipeGesture;

@end
