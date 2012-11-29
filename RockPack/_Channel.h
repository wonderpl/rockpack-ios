// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Channel.h instead.

#import <CoreData/CoreData.h>


extern const struct ChannelAttributes {
	__unsafe_unretained NSString *keyframeURL;
	__unsafe_unretained NSString *packedByUser;
	__unsafe_unretained NSString *rockedByUser;
	__unsafe_unretained NSString *subtitle;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *totalPacks;
	__unsafe_unretained NSString *totalRocks;
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





@property (nonatomic, strong) NSString* keyframeURL;



//- (BOOL)validateKeyframeURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* packedByUser;



@property BOOL packedByUserValue;
- (BOOL)packedByUserValue;
- (void)setPackedByUserValue:(BOOL)value_;

//- (BOOL)validatePackedByUser:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* rockedByUser;



@property BOOL rockedByUserValue;
- (BOOL)rockedByUserValue;
- (void)setRockedByUserValue:(BOOL)value_;

//- (BOOL)validateRockedByUser:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* subtitle;



//- (BOOL)validateSubtitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* totalPacks;



@property int64_t totalPacksValue;
- (int64_t)totalPacksValue;
- (void)setTotalPacksValue:(int64_t)value_;

//- (BOOL)validateTotalPacks:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* totalRocks;



@property int64_t totalRocksValue;
- (int64_t)totalRocksValue;
- (void)setTotalRocksValue:(int64_t)value_;

//- (BOOL)validateTotalRocks:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* wallpaperURL;



//- (BOOL)validateWallpaperURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *videos;

- (NSMutableSet*)videosSet;





@end

@interface _Channel (CoreDataGeneratedAccessors)

- (void)addVideos:(NSSet*)value_;
- (void)removeVideos:(NSSet*)value_;
- (void)addVideosObject:(Video*)value_;
- (void)removeVideosObject:(Video*)value_;

@end

@interface _Channel (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveKeyframeURL;
- (void)setPrimitiveKeyframeURL:(NSString*)value;




- (NSNumber*)primitivePackedByUser;
- (void)setPrimitivePackedByUser:(NSNumber*)value;

- (BOOL)primitivePackedByUserValue;
- (void)setPrimitivePackedByUserValue:(BOOL)value_;




- (NSNumber*)primitiveRockedByUser;
- (void)setPrimitiveRockedByUser:(NSNumber*)value;

- (BOOL)primitiveRockedByUserValue;
- (void)setPrimitiveRockedByUserValue:(BOOL)value_;




- (NSString*)primitiveSubtitle;
- (void)setPrimitiveSubtitle:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSNumber*)primitiveTotalPacks;
- (void)setPrimitiveTotalPacks:(NSNumber*)value;

- (int64_t)primitiveTotalPacksValue;
- (void)setPrimitiveTotalPacksValue:(int64_t)value_;




- (NSNumber*)primitiveTotalRocks;
- (void)setPrimitiveTotalRocks:(NSNumber*)value;

- (int64_t)primitiveTotalRocksValue;
- (void)setPrimitiveTotalRocksValue:(int64_t)value_;




- (NSString*)primitiveWallpaperURL;
- (void)setPrimitiveWallpaperURL:(NSString*)value;





- (NSMutableSet*)primitiveVideos;
- (void)setPrimitiveVideos:(NSMutableSet*)value;


@end
