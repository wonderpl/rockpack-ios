//
//  SYNRockpackNotification.m
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNRockpackNotification.h"
#import "SYNAppDelegate.h"

@implementation SYNRockpackNotification

@synthesize objectType;

-(id)initWithNotificationData:(NSDictionary*)data
{
    if(self = [super init])
    {
        SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
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
            
            // the response can either have a channel tag or a video tag, in the second case the video tag will include a channel tag //
            
            NSDictionary* channelDictionary = [messageDictionary objectForKey:@"channel"];
            if(channelDictionary && [channelDictionary isKindOfClass:[NSDictionary class]])
            {
                
                objectType = kNotificationObjectTypeChannel;
                self.channelId = [channelDictionary objectForKey:@"id"];
                self.channelResourceUrl = [channelDictionary objectForKey:@"resource_url"];
                self.channelThumbnailUrl = [channelDictionary objectForKey:@"thumbnail_url"];
            }
            
            
            NSDictionary* videoDictionary = [messageDictionary objectForKey:@"video"];
            if(videoDictionary && [videoDictionary isKindOfClass:[NSDictionary class]])
            {
                objectType = kNotificationObjectTypeVideo;
                self.videoId = [videoDictionary objectForKey:@"id"];
                self.videoThumbnailUrl = [videoDictionary objectForKey:@"thumbnail_url"];
                
                NSDictionary* channelDictionary = [videoDictionary objectForKey:@"channel"];
                if(channelDictionary && [channelDictionary isKindOfClass:[NSDictionary class]])
                {
                    self.channelId = [channelDictionary objectForKey:@"id"];
                    self.channelResourceUrl = [channelDictionary objectForKey:@"resource_url"];
                    self.channelThumbnailUrl = [channelDictionary objectForKey:@"thumbnail_url"];
                }
            }
            
            NSDictionary* userDictionary = [messageDictionary objectForKey:@"user"];
            if(userDictionary && [userDictionary isKindOfClass:[NSDictionary class]])
            {
                
                self.channelOwner = [ChannelOwner instanceFromDictionary:userDictionary
                                               usingManagedObjectContext:appDelegate.mainManagedObjectContext
                                                     ignoringObjectTypes:kIgnoreChannelObjects];
            }
        }
    }
    return self;
}

+(id)notificationWithData:(NSDictionary*)data
{
    return [[self alloc] initWithNotificationData:data];
}

-(NSString*)description
{
    NSMutableString* descriptionToReturn = [[NSMutableString alloc] init];
    [descriptionToReturn appendFormat:@"<SYNRockpackNotification: %p", self];
    [descriptionToReturn appendFormat:@" channelOwner: %@", self.channelOwner.uniqueId];
    [descriptionToReturn appendString:@">"];
    return descriptionToReturn;
}
@end
