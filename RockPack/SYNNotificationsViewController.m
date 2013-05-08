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
#import "UIImageView+ImageProcessing.h"
#import "SYNAppDelegate.h"
#import "SYNOAuthNetworkEngine.h"

#define kNotificationsCellIdent @"kNotificationsCellIdent"

@interface SYNNotificationsViewController ()


@property (nonatomic, weak) SYNAppDelegate* appDelegate;
@end

@implementation SYNNotificationsViewController

@synthesize notifications = _notifications;
@synthesize appDelegate;


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
    
    self.appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];

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

    return _notifications ? _notifications.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SYNNotificationsTableViewCell *notificationCell = [tableView dequeueReusableCellWithIdentifier:kNotificationsCellIdent forIndexPath:indexPath];
    
    SYNRockpackNotification* notification = (SYNRockpackNotification*)[_notifications objectAtIndex:indexPath.row];
    
    NSString* constructedMessage = [NSString stringWithFormat:@"%@ has %@ to your channel", [notification.userDisplayName uppercaseString], notification.messageType];
    
    notificationCell.messageTitle = constructedMessage;
    
    NSURL* thumbnailUrl = [NSURL URLWithString:notification.userThumbnailUrl];
    [notificationCell.imageView setAsynchronousImageFromURL:thumbnailUrl placeHolderImage:[UIImage imageNamed:@""]];
    
//    NSURL* thumbnailChannelUrl = [NSURL URLWithString:notification.channelResourceUrl];
//    notificationCell.thumbnailImageView setAsynchronousImageFromURL:thumbnailUrl placeHolderImage:[UIImage imageNamed:@""]];
    
    notificationCell.detailTextLabel.text = @"8 Mins";
    
    return notificationCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 80.0;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* array = @[@(indexPath.row)];
    [appDelegate.oAuthNetworkEngine markAdReadForNotificationIndexes:array
                                                          fromUserId:appDelegate.currentUser.uniqueId
                                                   completionHandler:^(id responce) {
                                                       
                                                       [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMarkedRead
                                                                                                           object:self];
        
                                                   } errorHandler:^(id error) {
        
                                                   }];
}

#pragma mark - Accessors

-(void)setNotifications:(NSArray *)notifications
{
    _notifications = notifications;
    [self.tableView reloadData];
}

@end
