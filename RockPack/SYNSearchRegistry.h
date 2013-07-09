//
//  SYNSearchRegistry.h
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNRegistry.h"
#import "ChannelOwner.h"

@interface SYNSearchRegistry : SYNRegistry

- (BOOL) registerVideosFromDictionary: (NSDictionary *) dictionary;
- (BOOL) registerChannelsFromDictionary: (NSDictionary *) dictionary;
-(BOOL)registerUsersFromDictionary:(NSDictionary *)dictionary;

@end
