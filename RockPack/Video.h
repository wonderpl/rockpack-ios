#import "_Video.h"

@interface Video : _Video

+ (Video *) instanceFromDictionary: (NSDictionary *) dictionary
         usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

- (UIImage *) thumbnailImage;
- (NSURL *) localVideoURL;

@end
