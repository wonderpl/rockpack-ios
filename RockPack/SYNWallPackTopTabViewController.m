//
//  SYNWallPackTopTabViewController.m
//  RockPack
//
//  Created by Nick Banks on 14/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppContants.h"
#import "SYNWallPackTopTabViewController.h"
#import "SYNWallPackCategoryAViewController.h"
#import "SYNWallPackCategoryBViewController.h"

@interface SYNWallPackTopTabViewController ()

@end

@implementation SYNWallPackTopTabViewController

// For the demo version, just set up two view controllers so that we can switch between them when the tabs are selected
- (void) viewDidLoad
{
    [super viewDidLoad];

    // Setup our four sub-viewcontrollers, one for each tab
    SYNWallPackCategoryAViewController *categoryAViewController = [[SYNWallPackCategoryAViewController alloc] init];
    SYNWallPackCategoryBViewController *categoryBViewController = [[SYNWallPackCategoryBViewController alloc] init];
    
    // Using new array syntax
    self.viewControllers = @[categoryAViewController, categoryBViewController, categoryAViewController, categoryBViewController, categoryAViewController,
                             categoryBViewController, categoryAViewController, categoryBViewController, categoryAViewController, categoryAViewController];
    
    self.selectedViewController = categoryAViewController;
}


@end
