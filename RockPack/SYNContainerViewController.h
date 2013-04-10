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
#import "SYNAbstractViewController.h"

@interface SYNContainerViewController : UIViewController <SYNVideoQueueDelegate, UIScrollViewDelegate>


@property (nonatomic, weak) SYNVideoQueueViewController* videoQueueController;
@property (nonatomic, readonly) SYNAbstractViewController* showingViewController;
@property (nonatomic) NSInteger page;

- (void) popCurrentViewController: (id) sender;
-(void) showSearchViewControllerWithTerm:(NSString*)term;
-(void) navigateToPageByName:(NSString*)pageName;



@end
