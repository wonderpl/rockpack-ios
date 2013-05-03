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

@property (nonatomic, strong) SYNPaddedUITextField* lastNameInputField;

@end

@implementation SYNAccountSettingsFullNameInput




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.lastNameInputField = [self createInputField];
    
    self.lastNameInputField.text = self.appDelegate.currentUser.lastName;
    self.lastNameInputField.leftViewMode = UITextFieldViewModeAlways;
    self.lastNameInputField.leftView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"IconFullname.png"]];
    
    [self.view addSubview:self.lastNameInputField];
    
    CGRect tableViewFrame = CGRectMake(10.0, self.lastNameInputField.frame.origin.y + 42.0, self.sizeInContainer, 120.0);
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
    
    
    self.errorLabel.center = CGPointMake(self.errorLabel.center.x, self.saveButton.center.y + 60.0);
    self.errorLabel.frame = CGRectIntegral(self.errorLabel.frame);
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* backButtonImage = [UIImage imageNamed: @"ButtonAccountBackDefault.png"];
    UIImage* backButtonHighlightedImage = [UIImage imageNamed: @"ButtonAccountBackHighlighted.png"];
    
    
    [backButton setImage: backButtonImage
                forState: UIControlStateNormal];
    
    [backButton setImage: backButtonHighlightedImage
                forState: UIControlStateHighlighted];
    
    [backButton addTarget:self action:@selector(didTapBackButton:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0.0, 0.0, backButtonImage.size.width, backButtonImage.size.height);
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
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
    
    
    if([self.inputField.text isEqualToString:self.appDelegate.currentUser.firstName] && // user did not change anything
       [self.lastNameInputField.text isEqualToString:self.appDelegate.currentUser.lastName]) {
        
        return;
    }
    
    if(![self inputIsValid:self.inputField.text] || ![self inputIsValid:self.lastNameInputField.text]) {
        self.errorLabel.text = @"You Have Entered Invalid Characters";
        [self.spinner stopAnimating];
        self.saveButton.hidden = NO;
        return;
    }
    
    
    
    [self updateField:@"first_name" forValue:self.inputField.text withCompletionHandler:^{
        
        self.appDelegate.currentUser.firstName = self.inputField.text;
        
        
        [self updateField:@"last_name" forValue:self.lastNameInputField.text withCompletionHandler:^{
            
            self.appDelegate.currentUser.lastName = self.lastNameInputField.text;
            
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
