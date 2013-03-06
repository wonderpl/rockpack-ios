//
//  SYNAutocompleteViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 05/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAutocompleteViewController.h"
#import "UIFont+SYNFont.h"
#import "UIColor+SYNColor.h"

@interface SYNAutocompleteViewController ()

@end

@implementation SYNAutocompleteViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        wordsArray = [[NSMutableArray alloc] init];
        rockpackFont = [UIFont rockpackFontOfSize:18.0];
        textColor = [UIColor rockpacTurcoiseColor];
        tableBGColor = [UIColor rockpacLedColor];
        
        self.title = @"Suggestions";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    self.tableView.separatorColor = [UIColor rockpacLedColor];
    self.tableView.backgroundColor = tableBGColor;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Add Words

-(void)addWord:(NSString*)word
{
    [wordsArray addObject:word];
}
-(void)addWords:(NSArray*)words
{
    [wordsArray removeAllObjects];
    [wordsArray addObjectsFromArray:words];
    [self.tableView reloadData];
}
#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return wordsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] init];
        
        // Accesory View
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        // Text
        
        cell.textLabel.font = rockpackFont;
        cell.textLabel.textColor = textColor;
        
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ArrowSearch.png"]];
        
    }
    
    
    cell.textLabel.text = (NSString*)wordsArray[indexPath.row];
    
    // Configure the cell...
    
    return cell;
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

-(NSString*)getWordAtIndex:(NSInteger)index
{
    return (NSString*)[wordsArray objectAtIndex:index];
}


@end
