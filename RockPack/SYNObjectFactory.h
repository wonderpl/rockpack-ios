//
//  SYNObjectFactory.h
//  rockpack
//
//  Created by Michael Michailidis on 24/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYNAbstractViewController.h"

@interface SYNObjectFactory : NSObject

+(UINavigationController*)wrapInNavigationController:(SYNAbstractViewController*)abstractViewController;

@end
