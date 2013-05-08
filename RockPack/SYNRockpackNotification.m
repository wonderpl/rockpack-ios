//
//  SYNRockpackNotification.m
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNRockpackNotification.h"

@implementation SYNRockpackNotification

-(id)initWithNotificationData:(NSDictionary*)data
{
    if(self = [super init])
    {
        self.identifier = [data objectForKey:@"id"];
        if(!self.identifier)
            return nil;
        
        self.messageType = [data objectForKey:@"message_type"];
        
        NSString* dateString = [data objectForKey:@"date_created"];
        if(dateString)
        {
            
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
            
            NSDate* date = [formatter dateFromString:dateString];
            if(date)
            {
                self.dateCreated = date;
            }
            
        }
        
        NSNumber* readNumber = [data objectForKey:@"read"];
        if(readNumber)
        {
            self.read = [readNumber boolValue];
        }
        
        NSDictionary* messageDictionary = [data objectForKey:@"message"];
        if(messageDictionary && [messageDictionary isKindOfClass:[NSDictionary class]])
        {
            NSDictionary* videoDictionary = [messageDictionary objectForKey:@"video"];
            if(videoDictionary && [videoDictionary isKindOfClass:[NSDictionary class]])
            {
                self.videoId = [videoDictionary objectForKey:@"id"];
                self.videoThumbnailUrl = [videoDictionary objectForKey:@"thumbnail_url"];
                
                NSDictionary* channelDictionary = [videoDictionary objectForKey:@"channel"];
                if(channelDictionary && [channelDictionary isKindOfClass:[NSDictionary class]])
                {
                    self.channelId = [channelDictionary objectForKey:@"id"];
                    self.channelResourceUrl = [channelDictionary objectForKey:@"resource_url"];
                }
            }
            
            NSDictionary* userDictionary = [messageDictionary objectForKey:@"user"];
            if(userDictionary && [userDictionary isKindOfClass:[NSDictionary class]])
            {
                self.userId = [userDictionary objectForKey:@"id"];
                self.userResourceUrl = [userDictionary objectForKey:@"resource_url"];
                self.userThumbnailUrl = [userDictionary objectForKey:@"avatar_thumbnail_url"];
                self.userDisplayName = [userDictionary objectForKey:@"display_name"];
            }
        }
    }
    return self;
}

+(id)notificationWithData:(NSDictionary*)data
{
    return [[self alloc] initWithNotificationData:data];
}

@end
