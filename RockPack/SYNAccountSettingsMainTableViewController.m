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
#import "SYNAccountSettingsShareSettings.h"
#import "SYNAccountSettingsPassword.h"
#import "SYNAccountSettingsLocation.h"
#import "SYNAccountSettingsAbout.h"

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
                
                if([user.firstName isEqualToString:@""] || [user.lastName isEqualToString:@""]) {
                    cell.textLabel.text = @"Full Name";
                } else {
                    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
                }
                cell.imageView.image = [UIImage imageNamed:@"IconFullname.png"];
                cell.detailTextLabel.text = @"Full Name - Public";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            case 1:
                if([user.username isEqualToString:@""]) {
                    cell.textLabel.text = @"Username";
                } else {
                    cell.textLabel.text = user.username;
                }
                cell.imageView.image = [UIImage imageNamed:@"IconUsername.png"];
                cell.detailTextLabel.text = @"Username - Public";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            case 2:
                if([user.emailAddress isEqualToString:@""]) {
                    cell.textLabel.text = @"Email Address";
                } else {
                    cell.textLabel.text = user.emailAddress;
                }
                cell.imageView.image = [UIImage imageNamed:@"IconEmail.png"];
                cell.detailTextLabel.text = @"Email - Private";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            case 3:
                if([user.locale isEqualToString:@"en-gb"]) {
                    cell.textLabel.text = @"United Kingdom";
                } else {
                    cell.textLabel.text = @"United States";
                }
                
                cell.detailTextLabel.text = @"Location";
                cell.imageView.image = [UIImage imageNamed:@"IconLocation.png"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            case 4:
                if([user.gender isEqual:@(GenderUndecided)]) {
                    cell.textLabel.text = @"Gender";
                } else {
                    cell.textLabel.text = [user.gender isEqual:@(GenderMale)] ? @"Male" : @"Female";
                }
                
                cell.detailTextLabel.text = @"Gender - Private";
                cell.imageView.image = [UIImage imageNamed:@"IconGender.png"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            case 5:
                if(!user.dateOfBirth)
                    cell.textLabel.text = @"Date of Birth";
                else
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




#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        
        
        switch (indexPath.row) {
                
            case 0:
                [self.navigationController pushViewController:[[SYNAccountSettingsFullNameInput alloc] initWithUserFieldType:UserFieldTypeFullname] animated:YES];
                break;
                
            case 1:
                [self.navigationController pushViewController:[[SYNAccountSettingsTextInputController alloc] initWithUserFieldType:UserFieldTypeUsername] animated:YES];
                
                break;
                
            case 2:
                [self.navigationController pushViewController:[[SYNAccountSettingsTextInputController alloc] initWithUserFieldType:UserFieldTypeEmail] animated:YES];
                break;
                
            case 3:
                [self.navigationController pushViewController:[[SYNAccountSettingsLocation alloc] init] animated:YES];
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
                [self.navigationController pushViewController:[[SYNAccountSettingsShareSettings alloc] init] animated:YES];
                break;
                
            case 1:
                [self.navigationController pushViewController:[[SYNAccountSettingsPushNotifications alloc] init] animated:YES];
                break;
                
            case 2:
                [self.navigationController pushViewController:[[SYNAccountSettingsPassword alloc] init] animated:YES];
                break;
                
            case 3:
                [self.navigationController pushViewController:[[SYNAccountSettingsAbout alloc] init] animated:YES];
                break;
                
            case 4:
                
                [self showLogoutAlert];
                break;
                
                
            default:
                break;
                
        }
    
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

}
-(void)showLogoutAlert
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Logout"
                          message: @"Are you sure you want to log out?"
                          delegate: self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Logout", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
	if (buttonIndex == 0) { // cancel
		
	}
	else { // logout
		[appDelegate logout];
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
    if(!user.dateOfBirth)
        return @"";
    
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
