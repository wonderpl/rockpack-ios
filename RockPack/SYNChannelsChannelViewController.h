//
//  SYNChannelsChannelViewController.h
//  rockpack
//
//  Created by Nick Banks on 01/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

@class Channel;

#import "SYNAbstractTopTabViewController.h"

@interface SYNChannelsChannelViewController : SYNAbstractViewController <UICollectionViewDataSource>

- (id) initWithChannel: (Channel *) channel;

@end
