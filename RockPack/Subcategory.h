#import "_Subcategory.h"

@interface Subcategory : _Subcategory {}

+ (Subcategory *)instanceFromDictionary: (NSDictionary *) dictionary usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

@end
