// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Video.h instead.

#import <CoreData/CoreData.h>
#import "AbstractCommon.h"

extern const struct VideoAttributes {
	__unsafe_unretained NSString *categoryId;
	__unsafe_unretained NSString *dateUploaded;
	__unsafe_unretained NSString *duration;
	__unsafe_unretained NSString *source;
	__unsafe_unretained NSString *sourceId;
	__unsafe_unretained NSString *sourceUsername;
	__unsafe_unretained NSString *starCount;
	__unsafe_unretained NSString *starredByUser;
	__unsafe_unretained NSString *thumbnailURL;
	__unsafe_unretained NSString *viewCount;
	__unsafe_unretained NSString *viewedByUser;
} VideoAttributes;

extern const struct VideoRelationships {
	__unsafe_unretained NSString *videoInstances;
} VideoRelationships;

extern const struct VideoFetchedProperties {
} VideoFetchedProperties;

@class VideoInstance;













@interface VideoID : NSManagedObjectID {}
@end

@interface _Video : AbstractCommon {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (VideoID*)objectID;





@property (nonatomic, strong) NSString* categoryId;



//- (BOOL)validateCategoryId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateUploaded;



//- (BOOL)validateDateUploaded:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* duration;



@property int64_t durationValue;
- (int64_t)durationValue;
- (void)setDurationValue:(int64_t)value_;

//- (BOOL)validateDuration:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* source;



//- (BOOL)validateSource:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* sourceId;



//- (BOOL)validateSourceId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* sourceUsername;



//- (BOOL)validateSourceUsername:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* starCount;



@property int64_t starCountValue;
- (int64_t)starCountValue;
- (void)setStarCountValue:(int64_t)value_;

//- (BOOL)validateStarCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* starredByUser;



@property BOOL starredByUserValue;
- (BOOL)starredByUserValue;
- (void)setStarredByUserValue:(BOOL)value_;

//- (BOOL)validateStarredByUser:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* thumbnailURL;



//- (BOOL)validateThumbnailURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* viewCount;



@property int64_t viewCountValue;
- (int64_t)viewCountValue;
- (void)setViewCountValue:(int64_t)value_;

//- (BOOL)validateViewCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* viewedByUser;



@property BOOL viewedByUserValue;
- (BOOL)viewedByUserValue;
- (void)setViewedByUserValue:(BOOL)value_;

//- (BOOL)validateViewedByUser:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *videoInstances;

- (NSMutableSet*)videoInstancesSet;





@end

@interface _Video (CoreDataGeneratedAccessors)

- (void)addVideoInstances:(NSSet*)value_;
- (void)removeVideoInstances:(NSSet*)value_;
- (void)addVideoInstancesObject:(VideoInstance*)value_;
- (void)removeVideoInstancesObject:(VideoInstance*)value_;

@end

@interface _Video (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCategoryId;
- (void)setPrimitiveCategoryId:(NSString*)value;




- (NSDate*)primitiveDateUploaded;
- (void)setPrimitiveDateUploaded:(NSDate*)value;




- (NSNumber*)primitiveDuration;
- (void)setPrimitiveDuration:(NSNumber*)value;

- (int64_t)primitiveDurationValue;
- (void)setPrimitiveDurationValue:(int64_t)value_;




- (NSString*)primitiveSource;
- (void)setPrimitiveSource:(NSString*)value;




- (NSString*)primitiveSourceId;
- (void)setPrimitiveSourceId:(NSString*)value;




- (NSString*)primitiveSourceUsername;
- (void)setPrimitiveSourceUsername:(NSString*)value;




- (NSNumber*)primitiveStarCount;
- (void)setPrimitiveStarCount:(NSNumber*)value;

- (int64_t)primitiveStarCountValue;
- (void)setPrimitiveStarCountValue:(int64_t)value_;




- (NSNumber*)primitiveStarredByUser;
- (void)setPrimitiveStarredByUser:(NSNumber*)value;

- (BOOL)primitiveStarredByUserValue;
- (void)setPrimitiveStarredByUserValue:(BOOL)value_;




- (NSString*)primitiveThumbnailURL;
- (void)setPrimitiveThumbnailURL:(NSString*)value;




- (NSNumber*)primitiveViewCount;
- (void)setPrimitiveViewCount:(NSNumber*)value;

- (int64_t)primitiveViewCountValue;
- (void)setPrimitiveViewCountValue:(int64_t)value_;




- (NSNumber*)primitiveViewedByUser;
- (void)setPrimitiveViewedByUser:(NSNumber*)value;

- (BOOL)primitiveViewedByUserValue;
- (void)setPrimitiveViewedByUserValue:(BOOL)value_;





- (NSMutableSet*)primitiveVideoInstances;
- (void)setPrimitiveVideoInstances:(NSMutableSet*)value;


@end
