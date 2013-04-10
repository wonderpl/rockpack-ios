//
//  SYNNotificationsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNNotificationsViewController.h"
#import "SYNNotificationsTableViewCell.h"
#import "SYNRockpackNotification.h"

#define kNotificationsCellIdent @"kNotificationsCellIdent"

@interface SYNNotificationsViewController ()

@property (nonatomic, strong) NSArray* notifications;

@end

@implementation SYNNotificationsViewController



- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // TODO: Get notifications
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[SYNNotificationsTableViewCell class] forCellReuseIdentifier:kNotificationsCellIdent];
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
    
    
    cell.textLabel.text = @"LUCY KERRIGHAN has subscribed to your channel.";
    cell.imageView.image = [UIImage imageNamed:@"NotFoundAvatarYou.png"];
    
    cell.detailTextLabel.text = @"8 Mins";
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 80.0;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Get the notification and do something with it
    // SYNRockpackNotification* notificationSelected = (SYNRockpackNotification*)[self.notifications objectAtIndex:indexPath.row];
}

@end
