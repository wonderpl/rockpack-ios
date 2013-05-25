#import "_Channel.h"
#import "AbstractCommon.h"

@interface Channel : _Channel 

+ (Channel *) instanceFromDictionary: (NSDictionary *) dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                  ignoringObjectTypes: (IgnoringObjects) ignoringObjects;


@property (nonatomic) BOOL hasChangedSubscribeValue;

- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects;

+ (Channel *) instanceFromChannel: (Channel *)channel
                        andViewId: (NSString*)viewId
        usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
              ignoringObjectTypes: (IgnoringObjects) ignoringObjects;


@end
