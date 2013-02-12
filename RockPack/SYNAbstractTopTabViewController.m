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
    
    
    [self createTab];
    
    

}




-(void)createTab
{
    SYNAppDelegate *appDelegate = UIApplication.sharedApplication.delegate;
    
    NSEntityDescription* categoryEntity = [NSEntityDescription entityForName: @"Category" inManagedObjectContext:appDelegate.mainManagedObjectContext];
    
    NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
    [categoriesFetchRequest setEntity:categoryEntity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"uniqueId" ascending:YES];
    [categoriesFetchRequest setSortDescriptors:@[sortDescriptor]];
    
    
    NSError* error;
    
    NSArray *matchingCategoryInstanceEntries = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                                   error: &error];
    
    if (matchingCategoryInstanceEntries.count <= 0)
    {
        DebugLog(@"Did not find Categories");
        return;
    }
   
    // Create tab
    
    self.tabView = [[SYNCategoriesTabView alloc] initWithCategories:matchingCategoryInstanceEntries];
    
    [self.view addSubview:self.tabView];
    
    
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
