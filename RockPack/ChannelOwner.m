#import "ChannelOwner.h"
#import "NSDictionary+Validation.h"

static NSEntityDescription *channelOwnerEntity = nil;

@interface ChannelOwner ()

// Private interface goes here.

@end


@implementation ChannelOwner

#pragma mark - Object factory

+ (ChannelOwner *) instanceFromDictionary: (NSDictionary *) dictionary
                usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                  withRootObjectType: (RootObject) rootObject
{
    NSError *error = nil;
    
    // Get the unique id of this object from the dictionary that has been passed in
    NSString *uniqueId = [dictionary objectForKey: @"id"];
    
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
    {
        instance = matchingChannelOwnerEntries[0];
        NSLog(@"Using existing ChannelOwner instance with id %@", instance.uniqueId);
        
        return instance;
    }
    else
    {
        instance = [ChannelOwner insertInManagedObjectContext: managedObjectContext];
        
        // As we have a new object, we need to set all the attributes (from the dictionary passed in)
        // We have already obtained the uniqueId, so pass it in as an optimisation
        [instance setAttributesFromDictionary: dictionary
                                       withId: uniqueId
                    usingManagedObjectContext: managedObjectContext
                           withRootObjectType: rootObject];
        
        NSLog(@"Created ChannelOwner instance with id %@", instance.uniqueId);
        
        return instance;
    }
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                              withId: (NSString *) uniqueId
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContex
                  withRootObjectType: (RootObject) rootObject

{
    // Is we are not actually a dictionary, then bail
    if (![dictionary isKindOfClass: [NSDictionary class]])
    {
        AssertOrLog (@"setAttributesFromDictionary: not a dictionary, unable to construct object");
        return;
    }
    
    // Simple objects
    self.uniqueId = uniqueId;
    
    self.thumbnailURL = [dictionary objectForKey: @"thumbnail_url"
                                     withDefault: @"http://"];
    
    self.name = [dictionary objectForKey: @"name"
                             withDefault: @""];
}


#pragma mark - Helper methods

- (NSString *) description
{
    return [NSString stringWithFormat: @"ChannelOwner(%@) name: %@, thumbnailURL: %@", self.uniqueId, self.name, self.thumbnailURL];
}


@end
