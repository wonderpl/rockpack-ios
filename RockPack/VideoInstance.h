#import "_VideoInstance.h"
#import "AbstractCommon.h"

@interface VideoInstance : _VideoInstance

+ (VideoInstance *) instanceFromDictionary: (NSDictionary *) dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                       ignoringObjectTypes: (IgnoringObjects) ignoringObjects;

+(VideoInstance*) instanceFromVideoInstance:(VideoInstance*)existingInstance
                  usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

@property (nonatomic) BOOL selectedForVideoQueue;

- (NSNumber *) daysAgo;
- (NSDate *) dateAddedIgnoringTime;

@end
