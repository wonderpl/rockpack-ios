#import "_Channel.h"
#import "AbstractCommon.h"

@interface Channel : _Channel 

+ (Channel *) instanceFromDictionary: (NSDictionary *) dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                  ignoringObjectTypes: (IgnoringObjects) ignoringObjects;


@property (nonatomic) BOOL hasChangedSubscribeValue;

- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                              withId: (NSString *) uniqueId
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects;


@end
