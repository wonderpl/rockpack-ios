//
//  SYNSubscribersViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 09/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNUsersViewController.h"

@class Channel;
@class SYNMasterViewController;

@interface SYNSubscribersViewController : SYNUsersViewController

@property (nonatomic, weak) Channel* channel;

-(id)initWithChannel:(Channel*)channel;

@end
