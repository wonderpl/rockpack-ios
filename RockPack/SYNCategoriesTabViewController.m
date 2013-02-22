//
//  SYNCategoriesBarViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 19/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCategoriesTabViewController.h"
#import <CoreData/CoreData.h>
#import "SYNAppDelegate.h"
#import "SYNNetworkEngine.h"
#import "SYNCategoryItemView.h"
#import "Category.h"
#import "Subcategory.h"

@interface SYNCategoriesTabViewController ()

@end




@implementation SYNCategoriesTabViewController




-(void)loadView
{
    // Calculate height
    
    SYNCategoriesTabView* categoriesTabView = [[SYNCategoriesTabView alloc] initWithSize:1024.0];
    categoriesTabView.tapDelegate = self;
    
    self.view = categoriesTabView;
    
    // align to top
    self.view.frame = CGRectMake(0.0, 44.0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self loadCategories];
    
}


-(void)loadCategories
{
    SYNAppDelegate* appDelegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSEntityDescription* categoryEntity = [NSEntityDescription entityForName: @"Category"
                                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
    [categoriesFetchRequest setEntity:categoryEntity];
    
    NSPredicate* excludePredicate = [NSPredicate predicateWithFormat:@"priority >= 0"];
    [categoriesFetchRequest setPredicate:excludePredicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"priority" ascending:NO];
    [categoriesFetchRequest setSortDescriptors:@[sortDescriptor]];
    
    
    NSError* error;
    
    NSArray *matchingCategoryInstanceEntries = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                                   error: &error];
    
    if (matchingCategoryInstanceEntries.count <= 0)
    {
        
        [appDelegate.networkEngine updateCategoriesOnCompletion:^{
            
            [self loadCategories];
            
        } onError:^(NSError* error) {
            DebugLog(@"%@", [error debugDescription]);
        }];
        
        return;
    }
    
    [self.tabView createCategoriesTab:matchingCategoryInstanceEntries];

}

#pragma mark - TabView Delagate methods

-(void)handleMainTap:(UITapGestureRecognizer *)recogniser
{
    SYNAppDelegate* appDelegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    SYNCategoryItemView *tab = (SYNCategoryItemView*)recogniser.view;
    
    NSEntityDescription* categoryEntity = [NSEntityDescription entityForName: @"Category"
                                                      inManagedObjectContext:appDelegate.mainManagedObjectContext];
    
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
    
    NSMutableSet* filteredSet = [[NSMutableSet alloc] init];
    for (Subcategory* subcategory in categoryTapped.subcategories) {
        if ([subcategory.priority integerValue] < 0) {
            DebugLog(@"Priority less than 0, not adding");
            continue;
        }
        
        
            
        [filteredSet addObject:subcategory];
    }
    
    [self.tabView createSubcategoriesTab:filteredSet];
    
    [self.delegate handleMainTap:recogniser];
    
}

-(void)handleSecondaryTap:(UITapGestureRecognizer *)recogniser
{
    [self.delegate handleSecondaryTap:recogniser];
}



@end
