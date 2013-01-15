#import "_VideoInstance.h"

@interface VideoInstance : _VideoInstance

+ (VideoInstance *) instanceFromDictionary: (NSDictionary *) dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

- (NSNumber *) daysAgo;
- (NSDate *) dateAddedIgnoringTime;

@end
