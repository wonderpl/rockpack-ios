//
//  SYNChannelCategoryTableViewController.m
//  rockpack
//
//  Created by Mats Trovik on 23/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNChannelCategoryTableViewController.h"
#import "SYNAppDelegate.h"
#import "SYNNetworkEngine.h"
#import "Category.h"
#import "Subcategory.h"
#import "SYNChannelCategoryTableCell.h"
#import "SYNChannelCategoryTableHeader.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNChannelCategoryTableViewController ()

@property (nonatomic, strong) NSArray* categoriesDatasource;
@property NSMutableArray* transientDatasource;
@property NSIndexPath* lastSelectedIndexpath;
@property NSMutableDictionary* headerRegister;

@end

@implementation SYNChannelCategoryTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _headerRegister = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerNib:[UINib nibWithNibName:@"SYNChannelCategoryTableCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SYNChannelCategoryTableCell"];
    
    SYNChannelCategoryTableHeader* topHeader = [[SYNChannelCategoryTableHeader alloc] init];
    topHeader.titleLabel.text = NSLocalizedString(@"ALL CATEGORIES",nil);
    topHeader.headerButton.tag = -1;
    topHeader.backgroundImage.image = [UIImage imageNamed:@"CategorySlide"];
    topHeader.frame = CGRectMake(0.0f, 0.0f, 245.0f, 45.0f);
    [topHeader.headerButton addTarget:self action:@selector(tappedAllCategories:) forControlEvents:UIControlEventTouchUpInside];
    [topHeader.headerButton addTarget:self action:@selector(pressedAllCategories:) forControlEvents:UIControlEventTouchDown];
    [topHeader.headerButton addTarget:self action:@selector(releasedAllCategories:) forControlEvents:UIControlEventTouchUpOutside];
    [topHeader.arrowImage removeFromSuperview];
    self.tableView.tableHeaderView = topHeader;
    
    
    [self loadCategories];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"CategorySlideBackground"]];
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
    
    NSEntityDescription* categoryEntity = [NSEntityDescription entityForName: @"Category"
                                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
    [categoriesFetchRequest setEntity:categoryEntity];
    
    NSPredicate* excludePredicate = [NSPredicate predicateWithFormat:@"priority >= 0"];
    [categoriesFetchRequest setPredicate:excludePredicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"priority" ascending:NO];
    [categoriesFetchRequest setSortDescriptors:@[sortDescriptor]];
    
    
    NSError* error;
    
    self.categoriesDatasource = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                                   error: &error];
    
    if (self.categoriesDatasource.count <= 0)
    {
        
        [appDelegate.networkEngine updateCategoriesOnCompletion:^{
            
            [self loadCategories];
            
        } onError:^(NSError* error) {
            DebugLog(@"%@", [error debugDescription]);
        }];
        
        return;
    }
    else
    {
        self.transientDatasource = [NSMutableArray arrayWithCapacity:[self.categoriesDatasource count] + 1];
        for(Category* category in self.categoriesDatasource)
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
    return [[[self.transientDatasource objectAtIndex:section] valueForKey:kSubCategoriesKey] count];
}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 44.0f;
//}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Subcategory* subCategory = [[[self.transientDatasource objectAtIndex:indexPath.section] valueForKey:kSubCategoriesKey] objectAtIndex:indexPath.row];
    SYNChannelCategoryTableCell *cell = (SYNChannelCategoryTableCell*) [tableView dequeueReusableCellWithIdentifier:@"SYNChannelCategoryTableCell"];
    cell.titleLabel.text = subCategory.name;
    return cell;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDictionary* dictionary = [self.transientDatasource objectAtIndex:section];
    SYNChannelCategoryTableHeader *header = [self.headerRegister objectForKey:@(section)];
    if(!header)
    {
        header = [[SYNChannelCategoryTableHeader alloc] init];
        [self.headerRegister setObject:header forKey:@(section)];
    }
    header.titleLabel.text = [dictionary objectForKey:kCategoryNameKey];
    if([dictionary valueForKey:kSubCategoriesKey])
    {
        header.backgroundImage.image = [UIImage imageNamed:@"CategorySlideSelected"];
        header.arrowImage.image = [UIImage imageNamed:@"IconCategorySlideChevronSelected"];
        header.titleLabel.textColor = [UIColor colorWithRed:32.0f/255.0f green:195.0f/255.0f blue:226.0f/255.0f alpha:1.0f];
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
    Subcategory* subCategory = [[[self.transientDatasource objectAtIndex:indexPath.section] objectForKey:kSubCategoriesKey] objectAtIndex:indexPath.row];
    //Callback to update content
    if([self.categoryTableControllerDelegate respondsToSelector:@selector(categoryTableController:didSelectSubCategoryWithId:categoryTitle:subCategoryTitle:)])
    {
        [self.categoryTableControllerDelegate categoryTableController:self didSelectSubCategoryWithId:subCategory.uniqueId categoryTitle:subCategory.category.name subCategoryTitle:subCategory.name];
    }}

#pragma mark - Table header tap callback

-(void)pressedHeader:(UIButton*)header;
{
    SYNChannelCategoryTableHeader* headerView = (SYNChannelCategoryTableHeader*)[self.tableView headerViewForSection:header.tag];
    headerView.backgroundImage.image = [UIImage imageNamed:@"CategorySlideHighlighted"];
}

-(void)releasedHeader:(UIButton*)header
{
    SYNChannelCategoryTableHeader* headerView = (SYNChannelCategoryTableHeader*)[self.tableView headerViewForSection:header.tag];
    NSMutableDictionary* sectionDictionary = [self.transientDatasource objectAtIndex:header.tag];
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
        [CATransaction begin];
    
        [CATransaction setCompletionBlock:^{
            NSIndexPath* topElement = [NSIndexPath indexPathForRow:0 inSection:header.tag];
            [self.tableView scrollToRowAtIndexPath:topElement atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }];
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
    }
    else
    {
        self.lastSelectedIndexpath = nil;
        if([self.categoryTableControllerDelegate respondsToSelector:@selector(categoryTableController:didSelectCategoryWithId:title:)])
        {
            [self.categoryTableControllerDelegate categoryTableController:self didSelectCategoryWithId:@"all" title:NSLocalizedString(@"ALL CATEGORIES", nil)];
        }

    }
    
    [self.tableView endUpdates];
    
    if(needToOpen)
    {
        [CATransaction commit];
    }
    
}

-(void)expandSection:(NSInteger)section
{
    NSMutableDictionary* sectionDictionary = [self.transientDatasource objectAtIndex:section];
    Category * category = [self.categoriesDatasource objectAtIndex:section];
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSArray* newSubCategories = [category.subcategories sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
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
        headerView.titleLabel.textColor = [UIColor colorWithRed:32.0f/255.0f green:195.0f/255.0f blue:226.0f/255.0f alpha:1.0f];
        headerView.titleLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.15f];
        headerView.backgroundImage.image = [UIImage imageNamed:@"CategorySlideSelected"];
        headerView.arrowImage.image = [UIImage imageNamed:@"IconCategorySlideChevronSelected"];
    } completion:nil];
        
    //Callback to update content
    if([self.categoryTableControllerDelegate respondsToSelector:@selector(categoryTableController:didSelectCategoryWithId:title:)])
    {
        [self.categoryTableControllerDelegate categoryTableController:self didSelectCategoryWithId:category.uniqueId title:category.name];
    }
    self.lastSelectedIndexpath = [NSIndexPath indexPathForRow:-1 inSection:section];
}

-(void)closeSection:(NSInteger)section
{
    NSMutableDictionary* sectionDictionary = [self.transientDatasource objectAtIndex:section];
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


@end