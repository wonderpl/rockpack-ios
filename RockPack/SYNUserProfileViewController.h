//
//  SYNUserProfileViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 12/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChannelOwner.h"


@interface SYNUserProfileViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIImageView* profileImageView;
@property (nonatomic, strong) IBOutlet UILabel* fullNameLabel;
@property (nonatomic, strong) IBOutlet UILabel* userNameLabel;
@property (nonatomic, weak) ChannelOwner* channelOwner;

- (void) setChannelOwner: (ChannelOwner*) channelOwner;

@end
