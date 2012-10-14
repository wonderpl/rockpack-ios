//
//  SYNAbstractTopTabViewController.m
//  RockPack
//
//  Created by Nick Banks on 14/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNAbstractTopTabViewController.h"

@interface SYNAbstractTopTabViewController ()

@end

@implementation SYNAbstractTopTabViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *topTabView = [[UIImageView alloc] initWithFrame: CGRectMake (0, 33, 1024, 65)];
    topTabView.contentMode  = UIViewContentModeScaleToFill;
    topTabView.image = [UIImage imageNamed: @"TabTop@2x.png"];
    [self.view addSubview: topTabView];
}



@end
