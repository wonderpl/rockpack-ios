//
//  SYNObjectFactory.m
//  rockpack
//
//  Created by Michael Michailidis on 24/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNObjectFactory.h"


@implementation SYNObjectFactory

+(UINavigationController*)wrapInNavigationController:(SYNAbstractViewController*)abstractViewController
{
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:abstractViewController];
    navigationController.title = abstractViewController.title;
    navigationController.view.frame = abstractViewController.view.frame;
    navigationController.navigationBarHidden = YES;
    navigationController.view.autoresizesSubviews = YES;
    navigationController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    abstractViewController.wantsFullScreenLayout = YES;
    return navigationController;
}

@end
