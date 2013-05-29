//
//  SYNUserProfileViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 12/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChannelOwner.h"

@protocol SYNUserProfileViewControllerDelegate <NSObject>

- (void) showAvatarPicker;

@end

@interface SYNUserProfileViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIImageView* profileImageView;
@property (nonatomic, strong) IBOutlet UILabel* fullNameLabel;
@property (nonatomic, strong) IBOutlet UILabel* userNameLabel;
@property (nonatomic, weak) ChannelOwner* channelOwner;
@property (nonatomic, weak) id<SYNUserProfileViewControllerDelegate> delegate;

- (void) setChannelOwner: (ChannelOwner*) channelOwner;

@end
