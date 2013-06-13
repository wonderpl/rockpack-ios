#import "_Channel.h"
#import "AbstractCommon.h"

@interface Channel : _Channel 

+ (Channel *) instanceFromDictionary: (NSDictionary *) dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                  ignoringObjectTypes: (IgnoringObjects) ignoringObjects;

+ (Channel *) instanceFromDictionary: (NSDictionary *) dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;


@property (nonatomic) BOOL hasChangedSubscribeValue;

@property (nonatomic) NSInteger totalVideosValue;

- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects;

+ (Channel *) instanceFromChannel: (Channel *)channel
                        andViewId: (NSString*)viewId
        usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
              ignoringObjectTypes: (IgnoringObjects) ignoringObjects;

-(void)addVideoInstancesFromDictionary:(NSDictionary*)videosInstancesDictionary;


@end
