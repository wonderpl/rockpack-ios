//
//  SYNUserTabViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 18/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNTabViewController.h"
#import "User.h"
#import "ChannelOwner.h"

@interface SYNUserTabViewController : SYNTabViewController

@property (nonatomic, weak) ChannelOwner* owner;

@end
