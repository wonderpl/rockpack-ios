//
//  SYNBottomTabViewController.h
//  RockPack
//
//  Created by Nick Banks on 13/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNVideoQueueDelegate.h"
#import "SYNVideoQueueViewController.h"

@interface SYNContainerViewController : UIViewController <SYNVideoQueueDelegate, UIScrollViewDelegate>


@property (nonatomic, strong) SYNVideoQueueViewController* videoQueueController;

- (void) popCurrentViewController: (id) sender;
- (void) repositionQueueView;
-(void) showSearchViewControllerWithTerm:(NSString*)term;


@end
