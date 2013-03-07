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
    // DebugLog (@"Creating Channel");
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %@ AND viewId == %@", uniqueId, viewId];
    [channelFetchRequest setPredicate: predicate];
    
    NSArray *matchingChannelEntries = [managedObjectContext executeFetchRequest: channelFetchRequest
                                                                                error: &error];
    Channel *instance;
    
    if (matchingChannelEntries.count > 0)
    {
        instance = matchingChannelEntries[0];
        // Mark this object so that it is not deleted in the post-import step
        instance.markedForDeletionValue = FALSE;
        
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
        else
        {
           
        }
        
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
                          ignoringObjectTypes: ignoringObjects
                                    andViewId: viewId];
        
        // DebugLog(@"Created Channel instance with id %@ and viewId %@", instance.uniqueId, instance.viewId);
        
        return instance;
    }
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                              withId: (NSString *) uniqueId
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects
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
    
    // If we are initially creating Channel objects, then set our viewId of the appropriate vide name
    // otherwise just set to blank
    
    if (!(ignoringObjects & kIgnoreVideoInstanceObjects))
    {
        self.viewId = viewId;
    }
    
    self.categoryId = [dictionary objectForKey: @"category_id"
                                   withDefault: @""];
    
    self.position = [dictionary objectForKey: @"position"
                                 withDefault: [NSNumber numberWithInt: 0]];
    
    self.title = [dictionary upperCaseStringForKey: @"title"
                                       withDefault: @""];
    
    self.lastUpdated = [dictionary dateFromISO6801StringForKey: @"last_updated"
                                                   withDefault: [NSDate date]];
    
    self.rockCount = [dictionary objectForKey: @"rock_count"
                                  withDefault: [NSNumber numberWithInt: 0]];
    
    self.rockCount = [dictionary objectForKey: @"rocked_by_user"
                                  withDefault: [NSNumber numberWithBool: FALSE]];
    
    self.subscribersCount = [dictionary objectForKey: @"subscribe_count"
                                         withDefault: [NSNumber numberWithBool: FALSE]];
    
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
    
    if (!(ignoringObjects & kIgnoreChannelObjects))
    {
        // NSManagedObjects
//        self.videoInstances = [VideoInstance instanceFromDictionary: [dictionary objectForKey: @"videos"]
//                                          usingManagedObjectContext: managedObjectContext
//                                                 withRootObjectType: rootObject
//                                                          andViewId: viewId];
        

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
    
    // NSManagedObjects
    self.channelOwner = [ChannelOwner instanceFromDictionary: [dictionary objectForKey: @"owner"]
                                   usingManagedObjectContext: managedObjectContext
                                         ignoringObjectTypes: ignoringObjects
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
    return [NSString stringWithFormat: @"Channel(%@) categoryId: %@, channelDescription: %@, position: %@, lastUpdated: %@, rockCount: %@, rockedByUser: %@, coverThumbnailSmallURL: %@, coverThumbnailLargeURL: %@,, title: %@, wallpaperURL: %@, resourceURL: %@", self.uniqueId, self.categoryId, self.channelDescription, self.position, self.lastUpdated, self.rockCount, self.rockedByUser, self.coverThumbnailSmallURL, self.coverThumbnailLargeURL, self.title, self.wallpaperURL, self.resourceURL];
}



@end
