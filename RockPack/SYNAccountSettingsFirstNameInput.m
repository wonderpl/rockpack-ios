//
//  SYNAccountSettingsFullNameInput.m
//  rockpack
//
//  Created by Michael Michailidis on 20/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAccountSettingsFirstNameInput.h"
#import "UIFont+SYNFont.h"
#import "SYNOAuthNetworkEngine.h"

@interface SYNAccountSettingsFirstNameInput ()

@property (nonatomic, strong) UITableView* tableView;

@end

@implementation SYNAccountSettingsFirstNameInput




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
    
    
    [self.spinner startAnimating];
    
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
    
    if(![self formIsValid]) {
        self.errorTextField.text = @"You Have Entered Invalid Characters";
        return;
    }
    
    
    
    [self updateField:@"first_name" forValue:self.inputField.text withCompletionHandler:^{
        
        
        self.appDelegate.currentUser.firstName = self.inputField.text;
        
        
        [self.appDelegate saveContext:YES];
        
        [self.navigationController popViewControllerAnimated:YES];
        
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
