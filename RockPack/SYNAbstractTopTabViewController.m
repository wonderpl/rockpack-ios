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
    

}


// Highlight selected tab by revealing a portion of the hightlight image corresponing to the active tab

- (void) highlightTab: (int) tabIndex
{
    
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
