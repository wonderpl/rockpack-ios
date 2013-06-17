//
//  SYNPageView.h
//  rockpack
//
//  Created by Nick Banks on 17/06/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNPageView : UIView

// The position is from 0.0f - 1.0f, with 0 being the leftmost position and 1.0f being the rightmost position
- (void) setPosition: (float) position;

@end
