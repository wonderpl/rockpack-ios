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
#import "SYNGenreTabViewController.h"
#import "SYNGenreItemView.h"
#import "SYNNetworkEngine.h"
#import "SubGenre.h"
#import <CoreData/CoreData.h>
#import "SYNDeviceManager.h"

@interface SYNGenreTabViewController ()


@property (nonatomic, assign) NSString* homeButtomString;
@property (nonatomic, readonly) SYNGenreTabView* categoriesTabView;
@property (nonatomic, strong) NSArray* genresFetched;
@end


@implementation SYNGenreTabViewController


- (id) initWithHomeButton: (NSString*) homeButtomString
{
    if ((self = [super init]))
    {
        self.homeButtomString = homeButtomString;
    }
    
    return self;
}


- (void) loadView
{
    SYNGenreTabView* categoriesTabView = [[SYNGenreTabView alloc] initWithSize: [[SYNDeviceManager sharedInstance] currentScreenWidth]
                                                                           andHomeButton: self.homeButtomString];
    categoriesTabView.tapDelegate = self;
    
    self.view = categoriesTabView;
    
    // align to top
    self.view.frame = CGRectMake(0.0, kStandardCollectionViewOffsetY, self.view.frame.size.width, self.view.frame.size.height);
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
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
    
    categoriesFetchRequest.includesSubentities = NO;

    self.genresFetched = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                                   error: &error];
    
    if (self.genresFetched.count == 0)
    {
        
        [appDelegate.networkEngine updateCategoriesOnCompletion: ^{
            [self loadCategories];
        } onError:^(NSError* error) {
            DebugLog(@"%@", [error debugDescription]);
        }];
        
        return;
    }
    
    
    
    
    [self.tabView createCategoriesTab:self.genresFetched];
}


#pragma mark - Orientation Change

- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    [self.tabView refreshViewForOrientation: toInterfaceOrientation];
}


#pragma mark - TabView Delagate methods

- (void) handleMainTap: (UIView *) tab
{
    
    SYNGenreItemView* genreTab = (SYNGenreItemView*)tab;
    
    if (!tab || tab.tag == 0)
    {
        // home button pressed
        [self.delegate handleMainTap: tab];
        
        [self.delegate handleNewTabSelectionWithId: @"all"];
        [self.delegate handleNewTabSelectionWithGenre: nil];
        
        if (tab.tag == 0)
        {
            [self.categoriesTabView hideSecondaryTabs];
        }
        
        return;   
    }
    
    Genre* genreSelected = (Genre*)genreTab.model;

    [self handleMainGenreSelection:genreSelected];

    [self.delegate handleMainTap: tab];
    
    
    [self.delegate handleNewTabSelectionWithGenre: genreSelected];
    
    // == Log Category in Google Analytics == //
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker sendEventWithCategory: @"uiAction"
                        withAction: @"categoryItemClick"
                         withLabel: genreSelected.name
                         withValue: nil];
    
    [tracker setCustom: kGADimensionCategory
             dimension: genreSelected.name];
}

-(void)handleMainGenreSelection:(Genre*)genreSelected
{
   
    
    NSArray* newSubCategories = [genreSelected.subgenres array];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"priority > 0"];
    newSubCategories = [newSubCategories filteredArrayUsingPredicate:predicate];
    NSSortDescriptor* idSortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"priority"
                                                                     ascending: NO];
    newSubCategories = [newSubCategories sortedArrayUsingDescriptors:@[idSortDescriptor]];
    
    // Finally Show SubGenres if needed
    
    if (self.delegate && [self.delegate showSubGenres])
    {
        [self.tabView createSubcategoriesTab:newSubCategories];
    }
    
}


- (void) handleSecondaryTap: (UIView *) tab
{
    
    
    
    SYNAppDelegate* appDelegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
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
    
    SubGenre* subGenreSelected = (SubGenre*)matchingCategoryInstanceEntries[0];
    
    [self.delegate handleSecondaryTap: tab];
    
    [self.delegate handleNewTabSelectionWithGenre: subGenreSelected];
    
    
    
    // == Log subcategory in Google Analytics == //
    
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    // TODO: Not sure if we need both of these
    [tracker sendEventWithCategory: @"uiAction"
                        withAction: @"categoryItemClick"
                         withLabel: subGenreSelected.name
                         withValue: nil];
    
    [tracker setCustom: kGADimensionCategory
             dimension: subGenreSelected.name];
}

-(SYNGenreTabView*)categoriesTabView
{
    return (SYNGenreTabView *)self.view;
}

-(void) deselectAll
{
    [self.categoriesTabView deselectAll];
}

-(Genre*)selectAndReturnGenreForId:(NSInteger)identifier andSubcategories:(BOOL)subcats
{
    if(!self.genresFetched || (self.genresFetched.count - 1) < identifier)
        return nil;
    
    
    Genre* genreToSelect = (Genre*)[self.genresFetched objectAtIndex:identifier];
    
    if(subcats)
    {
        genreToSelect = (SubGenre*)[genreToSelect.subgenres firstObject];
        [self handleMainGenreSelection:((SubGenre*)genreToSelect).genre];
    }
    
    
    [self.categoriesTabView highlightTabWithGenre:genreToSelect];
    
    
    
    
    return genreToSelect;
        
}

@end
