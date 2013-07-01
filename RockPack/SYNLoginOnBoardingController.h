//
//  SYNLoginOnBoardingController.h
//  rockpack
//
//  Created by Michael Michailidis on 21/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIScrollViewDelegate;

@interface SYNLoginOnBoardingController : UIViewController

- (id) initWithDelegate: (id <UIScrollViewDelegate>) delegate;

@property (nonatomic, readonly) UIScrollView* scrollView;
@property (nonatomic, readonly) UIPageControl* pageControl;

@end
