//
//  SYNAbstractTopTabViewController.m
//  RockPack
//
//  Created by Nick Banks on 14/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "SYNAbstractTopTabViewController.h"
#import "SYNNetworkEngine.h"
#import "SYNAppDelegate.h"
#import <CoreData/CoreData.h>
#import "SYNAppDelegate.h"
#import "SYNCategoryItemView.h"
#import "Category.h"
#import "Subcategory.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNAbstractTopTabViewController ()

@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, weak) UIViewController *selectedViewController;

@end

@implementation SYNAbstractTopTabViewController

@synthesize selectedIndex = _selectedIndex;
@synthesize tabViewController;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
}



- (void) highlightTab: (int) tabIndex
{
    
}


-(void)setTabViewController:(SYNTabViewController *)newTabViewController
{
    tabViewController = newTabViewController;
    tabViewController.delegate = self;
    [self.view addSubview:tabViewController.tabView];
    
    tabExpanded = NO;
}

#pragma mark - TabViewDelegate

-(void)handleMainTap:(UITapGestureRecognizer *)recogniser
{
    // to be implemented by child
}


-(void)handleSecondaryTap:(UITapGestureRecognizer *)recogniser
{
    // to be implemented by child
}


-(void)handleNewTabSelectionWithId:(NSString*)selectionId
{
    // to be implemented by child
}

-(BOOL)showSubcategories
{
    return YES;
}

@end
