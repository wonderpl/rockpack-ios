//
//  SYNChannelsChannelViewController.m
//  rockpack
//
//  Created by Nick Banks on 01/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "Channel.h"
#import "SYNChannelsChannelViewController.h"

@interface SYNChannelsChannelViewController ()

@property (nonatomic, strong) Channel *channel;
@property (nonatomic, strong) NSArray *videos;

@end

@implementation SYNChannelsChannelViewController

- (id) initWithChannel: (Channel *) channel
{
	
	if ((self = [super init]))
    {
		self.channel = channel;
        self.videos = [self.channel.videos allObjects];
	}
    
	return self;
}

@end
