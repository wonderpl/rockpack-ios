#import "_Channel.h"

@interface Channel : _Channel 

+ (Channel *) instanceFromDictionary: (NSDictionary *) dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

- (UIImage *) thumbnailImage;
- (UIImage *) wallpaperImage;

@end
