//
//  SYNUserProfileViewDelegate.h
//  rockpack
//
//  Created by Michael Michailidis on 16/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol SYNUserProfileViewDelegate <NSObject>

-(void)userSpaceTapped:(UITapGestureRecognizer*)recogniser;

@end
