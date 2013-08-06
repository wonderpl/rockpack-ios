#import "_ExternalAccount.h"

@interface ExternalAccount : _ExternalAccount {}

typedef enum {

    ExternalAccountFlagRead = 1 << 0,
    ExternalAccountFlagWrite = 1 << 1,
    ExternalAccountFlagAutopostAdd = 1 << 2,
    ExternalAccountFlagAutopostStar = 1 << 3
    

} ExternalAccountFlag;


+ (ExternalAccount*)instanceFromDictionary:(NSDictionary*)dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;


@end
