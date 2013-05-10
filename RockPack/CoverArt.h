#import "_CoverArt.h"

@interface CoverArt : _CoverArt

+ (CoverArt *) instanceFromDictionary: (NSDictionary *) dictionary
                usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                                andViewId: (NSString *) viewId;

@end
