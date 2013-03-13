#import "_AccessInfo.h"

@interface AccessInfo : _AccessInfo {}

+ (AccessInfo *) instanceFromDictionary: (NSDictionary *) dictionary
              usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

@end
