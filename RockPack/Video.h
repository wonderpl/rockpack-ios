#import "_Video.h"
#import "AbstractCommon.h"

@interface Video : _Video

+ (Video *) instanceFromDictionary: (NSDictionary *) dictionary
         usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
               ignoringObjectTypes: (IgnoringObjects) ignoringObjects
                         andViewId: (NSString *) viewId;

+(Video*)instanceFromVideo:(Video*)video
 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;


- (UIImage *) thumbnailImage;
- (NSURL *) localVideoURL;

@end
