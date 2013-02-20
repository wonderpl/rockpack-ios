//
//  SYNTabView.m
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNTabView.h"

#define kDefaultTabsHeight 20.0

@implementation SYNTabView

-(id)initWithSize:(CGFloat)totalWidth
{
    self = [super initWithFrame:CGRectMake(0.0, 0.0, totalWidth, kDefaultTabsHeight)];
    if (self) {
        
        
    }
    return self;
}


-(void)handleMainTap:(UITapGestureRecognizer*)recogniser {
    // implement in subclass
}
-(void)handleSecondaryTap:(UITapGestureRecognizer*)recogniser {
    // implement in subclass
}

@end
