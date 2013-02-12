//
//  SYNAbstractTopTabViewController.h
//  RockPack
//
//  Created by Nick Banks on 14/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNTabImageView.h"
#import "SYNAbstractViewController.h"
#import "SYNTabViewDelegate.h"
#import "SYNCategoriesTabView.h"

@interface SYNAbstractTopTabViewController : SYNAbstractViewController <SYNTabViewDelegate>


@property (nonatomic, strong) SYNCategoriesTabView* tabView;


- (void) highlightTab: (int) tabIndex;


-(void)createTab;

@end
