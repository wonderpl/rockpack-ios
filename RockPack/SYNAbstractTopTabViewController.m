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

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    [self createTab];
    
    

}



- (void) highlightTab: (int) tabIndex
{
    
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
        DebugLog(@"Did not find Categories, loading fresh");
        [appDelegate.networkEngine updateCategoriesOnCompletion:^{
            [self createTab];
        } onError:^(NSError* error){
            DebugLog(@"%@", [error debugDescription]);
        }];
        return;
    }
   
    // Create tab
    
    self.tabView = [[SYNCategoriesTabView alloc] initWithCategories:matchingCategoryInstanceEntries andSize:self.view.frame.size];
    self.tabView.frame = CGRectMake(0.0, 44.0, self.tabView.frame.size.width, self.tabView.frame.size.height);
    self.tabView.tapDelegate = self;
    [self.view addSubview:self.tabView];
    
    
    
    
}

#pragma mark - TabViewDelegate

-(void)handleMainTap:(UITapGestureRecognizer *)recogniser
{
    SYNCategoryItemView *tab = (SYNCategoryItemView*)recogniser.view;
    
    SYNAppDelegate *appDelegate = UIApplication.sharedApplication.delegate;
    
    NSEntityDescription* categoryEntity = [NSEntityDescription entityForName: @"Category" inManagedObjectContext:appDelegate.mainManagedObjectContext];
    
    NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
    [categoriesFetchRequest setEntity:categoryEntity];
    
    //DebugLog(@"Tag clicked : %d", tab.tag);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %d", tab.tag];
    [categoriesFetchRequest setPredicate: predicate];
    
    NSError* error = nil;
    
    NSArray *matchingCategoryInstanceEntries = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                                   error: &error];
    
    if(matchingCategoryInstanceEntries.count == 0)
    {
        DebugLog(@"WARNING: Found NO Category for Tab %d", tab.tag);
        return;
    }
    
    if (matchingCategoryInstanceEntries.count > 1)
    {
        DebugLog(@"WARNING: Found multiple (%i) Categories for Tab %d", matchingCategoryInstanceEntries.count, tab.tag);
        
    }
    
    
    
    
    Category* categoryTapped = (Category*)matchingCategoryInstanceEntries[0];
    
    [self.tabView createSubcategoriesTab:categoryTapped.subcategories];
    
    DebugLog(@"Pressed on Category:\n%@", categoryTapped);
}

-(void)handleSecondaryTap:(UITapGestureRecognizer *)recogniser
{
    //SYNAppDelegate *appDelegate = UIApplication.sharedApplication.delegate;
}







@end
