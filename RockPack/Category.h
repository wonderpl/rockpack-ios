#import "_Category.h"

@interface Category : _Category {}


+ (Category *)instanceFromDictionary: (NSDictionary *) dictionary usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;
- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                              withId: (NSString *) uniqueId
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;
@end
