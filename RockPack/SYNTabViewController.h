//
//  SYNTabViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "GAITrackedViewController.h"
#import "SYNCategoriesTabView.h"
#import "SYNTabView.h"
#import "SYNTabViewDelegate.h"
#import <UIKit/UIKit.h>

@interface SYNTabViewController : GAITrackedViewController <SYNTabViewDelegate>

@property (nonatomic, weak) id <SYNTabViewDelegate> delegate;
@property (nonatomic, readonly) SYNTabView* tabView;

- (void) setSelectedWithId: (NSString*) selectedId;

@end
