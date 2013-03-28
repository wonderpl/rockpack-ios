#import "_VideoInstance.h"
#import "AbstractCommon.h"

@interface VideoInstance : _VideoInstance

+ (VideoInstance *) instanceFromDictionary: (NSDictionary *) dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                       ignoringObjectTypes: (IgnoringObjects) ignoringObjects
                                 andViewId: (NSString *) viewId;

+(VideoInstance*) instanceFromVideoInstance:(VideoInstance*)existingInstance
                                 forChannel:(Channel*)channel
                  usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                                  andViewId: (NSString *) viewId;

- (NSNumber *) daysAgo;
- (NSDate *) dateAddedIgnoringTime;

@end
