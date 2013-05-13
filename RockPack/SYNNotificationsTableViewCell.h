//
//  SYNNotificationsTableViewCell.h
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYNNotificationsViewController;

@interface SYNNotificationsTableViewCell : UITableViewCell {
    CGSize mainTextSize;
    UIView* dividerImageView;
    SYNNotificationsViewController* delegate;
    CGRect imageViewRect;
    UIButton* mainImageButton;
    UIButton* secondaryImageButton;
    
}

@property (nonatomic, strong) UIImageView* thumbnailImageView;
@property (nonatomic, weak) NSString* messageTitle;
@property (nonatomic, weak) SYNNotificationsViewController* delegate;
@end
