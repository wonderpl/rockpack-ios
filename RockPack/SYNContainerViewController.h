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

typedef enum {
    ScrollingDirectionNone = 0,
    ScrollingDirectionRight,
    ScrollingDirectionLeft
} ScrollingDirection;

@interface SYNContainerViewController : UIViewController <SYNVideoQueueDelegate, UIScrollViewDelegate>


@property (nonatomic, weak) SYNVideoQueueViewController* videoQueueController;
@property (nonatomic, readonly) SYNAbstractViewController* showingViewController;
@property (nonatomic) NSInteger page;

@property (nonatomic) CGPoint currentPageOffset;
@property (nonatomic) ScrollingDirection scrollingDirection;

- (void) popCurrentViewController: (id) sender;
-(void) showSearchViewControllerWithTerm:(NSString*)term;
-(void) navigateToPageByName:(NSString*)pageName;



@end
