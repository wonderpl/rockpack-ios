#import "ChannelOwner.h"
#import "Channel.h"
#import "NSDictionary+Validation.h"
#import "AppConstants.h"



@interface ChannelOwner ()

// Private interface goes here.

@end


@implementation ChannelOwner

#pragma mark - Object factory

+ (ChannelOwner *) instanceFromChannelOwner: (ChannelOwner*)existingChannelOwner
                                  andViewId: (NSString*)viewId
                  usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                        ignoringObjectTypes: (IgnoringObjects) ignoringObjects
{
    if(!existingChannelOwner)
        return nil;
    
    
    ChannelOwner *copyChannelOwner = [ChannelOwner insertInManagedObjectContext: managedObjectContext];
    
    copyChannelOwner.uniqueId = existingChannelOwner.uniqueId;
    
    copyChannelOwner.thumbnailURL = existingChannelOwner.thumbnailURL;
    
    copyChannelOwner.displayName = existingChannelOwner.displayName;
    
    copyChannelOwner.viewId = viewId;
    
    if(!(ignoringObjects & kIgnoreChannelObjects))
    {
        for (Channel* channel in existingChannelOwner.channels)
        {
            Channel* copyChannel = [Channel instanceFromChannel:channel
                                                      andViewId:viewId
                                      usingManagedObjectContext:existingChannelOwner.managedObjectContext
                                            ignoringObjectTypes:ignoringObjects];
            
            
            [copyChannelOwner.channelsSet addObject:copyChannel];
            
        }
    }
    
    
    
    return copyChannelOwner;
}

+ (ChannelOwner *) instanceFromDictionary: (NSDictionary *) dictionary
                usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                      ignoringObjectTypes: (IgnoringObjects) ignoringObjects;
{
    NSError *error = nil;
    
    if(!dictionary || ![dictionary isKindOfClass:[NSDictionary class]])
        return nil;
    
    NSString *uniqueId = [dictionary objectForKey: @"id"];
    if([uniqueId isKindOfClass:[NSNull class]])
        return nil;
    
    ChannelOwner *instance;
    
    if(!(ignoringObjects & kIgnoreStoredObjects))
    {
        NSFetchRequest *channelOwnerFetchRequest = [[NSFetchRequest alloc] init];
        [channelOwnerFetchRequest setEntity: [NSEntityDescription entityForName: @"ChannelOwner"
                                                         inManagedObjectContext: managedObjectContext]];
        
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %@", uniqueId];
        [channelOwnerFetchRequest setPredicate: predicate];
        
        NSArray *matchingChannelOwnerEntries = [managedObjectContext executeFetchRequest: channelOwnerFetchRequest
                                                                                   error: &error];
        
        if (matchingChannelOwnerEntries.count > 0)
        {
            instance = matchingChannelOwnerEntries[0];
        }
            
        
    }
    
    
    if(!instance)
    {
        instance = [ChannelOwner insertInManagedObjectContext: managedObjectContext];
    }
    
    instance.uniqueId = uniqueId;
        
    
    [instance setAttributesFromDictionary: dictionary
                      ignoringObjectTypes: ignoringObjects];
    
    
    return instance;
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects {
    
    
    // Is we are not actually a dictionary, then bail
    if (![dictionary isKindOfClass: [NSDictionary class]])
    {
        AssertOrLog (@"setAttributesFromDictionary: not a dictionary, unable to construct object");
        return;
    }
    
    // Simple objects
    
    
    self.thumbnailURL = [dictionary objectForKey: @"avatar_thumbnail_url"
                                     withDefault: @"http://localhost"];
    
    self.displayName = [dictionary upperCaseStringForKey: @"display_name"
                                             withDefault: @""];
    
    
    BOOL hasChannels = YES;
    
    NSDictionary* channelsDictionary = [dictionary objectForKey:@"channels"];
    if([channelsDictionary isKindOfClass:[NSNull class]])
        hasChannels = NO;
    
    NSArray* channelItemsArray = [channelsDictionary objectForKey:@"items"];
    if([channelItemsArray isKindOfClass:[NSNull class]])
        hasChannels = NO;
    
    if(!(ignoringObjects & kIgnoreChannelObjects) && hasChannels)
    {
        
        // viewId is @"Profile" because this is the only place it is passed
        
        NSMutableDictionary* channelInsanceByIdDictionary = [[NSMutableDictionary alloc] initWithCapacity:self.channels.count];
        
        for (Channel* ch in self.channels)
            [channelInsanceByIdDictionary setObject:ch forKey:ch.uniqueId];
            
        
        [self.channelsSet removeAllObjects];
        
        
        NSString *newUniqueId;
        
        for (NSDictionary* channelDictionary in channelItemsArray)
        {
            Channel* channel;
            
            newUniqueId = [channelDictionary objectForKey: @"id" withDefault: @""];
            
            channel = [channelInsanceByIdDictionary objectForKey:newUniqueId];
            
            if(!channel)
            {
                channel = [Channel instanceFromDictionary: channelDictionary
                                usingManagedObjectContext: self.managedObjectContext
                                      ignoringObjectTypes: ignoringObjects | kIgnoreStoredObjects | kIgnoreChannelOwnerObject];
                
                
            }
            else
            {
                [channelInsanceByIdDictionary removeObjectForKey:newUniqueId];
            }
           
            
            if(!channel)
                continue;
            
            channel.viewId = self.viewId;
            
            channel.markedForDeletionValue = NO;
            
            channel.position = [dictionary objectForKey: @"position"
                                            withDefault: [NSNumber numberWithInt: 0]];
            
            
            
            [self.channelsSet addObject:channel];
            
        }
        
        
        for (id key in channelInsanceByIdDictionary)
        {
            Channel* ch = [channelInsanceByIdDictionary objectForKey:key];
            if(!ch)
                continue;
            
            [self.managedObjectContext deleteObject:ch];
            
        }
        
        
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
    
    NSMutableDictionary* subscriptionInsancesByIdDictionary = [[NSMutableDictionary alloc] initWithCapacity:self.subscriptions.count];
    
    for (Channel* su in self.subscriptions)
        [subscriptionInsancesByIdDictionary setObject:su forKey:su.uniqueId];
    
    
    
    [self.subscriptionsSet removeAllObjects];
    
    for (NSDictionary* subscriptionChannel in itemsArray)
    {
        
        // must use the main context so as to be able to link it with the channel owner
        
        Channel* channel = [Channel instanceFromDictionary: subscriptionChannel
                                 usingManagedObjectContext: self.managedObjectContext
                                       ignoringObjectTypes: kIgnoreStoredObjects | kIgnoreChannelOwnerObject | kIgnoreVideoInstanceObjects];
        
        if (!channel)
            continue;
        
        
        [self.subscriptionsSet addObject:channel];
        channel.subscribedByUserValue = YES;
        
        
    }
    
    for (id key in subscriptionInsancesByIdDictionary)
    {
        Channel* su = [subscriptionInsancesByIdDictionary objectForKey:key];
        if(!su)
            continue;
        
        [self.managedObjectContext deleteObject:su];
        
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
