#import "ChannelOwner.h"
#import "Channel.h"
#import "NSDictionary+Validation.h"
#import "AppConstants.h"

static NSEntityDescription *channelOwnerEntity = nil;

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
    
    // Get the unique id of this object from the dictionary that has been passed in
    NSString *uniqueId = [dictionary objectForKey: @"id"
                                      withDefault: @"Uninitialized Id"];
    
    // Only create an entity description once, should increase performance
    if (channelOwnerEntity == nil)
    {
        // Do once, and only once
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^
        {
            // Not entirely sure I shouldn't 'copy' this object before assigning it to the static variable
            channelOwnerEntity = [NSEntityDescription entityForName: @"ChannelOwner"
                                             inManagedObjectContext: managedObjectContext];
          
        });
    }
    
    // Now we need to see if this object already exists, and if so return it and if not create it
    NSFetchRequest *channelOwnerFetchRequest = [[NSFetchRequest alloc] init];
    [channelOwnerFetchRequest setEntity: channelOwnerEntity];
    
    // Search on the unique Id
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
    
    if(!(ignoringObjects & kIgnoreChannelObjects))
    {
        NSDictionary* channelsArray = [dictionary objectForKey:@"channels"];
        NSArray* channelItemsArray;
        if(channelsArray && (channelItemsArray = [channelsArray objectForKey:@"items"]))
        {
            for (NSDictionary* channelDictionary in channelItemsArray)
            {
                
                Channel* channel = [Channel instanceFromDictionary:channelDictionary
                                         usingManagedObjectContext:managedObjectContex
                                               ignoringObjectTypes:kIgnoreChannelOwnerObject
                                                         andViewId:kProfileViewId];
                channel.channelOwner = self;
                
                
                [self.channelsSet addObject:channel];
                
            }
        }
    }
    
    
    
}

#pragma mark - Channels



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
    return [NSString stringWithFormat: @"uniqueId(%@), userName: %@, thumbnailURL: %@", self.uniqueId, self.displayName, self.thumbnailURL];
}


@end
