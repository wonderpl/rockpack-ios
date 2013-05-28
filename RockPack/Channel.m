#import "Channel.h"
#import "ChannelOwner.h"
#import "ChannelCover.h"
#import "NSDictionary+Validation.h"
#import "VideoInstance.h"
#import "AppConstants.h"
#import "SYNAppDelegate.h"


@interface Channel ()

// Private interface goes here.

@end


@implementation Channel

@synthesize hasChangedSubscribeValue;

#pragma mark - Object factory

+ (Channel *) instanceFromChannel: (Channel *)channel
                        andViewId: (NSString*)viewId
        usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
              ignoringObjectTypes: (IgnoringObjects) ignoringObjects
{
    
    if(!channel)
        return nil;
    
    Channel* copyChannel = [Channel insertInManagedObjectContext: channel.managedObjectContext];
    
    copyChannel.uniqueId = channel.uniqueId;
    
    copyChannel.categoryId = channel.categoryId;
    
    copyChannel.position = channel.position;
    
    copyChannel.title = channel.title;
    
    copyChannel.lastUpdated = channel.lastUpdated;
    
    copyChannel.subscribersCount = channel.subscribersCount;
    
    copyChannel.subscribedByUserValue = channel.subscribedByUserValue;
    
    copyChannel.favouritesValue = channel.favouritesValue;
    
    copyChannel.resourceURL = channel.resourceURL;
    
    copyChannel.channelDescription = channel.channelDescription;
    
    copyChannel.eCommerceURL = channel.eCommerceURL;
    
    copyChannel.viewId = viewId;
    
    if (!(ignoringObjects & kIgnoreChannelOwnerObject))
    {
        copyChannel.channelOwner = [ChannelOwner instanceFromChannelOwner:channel.channelOwner
                                                                andViewId:viewId usingManagedObjectContext:channel.managedObjectContext
                                                      ignoringObjectTypes:kIgnoreChannelObjects];
    }
    
    
    copyChannel.channelCover = [ChannelCover instanceFromChannelCover:channel.channelCover
                                            usingManagedObjectContext:channel.managedObjectContext];
    
    
    if (!(ignoringObjects & kIgnoreVideoInstanceObjects))
    {
        
        for (VideoInstance* videoInstance in channel.videoInstances)
        {
            VideoInstance* copyVideoInstance = [VideoInstance instanceFromVideoInstance:videoInstance
                                                              usingManagedObjectContext:channel.managedObjectContext];
            
            copyVideoInstance.viewId = viewId;
            
            [copyChannel.videoInstancesSet addObject:copyVideoInstance];
        }
        
    }
    
    
    return copyChannel;
    
    
}

+ (Channel *) instanceFromDictionary: (NSDictionary *) dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects
{
    
    
    
    if (![dictionary isKindOfClass: [NSDictionary class]])
        return nil;
    
   
    NSString *uniqueId = [dictionary objectForKey: @"id"];
    if(!uniqueId || ![uniqueId isKindOfClass:[NSString class]])
        return nil;
    
    
    Channel *instance;
    
    if(!(ignoringObjects & kIgnoreStoredObjects))
    {
        NSFetchRequest *channelFetchRequest = [[NSFetchRequest alloc] init];
        [channelFetchRequest setEntity: [NSEntityDescription entityForName: @"Channel"
                                                    inManagedObjectContext: managedObjectContext]];
        
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %@", uniqueId];
        
        [channelFetchRequest setPredicate: predicate];
        
        NSError *error = nil;
        NSArray *matchingChannelEntries = [managedObjectContext executeFetchRequest: channelFetchRequest
                                                                              error: &error];
        
        
        if (matchingChannelEntries.count > 0)
        {
            instance = matchingChannelEntries[0];
            
            instance.markedForDeletionValue = NO;
            
        }
        
    }
    
    
    if(!instance)
    {
        instance = [Channel insertInManagedObjectContext: managedObjectContext];
        
        instance.uniqueId = uniqueId;
    }
    
    [instance setAttributesFromDictionary: dictionary
                      ignoringObjectTypes: ignoringObjects];
    
    
    return instance;
    
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects {
    
    
    
    
    BOOL hasVideoInstances = YES;
    
    NSDictionary *videosDictionary = [dictionary objectForKey: @"videos"];
    if(!videosDictionary || ![videosDictionary isKindOfClass: [NSDictionary class]])
        hasVideoInstances = NO;
    
    NSArray *itemArray = [videosDictionary objectForKey: @"items"];
    if(!itemArray || ![itemArray isKindOfClass: [NSArray class]])
        hasVideoInstances = NO;
    
    
    
    if (!(ignoringObjects & kIgnoreVideoInstanceObjects) && hasVideoInstances)
    {
        
        
        
        NSMutableDictionary* videoInsanceByIdDictionary = [[NSMutableDictionary alloc] initWithCapacity:self.videoInstances.count];
        
        for (VideoInstance* vi in self.videoInstances)
            [videoInsanceByIdDictionary setObject:vi forKey:vi.uniqueId];
        
        
        [self.videoInstancesSet removeAllObjects];
        
        NSString* newUniqueId;
        
        for (NSDictionary *channelDictionary in itemArray)
        {
            // viewId is @"ChannelDetails" because that is the only case where videos are passed
            
            VideoInstance* videoInstance;
            
            newUniqueId = [dictionary objectForKey: @"id"
                                       withDefault: @""];
            
            
            videoInstance = [videoInsanceByIdDictionary objectForKey:[dictionary objectForKey: @"id"]];
            
            if(!videoInstance)
            {
                videoInstance = [VideoInstance instanceFromDictionary: channelDictionary
                                            usingManagedObjectContext: self.managedObjectContext
                                                  ignoringObjectTypes: kIgnoreStoredObjects | kIgnoreChannelObjects];
                
                
            }
            else
            {
                [videoInsanceByIdDictionary removeObjectForKey:newUniqueId];
            }
            
            
            if(!videoInstance)
                continue;
            
            videoInstance.viewId = self.viewId;
            
            videoInstance.position = [dictionary objectForKey: @"position"
                                                  withDefault: [NSNumber numberWithInt: 0]];
            
            [self.videoInstancesSet addObject:videoInstance];
            
        }
        
        // clean the remaining //
        
        for (id key in videoInsanceByIdDictionary)
        {
            VideoInstance* vi = [videoInsanceByIdDictionary objectForKey:key];
            if(!vi)
                continue;
            
            [self.managedObjectContext deleteObject:vi];
            
        }
        
    
    }
    
    [self setBasicAttributesFromDictionary:dictionary];
    
    NSDictionary* ownerDictionary = [dictionary objectForKey: @"owner"];
    if(!(ignoringObjects & kIgnoreChannelOwnerObject) && ownerDictionary)
    {
        self.channelOwner = [ChannelOwner instanceFromDictionary: ownerDictionary
                                       usingManagedObjectContext: self.managedObjectContext
                                             ignoringObjectTypes: kIgnoreChannelObjects];
    }
    
    
    NSDictionary* channelCoverDictionary = [dictionary objectForKey:@"cover"];
    if(!(ignoringObjects & kIgnoreChannelCover) && channelCoverDictionary)
    {
        self.channelCover = [ChannelCover instanceFromDictionary:channelCoverDictionary
                                       usingManagedObjectContext:self.managedObjectContext];
    }
    
    
}


-(void)setBasicAttributesFromDictionary:(NSDictionary*)dictionary
{
    
    
    NSNumber* categoryNumber = [dictionary objectForKey:@"category"];
    
    self.categoryId = (categoryNumber && [categoryNumber isKindOfClass:[NSNumber class]]) ? [categoryNumber stringValue] : @"" ;
    
    self.position = [dictionary objectForKey: @"position"
                                 withDefault: [NSNumber numberWithInt: 0]];
    
    self.title = [dictionary upperCaseStringForKey: @"title"
                                       withDefault: @""];
    
    self.lastUpdated = [dictionary dateFromISO6801StringForKey: @"last_updated"
                                                   withDefault: [NSDate date]];
    
    self.subscribersCount = [dictionary objectForKey: @"subscriber_count"
                                         withDefault: [NSNumber numberWithInt:0]];
    
    
    
    // this field only comes back for the favourites channel
    
    NSNumber* favourites = [dictionary objectForKey:@"favourites"];
    
    self.favouritesValue = ![favourites isKindOfClass:[NSNull class]] ? [favourites boolValue] : NO;
    
    
    self.resourceURL = [dictionary objectForKey: @"resource_url"
                                    withDefault: @"http://localhost"];
    
    self.channelDescription = [dictionary objectForKey: @"description"
                                           withDefault: @""];
    
    self.eCommerceURL = [dictionary objectForKey: @"ecommerce_url"
                                     withDefault: @""];
    
}


#pragma mark - Adding Video Instances



-(void)addVideoInstancesObject:(VideoInstance *)value_
{
    [self.videoInstancesSet addObject:value_];
}

-(void)removeVideoInstancesObject:(VideoInstance *)value_
{
    [self.videoInstancesSet removeObject:value_];
}


#pragma mark - Object reference counting

// This is very important, we need to set the delete rule to 'Nullify' and then custom delete our connected NSManagedObjects
// dependent on whether they are only referenced by us

// Not sure if we should delete connected Channel/ChannelInstances at the same time
- (void) prepareForDeletion
{
    // Delete any channelOwners that are only associated with this channel
    if (self.channelOwner.channels.count == 1)
    {
        // DebugLog(@"Single reference to ChannelOwner, will be deleted");
        [self.managedObjectContext deleteObject: self.channelOwner];
    }
    
    // Delete any VideoInstances that are associated with this channel (I am assuming that as they only have a to-one relationship
    // with a channel, then they are only associated with that particular channel and can't exist independently
    for (VideoInstance *videoInstance in self.videoInstances)
    {
        [self.managedObjectContext deleteObject: videoInstance];
    }
}


#pragma mark - Helper methods

- (NSString *) description
{
    
    NSMutableString* initialDescription = [NSMutableString stringWithFormat: @"- Channel (cat#:'%@', title:'%@'), VI(%i):", self.categoryId, self.title, self.videoInstances.count];
    
    for (VideoInstance* childrenVideoInstance in self.videoInstances)
    {
        [initialDescription appendFormat:@"\n\t-%@", childrenVideoInstance];
    }
    
    return initialDescription;
}





@end
