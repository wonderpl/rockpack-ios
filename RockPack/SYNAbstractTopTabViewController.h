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

@interface SYNAbstractTopTabViewController : SYNAbstractViewController

@property (nonatomic, strong) SYNTabImageView *topTabView;
@property (nonatomic, strong) UIImageView *topTabHighlightedView;

- (void) highlightTab: (int) tabIndex;

@end
