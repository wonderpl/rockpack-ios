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

@interface SYNChannelCategoryTableViewController ()

@property (nonatomic, strong) NSArray* categoriesDatasource;
@property NSMutableArray* transientDatasource;
@property NSIndexPath* lastSelectedIndexpath;

@end

@implementation SYNChannelCategoryTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerNib:[UINib nibWithNibName:@"SYNChannelCategoryTableCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SYNChannelCategoryTableCell"];
    [self.tableView registerClass:[SYNChannelCategoryTableHeader class] forHeaderFooterViewReuseIdentifier:@"SYNChannelCategoryTableHeader"];
    
    [self loadCategories];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"SubCategorySlide"]];
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
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
    SYNChannelCategoryTableHeader *header = (SYNChannelCategoryTableHeader*) [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"SYNChannelCategoryTableHeader"];
    header.titleLabel.text = [dictionary objectForKey:kCategoryNameKey];
    if([dictionary valueForKey:kSubCategoriesKey])
    {
        header.backgroundImage.image = [UIImage imageNamed:@"CategorySlideSelected"];
        header.titleLabel.textColor = [UIColor colorWithRed:32.0f/255.0f green:195.0f/255.0f blue:226.0f/255.0f alpha:1.0f];
        header.titleLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.15f];
    }
    else
    {
        header.backgroundImage.image = [UIImage imageNamed:@"CategorySlide"];
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
    if([self.categoryTableControllerDelegate respondsToSelector:@selector(categoryTableController:didSelectSubCategoryWithId:)])
    {
        [self.categoryTableControllerDelegate categoryTableController:self didSelectSubCategoryWithId:subCategory.uniqueId];
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
    }
    else
    {
        headerView.backgroundImage.image = [UIImage imageNamed:@"CategorySlide"];
    }

}

-(void)tappedHeader:(UIButton*)header
{
    NSMutableDictionary* sectionDictionary = [self.transientDatasource objectAtIndex:header.tag];
    NSArray* subCategories = [sectionDictionary objectForKey:kSubCategoriesKey];
    if(subCategories)
    {
        //already expanded, close section
        [self.tableView beginUpdates];
        [sectionDictionary removeObjectForKey:kSubCategoriesKey];
        [self.transientDatasource replaceObjectAtIndex:header.tag withObject:sectionDictionary];
        NSMutableArray* indexPaths = [NSMutableArray arrayWithCapacity:[subCategories count]];
        for(int i=0; i< [subCategories count]; i++)
        {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:header.tag]];
        }
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
        SYNChannelCategoryTableHeader* headerView = (SYNChannelCategoryTableHeader*)[self.tableView headerViewForSection:header.tag];
        [UIView transitionWithView:headerView.titleLabel duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            headerView.titleLabel.textColor = [UIColor colorWithRed:106.0f/255.0f green:114.0f/255.0f blue:122.0f/255.0f alpha:1.0f];
            headerView.titleLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.75f];
        } completion:nil];
        
        [UIView transitionWithView:headerView.backgroundImage duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            headerView.backgroundImage.image = [UIImage imageNamed:@"CategorySlide"];
        } completion:nil];
               
        
    }
    else
    {
        //expand section
        
        Category * category = [self.categoriesDatasource objectAtIndex:header.tag];
        NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        NSArray* newSubCategories = [category.subcategories sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        [self.tableView beginUpdates];
        [sectionDictionary setObject:newSubCategories forKey:kSubCategoriesKey];
        [self.transientDatasource replaceObjectAtIndex:header.tag withObject:sectionDictionary];
        NSMutableArray* indexPaths = [NSMutableArray arrayWithCapacity:[newSubCategories count]];
        for(int i=0; i< [newSubCategories count]; i++)
        {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:header.tag]];
        }
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
        
        SYNChannelCategoryTableHeader* headerView = (SYNChannelCategoryTableHeader*)[self.tableView headerViewForSection:header.tag];
        [UIView transitionWithView:headerView.titleLabel duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            headerView.titleLabel.textColor = [UIColor colorWithRed:32.0f/255.0f green:195.0f/255.0f blue:226.0f/255.0f alpha:1.0f];
            headerView.titleLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.15f];
        } completion:nil];
        
        [UIView transitionWithView:headerView.backgroundImage duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            headerView.backgroundImage.image = [UIImage imageNamed:@"CategorySlideSelected"];
        } completion:nil];
        
        //Callback to update content
        if([self.categoryTableControllerDelegate respondsToSelector:@selector(categoryTableController:didSelectCategoryWithId:)])
        {
            [self.categoryTableControllerDelegate categoryTableController:self didSelectCategoryWithId:category.uniqueId];
        }
        
        self.lastSelectedIndexpath = [NSIndexPath indexPathForRow:-1 inSection:header.tag];
               
    }
}


@end
