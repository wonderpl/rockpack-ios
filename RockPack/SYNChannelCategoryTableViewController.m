//
//  SYNChannelCategoryTableViewController.m
//  rockpack
//
//  Created by Mats Trovik on 23/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNChannelCategoryTableViewController.h"
#import "SYNAppDelegate.h"
#import "SYNNetworkEngine.h"
#import "Genre.h"
#import "SubGenre.h"
#import "SYNChannelCategoryTableCell.h"
#import "SYNChannelCategoryTableHeader.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNChannelCategoryTableViewController ()
{
    BOOL hasRetried;
}

@property (nonatomic, strong) NSArray* categoriesDatasource;
@property (nonatomic, strong) NSMutableArray* transientDatasource;
@property (nonatomic, strong) NSIndexPath* lastSelectedIndexpath;
@property (nonatomic, strong) NSMutableDictionary* headerRegister;

@end

@implementation SYNChannelCategoryTableViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonSetup];
    }
    return self;
}
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        [self commonSetup];
    }
    return self;
}

-(void)commonSetup
{
    _headerRegister = [NSMutableDictionary dictionary];
    _showAllCategoriesHeader = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SYNChannelCategoryTableCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SYNChannelCategoryTableCell"];
    
    if(self.showAllCategoriesHeader)
    {
        // Show all category
        SYNChannelCategoryTableHeader* topHeader = [[SYNChannelCategoryTableHeader alloc] init];
        topHeader.frame = CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 45.0f);
        [topHeader layoutSubviews];
        topHeader.titleLabel.text = NSLocalizedString(@"ALL CATEGORIES",nil);
        topHeader.headerButton.tag = -1;
        topHeader.backgroundImage.image = [UIImage imageNamed:@"CategorySlide"];
        [topHeader.headerButton addTarget:self action:@selector(tappedAllCategories:) forControlEvents:UIControlEventTouchUpInside];
        [topHeader.headerButton addTarget:self action:@selector(pressedAllCategories:) forControlEvents:UIControlEventTouchDown];
        [topHeader.headerButton addTarget:self action:@selector(releasedAllCategories:) forControlEvents:UIControlEventTouchUpOutside];
        [topHeader.arrowImage removeFromSuperview];
        self.tableView.tableHeaderView = topHeader;
    }
    else
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"priority == -1"];
        self.otherGenre = [self fetchGenreWithPredicate:predicate includeSubGenres:NO];
        if(self.otherGenre)
        {
            SYNChannelCategoryTableHeader* topHeader = [[SYNChannelCategoryTableHeader alloc] init];
            topHeader.frame = CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 45.0f);
            [topHeader layoutSubviews];
            topHeader.titleLabel.text = [self.otherGenre.name uppercaseString];
            topHeader.headerButton.tag = -1;
            topHeader.backgroundImage.image = [UIImage imageNamed:@"CategorySlide"];
            [topHeader.headerButton addTarget:self action:@selector(tappedOtherCategory:) forControlEvents:UIControlEventTouchUpInside];
            [topHeader.headerButton addTarget:self action:@selector(pressedOtherCategory:) forControlEvents:UIControlEventTouchDown];
            [topHeader.headerButton addTarget:self action:@selector(releasedOtherCategorys:) forControlEvents:UIControlEventTouchUpOutside];
            [topHeader.arrowImage removeFromSuperview];
            self.tableView.tableHeaderView = topHeader;
        }

    }
    
    if(self.closeButton)
    {
        [self.closeButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if(self.confirmButton)
    {
        [self.confirmButton addTarget:self action:@selector(confirmButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self loadCategories];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - load data
- (void) loadCategories
{
    SYNAppDelegate* appDelegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSEntityDescription* categoryEntity = [NSEntityDescription entityForName: @"Genre"
                                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
    [categoriesFetchRequest setEntity:categoryEntity];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"priority >= 0"];
    [categoriesFetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"priority" ascending:NO];
    [categoriesFetchRequest setSortDescriptors:@[sortDescriptor]];
    
    categoriesFetchRequest.includesSubentities = NO;
    
    
    NSError* error;
    
    self.categoriesDatasource = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                    error: &error];
    
    if (self.categoriesDatasource.count <= 0 && ! hasRetried)
    {
        
        [appDelegate.networkEngine updateCategoriesOnCompletion:^(NSDictionary* dictionary){
            
            BOOL registryResultOk = [appDelegate.mainRegistry registerCategoriesFromDictionary: dictionary];
            if (!registryResultOk) {
                DebugLog(@"*** Cannot Register Genre Objects! ***");
                return;
            }
            
            [self loadCategories];
            
        } onError:^(NSError* error) {
            DebugLog(@"%@", [error debugDescription]);
        }];
        hasRetried = YES;
        return;
    }
    else
    {
        self.transientDatasource = [NSMutableArray arrayWithCapacity:[self.categoriesDatasource count] + 1];
        for(Genre* category in self.categoriesDatasource)
        {
            NSMutableDictionary* categoryEntry = [NSMutableDictionary dictionaryWithObject:category.name forKey:kCategoryNameKey];
            [self.transientDatasource addObject:categoryEntry];
        }
        [self.tableView reloadData];
    }
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.transientDatasource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.transientDatasource[section] valueForKey:kSubCategoriesKey] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SubGenre* subCategory = [self.transientDatasource[indexPath.section] valueForKey:kSubCategoriesKey][indexPath.row];
    SYNChannelCategoryTableCell *cell = (SYNChannelCategoryTableCell*) [tableView dequeueReusableCellWithIdentifier:@"SYNChannelCategoryTableCell"];
    cell.titleLabel.text = subCategory.name;
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:self.lastSelectedIndexpath])
    {
        [cell setSelected:YES];
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDictionary* dictionary = self.transientDatasource[section];
    SYNChannelCategoryTableHeader *header = [self.headerRegister objectForKey:@(section)];
    if(!header)
    {
        header = [[SYNChannelCategoryTableHeader alloc] init];
        [self.headerRegister setObject:header forKey:@(section)];
    }
    [header layoutSubviews];
    header.titleLabel.text = [dictionary objectForKey:kCategoryNameKey];
    if([dictionary valueForKey:kSubCategoriesKey])
    {
        header.backgroundImage.image = [UIImage imageNamed:@"CategorySlideSelected"];
        header.arrowImage.image = [UIImage imageNamed:@"IconCategorySlideChevronSelected"];
        header.titleLabel.textColor = [UIColor whiteColor];
        header.titleLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.15f];
    }
    else
    {
        header.backgroundImage.image = [UIImage imageNamed:@"CategorySlide"];
        header.arrowImage.image = [UIImage imageNamed:@"IconCategorySlideChevron"];
        header.titleLabel.textColor = [UIColor colorWithRed:106.0f/255.0f green:114.0f/255.0f blue:122.0f/255.0f alpha:1.0f];
        header.titleLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.75f];
    }
    [header.headerButton addTarget:self action:@selector(tappedHeader:) forControlEvents:UIControlEventTouchUpInside];
    [header.headerButton addTarget:self action:@selector(pressedHeader:) forControlEvents:UIControlEventTouchDown];
    [header.headerButton addTarget:self action:@selector(releasedHeader:) forControlEvents:UIControlEventTouchUpOutside];
    header.headerButton.tag = section;
    
    return header;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SubGenre* subCategory = [[self.transientDatasource objectAtIndex:indexPath.section] objectForKey:kSubCategoriesKey][indexPath.row];
    //Callback to update content
    if(!self.confirmButton)
    {
        if([self.categoryTableControllerDelegate respondsToSelector:@selector(categoryTableController:didSelectSubCategory:)])
        {
            [self.categoryTableControllerDelegate categoryTableController:self
                                                     didSelectSubCategory:subCategory];
        }
    }
    self.lastSelectedIndexpath = indexPath;
}


#pragma mark - Table header tap callback

-(void)pressedHeader:(UIButton*)header;
{
    SYNChannelCategoryTableHeader* headerView = [self.headerRegister objectForKey:@(header.tag)];
    headerView.backgroundImage.image = [UIImage imageNamed:@"CategorySlideHighlighted"];
}

-(void)releasedHeader:(UIButton*)header
{
    SYNChannelCategoryTableHeader* headerView = [self.headerRegister objectForKey:@(header.tag)];
    NSMutableDictionary* sectionDictionary = self.transientDatasource[header.tag];
    NSArray* subCategories = [sectionDictionary objectForKey:kSubCategoriesKey];
    if(subCategories)
    {
        headerView.backgroundImage.image = [UIImage imageNamed:@"CategorySlideSelected"];
        headerView.arrowImage.image = [UIImage imageNamed:@"IconCategorySlideChevronSelected"];
    }
    else
    {
        headerView.backgroundImage.image = [UIImage imageNamed:@"CategorySlide"];
        headerView.arrowImage.image = [UIImage imageNamed:@"IconCategorySlideChevron"];
    }
    
}

-(void)tappedHeader:(UIButton*)header
{
    BOOL needToOpen = !self.lastSelectedIndexpath || self.lastSelectedIndexpath.section != header.tag;
    if(needToOpen)
    {
        Genre* category = self.categoriesDatasource[header.tag];
        if([category.subgenres count]<1)
        {
            needToOpen = NO;
        }
        else
        {
            [CATransaction setCompletionBlock:^{
                NSIndexPath* topElement = [NSIndexPath indexPathForRow:0 inSection:header.tag];
                [self.tableView scrollToRowAtIndexPath:topElement atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }];

        }
    }
    else if(self.confirmButton)
    {
        [CATransaction begin];
        if(self.lastSelectedIndexpath.section == header.tag)
        {
            [CATransaction setCompletionBlock:^{
                [self.tableView setContentOffset:CGPointZero animated:YES];
            }];
        }
    }
    
    [self.tableView beginUpdates];
    //close previously open section
    if(self.lastSelectedIndexpath)
    {
        //close previously open section
        [self closeSection:self.lastSelectedIndexpath.section];
    }
    
    if(needToOpen)
    {
        //expand new section
        [self expandSection:header.tag];
        [self deselectOtherCategory];
    }
    else
    {
        self.lastSelectedIndexpath = nil;
        if([self.categoryTableControllerDelegate respondsToSelector:@selector(categoryTableController:didSelectCategory:)])
        {
            [self.categoryTableControllerDelegate categoryTableController:self didSelectCategory:nil];
        }
        [self tappedOtherCategory:nil];
    }
    
    [self.tableView endUpdates];
    
    if(needToOpen || self.confirmButton)
    {
        [CATransaction commit];
    }
}

-(void)expandSection:(NSInteger)section
{
    NSMutableDictionary* sectionDictionary = self.transientDatasource[section];
    
    Genre * category = self.categoriesDatasource[section];
    NSArray* newSubCategories = [category.subgenres array];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"priority > 0"];
    newSubCategories = [newSubCategories filteredArrayUsingPredicate:predicate];
    NSSortDescriptor* idSortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"priority"
                                                                     ascending: NO];
    newSubCategories = [newSubCategories sortedArrayUsingDescriptors:@[idSortDescriptor]];
    [sectionDictionary setObject:newSubCategories forKey:kSubCategoriesKey];
    [self.transientDatasource replaceObjectAtIndex:section withObject:sectionDictionary];
    
    NSMutableArray* indexPaths = [NSMutableArray arrayWithCapacity:[newSubCategories count]];
    for(int i=0; i< [newSubCategories count]; i++)
    {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    
    SYNChannelCategoryTableHeader* headerView = [self.headerRegister objectForKey:@(section)];
    [UIView transitionWithView:headerView duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        headerView.titleLabel.textColor = [UIColor whiteColor];
        headerView.titleLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.15f];
        headerView.backgroundImage.image = [UIImage imageNamed:@"CategorySlideSelected"];
        headerView.arrowImage.image = [UIImage imageNamed:@"IconCategorySlideChevronSelected"];
    } completion:nil];
    
    //Callback to update content
    if(!self.confirmButton)
    {

        if([self.categoryTableControllerDelegate respondsToSelector:@selector(categoryTableController:didSelectCategory:)])
        {
            [self.categoryTableControllerDelegate categoryTableController:self didSelectCategory:category];
        }
    }
    self.lastSelectedIndexpath = [NSIndexPath indexPathForRow:-1 inSection:section];
}

-(void)closeSection:(NSInteger)section
{
    NSMutableDictionary* sectionDictionary = self.transientDatasource[section];
    NSArray* subCategories = [sectionDictionary objectForKey:kSubCategoriesKey];
    [sectionDictionary removeObjectForKey:kSubCategoriesKey];
    [self.transientDatasource replaceObjectAtIndex:section withObject:sectionDictionary];
    NSMutableArray* indexPaths = [NSMutableArray arrayWithCapacity:[subCategories count]];
    for(int i=0; i< [subCategories count]; i++)
    {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    SYNChannelCategoryTableHeader* headerView = [self.headerRegister objectForKey:@(section)];
    [UIView transitionWithView:headerView duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        headerView.titleLabel.textColor = [UIColor colorWithRed:106.0f/255.0f green:114.0f/255.0f blue:122.0f/255.0f alpha:1.0f];
        headerView.titleLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.75f];
        headerView.arrowImage.image = [UIImage imageNamed:@"IconCategorySlideChevron"];
        headerView.backgroundImage.image=[UIImage imageNamed:@"CategorySlide"];
    } completion:nil];
    
}

#pragma mark - allCategories header

-(void)pressedAllCategories:(UIButton*)header;
{
    SYNChannelCategoryTableHeader* headerView = (SYNChannelCategoryTableHeader*)self.tableView.tableHeaderView;
    headerView.backgroundImage.image = [UIImage imageNamed:@"CategorySlideHighlighted"];
}

-(void)releasedAllCategories:(UIButton*)header
{
    SYNChannelCategoryTableHeader* headerView = (SYNChannelCategoryTableHeader*)self.tableView.tableHeaderView;
    headerView.backgroundImage.image = [UIImage imageNamed:@"CategorySlide"];
}

-(void)tappedAllCategories:(UIButton*)header
{
    SYNChannelCategoryTableHeader* headerView = (SYNChannelCategoryTableHeader*)self.tableView.tableHeaderView;
    headerView.backgroundImage.image = [UIImage imageNamed:@"CategorySlide"];
    if(self.lastSelectedIndexpath)
    {
        [self closeSection:self.lastSelectedIndexpath.section];
    }
    if([self.categoryTableControllerDelegate respondsToSelector:@selector(categoryTableControllerDeselectedAll:)])
    {
        [self.categoryTableControllerDelegate categoryTableControllerDeselectedAll:self];
    }
    self.lastSelectedIndexpath = nil;
    
}

#pragma mark - OtherCategory tapped

-(void)pressedOtherCategory:(UIButton*)header;
{
    SYNChannelCategoryTableHeader* headerView = (SYNChannelCategoryTableHeader*)self.tableView.tableHeaderView;
    headerView.backgroundImage.image = [UIImage imageNamed:@"CategorySlideHighlighted"];
}

-(void)releasedOtherCategory:(UIButton*)header
{
    SYNChannelCategoryTableHeader* headerView = (SYNChannelCategoryTableHeader*)self.tableView.tableHeaderView;
    headerView.backgroundImage.image = [UIImage imageNamed:@"CategorySlide"];
}

-(void)tappedOtherCategory:(UIButton*)header
{
    SYNChannelCategoryTableHeader* headerView = (SYNChannelCategoryTableHeader*)self.tableView.tableHeaderView;
    headerView.titleLabel.textColor = [UIColor whiteColor];
    headerView.titleLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.15f];
    headerView.backgroundImage.image = [UIImage imageNamed:@"CategorySlideSelected"];
    if(self.lastSelectedIndexpath)
    {
        [self closeSection:self.lastSelectedIndexpath.section];
    }
    self.lastSelectedIndexpath = nil;
    
}

-(void)deselectOtherCategory;
{
    SYNChannelCategoryTableHeader* headerView = (SYNChannelCategoryTableHeader*)self.tableView.tableHeaderView;
    headerView.titleLabel.textColor = [UIColor colorWithRed:106.0f/255.0f green:114.0f/255.0f blue:122.0f/255.0f alpha:1.0f];
    headerView.titleLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.75f];
    headerView.backgroundImage.image=[UIImage imageNamed:@"CategorySlide"];
}

#pragma mark - set selected Genre
-(void)setSelectedCategoryForId:(NSString*)selectedCategoryId
{
    if(!selectedCategoryId)
    {
        //Set Other selected
        SYNChannelCategoryTableHeader* headerView = (SYNChannelCategoryTableHeader*)self.tableView.tableHeaderView;
        headerView.titleLabel.textColor = [UIColor whiteColor];
        headerView.titleLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.15f];
        headerView.backgroundImage.image = [UIImage imageNamed:@"CategorySlideSelected"];
        return;
    }
    //We'll pre-select the right genre by simulating the equivalent user input
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"uniqueId == %@",selectedCategoryId];
    Genre* genreToSelect = [self fetchGenreWithPredicate:predicate includeSubGenres:YES];
    if(genreToSelect)
    {
        //We've found the selected genre
        if([genreToSelect isKindOfClass:[SubGenre class]])
        {
            //It's a sub genre. First open it's parent category
            SubGenre* subGenre = (SubGenre*) genreToSelect;
            
            //Is it the "other/other" category?
            if([subGenre.genre isEqual:self.otherGenre])
            {
                SYNChannelCategoryTableHeader* headerView = (SYNChannelCategoryTableHeader*)self.tableView.tableHeaderView;
                headerView.titleLabel.textColor = [UIColor whiteColor];
                headerView.titleLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.15f];
                headerView.backgroundImage.image = [UIImage imageNamed:@"CategorySlideSelected"];

                return;
            }
            
            Genre* superGenre = subGenre.genre;
            int index = [self.categoriesDatasource indexOfObject:superGenre];
            if(index != NSNotFound)
            {
                SYNChannelCategoryTableHeader* header = (SYNChannelCategoryTableHeader*)[self tableView:nil viewForHeaderInSection:index];
                [self tappedHeader:header.headerButton];
                //Now try to get the index of the subGenre
                NSMutableDictionary* sectionDictionary = self.transientDatasource[index];
                NSArray* subGenres = [sectionDictionary objectForKey:kSubCategoriesKey];
                if(subGenres)
                {
                    int subCategoryIndex = [subGenres indexOfObject:subGenre];
                    if (subCategoryIndex != NSNotFound)
                    {
                        //Simulate the user having tapped it
                        [self tableView:nil didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:subCategoryIndex inSection:index]];
                    }
                }
            }
        }
        else
        {
            //It's a genre, expand its section
            int index = [self.categoriesDatasource indexOfObject:genreToSelect];
            if(index != NSNotFound)
            {
                SYNChannelCategoryTableHeader* header = (SYNChannelCategoryTableHeader*)[self tableView:nil viewForHeaderInSection:index];
                [self tappedHeader:header.headerButton];
            }
        }
    }
}

#pragma mark - UI button interactions (only present in channel create/edit)

- (IBAction)confirmButtonTapped:(id)sender {
    if([self.categoryTableControllerDelegate respondsToSelector:@selector(categoryTableController:didSelectSubCategory:)])
    {
        if(self.lastSelectedIndexpath)
        {
            if(self.lastSelectedIndexpath.row >= 0)
            {
                if([self.categoryTableControllerDelegate respondsToSelector:@selector(categoryTableController:didSelectSubCategory:)])
                {
                    SubGenre* subCategory = [self.transientDatasource[self.lastSelectedIndexpath.section] objectForKey:kSubCategoriesKey][self.lastSelectedIndexpath.row];
                    [self.categoryTableControllerDelegate categoryTableController:self
                                                             didSelectSubCategory:subCategory];
                }
            }
            else
            {
                if([self.categoryTableControllerDelegate respondsToSelector:@selector(categoryTableController:didSelectCategory:)])
                {
                    Genre* category = self.categoriesDatasource[self.lastSelectedIndexpath.section];
                    [self.categoryTableControllerDelegate categoryTableController:self didSelectCategory:category];
                }
            }
        }
        else
        {
            //no selected indexpath.
            if([self.categoryTableControllerDelegate respondsToSelector:@selector(categoryTableController:didSelectCategory:)])
            {
                [self.categoryTableControllerDelegate categoryTableController:self didSelectCategory:self.otherGenre];
            }
        }
        
    }
    
}

- (IBAction)closeButtonTapped:(id)sender {
    if([self.categoryTableControllerDelegate respondsToSelector:@selector(categoryTableControllerDeselectedAll:)])
    {
        [self.categoryTableControllerDelegate categoryTableControllerDeselectedAll:self];
    }
    
}

#pragma mark - fetchHelper
-(Genre*)fetchGenreWithPredicate:(NSPredicate*)predicate includeSubGenres:(BOOL)includeSubGenres
{
    SYNAppDelegate* appDelegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSEntityDescription* categoryEntity = [NSEntityDescription entityForName: @"Genre"
                                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    // Look for Other category and show it if present.
    NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
    [categoriesFetchRequest setEntity:categoryEntity];
    
    [categoriesFetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"priority" ascending:NO];
    [categoriesFetchRequest setSortDescriptors:@[sortDescriptor]];
    
    categoriesFetchRequest.includesSubentities = includeSubGenres;
    
    
    NSError* error;
    
    NSArray* otherFetchArray = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                   error: &error];
    
    if([otherFetchArray count]==1)
    {
        return otherFetchArray[0];
    }

    return nil;
}

@end
