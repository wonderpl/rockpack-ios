//
//  SYNAccountSettingsLastNameInput.m
//  rockpack
//
//  Created by Michael Michailidis on 22/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAccountSettingsLastNameInput.h"
#import "UIFont+SYNFont.h"

@interface SYNAccountSettingsLastNameInput ()
@property (nonatomic, strong) UITableView* tableView;

@end

@implementation SYNAccountSettingsLastNameInput

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
    
    self.errorTextField.center = CGPointMake(self.errorTextField.center.x, self.saveButton.center.y + 60.0);
    self.errorTextField.frame = CGRectIntegral(self.errorTextField.frame);
   // self.errorTextField.backgroundColor = [UIColor redColor];
    
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
        [self.spinner stopAnimating];
        self.saveButton.hidden = NO;
        return;
    }
    
    
    
    [self updateField:@"last_name" forValue:self.inputField.text withCompletionHandler:^{
        
        
        self.appDelegate.currentUser.lastName = self.inputField.text;
        
        
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
