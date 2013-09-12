//
//  SYNContainerScrollView.h
//  rockpack
//
//  Created by Michael Michailidis on 24/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNContainerScrollView : UIScrollView

@property (nonatomic) NSInteger page;

- (id) initFullScreenWithDelegate:(id<UIScrollViewDelegate>)controller;

- (void) setPage: (NSInteger) page
        animated: (BOOL) animated;

@end
