// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Channel.h instead.

#import <CoreData/CoreData.h>


extern const struct ChannelAttributes {
	__unsafe_unretained NSString *categoryId;
	__unsafe_unretained NSString *channelDescription;
	__unsafe_unretained NSString *index;
	__unsafe_unretained NSString *lastUpdated;
	__unsafe_unretained NSString *rockCount;
	__unsafe_unretained NSString *rockedByUser;
	__unsafe_unretained NSString *thumbnailURL;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *uniqueId;
	__unsafe_unretained NSString *wallpaperURL;
} ChannelAttributes;

extern const struct ChannelRelationships {
	__unsafe_unretained NSString *channelOwner;
	__unsafe_unretained NSString *channelVideos;
	__unsafe_unretained NSString *videos;
} ChannelRelationships;

extern const struct ChannelFetchedProperties {
} ChannelFetchedProperties;

@class ChannelOwner;
@class VideoInstance;
@class Video;












@interface ChannelID : NSManagedObjectID {}
@end

@interface _Channel : NSManagedObject {}
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





@property (nonatomic, strong) NSString* uniqueId;



//- (BOOL)validateUniqueId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wallpaperURL;



//- (BOOL)validateWallpaperURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) ChannelOwner *channelOwner;

//- (BOOL)validateChannelOwner:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) VideoInstance *channelVideos;

//- (BOOL)validateChannelVideos:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSOrderedSet *videos;

- (NSMutableOrderedSet*)videosSet;





@end

@interface _Channel (CoreDataGeneratedAccessors)

- (void)addVideos:(NSOrderedSet*)value_;
- (void)removeVideos:(NSOrderedSet*)value_;
- (void)addVideosObject:(Video*)value_;
- (void)removeVideosObject:(Video*)value_;

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




- (NSString*)primitiveUniqueId;
- (void)setPrimitiveUniqueId:(NSString*)value;




- (NSString*)primitiveWallpaperURL;
- (void)setPrimitiveWallpaperURL:(NSString*)value;





- (ChannelOwner*)primitiveChannelOwner;
- (void)setPrimitiveChannelOwner:(ChannelOwner*)value;



- (VideoInstance*)primitiveChannelVideos;
- (void)setPrimitiveChannelVideos:(VideoInstance*)value;



- (NSMutableOrderedSet*)primitiveVideos;
- (void)setPrimitiveVideos:(NSMutableOrderedSet*)value;


@end
