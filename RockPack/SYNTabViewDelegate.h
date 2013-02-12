//
//  SYNTabViewDelegate.h
//  rockpack
//
//  Created by Michael Michailidis on 12/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SYNTabViewDelegate <NSObject>


-(void)handleMainTap:(UITapGestureRecognizer*)recogniser;
-(void)handleSecondaryTap:(UITapGestureRecognizer*)recogniser;

@end
