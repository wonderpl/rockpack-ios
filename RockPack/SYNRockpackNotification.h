//
//  SYNRockpackNotification.h
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

typedef enum {
    kNotificationObjectTypeVideo = 0,
    kNotificationObjectTypeChannel = 1

} kNotificationObjectType;

@interface SYNRockpackNotification : NSObject

@property (nonatomic) NSInteger identifier;
@property (nonatomic, strong) NSString* messageType;
@property (nonatomic, strong) NSDate* dateCreated;
@property (nonatomic, strong) NSString* dateDifferenceString;
@property (nonatomic) BOOL read;

@property (nonatomic, readonly) kNotificationObjectType objectType;

// Video Message

@property (nonatomic, strong) NSString* videoId;
@property (nonatomic, strong) NSString* videoThumbnailUrl;

@property (nonatomic, strong) NSString* channelId;
@property (nonatomic, strong) NSString* channelResourceUrl;
@property (nonatomic, strong) NSString* channelThumbnailUrl;

// User Data

@property (nonatomic, strong) ChannelOwner* channelOwner;

@property (nonatomic, strong) Channel* channel;



@property (nonatomic) NSInteger timeElapsesd;

-(id)initWithNotificationData:(NSDictionary*)data;
+(id)notificationWithData:(NSDictionary*)data;

@end
