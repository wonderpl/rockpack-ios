#import "_Channel.h"
#import "AbstractCommon.h"

@interface Channel : _Channel 

+ (Channel *) instanceFromDictionary: (NSDictionary *) dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                  ignoringObjectTypes: (IgnoringObjects) ignoringObjects
                           andViewId: (NSString *) viewId;


+ (Channel *) instanceFromDictionary: (NSDictionary *) dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                        channelOwner: (ChannelOwner*)owner
                           andViewId: (NSString *) viewId;

+ (Channel *) instanceFromDictionary:(NSDictionary*)dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

@end
