#import "_ExternalAccount.h"

@interface ExternalAccount : _ExternalAccount {}


+ (ExternalAccount*)instanceFromDictionary:(NSDictionary*)dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;


@end
