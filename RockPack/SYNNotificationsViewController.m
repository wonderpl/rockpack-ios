//
//  SYNNotificationsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNNotificationsViewController.h"
#import "SYNNotificationsTableViewCell.h"


#define kNotificationsCellIdent @"kNotificationsCellIdent"

@interface SYNNotificationsViewController ()

@end

@implementation SYNNotificationsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kNotificationsCellIdent];
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

    
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNotificationsCellIdent forIndexPath:indexPath];
    
    
    cell.textLabel.text = @"Mike";
    cell.imageView.image = [UIImage imageNamed:@"NotFoundAvatarYou.png"];
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
