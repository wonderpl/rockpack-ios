#import "_ChannelCover.h"

@interface ChannelCover : _ChannelCover {}


+ (ChannelCover *) instanceFromDictionary: (NSDictionary *) dictionary
            usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;


@end
