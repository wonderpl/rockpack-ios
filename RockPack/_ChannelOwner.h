// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ChannelOwner.h instead.

#import <CoreData/CoreData.h>


extern const struct ChannelOwnerAttributes {
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *thumbnailURL;
	__unsafe_unretained NSString *uniqueId;
} ChannelOwnerAttributes;

extern const struct ChannelOwnerRelationships {
	__unsafe_unretained NSString *channel;
} ChannelOwnerRelationships;

extern const struct ChannelOwnerFetchedProperties {
} ChannelOwnerFetchedProperties;

@class Channel;





@interface ChannelOwnerID : NSManagedObjectID {}
@end

@interface _ChannelOwner : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ChannelOwnerID*)objectID;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* thumbnailURL;



//- (BOOL)validateThumbnailURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* uniqueId;



//- (BOOL)validateUniqueId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Channel *channel;

//- (BOOL)validateChannel:(id*)value_ error:(NSError**)error_;





@end

@interface _ChannelOwner (CoreDataGeneratedAccessors)

@end

@interface _ChannelOwner (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveThumbnailURL;
- (void)setPrimitiveThumbnailURL:(NSString*)value;




- (NSString*)primitiveUniqueId;
- (void)setPrimitiveUniqueId:(NSString*)value;





- (Channel*)primitiveChannel;
- (void)setPrimitiveChannel:(Channel*)value;


@end
