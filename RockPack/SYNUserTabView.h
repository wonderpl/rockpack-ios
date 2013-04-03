//
//  SYNUserTabView.h
//  rockpack
//
//  Created by Michael Michailidis on 26/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNTabView.h"
#import "ChannelOwner.h"
#import "User.h"

@interface SYNUserTabView : SYNTabView

-(void)showOwnerData:(ChannelOwner*)user;
-(void)showUserData:(User*)nuser;

@end
