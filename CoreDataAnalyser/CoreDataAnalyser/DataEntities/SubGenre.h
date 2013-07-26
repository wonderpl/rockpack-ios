#import "_SubGenre.h"

@interface SubGenre : _SubGenre {}

+ (SubGenre *)instanceFromDictionary: (NSDictionary *) dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

@end
