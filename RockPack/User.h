#import "_User.h"

@interface User : _User {}


+ (User*) instanceFromDictionary: (NSDictionary *) dictionary
       usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
             ignoringObjectTypes: (IgnoringObjects) ignoringObjects;


@property (nonatomic, readonly) NSString* fullName;

@end
