#import "_VideoInstance.h"
#import "AbstractCommon.h"

@interface VideoInstance : _VideoInstance

+ (VideoInstance *) instanceFromDictionary: (NSDictionary *) dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                        withRootObjectType: (RootObject) rootObject
                                 andViewId: (NSString *) viewId;

- (NSNumber *) daysAgo;
- (NSDate *) dateAddedIgnoringTime;

@end
