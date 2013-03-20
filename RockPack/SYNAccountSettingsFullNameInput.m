//
//  SYNAccountSettingsFullNameInput.m
//  rockpack
//
//  Created by Michael Michailidis on 20/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAccountSettingsFullNameInput.h"
#import "UIFont+SYNFont.h"

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
    
    self.inputField.rightViewMode = UITextFieldViewModeAlways;
    self.inputField.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    
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
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 1) {
        
    } else {
        
    }
}



@end
