// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Channel.h instead.

#import <CoreData/CoreData.h>
#import "AbstractCommon.h"

extern const struct ChannelAttributes {
	__unsafe_unretained NSString *categoryId;
	__unsafe_unretained NSString *channelDescription;
	__unsafe_unretained NSString *index;
	__unsafe_unretained NSString *lastUpdated;
	__unsafe_unretained NSString *rockCount;
	__unsafe_unretained NSString *rockedByUser;
	__unsafe_unretained NSString *thumbnailURL;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *wallpaperURL;
} ChannelAttributes;

extern const struct ChannelRelationships {
	__unsafe_unretained NSString *channelOwner;
	__unsafe_unretained NSString *videoInstances;
} ChannelRelationships;

extern const struct ChannelFetchedProperties {
} ChannelFetchedProperties;

@class ChannelOwner;
@class VideoInstance;











@interface ChannelID : NSManagedObjectID {}
@end

@interface _Channel : AbstractCommon {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ChannelID*)objectID;





@property (nonatomic, strong) NSString* categoryId;



//- (BOOL)validateCategoryId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* channelDescription;



//- (BOOL)validateChannelDescription:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* index;



@property int64_t indexValue;
- (int64_t)indexValue;
- (void)setIndexValue:(int64_t)value_;

//- (BOOL)validateIndex:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastUpdated;



//- (BOOL)validateLastUpdated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* rockCount;



@property int64_t rockCountValue;
- (int64_t)rockCountValue;
- (void)setRockCountValue:(int64_t)value_;

//- (BOOL)validateRockCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* rockedByUser;



@property BOOL rockedByUserValue;
- (BOOL)rockedByUserValue;
- (void)setRockedByUserValue:(BOOL)value_;

//- (BOOL)validateRockedByUser:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* thumbnailURL;



//- (BOOL)validateThumbnailURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wallpaperURL;



//- (BOOL)validateWallpaperURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) ChannelOwner *channelOwner;

//- (BOOL)validateChannelOwner:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSOrderedSet *videoInstances;

- (NSMutableOrderedSet*)videoInstancesSet;





@end

@interface _Channel (CoreDataGeneratedAccessors)

- (void)addVideoInstances:(NSOrderedSet*)value_;
- (void)removeVideoInstances:(NSOrderedSet*)value_;
- (void)addVideoInstancesObject:(VideoInstance*)value_;
- (void)removeVideoInstancesObject:(VideoInstance*)value_;

@end

@interface _Channel (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCategoryId;
- (void)setPrimitiveCategoryId:(NSString*)value;




- (NSString*)primitiveChannelDescription;
- (void)setPrimitiveChannelDescription:(NSString*)value;




- (NSNumber*)primitiveIndex;
- (void)setPrimitiveIndex:(NSNumber*)value;

- (int64_t)primitiveIndexValue;
- (void)setPrimitiveIndexValue:(int64_t)value_;




- (NSDate*)primitiveLastUpdated;
- (void)setPrimitiveLastUpdated:(NSDate*)value;




- (NSNumber*)primitiveRockCount;
- (void)setPrimitiveRockCount:(NSNumber*)value;

- (int64_t)primitiveRockCountValue;
- (void)setPrimitiveRockCountValue:(int64_t)value_;




- (NSNumber*)primitiveRockedByUser;
- (void)setPrimitiveRockedByUser:(NSNumber*)value;

- (BOOL)primitiveRockedByUserValue;
- (void)setPrimitiveRockedByUserValue:(BOOL)value_;




- (NSString*)primitiveThumbnailURL;
- (void)setPrimitiveThumbnailURL:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSString*)primitiveWallpaperURL;
- (void)setPrimitiveWallpaperURL:(NSString*)value;





- (ChannelOwner*)primitiveChannelOwner;
- (void)setPrimitiveChannelOwner:(ChannelOwner*)value;



- (NSMutableOrderedSet*)primitiveVideoInstances;
- (void)setPrimitiveVideoInstances:(NSMutableOrderedSet*)value;


@end
