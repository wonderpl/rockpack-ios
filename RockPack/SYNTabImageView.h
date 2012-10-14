//
//  SYNTabImageView.h
//  RockPack
//
//  Created by Nick Banks on 14/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

// Touch handler block
typedef void (^TabTouchHandler) (CGPoint touchPoint);

@interface SYNTabImageView : UIImageView

- (id) initWithFrame: (CGRect) frame
        touchHandler: (TabTouchHandler) touchHandler;

@end
