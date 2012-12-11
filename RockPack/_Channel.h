// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Channel.h instead.

#import <CoreData/CoreData.h>


extern const struct ChannelAttributes {
	__unsafe_unretained NSString *biog;
	__unsafe_unretained NSString *biogTitle;
	__unsafe_unretained NSString *index;
	__unsafe_unretained NSString *keyframeURL;
	__unsafe_unretained NSString *rockedByUser;
	__unsafe_unretained NSString *subtitle;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *totalRocks;
	__unsafe_unretained NSString *userGenerated;
	__unsafe_unretained NSString *wallpaperURL;
} ChannelAttributes;

extern const struct ChannelRelationships {
	__unsafe_unretained NSString *videos;
} ChannelRelationships;

extern const struct ChannelFetchedProperties {
} ChannelFetchedProperties;

@class Video;












@interface ChannelID : NSManagedObjectID {}
@end

@interface _Channel : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ChannelID*)objectID;





@property (nonatomic, strong) NSString* biog;



//- (BOOL)validateBiog:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* biogTitle;



//- (BOOL)validateBiogTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* index;



@property int64_t indexValue;
- (int64_t)indexValue;
- (void)setIndexValue:(int64_t)value_;

//- (BOOL)validateIndex:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* keyframeURL;



//- (BOOL)validateKeyframeURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* rockedByUser;



@property BOOL rockedByUserValue;
- (BOOL)rockedByUserValue;
- (void)setRockedByUserValue:(BOOL)value_;

//- (BOOL)validateRockedByUser:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* subtitle;



//- (BOOL)validateSubtitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* totalRocks;



@property int64_t totalRocksValue;
- (int64_t)totalRocksValue;
- (void)setTotalRocksValue:(int64_t)value_;

//- (BOOL)validateTotalRocks:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* userGenerated;



@property BOOL userGeneratedValue;
- (BOOL)userGeneratedValue;
- (void)setUserGeneratedValue:(BOOL)value_;

//- (BOOL)validateUserGenerated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wallpaperURL;



//- (BOOL)validateWallpaperURL:(id*)value_ error:(NSError**)error_;





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


- (NSString*)primitiveBiog;
- (void)setPrimitiveBiog:(NSString*)value;




- (NSString*)primitiveBiogTitle;
- (void)setPrimitiveBiogTitle:(NSString*)value;




- (NSNumber*)primitiveIndex;
- (void)setPrimitiveIndex:(NSNumber*)value;

- (int64_t)primitiveIndexValue;
- (void)setPrimitiveIndexValue:(int64_t)value_;




- (NSString*)primitiveKeyframeURL;
- (void)setPrimitiveKeyframeURL:(NSString*)value;




- (NSNumber*)primitiveRockedByUser;
- (void)setPrimitiveRockedByUser:(NSNumber*)value;

- (BOOL)primitiveRockedByUserValue;
- (void)setPrimitiveRockedByUserValue:(BOOL)value_;




- (NSString*)primitiveSubtitle;
- (void)setPrimitiveSubtitle:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSNumber*)primitiveTotalRocks;
- (void)setPrimitiveTotalRocks:(NSNumber*)value;

- (int64_t)primitiveTotalRocksValue;
- (void)setPrimitiveTotalRocksValue:(int64_t)value_;




- (NSNumber*)primitiveUserGenerated;
- (void)setPrimitiveUserGenerated:(NSNumber*)value;

- (BOOL)primitiveUserGeneratedValue;
- (void)setPrimitiveUserGeneratedValue:(BOOL)value_;




- (NSString*)primitiveWallpaperURL;
- (void)setPrimitiveWallpaperURL:(NSString*)value;





- (NSMutableOrderedSet*)primitiveVideos;
- (void)setPrimitiveVideos:(NSMutableOrderedSet*)value;


@end
