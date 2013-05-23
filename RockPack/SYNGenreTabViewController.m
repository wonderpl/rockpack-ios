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


@property (nonatomic, strong) NSString* homeButtomString;
@property (nonatomic, readonly) SYNGenreTabView* categoriesTabView;
@property (nonatomic, strong) NSArray* genresFetched;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;
@end


@implementation SYNGenreTabViewController

@synthesize appDelegate;


- (id) initWithHomeButton: (NSString*) homeButtomString
{
    if ((self = [super init]))
    {
        self.homeButtomString = homeButtomString;
        
        self.appDelegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    return self;
}


- (void) loadView
{
 
    //TODO: This should be reworked. The home label string should not be used to define behaviour.
    if([self.homeButtomString isEqualToString:@"other"] )
    {
        NSEntityDescription* categoryEntity = [NSEntityDescription entityForName: @"Genre"
                                                          inManagedObjectContext: appDelegate.mainManagedObjectContext];
        
        // Look for Other category and show it if present.
        NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
        [categoriesFetchRequest setEntity:categoryEntity];
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"priority == -1"];
        [categoriesFetchRequest setPredicate:predicate];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"priority" ascending:NO];
        [categoriesFetchRequest setSortDescriptors:@[sortDescriptor]];
        
        categoriesFetchRequest.includesSubentities = NO;
        
        
        NSError* error;
        
        NSArray* otherFetchArray = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                       error: &error];
        if([otherFetchArray count]==1)
        {
            self.otherGenre = [otherFetchArray objectAtIndex:0];
            self.homeButtomString = [self.otherGenre.name uppercaseString];
        }
    }

    
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
    
    
    
    [appDelegate.networkEngine updateCategoriesOnCompletion: ^{
        
        
        [self loadCategories];
        
        
    } onError:^(NSError* error) {
        DebugLog(@"%@", [error debugDescription]);
        
        
    }];
    
    [self loadCategories];
}


- (void) loadCategories
{
    NSError* error;
    
    
    
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
    
    if(self.genresFetched.count > 0)
        [self.tabView createCategoriesTab:self.genresFetched];
}





#pragma mark - TabView Delagate methods

- (void) handleMainTap: (UIView *) tab
{
    
    SYNGenreItemView* genreTab = (SYNGenreItemView*)tab;
    
    if (!tab || tab.tag == 0)
    {
        // home button pressed
        [self.delegate handleMainTap: tab];
        
        if(self.otherGenre && tab.tag ==0)
        {
            //The "OTHER" category has been chosen on the channel create or edit screen
            [self.delegate handleNewTabSelectionWithGenre: self.otherGenre];
        }
        else
        {
            [self.delegate handleNewTabSelectionWithGenre: nil];
        }
        
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
    
    SYNGenreItemView* subGenreTab = (SYNGenreItemView*)tab;
    
    SubGenre* subGenreSelected = (SubGenre*)subGenreTab.model;
    
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


#pragma mark - Getting Genre from Tab Bar 

-(Genre*)selectAndReturnGenreForIndexPath:(NSIndexPath*)indexPath andSubcategories:(BOOL)subcats
{
    if(!self.genresFetched || !indexPath || !(self.genresFetched.count > indexPath.section))
        return nil;
    
    
    Genre* genreToSelect = (Genre*)[self.genresFetched objectAtIndex:indexPath.section];
    
    if(subcats && genreToSelect.subgenres.count > indexPath.item)
    {
        genreToSelect = (SubGenre*)[genreToSelect.subgenres objectAtIndex:indexPath.item];
        [self handleMainGenreSelection:((SubGenre*)genreToSelect).genre];
    }
    
    
    [self.categoriesTabView highlightTabWithGenre:genreToSelect];
    
    
    return genreToSelect;
        
}

-(NSIndexPath*)findIndexPathForGenreId:(NSString*)genreId
{
    
    NSInteger section = -1;
    NSInteger item = -1;
    
    NSInteger _section = 0;
    NSInteger _item = 0;
    
    for (Genre* genre in self.genresFetched)
    {
        if([genre.uniqueId isEqualToString:genreId])
        {
            section = section; // the genre is a top level category
            item = 0;
            break;
        }
            
        
        for (SubGenre* subgenre in genre.subgenres)
        {
            if([subgenre.uniqueId isEqualToString:genreId])
            {
                
                section = [self.genresFetched indexOfObject:subgenre.genre]; // get the parent genre
                item = _item;
                break;
            }
                
            
            _item++;
        }
        
        _section++;
        _item = 0;
    }
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForItem:item inSection:section];
    return indexPath;
}

#pragma mark - Orientation Change

- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    [self.tabView refreshViewForOrientation: toInterfaceOrientation];
}

@end
