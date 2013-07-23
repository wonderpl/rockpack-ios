//
//  SYNNotificationsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "GAI.h"
#import "SYNAppDelegate.h"
#import "SYNMasterViewController.h"
#import "SYNNotificationsTableViewCell.h"
#import "SYNNotificationsTableViewController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNRockpackNotification.h"
#import "UIImageView+WebCache.h"
#import "Video.h"

#define kNotificationsCellIdent @"kNotificationsCellIdent"

@interface SYNNotificationsTableViewController ()

@property (nonatomic, weak) SYNAppDelegate *appDelegate;
@property (nonatomic, strong) UIImageView *logoImageView;

@end


@implementation SYNNotificationsTableViewController

@synthesize notifications = _notifications;

#pragma mark - Object lifecycle

- (id) init
{
    if ((self = [super initWithStyle: UITableViewStylePlain]))
    {
        // TODO: Get notifications
    }
    
    return self;
}


#pragma mark - View Life Cycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [GAI.sharedInstance.defaultTracker sendView: @"Notifications"];
    
    self.appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    self.logoImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"LogoNotifications"]];

    [self.view addSubview: self.logoImageView];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerClass: [SYNNotificationsTableViewCell class]
           forCellReuseIdentifier: kNotificationsCellIdent];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [self.tableView addObserver: self
                     forKeyPath: @"contentSize"
                        options: NSKeyValueObservingOptionNew
                        context: nil];
}


- (void) viewDidDisappear: (BOOL) animated
{
    [self.tableView removeObserver: self
                        forKeyPath: @"contentSize"];
    
    [super viewDidDisappear: animated];
}


#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}


- (NSInteger)	tableView: (UITableView *) tableView
  numberOfRowsInSection: (NSInteger) section
{
    return _notifications ? _notifications.count : 0;
}


- (UITableViewCell *) tableView: (UITableView *) tableView
          cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    SYNNotificationsTableViewCell *notificationCell = [tableView dequeueReusableCellWithIdentifier: kNotificationsCellIdent
                                                                                      forIndexPath: indexPath];
    
    SYNRockpackNotification *notification = (SYNRockpackNotification *) _notifications[indexPath.row];
    
    NSMutableString *constructedMessage = [[NSMutableString alloc] init];
    
    [constructedMessage appendFormat: @"%@ ", [notification.channelOwner.displayName uppercaseString]];
    
    if ([notification.messageType isEqualToString: @"subscribed"])
    {
        [constructedMessage appendString: NSLocalizedString(@"notification_subscribed_action", nil)];
    }
    else if ([notification.messageType isEqualToString: @"starred"])
    {
        [constructedMessage appendString: NSLocalizedString(@"notification_liked_action", nil)];
    }
    else if ([notification.messageType isEqualToString: @"joined"])
    {
        NSString *message = [NSString stringWithFormat: NSLocalizedString(@"notification_joined_action", @"Your Facebook friend (yxz) has joined Rockpack as (username)"), @"Name", @"Username"];
        
        [constructedMessage appendString: message];
    }
    else
    {
        AssertOrLog(@"Eek! Machine anomaly. Notification type unexpected")
    }
    
    notificationCell.messageTitle = [NSString stringWithString: constructedMessage];
    
    NSURL *userThumbnailUrl = [NSURL URLWithString: notification.channelOwner.thumbnailLargeUrl];
    
    [notificationCell.imageView setImageWithURL: userThumbnailUrl
                               placeholderImage: [UIImage imageNamed: @"PlaceholderNotificationAvatar.png"]
                                        options: SDWebImageRetryFailed];
    
    NSURL *thumbnaillUrl;
    UIImage *placeholder;

    switch (notification.objectType)
    {
        case kNotificationObjectTypeVideo:
            thumbnaillUrl = [NSURL URLWithString: notification.videoThumbnailUrl];
            placeholder = [UIImage imageNamed: @"PlaceholderNotificationVideo"];
            break;
            
        case kNotificationObjectTypeChannel:
            thumbnaillUrl = [NSURL URLWithString: notification.channelThumbnailUrl];
            placeholder = [UIImage imageNamed: @"PlaceholderNotificationChannel"];
            break;
            
        case kNotificationObjectTypeUser:
            // TODO: Add friend notification support here
            // thumbnaillUrl = [NSURL URLWithString: notification.userThumbnailUrl];
            placeholder = [UIImage imageNamed: @"PlaceholderNotificationUser"];
            break;
            
        default:
            AssertOrLog(@"Unexpected notification type");
            break;
    }
    
    [notificationCell.thumbnailImageView setImageWithURL: thumbnaillUrl
                                        placeholderImage: placeholder
                                                 options: SDWebImageRetryFailed];
    
    notificationCell.delegate = self;
    notificationCell.read = notification.read;
    
    notificationCell.detailTextLabel.text = notification.dateDifferenceString;
    
    return notificationCell;
}


- (CGFloat) tableView: (UITableView *) tableView
            heightForRowAtIndexPath: (NSIndexPath *) indexPath;
{
    return 77.0;
}


#pragma mark - Table view delegate

- (void) tableView: (UITableView *) tableView
         didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    [self markAsReadForNotification: _notifications[indexPath.row]];
}


#pragma mark - KVO

- (void) observeValueForKeyPath: (NSString *) keyPath
                       ofObject: (id) object
                         change: (NSDictionary *) change
                        context: (void *) context
{
    if ([keyPath isEqualToString: @"contentSize"])
    {
        CGRect logoImageViewFrame = self.logoImageView.frame;
        logoImageViewFrame.origin.y = self.tableView.contentSize.height + 20.0;
        logoImageViewFrame.origin.x = (self.tableView.frame.size.width * 0.5) - (logoImageViewFrame.size.width * 0.5);
        self.logoImageView.frame = logoImageViewFrame;
    }
}


#pragma mark - Delegate Handler

// this is the user who initialed the action, goes to is profile
- (void) mainImageTableCellPressed: (UIButton *) button
{
    SYNNotificationsTableViewCell *cellPressed = (SYNNotificationsTableViewCell *) button.superview;
    
    NSIndexPath *indexPathForCellPressed = [self.tableView indexPathForCell: cellPressed];
    
    if (indexPathForCellPressed.row > self.notifications.count)
    {
        return;
    }
    
    SYNRockpackNotification *notification = self.notifications[indexPathForCellPressed.row];
    
    SYNAppDelegate *appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    [appDelegate.viewStackManager viewProfileDetails: notification.channelOwner];
    
    [self markAsReadForNotification: notification];
}


- (void) itemImageTableCellPressed: (UIButton *) button
{
    SYNNotificationsTableViewCell *cellPressed = (SYNNotificationsTableViewCell *) button.superview;
    
    NSIndexPath *indexPathForCellPressed = [self.tableView
                                            indexPathForCell: cellPressed];
    
    SYNRockpackNotification *notification = self.notifications[indexPathForCellPressed.row];
    
    if (!notification)
    {
        return;
    }
    
    SYNAppDelegate *appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    switch (notification.objectType)
    {
        case kNotificationObjectTypeVideo:
        {
            Channel *channel = [self channelFromChannelId: notification.channelId];
            
            if (!channel)
            {
                return;
            }
            
            [appDelegate.viewStackManager viewChannelDetails: channel
                                              withAutoplayId: notification.videoId];
            break;
        }
            
        case kNotificationObjectTypeChannel:
        {
            Channel *channel = [self channelFromChannelId: notification.channelId];
            
            if (!channel)
            {
                return;
            }
            
            [appDelegate.viewStackManager viewChannelDetails: channel];
            break;
        }
            
        case kNotificationObjectTypeUser:
        {
            ChannelOwner *channelOwner = notification.channelOwner;
            
            if (!channelOwner)
            {
                return;
            }
            
            [appDelegate.viewStackManager viewProfileDetails: channelOwner];
            break;
        }
            
        default:
            AssertOrLog(@"Unexpected notification type");
            break;
    }
    
    [self markAsReadForNotification: notification];
}


- (void) markAsReadForNotification: (SYNRockpackNotification *) notification
{
    if (notification == nil || notification.read) // if already read or nil, don't bother...
    {
        return;
    }
    
    NSArray *array = @[@(notification.identifier)];
    
    [self.appDelegate.oAuthNetworkEngine markAdReadForNotificationIndexes: array
                                                               fromUserId: self.appDelegate.currentUser.uniqueId
                                                        completionHandler: ^(id response) {
                                                            notification.read = YES;
                                                            
                                                            [self.tableView reloadData];
                                                            
                                                            [[NSNotificationCenter defaultCenter]  postNotificationName: kNotificationMarkedRead
                                                                                                                 object: self];
                                                        } errorHandler: ^(id error) {
                                                            
                                                            
                                                        }];
}


#pragma mark - Accessors

- (void) setNotifications: (NSArray *) notifications
{
    _notifications = notifications;
    [self.tableView reloadData];
}


- (NSArray *) notifications
{
    return _notifications;
}


- (Channel *) channelFromChannelId: (NSString *) channelId
{
    NSError *error;
    Channel *channel;

    NSFetchRequest *channelFetchRequest = [[NSFetchRequest alloc] init];
    
    channelFetchRequest.entity = [NSEntityDescription entityForName: @"Channel"
                                             inManagedObjectContext: self.appDelegate.mainManagedObjectContext];
    
    channelFetchRequest.predicate = [NSPredicate predicateWithFormat: @"uniqueId == %@", channelId];

    NSArray *matchingChannelEntries = [self.appDelegate.mainManagedObjectContext executeFetchRequest: channelFetchRequest
                                                                                               error: &error];
    
    if (matchingChannelEntries.count > 0)
    {
        channel = matchingChannelEntries[0];
    }
    
    return channel;
}


@end
