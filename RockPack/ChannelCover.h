#import "_ChannelCover.h"

@interface ChannelCover : _ChannelCover {}


+ (ChannelCover *) instanceFromDictionary: (NSDictionary *) dictionary
                usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

@property (nonatomic, readonly) NSString* imageSmallUrl;
@property (nonatomic, readonly) NSString* imageMidiumUrl;
@property (nonatomic, readonly) NSString* imageLargeUrl;

@end
