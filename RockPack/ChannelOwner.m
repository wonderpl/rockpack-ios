#import "ChannelOwner.h"
#import "Channel.h"
#import "NSDictionary+Validation.h"
#import "AppConstants.h"



@interface ChannelOwner ()

// Private interface goes here.

@end


@implementation ChannelOwner

#pragma mark - Object factory

+ (ChannelOwner *) instanceFromChannelOwner:(ChannelOwner*)existingChannelOwner
                  usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    if(!existingChannelOwner)
        return nil;
    
    ChannelOwner *instance = [ChannelOwner insertInManagedObjectContext: managedObjectContext];
    
    instance.uniqueId = existingChannelOwner.uniqueId;
    
    instance.thumbnailURL = existingChannelOwner.thumbnailURL;
    
    instance.displayName = existingChannelOwner.displayName;
    
    // no videos
    
    return instance;
}

+ (ChannelOwner *) instanceFromDictionary: (NSDictionary *) dictionary
                usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                      ignoringObjectTypes: (IgnoringObjects) ignoringObjects;
{
    NSError *error = nil;
    
//    if(![dictionary isKindOfClass:[NSDictionary class]])
//        return nil;
    
    NSString *uniqueId = [dictionary objectForKey: @"id"];
    
    
    NSFetchRequest *channelOwnerFetchRequest = [[NSFetchRequest alloc] init];
    [channelOwnerFetchRequest setEntity: [NSEntityDescription entityForName: @"ChannelOwner"
                                                     inManagedObjectContext: managedObjectContext]];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %@", uniqueId];
    [channelOwnerFetchRequest setPredicate: predicate];
    
    NSArray *matchingChannelOwnerEntries = [managedObjectContext executeFetchRequest: channelOwnerFetchRequest
                                                                               error: &error];
    ChannelOwner *instance;
    
    if (matchingChannelOwnerEntries.count > 0)
        instance = matchingChannelOwnerEntries[0];
    else
        instance = [ChannelOwner insertInManagedObjectContext: managedObjectContext];
        
    
    [instance setAttributesFromDictionary: dictionary
                                   withId: uniqueId
                usingManagedObjectContext: managedObjectContext
                      ignoringObjectTypes: ignoringObjects];
    
    
    return instance;
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                              withId: (NSString *) uniqueId
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContex
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects {
    
    
    // Is we are not actually a dictionary, then bail
    if (![dictionary isKindOfClass: [NSDictionary class]])
    {
        AssertOrLog (@"setAttributesFromDictionary: not a dictionary, unable to construct object");
        return;
    }
    
    // Simple objects
    self.uniqueId = uniqueId;
    
    self.thumbnailURL = [dictionary objectForKey: @"avatar_thumbnail_url"
                                     withDefault: @"http://localhost"];
    
    self.displayName = [dictionary upperCaseStringForKey: @"display_name"
                                             withDefault: @""];
    
    
    BOOL hasChannels = YES;
    
    if(!(ignoringObjects & kIgnoreChannelObjects))
    {
        
        
        NSDictionary* channelsDictionary = [dictionary objectForKey:@"channels"];
        if([channelsDictionary isKindOfClass:[NSNull class]])
        {
            
            hasChannels = NO;
        }
        
        
        
        NSArray* channelItemsArray = [channelsDictionary objectForKey:@"items"];
        if([channelItemsArray isKindOfClass:[NSNull class]])
        {
   
            hasChannels = NO;
        }
        
        NSOrderedSet* oldUserChannels = [NSOrderedSet orderedSetWithOrderedSet:self.channels];
        
        
        if(hasChannels)
        {
            [self.channelsSet removeAllObjects];
            
            for (NSDictionary* channelDictionary in channelItemsArray)
            {
                
                Channel* channel = [Channel instanceFromDictionary: channelDictionary
                                         usingManagedObjectContext: managedObjectContex
                                               ignoringObjectTypes: kIgnoreChannelOwnerObject];
                
                if(!channel)
                    continue;
                
                [self.channelsSet addObject:channel];
                
            }
        }
        
        // restore the link
        
        [oldUserChannels enumerateObjectsUsingBlock:^(Channel* channel, NSUInteger idx, BOOL *stop) {
            channel.channelOwner = self;
        }];
    }
    
    
    
}

#pragma mark - Channels

-(void)addSubscriptionsDictionary:(NSDictionary *)subscriptionsDictionary
{
    NSDictionary* channeslDictionary = [subscriptionsDictionary objectForKey: @"channels"];
    if (!channeslDictionary)
        return;
    
    NSArray* itemsArray = [channeslDictionary objectForKey: @"items"];
    if (!itemsArray)
        return;
    
    
    [self.subscriptionsSet removeAllObjects];
    
    for (NSDictionary* subscriptionChannel in itemsArray)
    {
        
        // must use the main context so as to be able to link it with the channel owner
        
        Channel* channel = [Channel instanceFromDictionary: subscriptionChannel
                                 usingManagedObjectContext: self.managedObjectContext
                                       ignoringObjectTypes: kIgnoreNothing];
        
        if (!channel)
            continue;
        
        
        [self addSubscriptionsObject:channel];
        
    }
}

-(void)addChannelsObject:(Channel *)newChannel
{
    [self.channelsSet addObject:newChannel];
}
-(void)removeChannelsObject:(Channel *)oldChannel
{
    [self.channelsSet removeObject:oldChannel];
}


-(void)addSubscriptionsObject:(Channel *)newSubscription
{
    [self.subscriptionsSet addObject:newSubscription];
    newSubscription.subscribersCountValue += 1;
}
-(void)removeSubscriptionsObject:(Channel *)oldSubscription
{
    [self.subscriptionsSet removeObject:oldSubscription];
    oldSubscription.subscribersCountValue -= 1;
}

#pragma mark - Helper methods

-(NSDictionary*) channelsDictionary
{
    NSMutableDictionary* cDictionary = [NSMutableDictionary dictionary];
    for (Channel *channel in self.channels) {
        [cDictionary setObject:channel forKey:channel.uniqueId];
    }
    return [NSDictionary dictionaryWithDictionary:cDictionary];
}

- (NSString *) description
{
    
    
    NSMutableString* ownerDescription = [NSMutableString stringWithFormat:@"User (%i) - username: '%@'", [self.uniqueId intValue], self.displayName];
    
    [ownerDescription appendFormat:@"\nUser Channels (%i)", self.channels.count];
    
    if(self.channels.count == 0) {
        [ownerDescription appendString:@"."];
    } else {
        [ownerDescription appendString:@":"];
        for (Channel* channel in self.channels)
            [ownerDescription appendFormat:@"\n - %@ (%@)", channel.title, [channel.subscribedByUser boolValue] ? @"Subscribed" : @"-"];
        
    }
    
    return ownerDescription;
}


@end
