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
                                            ignoringObjectTypes:ignoringObjects | kIgnoreChannelOwnerObject];
            
            NSLog(@"Copied channel %@", copyChannel.uniqueId);
            
            [copyChannelOwner.channelsSet addObject:copyChannel];
            
        }
    }
    
    
    if(!(ignoringObjects & kIgnoreSubscriptionObjects))
    {
        for (Channel* channel in existingChannelOwner.subscriptions)
        {
            Channel* copyChannel = [Channel instanceFromChannel:channel
                                                      andViewId:viewId
                                      usingManagedObjectContext:existingChannelOwner.managedObjectContext
                                            ignoringObjectTypes:ignoringObjects];
            
            
            [copyChannelOwner.subscriptionsSet addObject:copyChannel];
            
        }
    }
    
    
    
    return copyChannelOwner;
}

+ (ChannelOwner *) instanceFromDictionary: (NSDictionary *) dictionary
                usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                      ignoringObjectTypes: (IgnoringObjects) ignoringObjects;
{
    
    
    if(!dictionary || ![dictionary isKindOfClass:[NSDictionary class]])
        return nil;
    
    NSString *uniqueId = [dictionary objectForKey: @"id"];
    if([uniqueId isKindOfClass:[NSNull class]])
        return nil;
    
    ChannelOwner *instance = [ChannelOwner insertInManagedObjectContext: managedObjectContext];
    
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
    NSString* n_username = [dictionary objectForKey: @"username"];
    self.username = n_username ? n_username : self.username;
    
    
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
            
        
        
        NSString *newUniqueId;
        
        for (NSDictionary* channelDictionary in channelItemsArray)
        {
            Channel* channel;
            
            newUniqueId = [channelDictionary objectForKey: @"id" withDefault: @""];
            
            channel = [channelInsanceByIdDictionary objectForKey:newUniqueId];
            
            IgnoringObjects ignoreInstantiationFlags = 
            ignoringObjects | kIgnoreChannelOwnerObject;
            
            if(!channel)
            {
                channel = [Channel instanceFromDictionary: channelDictionary
                                usingManagedObjectContext: self.managedObjectContext
                                      ignoringObjectTypes: ignoreInstantiationFlags];
                
                if(!channel) // instantiation failed
                    continue;
                
                channel.viewId = self.viewId;
                
                [self.channelsSet addObject:channel];
                
            }
            else
            {
                [channelInsanceByIdDictionary removeObjectForKey:newUniqueId];
                
              
                [channel setAttributesFromDictionary:channelDictionary
                                 ignoringObjectTypes:ignoreInstantiationFlags];
            }
           
            
            
            
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

-(void)setSubscriptionsDictionary:(NSDictionary *)subscriptionsDictionary
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
    
    
    
    
    for (NSDictionary* subscriptionChannel in itemsArray)
    {
        
        NSString *uniqueId = [subscriptionChannel objectForKey: @"id"];
        if(!uniqueId || ![uniqueId isKindOfClass:[NSString class]])
            continue;
        
        Channel* channel = [subscriptionInsancesByIdDictionary objectForKey:uniqueId];
        
        if(!channel)
        {
            channel = [Channel instanceFromDictionary: subscriptionChannel
                            usingManagedObjectContext: self.managedObjectContext
                                  ignoringObjectTypes: kIgnoreVideoInstanceObjects];
            
            if (!channel)
                continue;
            
            channel.viewId = self.viewId;
            
            [self addSubscriptionsObject:channel];
        }
        else
        {
            [subscriptionInsancesByIdDictionary removeObjectForKey:uniqueId];
        }
        
        
        
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


#pragma mark - Accessors

-(void)addSubscriptionsObject:(Channel *)value_
{
    [self.subscriptionsSet addObject:value_];
}
-(void)removeSubscriptions:(NSOrderedSet *)value_
{
    [self.subscriptionsSet removeObject:value_];
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

- (NSString*) thumbnailSmallUrl
{
    return [self.thumbnailURL stringByReplacingOccurrencesOfString: kImageSizeStringReplace
                                                        withString: @"thumbnail_small"];
}


- (NSString*) thumbnailMediumUrl
{
    return self.thumbnailURL; // by default it is set for medium
}


- (NSString*) thumbnailLargeUrl
{
    return [self.thumbnailURL stringByReplacingOccurrencesOfString: kImageSizeStringReplace
                                                        withString: @"thumbnail_large"];
}

@end
