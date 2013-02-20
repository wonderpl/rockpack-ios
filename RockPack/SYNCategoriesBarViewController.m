//
//  SYNCategoriesBarViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 19/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCategoriesBarViewController.h"
#import "SYNCategoriesTabView.h"
#import <CoreData/CoreData.h>
#import "SYNAppDelegate.h"
#import "SYNNetworkEngine.h"

@interface SYNCategoriesBarViewController ()

@end

@implementation SYNCategoriesBarViewController

-(id)initWithSize:(CGFloat)width
{
    if (self = [super init]) {
        tabsWidth = width;
    }
    return self;
}

-(void)loadView
{
    // Calculate height
    
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 44.0, tabsWidth, 50.0)];
    
    
}


-(void)loadCategoriesView
{
    SYNAppDelegate* appDelegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSEntityDescription* categoryEntity = [NSEntityDescription entityForName: @"Category"
                                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
    [categoriesFetchRequest setEntity:categoryEntity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"uniqueId" ascending:YES];
    [categoriesFetchRequest setSortDescriptors:@[sortDescriptor]];
    
    
    NSError* error;
    
    NSArray *matchingCategoryInstanceEntries = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                                   error: &error];
    
    if (matchingCategoryInstanceEntries.count <= 0)
    {
        
        [appDelegate.networkEngine updateCategoriesOnCompletion:^{
            
            [self loadView];
            
        } onError:^(NSError* error) {
            DebugLog(@"%@", [error debugDescription]);
        }];
        
        return;
    }
    
    //SYNCategoriesTabView* categoriesView = [[SYNCategoriesTabView alloc] initWithCategories:matchingCategoryInstanceEntries andSize:self.view.frame.size];
    
    //[self.view addSubview:categoriesView];
}

@end
