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
                  withRootObjectType: (RootObject) rootObject
                           andViewId: (NSString *) viewId
{
    NSLog (@"Creating Channel");
    NSError *error = nil;
    
    // Get the unique id of this object from the dictionary that has been passed in
    NSString *uniqueId = [dictionary objectForKey: @"id"
                                      withDefault: @"Uninitialized Id"];
    
    // Only create an entity description once, should increase performance
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

    // Now we need to see if this object already exists, and if so return it and if not create it
    NSFetchRequest *channelFetchRequest = [[NSFetchRequest alloc] init];
    [channelFetchRequest setEntity: channelEntity];
    
    // Search on the unique Id
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %@", uniqueId];
    [channelFetchRequest setPredicate: predicate];
    
    NSArray *matchingChannelEntries = [managedObjectContext executeFetchRequest: channelFetchRequest
                                                                                error: &error];
    Channel *instance;
    
    if (matchingChannelEntries.count > 0)
    {
        instance = matchingChannelEntries[0];
        NSLog(@"Using existing Channel instance with id %@", instance.uniqueId);
        return instance;
    }
    else
    {
        instance = [Channel insertInManagedObjectContext: managedObjectContext];
        
        // As we have a new object, we need to set all the attributes (from the dictionary passed in)
        // We have already obtained the uniqueId, so pass it in as an optimisation
        [instance setAttributesFromDictionary: dictionary
                                       withId: uniqueId
                    usingManagedObjectContext: managedObjectContext
                           withRootObjectType: rootObject
                                    andViewId: viewId];
        
        NSLog(@"Created Channel instance with id %@", instance.uniqueId);
        
        return instance;
    }
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                              withId: (NSString *) uniqueId
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                  withRootObjectType: (RootObject) rootObject
                           andViewId: (NSString *) viewId
{
    // Is we are not actually a dictionary, then bail
    if (![dictionary isKindOfClass: [NSDictionary class]])
    {
        AssertOrLog (@"setAttributesFromDictionary: not a dictionary, unable to construct object");
        return;
    }
    
    // Simple objects
    self.uniqueId = uniqueId;
    
    self.viewId = viewId;
    
    self.categoryId = [dictionary objectForKey: @"category_id"
                                   withDefault: @""];
    
    self.index = [dictionary objectForKey: @"index"
                              withDefault: [NSNumber numberWithInt: 0]];
    
    self.lastUpdated = [dictionary dateFromISO6801StringForKey: @"last_updated"
                                                   withDefault: [NSDate date]];
    
    self.rockCount = [dictionary objectForKey: @"rock_count"
                                  withDefault: [NSNumber numberWithInt: 0]];
    
    self.rockCount = [dictionary objectForKey: @"rocked_by_user"
                                  withDefault: [NSNumber numberWithBool: FALSE]];
    
    self.subscribersCount = [dictionary objectForKey: @"subscribe_count"
                                         withDefault: [NSNumber numberWithBool: FALSE]];
    
    self.thumbnailURL = [dictionary objectForKey: @"thumbnail_url"
                                     withDefault: @"http://"];
    
    self.title = [dictionary upperCaseStringForKey: @"title"
                                       withDefault: @""];
    
    self.wallpaperURL = [dictionary objectForKey: @"wallpaper_url"
                                     withDefault: @"http://"];
    
    // NSManagedObjects
    self.channelOwner = [ChannelOwner instanceFromDictionary: [dictionary objectForKey: @"owner"]
                                   usingManagedObjectContext: managedObjectContext
                                          withRootObjectType: rootObject
                                                   andViewId: viewId];
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
        DebugLog(@"Single reference to ChannelOwner, will be deleted");
        [self.managedObjectContext deleteObject: self.channelOwner];
    }
    else
    {
        DebugLog(@"Multiple references to ChannelOwner object, not deleted");
    }
    
    // Delete any VideoInstances that are associated with this channel (I am assuming that as they only have a to-one relationship
    // with a channel, then they are only associated with that particular channel and can't exist independently
    for (VideoInstance *videoInstance in self.videoInstances)
    {
        [self.managedObjectContext deleteObject: videoInstance];
    }
}


#pragma mark - Helper methods

- (UIImage *) thumbnailImage
{
    return [UIImage imageNamed: self.thumbnailURL];
}

- (UIImage *) wallpaperImage
{
    return [UIImage imageNamed: self.wallpaperURL];
}

- (NSString *) description
{
    return [NSString stringWithFormat: @"Channel(%@) categoryId: %@, channelDescription: %@, index: %@, lastUpdated: %@, rockCount: %@, rockedByUser: %@, thumbnailURL: %@, title: %@, wallpaperURL: %@", self.uniqueId, self.categoryId, self.channelDescription, self.index, self.lastUpdated, self.rockCount, self.rockedByUser, self.thumbnailURL, self.title, self.wallpaperURL];
}



@end
