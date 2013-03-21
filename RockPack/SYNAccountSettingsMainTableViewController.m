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
#import "SYNAppDelegate.h"
#import "AppConstants.h"
#import "User.h"
#import "SYNAccountSettingsTextInputController.h"
#import "SYNAccountSettingsFullNameInput.h"
#import "SYNAccountSettingsDOB.h"
#import "SYNAccountSettingsPushNotifications.h"

@interface SYNAccountSettingsMainTableViewController ()

@property (nonatomic, strong) NSArray* dataItems2ndSection;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;
@property (nonatomic, weak) User* user;
@property (nonatomic, strong) UIPopoverController* dobPopover;

@end

@implementation SYNAccountSettingsMainTableViewController

@synthesize dataItems2ndSection, appDelegate, user;

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
        dataItems2ndSection = @[@"Share Settings",
                                @"Push Notification Settings",
                                @"Change Password",
                                @"About",
                                @"Logout"];
        
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        user = appDelegate.currentUser;
        
        self.title = @"Account Settings";
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contentSizeForViewInPopover = CGSizeMake(380, 476);

    self.tableView.scrollEnabled = NO;
    
}

- (void) forcePopoverSize {
    CGSize currentSetSizeForPopover = self.contentSizeForViewInPopover;
    CGSize fakeMomentarySize = CGSizeMake(currentSetSizeForPopover.width - 1.0f, currentSetSizeForPopover.height - 1.0f);
    self.contentSizeForViewInPopover = fakeMomentarySize;
    self.contentSizeForViewInPopover = currentSetSizeForPopover;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                
                if([user.firstName isEqualToString:@"(First Name)"] || [user.lastName isEqualToString:@"(Last Name)"]) {
                    cell.textLabel.text = @"Full Name";
                } else {
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
                }
                cell.imageView.image = [UIImage imageNamed:@"IconFullname.png"];
                cell.detailTextLabel.text = @"Full Name - Public";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            case 1:
                if([user.username isEqualToString:@"(Username)"]) {
                    cell.textLabel.text = @"Username";
                } else {
                    cell.textLabel.text = user.username;
                }
                cell.imageView.image = [UIImage imageNamed:@"IconUsername.png"];
                cell.detailTextLabel.text = @"Username - Public";
                break;
                
            case 2:
                if([user.emailAddress isEqualToString:@"(Email Address)"]) {
                    cell.textLabel.text = @"Email Address";
                } else {
                    cell.textLabel.text = user.emailAddress;
                }
                cell.imageView.image = [UIImage imageNamed:@"IconEmail.png"];
                cell.detailTextLabel.text = @"Email - Private";
                break;
                
            case 3:
                cell.textLabel.text = @"London - UK";
                cell.detailTextLabel.text = @"Location";
                cell.imageView.image = [UIImage imageNamed:@"IconLocation.png"];
                break;
                
            case 4:
                cell.textLabel.text = ([user.gender isEqual:@(GenderMale)]) ? @"Male" : @"Female";
                cell.detailTextLabel.text = @"Gender - Private";
                cell.imageView.image = [UIImage imageNamed:@"IconGender.png"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            case 5:
                cell.textLabel.text = [self getDOBStringFromCurrentUser];
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
                
            case 0:
                [self.navigationController pushViewController:[[SYNAccountSettingsFullNameInput alloc] initWithUserFieldType:UserFieldTypeFirstName] animated:YES];
                break;
                
            case 1:
                [self.navigationController pushViewController:[[SYNAccountSettingsTextInputController alloc] initWithUserFieldType:UserFieldTypeFirstName] animated:YES];
                break;
                
            case 2:
                [self.navigationController pushViewController:[[SYNAccountSettingsTextInputController alloc] initWithUserFieldType:UserFieldTypeFirstName] animated:YES];
                break;
                
            case 3:
                [self.navigationController pushViewController:[[SYNAccountSettingsTextInputController alloc] initWithUserFieldType:UserFieldTypeFirstName] animated:YES];
                break;
            
            case 4:
                [self.navigationController pushViewController:[[SYNAccountSettingsGender alloc] init] animated:YES];
                break;
                
            case 5:
                [self showDOBPopover];
                break;
                
            default:
                break;
                
        }
        
    } else {
        
        switch (indexPath.row) {
                
            case 0:
                
                break;
                
            case 1:
                [self.navigationController pushViewController:[[SYNAccountSettingsPushNotifications alloc] init] animated:YES];
                break;
                
            case 2:
                
                break;
                
            case 3:
            
                break;
                
            case 4:
                
                break;
                
            case 5:
                
                break;
                
            default:
                break;
                
        }
    
    }

}


-(void)showDOBPopover
{
    if(self.dobPopover)
        return;
    
    SYNAccountSettingsDOB* dobController = [[SYNAccountSettingsDOB alloc] init];
    
    [dobController.datePicker addTarget:self
                                 action:@selector(datePickerValueChanged:)
                       forControlEvents:UIControlEventValueChanged];
    
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:dobController];
    
    
    self.dobPopover = [[UIPopoverController alloc] initWithContentViewController: navigationController];
    self.dobPopover.popoverContentSize = dobController.datePicker.frame.size;
    self.dobPopover.delegate = self;
    
    
    
    
    [self.dobPopover presentPopoverFromRect: [self getDOBTableViewCell].frame
                                     inView: self.view
                   permittedArrowDirections: UIPopoverArrowDirectionAny
                                   animated: YES];
    
    
    
}

-(UITableViewCell*)getDOBTableViewCell
{
    
    UITableViewCell* cellClicked = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:5 inSection:0]];
    return cellClicked;
}

-(void)datePickerValueChanged:(UIDatePicker*)datePicker
{
    user.dateOfBirth = datePicker.date;
    
    [self getDOBTableViewCell].textLabel.text = [self getDOBStringFromCurrentUser];
    
    
}

-(NSString*)getDOBStringFromCurrentUser
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    return [dateFormatter stringFromDate:user.dateOfBirth];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if(popoverController == self.dobPopover)
    {
        self.dobPopover = nil;
    }
    
}

@end
