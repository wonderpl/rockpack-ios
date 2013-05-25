#import "_ChannelOwner.h"
#import "AbstractCommon.h"

@interface ChannelOwner : _ChannelOwner

+ (ChannelOwner *) instanceFromDictionary: (NSDictionary *) dictionary
                usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                      ignoringObjectTypes: (IgnoringObjects) ignoringObjects;


+ (ChannelOwner *) instanceFromChannelOwner: (ChannelOwner*)existingChannelOwner
                                  andViewId: (NSString*)viewId
                  usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                        ignoringObjectTypes: (IgnoringObjects) ignoringObjects;

- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects;


-(NSDictionary*) channelsDictionary;

-(void)addSubscriptionsDictionary:(NSDictionary *)subscriptionsDictionary;

@end
