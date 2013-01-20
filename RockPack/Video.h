#import "_Video.h"
#import "AbstractCommon.h"

@interface Video : _Video

+ (Video *) instanceFromDictionary: (NSDictionary *) dictionary
         usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                withRootObjectType: (RootObject) rootObject
                         andViewId: (NSString *) viewId;


- (UIImage *) thumbnailImage;
- (NSURL *) localVideoURL;

@end
