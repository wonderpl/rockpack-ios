#import "_Friend.h"

@interface Friend : _Friend {}
+ (Friend *) instanceFromDictionary: (NSDictionary *) dictionary
          usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;
@end
