#import "_VideoInstance.h"
#import "AbstractCommon.h"

@interface VideoInstance : _VideoInstance

@property (nonatomic) BOOL selectedForVideoQueue;
@property (nonatomic, weak) NSNumber* starredByUser;
@property (nonatomic) BOOL starredByUserValue;

+ (VideoInstance *) instanceFromDictionary: (NSDictionary *) dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                       ignoringObjectTypes: (IgnoringObjects) ignoringObjects
                            existingVideos: (NSArray *) existingVideos;

+ (VideoInstance *) instanceFromDictionary: (NSDictionary *) dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                            existingVideos: (NSArray *) existingVideos;

+ (VideoInstance *) instanceFromVideoInstance: (VideoInstance *) existingInstance
                    usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                          ignoringObjectTypes: (IgnoringObjects) ignoringObjects;

+ (VideoInstance *) instanceFromDictionary: (NSDictionary *) dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

- (NSNumber *) daysAgo;
- (NSDate *) dateAddedIgnoringTime;



@end
