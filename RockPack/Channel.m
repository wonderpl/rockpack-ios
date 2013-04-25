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
                        channelOwner: (ChannelOwner*)owner
                           andViewId: (NSString *) viewId {
    
    if (![dictionary isKindOfClass: [NSDictionary class]])
    {
        AssertOrLog (@"setAttributesFromDictionary: not a dictionary, unable to construct object");
        return nil;
    }
    
    
    NSString *uniqueId = [dictionary objectForKey: @"id"
                                      withDefault: @"Uninitialized Id"];
    
    // Do once, and only once
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
                      channelEntity = [NSEntityDescription entityForName: @"Channel"
                                                  inManagedObjectContext: managedObjectContext];
                  });
    
    
    Channel *instance = [Channel insertInManagedObjectContext: managedObjectContext];
    
    
    
    // Simple objects
    instance.uniqueId = uniqueId;
    
    instance.viewId = viewId;
    
    [instance setBasicAttributesFromDictionary:dictionary];
    
    instance.channelOwner = owner;
    
    
    return instance;
    
    
    
    
}




#pragma mark - Without Owner

+ (Channel *) subscriberInstanceFromDictionary: (NSDictionary*)dictionary
                     usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                                     andViewId: (NSString*)viewId {
    
    NSError *error = nil;
    
    NSString *uniqueId = [dictionary objectForKey: @"id" withDefault: @""];
    
    if (channelEntity == nil)
    {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            channelEntity = [NSEntityDescription entityForName: @"Channel"
                                        inManagedObjectContext: managedObjectContext];
        });
        
    }
    
    Channel* instance;
    
    NSFetchRequest *channelFetchRequest = [[NSFetchRequest alloc] init];
    [channelFetchRequest setEntity: channelEntity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %@", uniqueId];
    [channelFetchRequest setPredicate: predicate];
    
    NSArray *matchingChannelEntries = [managedObjectContext executeFetchRequest: channelFetchRequest
                                                                          error: &error];
    
    if(matchingChannelEntries.count > 0)
    {
        instance = matchingChannelEntries[0];
        
        if ([instance.eCommerceURL isEqualToString: @""])
        {
            instance.eCommerceURL = [dictionary objectForKey: @"ecommerce_url"
                                                 withDefault: @""];
            
            if (![instance.eCommerceURL isEqualToString: @""])
            {
                NSLog (@"Found ecommerce URL");
            }
        }  
    }
    else
    {
        instance = [Channel insertInManagedObjectContext: managedObjectContext];
        
        [instance setAttributesFromDictionary: dictionary
                                       withId: uniqueId
                    usingManagedObjectContext: managedObjectContext
                          ignoringObjectTypes: kIgnoreChannelObjects
                                    andViewId: viewId];
        
       instance.subscribedByUser = @(YES);
    }
    
    
    return instance;
}

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
            // Mark this object so that it is not deleted in the post-import step
            instance.markedForDeletionValue = FALSE;
            
            if ([instance.eCommerceURL isEqualToString: @""])
            {
                instance.eCommerceURL = [dictionary objectForKey: @"ecommerce_url"
                                                     withDefault: @""];
                
                if (![instance.eCommerceURL isEqualToString: @""])
                {
                    NSLog (@"Found ecommerce URL");
                }
            }
            
            // NSLog(@"Using existing Channel instance with id %@", instance.uniqueId);
            
            // Check to see if we need to fill in the viewId
            if (!(ignoringObjects & kIgnoreVideoInstanceObjects))
            {
                instance.viewId = viewId;
                
                NSDictionary *videosDictionary = [dictionary objectForKey: @"videos"];
                
                // Get Data, being cautious and checking to see that we do indeed have an 'Data' key and it does return a dictionary
                if (videosDictionary && [videosDictionary isKindOfClass: [NSDictionary class]])
                {
                    // Template for reading values from model (numbers, strings, dates and bools are the data types that we currently have)
                    NSArray *itemArray = [videosDictionary objectForKey: @"items"];
                    
                    if ([itemArray isKindOfClass: [NSArray class]])
                    {
                        for (NSDictionary *itemDictionary in itemArray)
                        {
                            if ([itemDictionary isKindOfClass: [NSDictionary class]])
                            {
                                [instance.videoInstancesSet addObject: [VideoInstance instanceFromDictionary: itemDictionary
                                                                                   usingManagedObjectContext: managedObjectContext
                                                                                         ignoringObjectTypes: kIgnoreChannelObjects
                                                                                                   andViewId: viewId]];
                            }
                        }
                    }
                }
            }
           
            
            
        }
        else
        {
            instance = [Channel insertInManagedObjectContext: managedObjectContext];
            
            
            [instance setAttributesFromDictionary: dictionary
                                           withId: uniqueId
                        usingManagedObjectContext: managedObjectContext
                              ignoringObjectTypes: ignoringObjects
                                        andViewId: viewId];
            
            
            
        }
    }
    else
    {
        instance = [Channel insertInManagedObjectContext: managedObjectContext];
        
        
        [instance setAttributesFromDictionary: dictionary
                                       withId: uniqueId
                    usingManagedObjectContext: managedObjectContext
                          ignoringObjectTypes: ignoringObjects
                                    andViewId: viewId];
        
        
        
    }
    
    return instance;
    
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                              withId: (NSString *) uniqueId
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects
                           andViewId: (NSString *) viewId
{
    
    
    
    self.uniqueId = uniqueId;
    
    if (!(ignoringObjects & kIgnoreVideoInstanceObjects))
    {
        self.viewId = viewId;
    }
    
    [self setBasicAttributesFromDictionary:dictionary];
    
    
    if (!(ignoringObjects & kIgnoreChannelObjects))
    {
        NSDictionary *videosDictionary = [dictionary objectForKey: @"videos"];
        
        // Get Data, being cautious and checking to see that we do indeed have an 'Data' key and it does return a dictionary
        if (videosDictionary && [videosDictionary isKindOfClass: [NSDictionary class]])
        {
            // Template for reading values from model (numbers, strings, dates and bools are the data types that we currently have)
            NSArray *itemArray = [videosDictionary objectForKey: @"items"];
            
            if ([itemArray isKindOfClass: [NSArray class]])
            {
                for (NSDictionary *itemDictionary in itemArray)
                {
                    if ([itemDictionary isKindOfClass: [NSDictionary class]])
                    {
                        [self.videoInstancesSet addObject: [VideoInstance instanceFromDictionary: itemDictionary
                                                                   usingManagedObjectContext: managedObjectContext
                                                                          ignoringObjectTypes: kIgnoreChannelObjects
                                                                                   andViewId: viewId]];
                    }
                }
            }
        }
    }
    
    
    self.channelOwner = [ChannelOwner instanceFromDictionary: [dictionary objectForKey: @"owner"]
                                   usingManagedObjectContext: managedObjectContext
                                         ignoringObjectTypes: ignoringObjects
                                                   andViewId: viewId];
}


-(void)setBasicAttributesFromDictionary:(NSDictionary*)dictionary
{
    
    if (![dictionary isKindOfClass: [NSDictionary class]])
    {
        AssertOrLog (@"setAttributesFromDictionary: not a dictionary, unable to construct object");
        return;
    }
    
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
    
    self.subscribedByUser = @(NO);
    
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
    
    if (![self.eCommerceURL isEqualToString: @""])
    {
        NSLog (@"Found ecommerce URL");
    }
}


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
