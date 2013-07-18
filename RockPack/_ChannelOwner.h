// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ChannelOwner.h instead.

#import <CoreData/CoreData.h>


extern const struct ChannelOwnerAttributes {
	__unsafe_unretained NSString *displayName;
	__unsafe_unretained NSString *fresh;
	__unsafe_unretained NSString *markedForDeletion;
	__unsafe_unretained NSString *position;
	__unsafe_unretained NSString *thumbnailURL;
	__unsafe_unretained NSString *uniqueId;
	__unsafe_unretained NSString *username;
	__unsafe_unretained NSString *viewId;
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

@interface _ChannelOwner : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ChannelOwnerID*)objectID;





@property (nonatomic, strong) NSString* displayName;



//- (BOOL)validateDisplayName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* fresh;



@property BOOL freshValue;
- (BOOL)freshValue;
- (void)setFreshValue:(BOOL)value_;

//- (BOOL)validateFresh:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* markedForDeletion;



@property BOOL markedForDeletionValue;
- (BOOL)markedForDeletionValue;
- (void)setMarkedForDeletionValue:(BOOL)value_;

//- (BOOL)validateMarkedForDeletion:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* position;



@property int64_t positionValue;
- (int64_t)positionValue;
- (void)setPositionValue:(int64_t)value_;

//- (BOOL)validatePosition:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* thumbnailURL;



//- (BOOL)validateThumbnailURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* uniqueId;



//- (BOOL)validateUniqueId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* username;



//- (BOOL)validateUsername:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* viewId;



//- (BOOL)validateViewId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSOrderedSet *channels;

- (NSMutableOrderedSet*)channelsSet;




@property (nonatomic, strong) NSOrderedSet *subscriptions;

- (NSMutableOrderedSet*)subscriptionsSet;





@end

@interface _ChannelOwner (CoreDataGeneratedAccessors)

- (void)addChannels:(NSOrderedSet*)value_;
- (void)removeChannels:(NSOrderedSet*)value_;
- (void)addChannelsObject:(Channel*)value_;
- (void)removeChannelsObject:(Channel*)value_;

- (void)addSubscriptions:(NSOrderedSet*)value_;
- (void)removeSubscriptions:(NSOrderedSet*)value_;
- (void)addSubscriptionsObject:(Channel*)value_;
- (void)removeSubscriptionsObject:(Channel*)value_;

@end

@interface _ChannelOwner (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveDisplayName;
- (void)setPrimitiveDisplayName:(NSString*)value;




- (NSNumber*)primitiveFresh;
- (void)setPrimitiveFresh:(NSNumber*)value;

- (BOOL)primitiveFreshValue;
- (void)setPrimitiveFreshValue:(BOOL)value_;




- (NSNumber*)primitiveMarkedForDeletion;
- (void)setPrimitiveMarkedForDeletion:(NSNumber*)value;

- (BOOL)primitiveMarkedForDeletionValue;
- (void)setPrimitiveMarkedForDeletionValue:(BOOL)value_;




- (NSNumber*)primitivePosition;
- (void)setPrimitivePosition:(NSNumber*)value;

- (int64_t)primitivePositionValue;
- (void)setPrimitivePositionValue:(int64_t)value_;




- (NSString*)primitiveThumbnailURL;
- (void)setPrimitiveThumbnailURL:(NSString*)value;




- (NSString*)primitiveUniqueId;
- (void)setPrimitiveUniqueId:(NSString*)value;




- (NSString*)primitiveUsername;
- (void)setPrimitiveUsername:(NSString*)value;




- (NSString*)primitiveViewId;
- (void)setPrimitiveViewId:(NSString*)value;





- (NSMutableOrderedSet*)primitiveChannels;
- (void)setPrimitiveChannels:(NSMutableOrderedSet*)value;



- (NSMutableOrderedSet*)primitiveSubscriptions;
- (void)setPrimitiveSubscriptions:(NSMutableOrderedSet*)value;


@end
