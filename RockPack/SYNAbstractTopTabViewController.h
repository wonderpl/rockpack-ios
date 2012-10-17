//
//  SYNAbstractTopTabViewController.h
//  RockPack
//
//  Created by Nick Banks on 14/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNAbstractTopTabViewController : UIViewController

- (void) setViewControllers: (NSArray *) newViewControllers;
- (void) setSelectedViewController: (UIViewController *) newSelectedViewController;
- (void) highlightTab: (int) tabIndex;
@end
