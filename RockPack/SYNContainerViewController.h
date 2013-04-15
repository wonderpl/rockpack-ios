//
//  SYNBottomTabViewController.h
//  RockPack
//
//  Created by Nick Banks on 13/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "GAITrackedViewController.h"
#import "SYNAbstractViewController.h"
#import "SYNVideoQueueDelegate.h"
#import "SYNVideoQueueViewController.h"
#import <UIKit/UIKit.h>

<<<<<<< HEAD
@interface SYNContainerViewController : GAITrackedViewController <SYNVideoQueueDelegate, UIScrollViewDelegate>
=======
typedef enum {
    ScrollingDirectionNone = 0,
    ScrollingDirectionRight,
    ScrollingDirectionLeft
} ScrollingDirection;

@interface SYNContainerViewController : UIViewController <SYNVideoQueueDelegate, UIScrollViewDelegate>
>>>>>>> origin/develop


@property (nonatomic, weak) SYNVideoQueueViewController* videoQueueController;
@property (nonatomic, readonly) SYNAbstractViewController* showingViewController;
@property (nonatomic, readonly) UIScrollView* scrollView;

@property (nonatomic) NSInteger page;
@property (nonatomic) NSInteger currentPage;

@property (nonatomic) CGPoint currentPageOffset;
@property (nonatomic) ScrollingDirection scrollingDirection;
-(SYNAbstractViewController*)nextShowingViewController;

- (void) popCurrentViewController: (id) sender;
-(void) showSearchViewControllerWithTerm:(NSString*)term;
-(void) navigateToPageByName:(NSString*)pageName;



@end
