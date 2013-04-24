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


@property (nonatomic, readonly) SYNAbstractViewController* showingViewController;
@property (nonatomic, readonly) SYNContainerScrollView* scrollView;


@property (nonatomic, readonly) NSInteger currentPage;

@property (nonatomic) CGPoint currentPageOffset;
@property (nonatomic) ScrollingDirection scrollingDirection;
-(SYNAbstractViewController*)nextShowingViewController;

- (void) popCurrentViewController: (id) sender;
-(void) showSearchViewControllerWithTerm:(NSString*)term;
-(void) navigateToPageByName:(NSString*)pageName;



@end
