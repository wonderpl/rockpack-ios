#import "Channel.h"
#import "ChannelOwner.h"
#import "NSDictionary+Validation.h"
#import "VideoInstance.h"

static NSEntityDescription *channelEntity = nil;

@interface Channel ()

// Private interface goes here.

@end


@implementation Channel

#pragma mark - Object factory



+ (Channel *) instanceFromDictionary: (NSDictionary *) dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects
                           andViewId: (NSString *) viewId
{
    
    NSError *error = nil;
    
   
    NSString *uniqueId = [dictionary objectForKey: @"id"
                                      withDefault: @"Uninitialized Id"];
    
    
    if (channelEntity == nil)
    {
        // Do once, and only once
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^
        {
            // Not entirely sure I shouldn't 'copy' this object before assigning it to the static variable
            channelEntity = [NSEntityDescription entityForName: @"Channel"
                                        inManagedObjectContext: managedObjectContext];
        });
    }
    
    Channel *instance;
    
    if(!(ignoringObjects & kIgnoreStoredObjects))
    {
        NSFetchRequest *channelFetchRequest = [[NSFetchRequest alloc] init];
        [channelFetchRequest setEntity: channelEntity];
        
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %@ AND viewId == %@", uniqueId, viewId];
        
        [channelFetchRequest setPredicate: predicate];
        
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
    }
    
    
    
    
    [instance setAttributesFromDictionary: dictionary
                                   withId: uniqueId
                usingManagedObjectContext: managedObjectContext
                      ignoringObjectTypes: ignoringObjects
                                andViewId: viewId];
    
    return instance;
    
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                              withId: (NSString *) uniqueId
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects
                           andViewId: (NSString *) viewId {
    
    
    self.uniqueId = uniqueId;
    
    if(!(ignoringObjects & kIgnoreViewId))
    {
        self.viewId = viewId;
    }
    
    
    if (!(ignoringObjects & kIgnoreVideoInstanceObjects))
    {
        
        [self addVideoInstancesFromDictionary:dictionary
                    usingManagedObjectContext:managedObjectContext
                                    andViewId:viewId];
        
    }
    
    [self setBasicAttributesFromDictionary:dictionary];
    
    
    if(!(ignoringObjects & kIgnoreChannelOwnerObject))
    {
        self.channelOwner = [ChannelOwner instanceFromDictionary: [dictionary objectForKey: @"owner"]
                                       usingManagedObjectContext: managedObjectContext
                                             ignoringObjectTypes: ignoringObjects
                                                       andViewId: viewId];
    }
    
    
}


-(void)setBasicAttributesFromDictionary:(NSDictionary*)dictionary
{
    
    
    NSNumber* categoryNumber = [dictionary objectForKey:@"category"];
    
    self.categoryId = (categoryNumber && [categoryNumber isKindOfClass:[NSNumber class]]) ? [categoryNumber stringValue] : @"0" ;
    
    self.position = [dictionary objectForKey: @"position"
                                 withDefault: [NSNumber numberWithInt: 0]];
    
    self.title = [dictionary upperCaseStringForKey: @"title"
                                       withDefault: @""];
    
    self.lastUpdated = [dictionary dateFromISO6801StringForKey: @"last_updated"
                                                   withDefault: [NSDate date]];
    
    self.subscribersCount = [dictionary objectForKey: @"subscribe_count"
                                         withDefault: [NSNumber numberWithBool: FALSE]];
    
    self.subscribedByUserValue = NO;
    
    self.coverThumbnailSmallURL = [dictionary objectForKey: @"cover_thumbnail_small_url"
                                               withDefault: @"http://localhost"];
    
    self.coverThumbnailLargeURL = [dictionary objectForKey: @"cover_thumbnail_large_url"
                                               withDefault: @"http://localhost"];
    
    self.wallpaperURL = [dictionary objectForKey: @"cover_background_url"
                                     withDefault: @"http://localhost"];
    
    self.resourceURL = [dictionary objectForKey: @"resource_url"
                                    withDefault: @"http://localhost"];
    
    self.channelDescription = [dictionary objectForKey: @"description"
                                           withDefault: @"Description of channel goes here"];
    
    self.eCommerceURL = [dictionary objectForKey: @"ecommerce_url"
                                     withDefault: @""];
    
}


#pragma mark - Adding Video Instances


-(void)addVideoInstancesFromChannel:(Channel*)channel
{
    
    for (VideoInstance* videoInstance in channel.videoInstances)
    {
        VideoInstance* copyOfVideoInstance = [VideoInstance instanceFromVideoInstance:videoInstance
                                                                           forChannel:self
                                                            usingManagedObjectContext:self.managedObjectContext
                                                                            andViewId:@"ChannelDetails"];
        [self.videoInstancesSet addObject: copyOfVideoInstance];
        
    }
    
}

-(void)addVideoInstancesFromDictionary: (NSDictionary*)dictionary
             usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                             andViewId: (NSString *) viewId {
    
    
    NSDictionary *videosDictionary = [dictionary objectForKey: @"videos"];
    if(!videosDictionary || ![videosDictionary isKindOfClass: [NSDictionary class]])
        return;
    
    NSArray *itemArray = [videosDictionary objectForKey: @"items"];
    if(!itemArray || ![itemArray isKindOfClass: [NSArray class]])
        return;
    
    for (NSDictionary *itemDictionary in itemArray)
    {
        if (![itemDictionary isKindOfClass: [NSDictionary class]])
            continue;
        
        [self.videoInstancesSet addObject: [VideoInstance instanceFromDictionary: itemDictionary
                                                       usingManagedObjectContext: managedObjectContext
                                                             ignoringObjectTypes: kIgnoreChannelObjects
                                                                       andViewId: viewId]];
        
    }
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
    
    NSMutableString* initialDescription = [NSMutableString stringWithFormat: @"Channel: id:'%@', viewId:'%@', category:'%@', lastUpdated: %@, subscribersCount: %@, subscribedByUser: %@, title: %@, eCommerceURL: %@", self.uniqueId, self.viewId, self.categoryId, self.lastUpdated, self.subscribersCount, self.subscribedByUser, self.title, self.eCommerceURL];
    
    for (VideoInstance* childrenVideoInstance in self.videoInstances)
    {
        [initialDescription appendFormat:@"\n\t-%@", childrenVideoInstance];
    }
    
    return initialDescription;
}





@end
