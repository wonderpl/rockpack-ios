//
//  SYNTabView.h
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNTabViewDelegate.h"

@interface SYNTabView : UIView <SYNTabViewDelegate>

-(id)initWithSize:(CGFloat)totalWidth;

@end
