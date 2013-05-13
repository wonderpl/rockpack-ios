//
//  SYNRockpackNotification.h
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface SYNRockpackNotification : NSObject

@property (nonatomic) NSInteger identifier;
@property (nonatomic, strong) NSString* messageType;
@property (nonatomic, strong) NSDate* dateCreated;
@property (nonatomic) BOOL read;

// Video Message

@property (nonatomic, strong) NSString* videoId;
@property (nonatomic, strong) NSString* videoThumbnailUrl;

@property (nonatomic, strong) NSString* channelId;
@property (nonatomic, strong) NSString* channelResourceUrl;
@property (nonatomic, strong) NSString* channelThumbnailUrl;

// User Data

@property (nonatomic, strong) NSString* userId;
@property (nonatomic, strong) NSString* userDisplayName;
@property (nonatomic, strong) NSString* userThumbnailUrl;

@property (nonatomic, strong) ChannelOwner* channelOwner;

@property (nonatomic, strong) Channel* channel;



@property (nonatomic) NSInteger timeElapsesd;

-(id)initWithNotificationData:(NSDictionary*)data;
+(id)notificationWithData:(NSDictionary*)data;

@end
