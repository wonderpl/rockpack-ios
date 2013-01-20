#import "_ChannelOwner.h"
#import "AbstractCommon.h"

@interface ChannelOwner : _ChannelOwner

+ (ChannelOwner *) instanceFromDictionary: (NSDictionary *) dictionary
                usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                       withRootObjectType: (RootObject) rootObject
                                andViewId: (NSString *) viewId;

@end
