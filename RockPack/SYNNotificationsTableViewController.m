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
#import "UIFont+SYNFont.h"
#import "Video.h"
#import "SYNDeviceManager.h"

#define kNotificationsCellIdent @"kNotificationsCellIdent"

@interface SYNNotificationsTableViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) SYNAppDelegate *appDelegate;

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UITableView* tableView;

@property (nonatomic) BOOL hasUnreadNotifications;

@end


@implementation SYNNotificationsTableViewController

@synthesize notifications = _notifications;


#pragma mark - View Life Cycle

- (void) viewDidLoad
{
    
    [super viewDidLoad];
    
    
    
    
    self.tableView = [[UITableView alloc] initWithFrame: CGRectZero
                                                  style: UITableViewStylePlain];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.showsVerticalScrollIndicator = NO;
    
    [self.view addSubview:self.tableView];
    
    [GAI.sharedInstance.defaultTracker sendView: @"Notifications"];
    
    self.appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    self.logoImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"LogoNotifications"]];

    [self.view addSubview: self.logoImageView];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.tableView registerClass: [SYNNotificationsTableViewCell class]
           forCellReuseIdentifier: kNotificationsCellIdent];
    
    self.hasUnreadNotifications = NO;
    
    self.view.autoresizesSubviews = YES;
}



- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [self.tableView addObserver: self
                     forKeyPath: @"contentSize"
                        options: NSKeyValueObservingOptionNew
                        context: nil];
    
    
    [self resizeTableViewForInterfaceOrientation:[[SYNDeviceManager sharedInstance] currentOrientation]];
    
}

-(void)resizeTableViewForInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    CGRect tvFrame = CGRectZero;
    tvFrame.size = self.view.frame.size;
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        tvFrame.size.height = 680.0f;
    }
    else
    {
        tvFrame.size.height = 928.0f;
    }
    self.tableView.frame = tvFrame;
}


- (void) viewDidDisappear: (BOOL) animated
{
    [self.tableView removeObserver: self
                        forKeyPath: @"contentSize"];
    
    [super viewDidDisappear: animated];
    
    
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation: toInterfaceOrientation
                                            duration: duration];
    
    [self resizeTableViewForInterfaceOrientation:toInterfaceOrientation];
}
#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return 1;
}


- (NSInteger)	tableView: (UITableView *) tableView
    numberOfRowsInSection: (NSInteger) section
{
    
    if(!_notifications)
    {
        return 0;
    }
    
    // we should display the 'MARK AS READ' cell
    for (SYNRockpackNotification* notification in _notifications)
    {
        if(!notification.read)
        {
            self.hasUnreadNotifications = YES;
            break;
        }
        
    }
    
    return self.hasUnreadNotifications ? _notifications.count + 1 : _notifications.count;
}


- (UITableViewCell *) tableView: (UITableView *) tableView
          cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    
    if(indexPath.row == 0 && self.hasUnreadNotifications)
    {
        UITableViewCell* cell = [[UITableViewCell alloc] init];
        
        cell.textLabel.text = @"MARK ALL AS READ";
        
        cell.textLabel.font = [UIFont rockpackFontOfSize: 15.0f];
        
        cell.textLabel.textColor = [UIColor colorWithRed: (40.0f/255.0f)
                                                   green: (45.0f/255.0f)
                                                    blue: (51.0f/255.0f)
                                                   alpha: 1.0f];
        
        UIView* dividerView = [[UIView alloc] initWithFrame: CGRectMake(0.0f, 74.0f, self.tableView.frame.size.width, 2.0f)];
        dividerView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"NavDivider"]];
        [cell addSubview:dividerView];
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        
        return cell;
    }
    
    SYNNotificationsTableViewCell *notificationCell = [tableView dequeueReusableCellWithIdentifier: kNotificationsCellIdent
                                                                                      forIndexPath: indexPath];
    
    SYNRockpackNotification *notification = (SYNRockpackNotification *)_notifications[indexPath.row - (self.hasUnreadNotifications ? 1 : 0)];
    
    NSMutableString *constructedMessage = [[NSMutableString alloc] init];
    
    
    if ([notification.messageType isEqualToString: @"subscribed"])
    {
        [constructedMessage appendFormat: @"%@ ", [notification.channelOwner.displayName uppercaseString]];
        [constructedMessage appendString: NSLocalizedString(@"notification_subscribed_action", nil)];
    }
    else if ([notification.messageType isEqualToString: @"starred"])
    {
        [constructedMessage appendFormat: @"%@ ", [notification.channelOwner.displayName uppercaseString]];
        [constructedMessage appendString: NSLocalizedString(@"notification_liked_action", nil)];
    }
    else if ([notification.messageType isEqualToString: @"joined"])
    {
        
        [constructedMessage appendFormat: NSLocalizedString(@"notification_joined_action", @"Your Facebook friend %@ has joined Rockpack"), [notification.channelOwner.displayName uppercaseString]];
    }
    else if ([notification.messageType isEqualToString: @"repack"])
    {
        [constructedMessage appendFormat: @"%@ ", [notification.channelOwner.displayName uppercaseString]];
        [constructedMessage appendString: NSLocalizedString(@"notification_repack_action", nil)];
    }
    else if ([notification.messageType isEqualToString: @"unavailable"])
    {
        [constructedMessage appendString: NSLocalizedString(@"notification_unavailable_action", nil)];
    }
    else
    {
        // nothing for the moment
    }
    
    notificationCell.messageTitle = [NSString stringWithString: constructedMessage];
    
    NSURL *userThumbnailUrl = [NSURL URLWithString: notification.channelOwner.thumbnailLargeUrl];
    
    [notificationCell.imageView setImageWithURL: userThumbnailUrl
                               placeholderImage: [UIImage imageNamed: @"PlaceholderNotificationAvatar.png"]
                                        options: SDWebImageRetryFailed];
    
    
    // display image on the right side of the cell...
    NSURL *thumbnaillUrl;
    UIImage *placeholder;
    
    notificationCell.playSymbolImageView.hidden = TRUE;

    switch (notification.objectType)
    {
        case kNotificationObjectTypeUserLikedYourVideo:
            thumbnaillUrl = [NSURL URLWithString: notification.videoThumbnailUrl];
            placeholder = [UIImage imageNamed: @"PlaceholderNotificationVideo"];
            
            break;
            
        case kNotificationObjectTypeUserSubscibedToYourChannel:
            thumbnaillUrl = [NSURL URLWithString: notification.channelThumbnailUrl];
            placeholder = [UIImage imageNamed: @"PlaceholderNotificationChannel"];
            break;
            
        case kNotificationObjectTypeFacebookFriendJoined:
            // TODO: Check if Implemented
            break;
            
        case kNotificationObjectTypeUserAddedYourVideo:
            thumbnaillUrl = [NSURL URLWithString: notification.videoThumbnailUrl];
            placeholder = [UIImage imageNamed: @"PlaceholderNotificationVideo"];
            break;
            
        case kNotificationObjectTypeYourVideoNotAvailable:
            if(notification.videoThumbnailUrl) // this should be the case for recent notifaction of this type
            {
                thumbnaillUrl = [NSURL URLWithString: notification.videoThumbnailUrl];
                placeholder = [UIImage imageNamed: @"PlaceholderNotificationVideo"];
            }
            else
            {
                thumbnaillUrl = [NSURL URLWithString: notification.channelThumbnailUrl];
                placeholder = [UIImage imageNamed: @"PlaceholderNotificationVideo"];
            }
            
            break;
            
        default:
            break;
    }
    
    // If we have a righthand image then load it
    if (thumbnaillUrl && placeholder)
    {
        notificationCell.thumbnailImageView.hidden = FALSE;
        
        [notificationCell.thumbnailImageView setImageWithURL: thumbnaillUrl
                                            placeholderImage: placeholder
                                                     options: SDWebImageRetryFailed];
    }
    else
    {
        // Otherwse hide it
        notificationCell.thumbnailImageView.hidden = TRUE;
    }
    
    notificationCell.delegate = self;
    notificationCell.read = notification.read;
    
    notificationCell.detailTextLabel.text = notification.dateDifferenceString;
    
    
    return notificationCell;
}


- (CGFloat) tableView: (UITableView *) tableView
            heightForRowAtIndexPath: (NSIndexPath *) indexPath;
{
    return 77.0f;
}


#pragma mark - Table view delegate

- (void) tableView: (UITableView *) tableView
         didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    if(indexPath.row == 0 && self.hasUnreadNotifications)
    {
        [self.appDelegate.oAuthNetworkEngine markAsReadForNotificationIndexes: @[] // empty array suggests 'all' to the server
                                                                   fromUserId: self.appDelegate.currentUser.uniqueId
                                                            completionHandler: ^(id response) {
                                                                
                                                                for (SYNRockpackNotification* notification in self.notifications)
                                                                {
                                                                    notification.read = YES;
                                                                    
                                                                }
                                                                
                                                                UIApplication.sharedApplication.applicationIconBadgeNumber = 0;
                                                                
                                                                [self.tableView reloadData];
                                                                
                                                                [[NSNotificationCenter defaultCenter]  postNotificationName:kNotificationMarkedRead
                                                                                                                     object:self
                                                                                                                   userInfo:@{@"type":@"all"}];
                                                            } errorHandler: ^(id error) {
                                                                
                                                                
                                                            }];
        
        
        
        return;
    }
    
    [self markAsReadForNotification: _notifications[indexPath.row  - (self.hasUnreadNotifications ? 1 : 0)]];
    
    // Decrement the badge number (min zero)
    UIApplication.sharedApplication.applicationIconBadgeNumber = MAX((UIApplication.sharedApplication.applicationIconBadgeNumber - 1) , 0);
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

-(SYNNotificationsTableViewCell*)getCellFromButton:(UIButton*)button
{
    
    
    UIView* cell = button;
    while (![cell isKindOfClass:[SYNNotificationsTableViewCell class]])
    {
        cell = cell.superview;
    }
    
    
    return (SYNNotificationsTableViewCell*)cell;
}

// this is the user who initialed the action, goes to is profile
- (void) mainImageTableCellPressed: (UIButton *) button
{
    
    SYNNotificationsTableViewCell *cellPressed = [self getCellFromButton:button];
    
    NSIndexPath *indexPathForCellPressed = [self.tableView indexPathForCell: cellPressed];
    
    if (indexPathForCellPressed.row > self.notifications.count)
        return;
    
    SYNRockpackNotification *notification = self.notifications[indexPathForCellPressed.row];
    
    SYNAppDelegate *appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    [appDelegate.viewStackManager viewProfileDetails: notification.channelOwner];
    
    [self markAsReadForNotification: notification];
}


- (void) itemImageTableCellPressed: (UIButton *) button
{
    SYNNotificationsTableViewCell *cellPressed = [self getCellFromButton:button];
    
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
        case kNotificationObjectTypeUserLikedYourVideo:
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
            
        case kNotificationObjectTypeUserSubscibedToYourChannel:
        {
            Channel *channel = [self channelFromChannelId: notification.channelId];
            
            if (!channel)
            {
                return;
            }
            
            [appDelegate.viewStackManager viewChannelDetails: channel];
            break;
        }
            
        case kNotificationObjectTypeFacebookFriendJoined:
        {
            ChannelOwner *channelOwner = notification.channelOwner;
            
            if (!channelOwner)
            {
                return;
            }
            
            [appDelegate.viewStackManager viewProfileDetails: channelOwner];
            break;
        }
            
        case kNotificationObjectTypeUserAddedYourVideo:
        {
            Channel *channel = [self channelFromChannelId: notification.channelId];
            
            if (!channel)
            {
                return;
            }
            if(notification.videoId)
            {
                [appDelegate.viewStackManager viewChannelDetails: channel
                                                  withAutoplayId: notification.videoId];
            }
            else
            {
                [appDelegate.viewStackManager viewChannelDetails: channel
                                                  withAutoplayId: nil];
            }
            break;
        }
            
        case kNotificationObjectTypeYourVideoNotAvailable:
        {
            Channel *channel = [self channelFromChannelId: notification.channelId];
            
            if (!channel)
            {
                return;
            }
            if(notification.videoId)
            {
                [appDelegate.viewStackManager viewChannelDetails: channel
                                                  withAutoplayId: notification.videoId];
            }
            else
            {
                [appDelegate.viewStackManager viewChannelDetails: channel
                                                  withAutoplayId: nil];
            }
            
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
    
    [self.appDelegate.oAuthNetworkEngine markAsReadForNotificationIndexes: array
                                                               fromUserId: self.appDelegate.currentUser.uniqueId
                                                        completionHandler: ^(id response) {
                                                            notification.read = YES;
                                                            
                                                            [self.tableView reloadData];
                                                            
                                                            [[NSNotificationCenter defaultCenter]  postNotificationName: kNotificationMarkedRead
                                                                                                                 object: self
                                                                                                               userInfo:@{@"type":@"one"}];
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
