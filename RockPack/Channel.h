#import "_Channel.h"
#import "AbstractCommon.h"

@interface Channel : _Channel 

+ (Channel *) instanceFromDictionary: (NSDictionary *) dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                  withRootObjectType: (RootObject) rootObject
                           andViewId: (NSString *) viewId;

@end
