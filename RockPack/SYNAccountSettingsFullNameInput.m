//
//  SYNAccountSettingsFullNameInput.m
//  rockpack
//
//  Created by Michael Michailidis on 20/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAccountSettingsFullNameInput.h"
#import "UIFont+SYNFont.h"
#import "SYNOAuthNetworkEngine.h"

@interface SYNAccountSettingsFullNameInput ()

@property (nonatomic, strong) UITableView* tableView;

@end

@implementation SYNAccountSettingsFullNameInput



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    CGRect tableViewFrame = CGRectMake(10.0, 50.0, self.contentSizeForViewInPopover.width - 10.0, 120.0);
    self.tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
    self.tableView.backgroundView = nil;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    CGRect saveButtonRect = self.saveButton.frame;
    saveButtonRect.origin.y = self.tableView.frame.origin.y + self.tableView.frame.size.height + 10.0;
    self.saveButton.frame = saveButtonRect;
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;
    
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    if(indexPath.row == 0) {
        cell.textLabel.text = @"Public";
    } else {
        cell.textLabel.text = @"Private";
    }
    
    
    cell.textLabel.font = [UIFont rockpackFontOfSize:18.0];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

-(void)saveButtonPressed:(UIButton*)button
{
    
    [super saveButtonPressed:button];
    
    NSArray* componentsOfInput = [self.inputField.text componentsSeparatedByString:@" "];
    
    NSString* firstName = componentsOfInput[0];
    NSString* lastName;
    if(componentsOfInput.count >= 2) {
        lastName = componentsOfInput[componentsOfInput.count-1];
    }
    
    [self updateField:@"first_name" forValue:firstName withCompletionHandler:^{
        
        
        self.appDelegate.currentUser.firstName = firstName;
        
        
        [self.appDelegate saveContext:YES];
        
        if(!lastName) // do not update last name if there is no input for it
            return;
        
        [self updateField:@"last_name" forValue:lastName withCompletionHandler:^{
            
            
            self.appDelegate.currentUser.lastName = lastName;
            
            
            [self.appDelegate saveContext:YES];
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }];
    }];
}





#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.tableView reloadData];
    
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    if(indexPath.row == 1) {
        
    } else {
        
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
