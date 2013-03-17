//
//  SYNPassthroughView.h
//  rockpack
//
//  Created by Nick Banks on 09/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNPassthroughView : UIView

-(BOOL) pointInside: (CGPoint) point
          withEvent: (UIEvent *) event;
@end
