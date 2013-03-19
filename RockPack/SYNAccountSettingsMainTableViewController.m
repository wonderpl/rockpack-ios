//
//  SYNAccountSettingsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 18/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAccountSettingsMainTableViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNAccountSettingTableViewCell.h"

#import "SYNAccountSettingsGender.h"
#import "AppConstants.h"

@interface SYNAccountSettingsMainTableViewController ()

@property (nonatomic, strong) NSArray* dataItems2ndSection;

@end

@implementation SYNAccountSettingsMainTableViewController

@synthesize dataItems2ndSection;

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
        dataItems2ndSection = @[@"Share Settings",
                                @"Push Notification Settings",
                                @"Change Password",
                                @"About",
                                @"Logout"];
        
        
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    CGSize size = kAccountSettingRect;
    self.contentSizeForViewInPopover = size;
    
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.scrollEnabled = NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) { // first section
        return 6;
    } else { // second section
        return dataItems2ndSection.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;
   
    
    if(indexPath.section == 0) {
        
        cell = [[SYNAccountSettingTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        switch (indexPath.row) {
                
            case 0:
                cell.textLabel.text = @"Alexandra Longname-Smith";
                cell.detailTextLabel.text = @"Full Name - Public";
                cell.imageView.image = [UIImage imageNamed:@"IconFullname.png"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            case 1:
                cell.textLabel.text = @"alex_1989";
                cell.detailTextLabel.text = @"Username - Public";
                cell.imageView.image = [UIImage imageNamed:@"IconUsername.png"];
                break;
                
            case 2:
                cell.textLabel.text = @"alex_longname@gmail.com";
                cell.detailTextLabel.text = @"Email - Private";
                cell.imageView.image = [UIImage imageNamed:@"IconEmail.png"];
                break;
                
            case 3:
                cell.textLabel.text = @"078897898";
                cell.detailTextLabel.text = @"Phone - Private";
                cell.imageView.image = [UIImage imageNamed:@"IconLocation.png"];
                break;
                
            case 4:
                cell.textLabel.text = @"Female";
                cell.detailTextLabel.text = @"Gender - Private";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.imageView.image = [UIImage imageNamed:@"IconGender.png"];
                break;
                
            case 5:
                cell.textLabel.text = @"14 Jan 1989";
                cell.detailTextLabel.text = @"D.O.B Private";
                cell.imageView.image = [UIImage imageNamed:@"IconBirthday.png"];
                break;
                
        }
        
        cell.textLabel.font = [UIFont rockpackFontOfSize:18.0];
        cell.detailTextLabel.font = [UIFont rockpackFontOfSize:13.0];
        
        
    } else {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        
        cell.textLabel.text = (NSString*)dataItems2ndSection[indexPath.row];
        
        cell.textLabel.font = [UIFont rockpackFontOfSize:18.0];
        
        if(indexPath.row != 4) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
    }
    
    return cell;
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


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
    if(indexPath.section == 0)
    {
        switch (indexPath.row) {
            case 4:
                [self.navigationController pushViewController:[[SYNAccountSettingsGender alloc] init] animated:YES];
                break;
                
            default:
                break;
                
        }
    }
}

@end
