//
//  SYNYouRootViewController.h
//  rockpack
//
//  Created by Nick Banks on 24/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAbstractViewController.h"
#import "ChannelOwner.h"

@interface SYNProfileRootViewController : SYNAbstractViewController


@property (nonatomic, weak) ChannelOwner* user;

@end
