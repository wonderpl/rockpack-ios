#import "_Friend.h"

@interface Friend : _Friend {}
+ (Friend *) instanceFromDictionary: (NSDictionary *) dictionary
          usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

@property (nonatomic, readonly) BOOL isOnRockpack;

@end
