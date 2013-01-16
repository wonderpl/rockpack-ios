#import "_VideoInstance.h"
#import "AbstractCommon.h"

@interface VideoInstance : _VideoInstance

+ (VideoInstance *) instanceFromDictionary: (NSDictionary *) dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                        withRootObjectType: (RootObject) rootObject;

- (NSNumber *) daysAgo;
- (NSDate *) dateAddedIgnoringTime;

@end
