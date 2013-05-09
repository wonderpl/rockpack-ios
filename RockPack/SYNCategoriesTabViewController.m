//
//  SYNCategoriesBarViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 19/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "Genre.h"
#import "GAI.h"
#import "SYNAppDelegate.h"
#import "SYNCategoriesTabViewController.h"
#import "SYNCategoryItemView.h"
#import "SYNNetworkEngine.h"
#import "SubGenre.h"
#import <CoreData/CoreData.h>
#import "SYNDeviceManager.h"

@interface SYNCategoriesTabViewController ()

@property (nonatomic, strong) NSString *currentTopLevelCategoryName;
@property (nonatomic, assign) BOOL useHomeButton;
@end


@implementation SYNCategoriesTabViewController

- (id) initWithHomeButton: (BOOL) useHomeButton
{
    if ((self = [super init]))
    {
        self.useHomeButton = useHomeButton;
    }
    
    return self;
}


- (void) loadView
{
    SYNCategoriesTabView* categoriesTabView = [[SYNCategoriesTabView alloc] initWithSize: [[SYNDeviceManager sharedInstance] currentScreenWidth]
                                                                           andHomeButton: self.useHomeButton];
    categoriesTabView.tapDelegate = self;
    
    self.view = categoriesTabView;
    
    // align to top
    self.view.frame = CGRectMake(0.0, kStandardCollectionViewOffsetY, self.view.frame.size.width, self.view.frame.size.height);
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self loadCategories];
}


- (void) loadCategories
{
    NSError* error;
    
    SYNAppDelegate* appDelegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSEntityDescription* categoryEntity = [NSEntityDescription entityForName: @"Genre"
                                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
    [categoriesFetchRequest setEntity: categoryEntity];
    
    NSPredicate* excludePredicate = [NSPredicate predicateWithFormat: @"priority >= 0"];
    [categoriesFetchRequest setPredicate: excludePredicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"priority"
                                                                   ascending: NO];
    
    [categoriesFetchRequest setSortDescriptors: @[sortDescriptor]];

    NSArray *matchingCategoryInstanceEntries = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                                   error: &error];
    
    if (matchingCategoryInstanceEntries.count <= 0)
    {
        
        [appDelegate.networkEngine updateCategoriesOnCompletion: ^{
            [self loadCategories];
        } onError:^(NSError* error) {
            DebugLog(@"%@", [error debugDescription]);
        }];
        
        return;
    }
    
    [self.tabView createCategoriesTab:matchingCategoryInstanceEntries];
}


#pragma mark - Orientation Change

- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    [self.tabView refreshViewForOrientation: toInterfaceOrientation];
}


#pragma mark - TabView Delagate methods

- (void) handleMainTap: (UITapGestureRecognizer *) recogniser
{
    SYNCategoryItemView *tab = (SYNCategoryItemView*)recogniser.view;
    
    if (recogniser == nil || tab.tag == 0)
    {
        // home button pressed
        [self.delegate handleMainTap: recogniser];
        
        [self.delegate handleNewTabSelectionWithId: @"all"];
        [self.delegate handleNewTabSelectionWithName: @"OTHER"];
        
        if (tab.tag == 0)
        {
            [(SYNCategoriesTabView *)self.view hideSecondaryTabs];
        }
        
        return;   
    }
    
    SYNAppDelegate* appDelegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];

    NSEntityDescription* categoryEntity = [NSEntityDescription entityForName: @"Genre"
                                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
    [categoriesFetchRequest setEntity: categoryEntity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %d", tab.tag];
    [categoriesFetchRequest setPredicate: predicate];
    
    NSError* error = nil;
    
    NSArray *matchingCategoryInstanceEntries = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                                   error: &error];
    
    if (matchingCategoryInstanceEntries.count == 0)
    {
        DebugLog(@"WARNING: Found NO Category for Tab %d", tab.tag);
        return;
    }
    
    if (matchingCategoryInstanceEntries.count > 1)
    {
        DebugLog(@"WARNING: Found multiple (%i) Categories for Tab %d", matchingCategoryInstanceEntries.count, tab.tag);
    }
    
    Genre* categoryTapped = (Genre*)matchingCategoryInstanceEntries[0];
    
    NSMutableSet* filteredSet = [[NSMutableSet alloc] init];
    
    for (SubGenre* subgenre in categoryTapped.subgenres)
    {
        if ([subgenre.priority integerValue] < 0)
        {
            continue;
        }
        
        [filteredSet addObject: subgenre];
    }
    
    if (self.delegate && [self.delegate showSubcategories])
        [self.tabView createSubcategoriesTab: filteredSet];
    
    [self.delegate handleMainTap: recogniser];
    [self.delegate handleNewTabSelectionWithId: categoryTapped.uniqueId];
    [self.delegate handleNewTabSelectionWithName: categoryTapped.name];
    self.currentTopLevelCategoryName = categoryTapped.name;
    
    // Log Category in Google Analytics
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker sendEventWithCategory: @"uiAction"
                        withAction: @"categoryItemClick"
                         withLabel: categoryTapped.name
                         withValue: nil];
    
    [tracker setCustom: kGADimensionCategory
             dimension: categoryTapped.name];
}


- (void) handleSecondaryTap: (UITapGestureRecognizer *) recogniser
{
    
    SYNAppDelegate* appDelegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    SYNCategoryItemView *tab = (SYNCategoryItemView*)recogniser.view;
    
    NSEntityDescription* categoryEntity = [NSEntityDescription entityForName: @"SubGenre"
                                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
    [categoriesFetchRequest setEntity: categoryEntity];
    
    //DebugLog(@"Tag clicked : %d", tab.tag);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %d", tab.tag];
    [categoriesFetchRequest setPredicate: predicate];
    
    NSError* error = nil;
    
    NSArray *matchingCategoryInstanceEntries = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                                   error: &error];
    
    if (matchingCategoryInstanceEntries.count == 0)
    {
        DebugLog(@"WARNING: Found NO Category for Tab %d", tab.tag);
        return;
    }
    
    if (matchingCategoryInstanceEntries.count > 1)
    {
        DebugLog(@"WARNING: Found multiple (%i) Categories for Tab %d", matchingCategoryInstanceEntries.count, tab.tag);
        
    }
    
    SubGenre* subcategoryTapped = (SubGenre*)matchingCategoryInstanceEntries[0];
    
    [self.delegate handleSecondaryTap: recogniser];
    [self.delegate handleNewTabSelectionWithId: subcategoryTapped.uniqueId];
    [self.delegate handleNewTabSelectionWithName: [NSString stringWithFormat: @"%@ / %@", self.currentTopLevelCategoryName, subcategoryTapped.name]];
    
    // Log subcategory in Google Analytics
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    // TODO: Not sure if we need both of these
    [tracker sendEventWithCategory: @"uiAction"
                        withAction: @"categoryItemClick"
                         withLabel: subcategoryTapped.name
                         withValue: nil];
    
    [tracker setCustom: kGADimensionCategory
             dimension: subcategoryTapped.name];
}


@end
