//
//  SYNBottomTabViewController.h
//  RockPack
//
//  Created by Nick Banks on 13/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "GAITrackedViewController.h"
#import "SYNAbstractViewController.h"
#import "SYNContainerScrollView.h"
#import <UIKit/UIKit.h>

typedef enum {
    ScrollingDirectionNone = 0,
    ScrollingDirectionRight,
    ScrollingDirectionLeft
} ScrollingDirection;

@interface SYNContainerViewController : GAITrackedViewController <UIScrollViewDelegate>

@property (nonatomic) CGPoint currentPageOffset;
@property (nonatomic) ScrollingDirection scrollingDirection;
@property (nonatomic, readonly) NSInteger currentPage;
@property (nonatomic, readonly) SYNAbstractViewController* showingBaseViewController;
@property (nonatomic, readonly) SYNAbstractViewController* showingViewController;
@property (nonatomic, readonly) SYNContainerScrollView* scrollView;

- (SYNAbstractViewController*) nextShowingViewController;

- (void) navigateToPageByName: (NSString*) pageName;

/**
	Method to re-layout view to maintain orientation. Specifically intended for when orientation may have changed during popover views.
 */
-(void)refreshView;


- (void) backButtonWillShow;
- (void) backButtonwillHide;



@end
