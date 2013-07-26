#import "_ChannelOwner.h"
#import "AbstractCommon.h"

@interface ChannelOwner : _ChannelOwner

@property (nonatomic, readonly) NSString *thumbnailSmallUrl;
@property (nonatomic, readonly) NSString *thumbnailLargeUrl;

+ (ChannelOwner *) instanceFromDictionary: (NSDictionary *) dictionary
                usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                      ignoringObjectTypes: (IgnoringObjects) ignoringObjects;

+ (ChannelOwner *) instanceFromChannelOwner: (ChannelOwner *) existingChannelOwner
                                  andViewId: (NSString *) viewId
                  usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                        ignoringObjectTypes: (IgnoringObjects) ignoringObjects;

- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects;

- (NSDictionary *) channelsDictionary;

- (void) setSubscriptionsDictionary: (NSDictionary *) subscriptionsDictionary;

@end
