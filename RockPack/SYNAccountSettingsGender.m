//
//  SYNAccountSettingsGender.m
//  rockpack
//
//  Created by Michael Michailidis on 18/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAccountSettingsGender.h"
#import "AppConstants.h"
#import "SYNAccountSettingTableViewCell.h"

@interface SYNAccountSettingsGender ()

@end

@implementation SYNAccountSettingsGender

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
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

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        cell.textLabel.text = @"Male";
        
    } else if(indexPath.row == 1) {
        cell.textLabel.text = @"Female";
    }
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cellSelected = [self.tableView cellForRowAtIndexPath:indexPath];
    cellSelected.accessoryType = UITableViewCellAccessoryCheckmark;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
