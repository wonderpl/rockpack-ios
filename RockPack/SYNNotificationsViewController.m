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
    //[self.view addSubview:self.logoImageView];

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
    
    NSURL* userThumbnailUrl = [NSURL URLWithString:notification.userThumbnailUrl];
    [notificationCell.imageView setAsynchronousImageFromURL:userThumbnailUrl
                                           placeHolderImage:[UIImage imageNamed:@"AvatarProfile"]];
    NSURL* thumbnaillUrl;
    if([notification.messageType isEqualToString:@"starred"])
    {
        thumbnaillUrl = [NSURL URLWithString:notification.videoThumbnailUrl];
        
    }
    else
    {
        thumbnaillUrl = [NSURL URLWithString:notification.channelThumbnailUrl];
        
    }
    
    // NSLog(@"%@", thumbnaillUrl);
     
    
    [notificationCell.thumbnailImageView setAsynchronousImageFromURL: thumbnaillUrl
                                                    placeHolderImage: [UIImage imageNamed:@""]];
    
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
        CGRect tableViewFrame = self.tableView.frame;
        CGRect logoImageViewFrame = self.logoImageView.frame;
        logoImageViewFrame.origin.y = tableViewFrame.size.height + 4.0;
        self.logoImageView.frame = logoImageViewFrame;
    }
}

#pragma mark - Accessors

-(void)setNotifications:(NSArray *)notifications
{
    _notifications = notifications;
    [self.tableView reloadData];
}

@end
