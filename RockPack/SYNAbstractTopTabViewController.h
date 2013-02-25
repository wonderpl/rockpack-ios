//
//  SYNAbstractTopTabViewController.h
//  RockPack
//
//  Created by Nick Banks on 14/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNTabImageView.h"
#import "SYNAbstractViewController.h"
#import "SYNTabViewDelegate.h"
#import "SYNCategoriesTabView.h"
#import "SYNCategoriesTabViewController.h"
#import "SYNTabViewController.h"
#import "SYNTabView.h"

@interface SYNAbstractTopTabViewController : SYNAbstractViewController <SYNTabViewDelegate> {
    @protected BOOL tabExpanded;
    @protected SYNTabViewController* tabViewController;
}

@property (nonatomic, strong) SYNTabViewController* tabViewController;

- (void) highlightTab: (int) tabIndex;
-(void)handleNewTabSelectionWithId:(NSString*)selectionId;


@end
