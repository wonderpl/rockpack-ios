//
//  SYNInviteFriendView.h
//  rockpack
//
//  Created by Michael Michailidis on 23/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friend.h"

@interface SYNInviteFriendView : UIView

@property (nonatomic, weak) Friend* friend;


@property (nonatomic, strong) IBOutlet UIImageView* profileImageView;
@property (nonatomic, strong) IBOutlet UIButton* inviteButton;
@property (nonatomic, strong) IBOutlet UILabel* titleLabel;

@end
