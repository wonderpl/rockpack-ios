#import "_VideoInstance.h"
#import "AbstractCommon.h"

@interface VideoInstance : _VideoInstance

+ (VideoInstance *) instanceFromDictionary: (NSDictionary *) dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                       ignoringObjectTypes: (IgnoringObjects) ignoringObjects;

+ (VideoInstance *) instanceFromDictionary: (NSDictionary *) dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

+ (VideoInstance *) instanceFromDictionary: (NSDictionary *) dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                        existingVideos:(NSArray*)exisitingVideos;

+(VideoInstance*) instanceFromVideoInstance:(VideoInstance*)existingInstance
                  usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                        ignoringObjectTypes: (IgnoringObjects) ignoringObjects;

@property (nonatomic) BOOL selectedForVideoQueue;

- (NSNumber *) daysAgo;
- (NSDate *) dateAddedIgnoringTime;

@end
