#import "_ChannelOwner.h"
#import "AbstractCommon.h"

@interface ChannelOwner : _ChannelOwner

+ (ChannelOwner *) instanceFromDictionary: (NSDictionary *) dictionary
                usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                      ignoringObjectTypes: (IgnoringObjects) ignoringObjects;


+ (ChannelOwner *) instanceFromChannelOwner:(ChannelOwner*)existingChannelOwner
                  usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                              withId: (NSString *) uniqueId
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContex
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects;


-(NSDictionary*) channelsDictionary;

-(void)addSubscriptionsDictionary:(NSDictionary *)subscriptionsDictionary;

@end
