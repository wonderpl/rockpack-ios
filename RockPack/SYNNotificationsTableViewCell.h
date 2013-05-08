//
//  SYNNotificationsTableViewCell.h
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNNotificationsTableViewCell : UITableViewCell {
    CGSize mainTextSize;
    UIView* dividerImageView;
}

@property (nonatomic, strong) UIImageView* thumbnailImageView;
@property (nonatomic, weak) NSString* messageTitle;
@end
