//
//  SYNActivityManager.h
//  rockpack
//
//  Created by Nick Banks on 25/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Video, Channel;

@interface SYNActivityManager : NSObject

+ (id) sharedInstance;
- (void) updateActivityForCurrentUser;
- (void) updateActivityForVideo: (Video *) video;
- (void) updateSubscriptionForChannel: (Channel *) channel;

@end
