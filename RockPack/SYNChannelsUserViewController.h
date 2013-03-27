//
//  SYNChannelsUserViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 26/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNChannelsRootViewController.h"
#import "ChannelOwner.h"

@interface SYNChannelsUserViewController : SYNChannelsRootViewController {
    ChannelOwner* owner;
}


-(void)fetchUserChannels:(ChannelOwner*)channelOwner;

@end
