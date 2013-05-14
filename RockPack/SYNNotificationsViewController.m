//
//  SYNNotificationsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAppDelegate.h"
#import "SYNNotificationsTableViewCell.h"
#import "SYNNotificationsViewController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNRockpackNotification.h"
#import "UIImageView+WebCache.h"
#import "Video.h"

#define kNotificationsCellIdent @"kNotificationsCellIdent"

@interface SYNNotificationsViewController ()


@property (nonatomic, weak) SYNAppDelegate* appDelegate;
@property (nonatomic, strong) UIImageView* logoImageView;
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

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    self.logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoNotifications"]];
    // self.logoImageView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.logoImageView];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[SYNNotificationsTableViewCell class] forCellReuseIdentifier:kNotificationsCellIdent];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tableView removeObserver:self forKeyPath:@"contentSize"];
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
    
    NSMutableString* constructedMessage = [[NSMutableString alloc] init];
    [constructedMessage appendFormat:@"%@", [notification.channelOwner.displayName uppercaseString]];
    [constructedMessage appendString:@" has "];
    [constructedMessage appendFormat:@"%@", notification.messageType];
    if([notification.messageType isEqualToString:@"subscribed"])
        [constructedMessage appendString:@" to your channel"];
    else
        [constructedMessage appendString:@" your video"];
    
    
    
    notificationCell.messageTitle = [NSString stringWithString:constructedMessage];
    
    NSURL* userThumbnailUrl = [NSURL URLWithString:notification.channelOwner.thumbnailURL];
    
    [notificationCell.imageView setImageWithURL: userThumbnailUrl
                     placeholderImage: [UIImage imageNamed:@"AvatarProfile"]
                              options: SDWebImageRetryFailed];
    
    
    NSURL* thumbnaillUrl;
    if(notification.objectType == kNotificationObjectTypeVideo)
    {
        thumbnaillUrl = [NSURL URLWithString:notification.videoThumbnailUrl];
        
    }
    else
    {
        thumbnaillUrl = [NSURL URLWithString:notification.channelThumbnailUrl];
        
    }
    
    [notificationCell.thumbnailImageView setImageWithURL: thumbnaillUrl
                                        placeholderImage: [UIImage imageNamed:@"AvatarProfile"]
                                                 options: SDWebImageRetryFailed];
    
    notificationCell.delegate = self;
    
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

-(void)mainImageTableCellPressed:(UIButton*)button
{
    SYNNotificationsTableViewCell* cellPressed = (SYNNotificationsTableViewCell*)button.superview;
    
    NSIndexPath* indexPathForCellPressed = [self.tableView indexPathForCell:cellPressed];
    
    SYNRockpackNotification* notification = self.notifications[indexPathForCellPressed.row];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kProfileRequested
                                                        object:self
                                                      userInfo:@{kChannelOwner:notification.channelOwner}];
    
}
-(void)itemImageTableCellPressed:(UIButton*)button
{
    SYNNotificationsTableViewCell* cellPressed = (SYNNotificationsTableViewCell*)button.superview;
    
    NSIndexPath* indexPathForCellPressed = [self.tableView indexPathForCell:cellPressed];
    
    SYNRockpackNotification* notification = self.notifications[indexPathForCellPressed.row];
    
    if(notification.objectType == kNotificationObjectTypeVideo)
    {
        Channel* channel = [self channelFromChannelId:notification.channelId];
        
        if(!channel)
            return;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kChannelDetailsRequested
                                                            object:self
                                                          userInfo:@{kChannel:channel}];
    }
    else
    {
        Channel* channel = [self channelFromChannelId:notification.channelId];
        
        if(!channel)
            return;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kChannelDetailsRequested
                                                            object:self
                                                          userInfo:@{kChannel:channel}];
    }
    
    
    
}

#pragma mark - Accessors

-(void)setNotifications:(NSArray *)notifications
{
    _notifications = notifications;
    [self.tableView reloadData];
}

-(Video*)videoFromVideoId:(NSString*)videoId
{
    Video* video;
    
    NSEntityDescription* channelEntity = [NSEntityDescription entityForName:@"Video"
                                                     inManagedObjectContext:appDelegate.mainManagedObjectContext];
    
    NSFetchRequest *channelFetchRequest = [[NSFetchRequest alloc] init];
    [channelFetchRequest setEntity: channelEntity];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %@", videoId];
    
    [channelFetchRequest setPredicate: predicate];
    
    NSError* error;
    
    NSArray *matchingChannelEntries = [appDelegate.mainManagedObjectContext executeFetchRequest: channelFetchRequest
                                                                                          error: &error];
    
    
    if (matchingChannelEntries.count > 0)
    {
        video = matchingChannelEntries[0];
        
    }
    else
    {
        
    }
    
    return video;
}

-(Channel*)channelFromChannelId:(NSString*)channelId
{
    Channel* channel;
    
    NSEntityDescription* channelEntity = [NSEntityDescription entityForName:@"Channel"
                                                         inManagedObjectContext:appDelegate.mainManagedObjectContext];
    
    NSFetchRequest *channelFetchRequest = [[NSFetchRequest alloc] init];
    [channelFetchRequest setEntity: channelEntity];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %@", channelId];
    
    [channelFetchRequest setPredicate: predicate];
    
    NSError* error;
    
    NSArray *matchingChannelEntries = [appDelegate.mainManagedObjectContext executeFetchRequest: channelFetchRequest
                                                                                          error: &error];
    
    
    if (matchingChannelEntries.count > 0)
    {
        channel = matchingChannelEntries[0];
                
    }
    
    return channel;
}
@end
