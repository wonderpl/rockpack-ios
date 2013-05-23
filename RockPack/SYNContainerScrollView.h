//
//  SYNContainerScrollView.h
//  rockpack
//
//  Created by Michael Michailidis on 24/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNContainerScrollView : UIScrollView

@property (nonatomic) NSInteger page;

- (void) setPage: (NSInteger) page
        animated: (BOOL) animated;

@end
