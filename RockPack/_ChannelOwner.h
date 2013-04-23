// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ChannelOwner.h instead.

#import <CoreData/CoreData.h>
#import "AbstractCommon.h"

extern const struct ChannelOwnerAttributes {
	__unsafe_unretained NSString *displayName;
	__unsafe_unretained NSString *thumbnailURL;
} ChannelOwnerAttributes;

extern const struct ChannelOwnerRelationships {
	__unsafe_unretained NSString *channels;
	__unsafe_unretained NSString *subscriptions;
} ChannelOwnerRelationships;

extern const struct ChannelOwnerFetchedProperties {
} ChannelOwnerFetchedProperties;

@class Channel;
@class Channel;




@interface ChannelOwnerID : NSManagedObjectID {}
@end

@interface _ChannelOwner : AbstractCommon {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ChannelOwnerID*)objectID;





@property (nonatomic, strong) NSString* displayName;



//- (BOOL)validateDisplayName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* thumbnailURL;



//- (BOOL)validateThumbnailURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *channels;

- (NSMutableSet*)channelsSet;




@property (nonatomic, strong) NSSet *subscriptions;

- (NSMutableSet*)subscriptionsSet;





@end

@interface _ChannelOwner (CoreDataGeneratedAccessors)

- (void)addChannels:(NSSet*)value_;
- (void)removeChannels:(NSSet*)value_;
- (void)addChannelsObject:(Channel*)value_;
- (void)removeChannelsObject:(Channel*)value_;

- (void)addSubscriptions:(NSSet*)value_;
- (void)removeSubscriptions:(NSSet*)value_;
- (void)addSubscriptionsObject:(Channel*)value_;
- (void)removeSubscriptionsObject:(Channel*)value_;

@end

@interface _ChannelOwner (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveDisplayName;
- (void)setPrimitiveDisplayName:(NSString*)value;




- (NSString*)primitiveThumbnailURL;
- (void)setPrimitiveThumbnailURL:(NSString*)value;





- (NSMutableSet*)primitiveChannels;
- (void)setPrimitiveChannels:(NSMutableSet*)value;



- (NSMutableSet*)primitiveSubscriptions;
- (void)setPrimitiveSubscriptions:(NSMutableSet*)value;


@end
