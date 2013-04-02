#import "_ChannelOwner.h"
#import "AbstractCommon.h"

@interface ChannelOwner : _ChannelOwner

+ (ChannelOwner *) instanceFromDictionary: (NSDictionary *) dictionary
                usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                      ignoringObjectTypes: (IgnoringObjects) ignoringObjects
                                andViewId: (NSString *) viewId;

- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                              withId: (NSString *) uniqueId
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContex
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects
                           andViewId: (NSString *) viewId;

+ (ChannelOwner *) instanceFromChannelOwner:(ChannelOwner*)existingChannelOwner
                  usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

-(NSDictionary*) channelsDictionary;

@end
