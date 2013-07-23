//
//  SYNNotificationsTableViewCell.h
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYNNotificationsTableViewController;

@interface SYNNotificationsTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, weak) NSString *messageTitle;
@property (nonatomic, weak) SYNNotificationsTableViewController *delegate;
@property (nonatomic) BOOL read;

@end
