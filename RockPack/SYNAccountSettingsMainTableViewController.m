//
//  SYNAccountSettingsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 18/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//


#import "AppConstants.h"
#import "GAI.h"
#import "SYNAccountSettingTableViewCell.h"
#import "SYNAccountSettingsAbout.h"
#import "SYNAccountSettingsDOB.h"
#import "SYNAccountSettingsEmail.h"
#import "SYNAccountSettingsFullNameInput.h"
#import "SYNAccountSettingsGender.h"
#import "SYNAccountSettingsLocation.h"
#import "SYNAccountSettingsMainTableViewController.h"
#import "SYNAccountSettingsPassword.h"
#import "SYNAccountSettingsPushNotifications.h"
#import "SYNAccountSettingsShareSettings.h"
#import "SYNAccountSettingsTextInputController.h"
#import "SYNAccountSettingsUsername.h"
#import "SYNAppDelegate.h"
#import "SYNDeviceManager.h"
#import "UIFont+SYNFont.h"
#import "User.h"

@interface SYNAccountSettingsMainTableViewController ()

@property (nonatomic, strong) NSArray* dataItems2ndSection;
@property (nonatomic, strong) UIPopoverController* dobPopover;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;
@property (nonatomic, weak) User* user;

@end

@implementation SYNAccountSettingsMainTableViewController

@synthesize dataItems2ndSection, appDelegate, user;

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
        dataItems2ndSection = @[NSLocalizedString (@"Change Password", nil),
                                NSLocalizedString (@"About", nil),
                                NSLocalizedString (@"Logout", nil)];
        
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        user = appDelegate.currentUser;
        
        self.title = @"ACCOUNT SETTINGS";
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contentSizeForViewInPopover = CGSizeMake(380, 476);

    self.tableView.scrollEnabled = [[SYNDeviceManager sharedInstance] isIPhone];
    
    
    
    
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
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
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
    UITableViewCell *cell;
    
    
    if(indexPath.section == 0) {
        
        static NSString *CellIdentifier = @"Section0Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!cell)
        {
            cell = [[SYNAccountSettingTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        switch (indexPath.row) {
                
            case 0:
                cell.imageView.image = [UIImage imageNamed:@"IconFullname.png"];
                cell.textLabel.text = user.firstName;
                cell.detailTextLabel.text = NSLocalizedString (@"Public" , nil);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
                
            case 1:
                cell.imageView.image = [UIImage imageNamed:@"IconUsername.png"];
                cell.textLabel.text = user.username;
                cell.detailTextLabel.text = NSLocalizedString (@"Public", nil);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            case 2:
                if([user.emailAddress isEqualToString:@""]) {
                    cell.textLabel.text = @"Email Address";
                } else {
                    cell.textLabel.text = user.emailAddress;
                }
                cell.imageView.image = [UIImage imageNamed:@"IconEmail.png"];
                cell.detailTextLabel.text = NSLocalizedString (@"Email - Private", nil);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            case 3:
                if([user.locale isEqualToString:@"en-gb"]) {
                    cell.textLabel.text = NSLocalizedString (@"United Kingdom", nil);
                } else {
                    cell.textLabel.text = NSLocalizedString (@"United States", nil);
                }
                
                cell.detailTextLabel.text = @"Location";
                cell.imageView.image = [UIImage imageNamed:@"IconLocation.png"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            case 4:
                if([user.gender isEqual:@(GenderUndecided)]) {
                    cell.textLabel.text = NSLocalizedString (@"Gender", nil);
                } else {
                    cell.textLabel.text = [user.gender isEqual:@(GenderMale)] ? @"Male" : @"Female";
                }
                
                cell.detailTextLabel.text = NSLocalizedString (@"Gender - Private", nil);
                cell.imageView.image = [UIImage imageNamed:@"IconGender.png"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            case 5:
                if(!user.dateOfBirth)
                    cell.textLabel.text = NSLocalizedString (@"Date of Birth", nil);
                else
                    cell.textLabel.text = [self getDOBPlainString:user.dateOfBirth];
                
                cell.detailTextLabel.text = NSLocalizedString (@"D.O.B Private", nil);
                cell.imageView.image = [UIImage imageNamed:@"IconBirthday.png"];
                break;
                
        }
        
        cell.textLabel.font = [UIFont rockpackFontOfSize:18.0];
        cell.detailTextLabel.font = [UIFont rockpackFontOfSize:13.0];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        
        
    } else {
        
        static NSString *CellIdentifier = @"OtherSectionCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        
        cell.textLabel.text = (NSString*)dataItems2ndSection[indexPath.row];
        
        cell.textLabel.font = [UIFont rockpackFontOfSize:18.0];
        
        if(indexPath.row != 2) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
    }
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        
        switch (indexPath.row) {
                
            case 0:
                [self.navigationController pushViewController:[[SYNAccountSettingsFullNameInput alloc] initWithUserFieldType:UserFieldTypeFullName] animated:YES];
                break;
                
            
                
            case 1:
                [self.navigationController pushViewController:[[SYNAccountSettingsUsername alloc] initWithUserFieldType:UserFieldTypeUsername] animated:YES];
                
                break;
                
            case 2:
                [self.navigationController pushViewController:[[SYNAccountSettingsEmail alloc] initWithUserFieldType:UserFieldTypeEmail] animated:YES];
                break;
                
            case 3:
                [self.navigationController pushViewController:[[SYNAccountSettingsLocation alloc] init] animated:YES];
                break;
            
            case 4:
                [self.navigationController pushViewController:[[SYNAccountSettingsGender alloc] init] animated:YES];
                break;
                
            case 5:
            {
                SYNAccountSettingsDOB* dobController = [[SYNAccountSettingsDOB alloc] init];
                
                [dobController.datePicker addTarget:self
                                             action:@selector(datePickerValueChanged:)
                                   forControlEvents:UIControlEventValueChanged];
                NSDate* date = [NSDate date];
                if(appDelegate.currentUser.dateOfBirth)
                {
                    date = appDelegate.currentUser.dateOfBirth;
                }
                [dobController.datePicker setDate:date];
                
                if([[SYNDeviceManager sharedInstance] isIPad])
                {
                    if(self.dobPopover)
                        return;
                    
                    
                    
                    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:dobController];
                    
                    
                    self.dobPopover = [[UIPopoverController alloc] initWithContentViewController: navigationController];
                    self.dobPopover.popoverContentSize = dobController.datePicker.frame.size;
                    self.dobPopover.delegate = self;
                    
                    
                    [self.dobPopover presentPopoverFromRect: [self getDOBTableViewCell].frame
                                                     inView: self.view
                                   permittedArrowDirections: UIPopoverArrowDirectionAny
                                                   animated: YES];
                }
                else
                {
                    
                    
                    [self.navigationController pushViewController:dobController animated:YES];
                
                }
                
            }
            break;
                
            default:
                break;
                
        }
        
    } else {
        
        switch (indexPath.row) {
                
            case 0:
                [self.navigationController pushViewController:[[SYNAccountSettingsPassword alloc] init] animated:YES];
                break;
                
            case 1:
                [self.navigationController pushViewController:[[SYNAccountSettingsAbout alloc] init] animated:YES];
                break;
                
            case 2:
                [self showLogoutAlert];
                break;
               
                
        }
    
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

}
-(void)showLogoutAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString (@"Logout", nil)
                                                    message: NSLocalizedString (@"Are you sure you want to log out?", nil)
                                                   delegate: self
                                          cancelButtonTitle: NSLocalizedString (@"Cancel", nil)
                                          otherButtonTitles: NSLocalizedString (@"Logout", nil), nil];
    [alert show];
}

- (void) alertView: (UIAlertView *) alertView
         clickedButtonAtIndex: (NSInteger) buttonIndex
{
	if (buttonIndex == 0) { // cancel
		
	}
	else
    { // logout
        [[NSNotificationCenter defaultCenter] postNotificationName: kAccountSettingsLogout
                                                            object: self];
	}
}


-(UITableViewCell*) getDOBTableViewCell
{
    
    UITableViewCell* cellClicked = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:6 inSection:0]];
    return cellClicked;
}

-(void)datePickerValueChanged:(UIDatePicker*)datePicker
{
    
    
    NSString* dateString = [self getDOBFormattedString:datePicker.date];
    
    
    
    [self.appDelegate.oAuthNetworkEngine changeUserField:@"date_of_birth"
                                                 forUser:self.appDelegate.currentUser
                                            withNewValue:dateString
                                       completionHandler:^ {
                                           
                                           user.dateOfBirth = datePicker.date;
                                           
                                           [self getDOBTableViewCell].textLabel.text = [self getDOBPlainString:user.dateOfBirth];
                                           
                                       } errorHandler:^(id errorInfo) {
                                           
                                           
                                           
                                       }];

    // Calculate age, taking account of leap-years etc. (probably too accurate!)
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar] components: NSYearCalendarUnit
                                                                      fromDate: user.dateOfBirth
                                                                        toDate: NSDate.date
                                                                       options: 0];
    
    NSInteger age = [ageComponents year];
    NSString *ageString = [NSString stringWithFormat: @"%d", age];
    
    // Now set the age
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker setCustom: kGADimensionAge
             dimension: ageString];
}

-(NSString*)getDOBPlainString:(NSDate*)date
{
    if(!date) return nil;
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    return [dateFormatter stringFromDate:date];
}

-(NSString*) getDOBFormattedString:(NSDate*)date
{
    if(!date) return nil;
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    
    return [dateFormatter stringFromDate:date];
}

- (void) popoverControllerDidDismissPopover: (UIPopoverController *) popoverController
{
    if (popoverController == self.dobPopover)
    {
        self.dobPopover = nil;
    }
}

@end
