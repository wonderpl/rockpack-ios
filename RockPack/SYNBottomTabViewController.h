//
//  SYNBottomTabViewController.h
//  RockPack
//
//  Created by Nick Banks on 13/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNAbstractViewController.h"
#import "SYNVideoQueueDelegate.h"

@interface SYNBottomTabViewController : SYNAbstractViewController <SYNVideoQueueDelegate>

@property (nonatomic, strong, readonly) UIButton *messageInboxButton;


- (void) popCurrentViewController: (id) sender;

-(void) showSearchViewControllerWithTerm:(NSString*)term;

@end
