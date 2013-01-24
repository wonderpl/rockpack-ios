//
//  SYNAbstractTopTabViewController.m
//  RockPack
//
//  Created by Nick Banks on 14/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "SYNAbstractTopTabViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNAbstractTopTabViewController ()

@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, weak) UIViewController *selectedViewController;

@end

@implementation SYNAbstractTopTabViewController

@synthesize selectedIndex = _selectedIndex;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    _selectedIndex = NSNotFound;
    
//    //Underlying (unselected) tab images
//    self.topTabView = [[SYNTabImageView alloc] initWithFrame: CGRectMake (0, 33, 1024, 65)
//                                            touchHandler: ^(CGPoint touchPoint)
//                                                          {
//                                                              [self tabButtonTouched: touchPoint];
//                                                          }];
//    
//    self.topTabView.contentMode  = UIViewContentModeLeft;
//    self.topTabView.image = [UIImage imageNamed: @"TabTop.png"];
//    self.topTabView.userInteractionEnabled = YES;
//    
//    [self.view addSubview: self.topTabView];
//    
//    // Highlighted tab images to craftily overlay (by using a superview to clip)
//    self.topTabHighlightedView = [[UIImageView alloc] initWithFrame: CGRectMake (0, 0, 1024, 65)];
//    self.topTabHighlightedView.contentMode  = UIViewContentModeLeft;
//    self.topTabHighlightedView.image = [UIImage imageNamed: @"TabTopHighlighted.png"];
    
    // Just put placeholder image in for now
    self.topTabView = [[UIImageView alloc] initWithFrame: CGRectMake (0, 79, 1024, 65)];
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


// Set the selected tab (with no animation)

- (void) setSelectedIndex: (NSUInteger) newSelectedIndex
{
    [self highlightTab: newSelectedIndex];
}


// Use the tag index of the button (100 - 103) to calculate the button index

- (IBAction) tabButtonPressed: (UIButton *) sender
{
    [self setSelectedIndex: sender.tag - kBottomTabIndexOffset];
}

- (IBAction) tabButtonTouched: (CGPoint) touchPoint
{
    CGFloat tabWidth = 1024.0f / kTopTabCount;
    
    int tab = trunc(touchPoint.x / tabWidth);

	[self setSelectedIndex: tab];
}

@end
