//
//  SYNTabViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SYNTabViewDelegate.h"
#import "SYNTabView.h"
#import "SYNCategoriesTabView.h"

@interface SYNTabViewController : UIViewController <SYNTabViewDelegate> 


@property (nonatomic, weak) id <SYNTabViewDelegate> delegate;

@property (nonatomic, readonly) SYNTabView* tabView;

@end
