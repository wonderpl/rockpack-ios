// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Channel.h instead.

#import <CoreData/CoreData.h>
#import "AbstractCommon.h"

extern const struct ChannelAttributes {
	__unsafe_unretained NSString *categoryId;
	__unsafe_unretained NSString *channelDescription;
	__unsafe_unretained NSString *coverBackgroundURL;
	__unsafe_unretained NSString *coverThumbnailLargeURL;
	__unsafe_unretained NSString *coverThumbnailSmallURL;
	__unsafe_unretained NSString *lastUpdated;
	__unsafe_unretained NSString *position;
	__unsafe_unretained NSString *resourceURL;
	__unsafe_unretained NSString *rockCount;
	__unsafe_unretained NSString *rockedByUser;
	__unsafe_unretained NSString *subscribersCount;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *viewId;
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





@property (nonatomic, strong) NSString* coverBackgroundURL;



//- (BOOL)validateCoverBackgroundURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* coverThumbnailLargeURL;



//- (BOOL)validateCoverThumbnailLargeURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* coverThumbnailSmallURL;



//- (BOOL)validateCoverThumbnailSmallURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastUpdated;



//- (BOOL)validateLastUpdated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* position;



@property int64_t positionValue;
- (int64_t)positionValue;
- (void)setPositionValue:(int64_t)value_;

//- (BOOL)validatePosition:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* resourceURL;



//- (BOOL)validateResourceURL:(id*)value_ error:(NSError**)error_;





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





@property (nonatomic, strong) NSNumber* subscribersCount;



@property int64_t subscribersCountValue;
- (int64_t)subscribersCountValue;
- (void)setSubscribersCountValue:(int64_t)value_;

//- (BOOL)validateSubscribersCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* viewId;



//- (BOOL)validateViewId:(id*)value_ error:(NSError**)error_;





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




- (NSString*)primitiveCoverBackgroundURL;
- (void)setPrimitiveCoverBackgroundURL:(NSString*)value;




- (NSString*)primitiveCoverThumbnailLargeURL;
- (void)setPrimitiveCoverThumbnailLargeURL:(NSString*)value;




- (NSString*)primitiveCoverThumbnailSmallURL;
- (void)setPrimitiveCoverThumbnailSmallURL:(NSString*)value;




- (NSDate*)primitiveLastUpdated;
- (void)setPrimitiveLastUpdated:(NSDate*)value;




- (NSNumber*)primitivePosition;
- (void)setPrimitivePosition:(NSNumber*)value;

- (int64_t)primitivePositionValue;
- (void)setPrimitivePositionValue:(int64_t)value_;




- (NSString*)primitiveResourceURL;
- (void)setPrimitiveResourceURL:(NSString*)value;




- (NSNumber*)primitiveRockCount;
- (void)setPrimitiveRockCount:(NSNumber*)value;

- (int64_t)primitiveRockCountValue;
- (void)setPrimitiveRockCountValue:(int64_t)value_;




- (NSNumber*)primitiveRockedByUser;
- (void)setPrimitiveRockedByUser:(NSNumber*)value;

- (BOOL)primitiveRockedByUserValue;
- (void)setPrimitiveRockedByUserValue:(BOOL)value_;




- (NSNumber*)primitiveSubscribersCount;
- (void)setPrimitiveSubscribersCount:(NSNumber*)value;

- (int64_t)primitiveSubscribersCountValue;
- (void)setPrimitiveSubscribersCountValue:(int64_t)value_;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSString*)primitiveViewId;
- (void)setPrimitiveViewId:(NSString*)value;




- (NSString*)primitiveWallpaperURL;
- (void)setPrimitiveWallpaperURL:(NSString*)value;





- (ChannelOwner*)primitiveChannelOwner;
- (void)setPrimitiveChannelOwner:(ChannelOwner*)value;



- (NSMutableOrderedSet*)primitiveVideoInstances;
- (void)setPrimitiveVideoInstances:(NSMutableOrderedSet*)value;


@end
