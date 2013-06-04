//
//  SYNRockpackNotification.m
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNRockpackNotification.h"
#import "SYNAppDelegate.h"
#import "NSDate+RFC1123.h"
#import "ISO8601DateFormatter.h"
#import "AppConstants.h"

@implementation SYNRockpackNotification

@synthesize objectType;

-(id)initWithNotificationData:(NSDictionary*)data
{
    if(self = [super init])
    {
        SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        NSNumber* identifierNumber = [data objectForKey:@"id"];
        if(!identifierNumber || ![identifierNumber isKindOfClass:[NSNumber class]])
        {
            NSLog(@"Did not find a valid notification id: %@", data);
            return nil;
        }
        
        
        self.identifier = [identifierNumber integerValue];
        
        self.messageType = [data objectForKey:@"message_type"];
        
        NSString* dateString = [data objectForKey:@"date_created"];
        if(dateString)
        {
            
            
            ISO8601DateFormatter* formatter = [[ISO8601DateFormatter alloc] init];
            
            NSDate* date = [formatter dateFromString:dateString];

            if(date)
            {
                self.dateCreated = date;
                
                // find difference from today
                
                NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
                NSInteger seconds = [timeZone secondsFromGMTForDate: date];
                date = [NSDate dateWithTimeInterval: seconds sinceDate: date];
                
                
                NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSUInteger componentflags =
                NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit;
                NSDateComponents *components = [calendar components:componentflags
                                                           fromDate:self.dateCreated
                                                             toDate:[NSDate date]
                                                            options:0];
                
                NSMutableString* dateDifferenceMutableString = [[NSMutableString alloc] init];
                
                if(components.year > 0)
                {
                    [dateDifferenceMutableString appendString:@"More than a year ago"];
                }
                else if(components.month > 0)
                {
                    [dateDifferenceMutableString appendString:[NSString stringWithFormat:@"%i month%@", components.month, (components.month > 1 ? @"s" : @"")]];
                    
                    if(components.day > 0)
                    {
                        [dateDifferenceMutableString appendString:[NSString stringWithFormat:@" and %i day%@ ago", components.day, (components.day > 1 ? @"s" : @"")]];
                    }
                    
                    
                }
                else if(components.day > 0)
                {
                    [dateDifferenceMutableString appendString:[NSString stringWithFormat:@"%i day%@", components.day, (components.day > 1 ? @"s" : @"")]];
                    
                    if(components.hour > 0)
                    {
                        [dateDifferenceMutableString appendString:[NSString stringWithFormat:@" and %i hour%@ ago", components.hour, (components.hour > 1 ? @"s" : @"")]];
                    }
                    
                }
                else if(components.hour > 0)
                {
                    [dateDifferenceMutableString appendString:[NSString stringWithFormat:@"%i hour%@", components.hour, (components.hour > 1 ? @"s" : @"")]];
                    
                    if(components.minute > 0)
                    {
                        [dateDifferenceMutableString appendString:[NSString stringWithFormat:@" and %i minute%@ ago", components.minute, (components.minute > 1 ? @"s" : @"")]];
                    }
                    
                }
                else
                {
                    [dateDifferenceMutableString appendString:[NSString stringWithFormat:@"%i minute%@ ago", components.minute, (components.minute > 1 ? @"s" : @"")]];
                }
                
                
                self.dateDifferenceString = [NSString stringWithString:dateDifferenceMutableString];
                
            }
            else
            {
                self.dateDifferenceString = dateString;
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
            
            // case 1 : Channel Tag
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
                
                NSLog(@"self.videoThumbnailUrl: %@", self.videoThumbnailUrl);
                
                NSDictionary* channelDictionary = [videoDictionary objectForKey:@"channel"];
                if(channelDictionary && [channelDictionary isKindOfClass:[NSDictionary class]])
                {
                    self.channelId = [channelDictionary objectForKey:@"id"];
                    self.channelResourceUrl = [channelDictionary objectForKey:@"resource_url"];
                    // no thumbnail url in case of a channel object within a video object
                    
                }
            }
            
            NSDictionary* userDictionary = [messageDictionary objectForKey:@"user"];
            if(userDictionary && [userDictionary isKindOfClass:[NSDictionary class]])
            {
                
                self.channelOwner = [ChannelOwner instanceFromDictionary:userDictionary
                                               usingManagedObjectContext:appDelegate.mainManagedObjectContext
                                                     ignoringObjectTypes:kIgnoreChannelObjects];
                
                self.channelOwner.viewId = kSideNavigationViewId;
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
    [descriptionToReturn appendFormat:@"<SYNRockpackNotification: %p (%i", self, self.identifier];
    [descriptionToReturn appendFormat:@" channelOwner: %@)", self.channelOwner.uniqueId];
    [descriptionToReturn appendString:@">"];
    return descriptionToReturn;
}
@end
