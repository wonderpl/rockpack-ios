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

    [self loadCategories];
    self.tableView.backgroundColor = [UIColor greenColor];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    Subcategory* subCategory = [[[self.transientDatasource objectAtIndex:indexPath.section] valueForKey:kSubCategoriesKey] objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = subCategory.name;
    return cell;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIButton* header = [[UIButton alloc] initWithFrame:CGRectMake(0.0f,0.0f, 320.0f,60.0f)];
    NSDictionary* dictionary = [self.transientDatasource objectAtIndex:section];
    header.titleLabel.text = [dictionary valueForKey:kCategoryNameKey];
    if([[dictionary valueForKey:kSubCategoriesKey] count])
    {
        header.backgroundColor = [UIColor redColor];
    }
    else
    {
        header.backgroundColor = [UIColor blueColor];
    }
    header.tag = section;
    
    [header addTarget:self action:@selector(tappedHeader:) forControlEvents:UIControlEventTouchUpInside];
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Table header tap callback
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
    }
    else
    {
        Category * category = [self.categoriesDatasource objectAtIndex:header.tag];
        NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        NSArray* newSubCategories = [category.subcategories sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        //already expanded, close section
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
    }
}

@end
