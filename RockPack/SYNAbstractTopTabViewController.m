//
//  SYNAbstractTopTabViewController.m
//  RockPack
//
//  Created by Nick Banks on 14/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppContants.h"
#import "SYNAbstractTopTabViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNAbstractTopTabViewController ()

@property (nonatomic, strong) UIImageView *topTabView;
@property (nonatomic, strong) UIImageView *topTabHighlightedView;

@end

@implementation SYNAbstractTopTabViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.topTabView = [[UIImageView alloc] initWithFrame: CGRectMake (0, 33, 1024, 65)];
    self.topTabView.contentMode  = UIViewContentModeLeft;
    self.topTabView.image = [UIImage imageNamed: @"TabTop.png"];
    [self.view addSubview: self.topTabView];
    
    self.topTabHighlightedView = [[UIImageView alloc] initWithFrame: CGRectMake (0, 0, 1024, 65)];
    self.topTabHighlightedView.contentMode  = UIViewContentModeLeft;
    self.topTabHighlightedView.image = [UIImage imageNamed: @"TabTopHighlighted.png"];
//    [self.view addSubview: self.topTabHighlightedView];
    
    [self highlightTab: 7];
}


// Highlight selected tab by revealing a portion of the hightlight image corresponing to the active tab

- (void) highlightTab: (int) tabIndex
{
    CGFloat tabWidth = 1024.0f / kTopTabCount;
    
    // Work our where to show our highlight
    float startX = tabIndex * tabWidth;

    UIView *containerView = [[UIImageView alloc] initWithFrame: CGRectMake (startX , 33, tabWidth, 65)];

    // Update the meter view width
    CGRect tabBounds = self.topTabHighlightedView.frame;
    tabBounds.origin.x = - startX;
    self.topTabHighlightedView.frame = tabBounds;
    
    containerView.clipsToBounds = YES;
    [containerView addSubview: self.topTabHighlightedView];
    [self.view addSubview: containerView];
}



@end
