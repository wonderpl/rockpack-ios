#import "Channel.h"
#import "ChannelOwner.h"
#import "ChannelCover.h"
#import "NSDictionary+Validation.h"
#import "AppConstants.h"
#import "VideoInstance.h"

static NSEntityDescription *channelEntity = nil;

@interface Channel ()

// Private interface goes here.

@end


@implementation Channel

@synthesize hasChangedSubscribeValue;

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
        
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %@", uniqueId];
        
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
                      ignoringObjectTypes: ignoringObjects
                                andViewId: viewId];
    
    
    return instance;
    
}

// This is called directly by the ChannelManager to get the videos

- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                              withId: (NSString *) uniqueId
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects
                           andViewId: (NSString *) viewId {
    
    
    self.uniqueId = uniqueId;
    
    
    [self setBasicAttributesFromDictionary:dictionary];
    
    
    
    NSDictionary* videosDictionary = [dictionary objectForKey:@"videos"];
    if (!(ignoringObjects & kIgnoreVideoInstanceObjects) && [videosDictionary isKindOfClass:[NSDictionary class]])
    {
        
        NSArray *itemArray = [videosDictionary objectForKey: @"items"];
        if(![itemArray isKindOfClass:[NSArray class]])
            return;
        
        
        
        [self.videoInstancesSet removeAllObjects];
        
        // view id is @"ChannelDetails"
        
        for (NSDictionary *itemDictionary in itemArray)
        {
            
            VideoInstance* videoInstance = [VideoInstance instanceFromDictionary: itemDictionary
                                                       usingManagedObjectContext: self.managedObjectContext
                                                             ignoringObjectTypes: kIgnoreNothing
                                                                       andViewId: viewId];
            
            if(!videoInstance) // nil can be returned by a malformed JSON or missing a uniqueId
                continue;
            
            [self addVideoInstancesObject:videoInstance];
            
        }
        
    }
    
    
    NSDictionary* ownerDictionary = [dictionary objectForKey: @"owner"];
    if(!(ignoringObjects & kIgnoreChannelOwnerObject) && [ownerDictionary isKindOfClass:[NSDictionary class]])
    {
        self.channelOwner = [ChannelOwner instanceFromDictionary: ownerDictionary
                                       usingManagedObjectContext: self.managedObjectContext
                                             ignoringObjectTypes: kIgnoreChannelObjects];
    }
    
    
    NSDictionary* channelCoverDictionary = [dictionary objectForKey:@"cover"];
    if(!(ignoringObjects & kIgnoreChannelCover) && [channelCoverDictionary isKindOfClass:[NSDictionary class]])
    {
        self.channelCover = [ChannelCover instanceFromDictionary:channelCoverDictionary
                                       usingManagedObjectContext:self.managedObjectContext];
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
    
    NSLog(@"* Title: %@", self.title);
    
    self.lastUpdated = [dictionary dateFromISO6801StringForKey: @"last_updated"
                                                   withDefault: [NSDate date]];
    
    self.subscribersCount = [dictionary objectForKey: @"subscriber_count"
                                         withDefault: [NSNumber numberWithInt:0]];
    
    // this field only comes back for the favourites channel
    NSNumber* favourites = [dictionary objectForKey:@"favourites"];
    
    self.favouritesValue = ![favourites isKindOfClass:[NSNull class]] ? [favourites boolValue] : NO;
    
    if([self.title isEqualToString:@"FAVOURITES"])
    {
        DebugLog(@"Favourites Value: %@", favourites);
    }
    
    self.resourceURL = [dictionary objectForKey: @"resource_url"
                                    withDefault: @"http://localhost"];
    
    self.channelDescription = [dictionary objectForKey: @"description"
                                           withDefault: @""];
    
    self.eCommerceURL = [dictionary objectForKey: @"ecommerce_url"
                                     withDefault: @""];
    
}


#pragma mark - Adding Video Instances


-(void)addVideoInstancesFromChannel:(Channel*)channel
{
    
    for (VideoInstance* videoInstance in channel.videoInstances)
    {
        VideoInstance* copyOfVideoInstance = [VideoInstance instanceFromVideoInstance:videoInstance
                                                            usingManagedObjectContext:self.managedObjectContext];
        
        
        [self addVideoInstancesObject:copyOfVideoInstance];
        
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


#pragma mark - Accessors


-(void)addVideoInstancesObject:(VideoInstance *)value_
{
    [self.videoInstancesSet addObject: value_];
    value_.channel = self;
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
