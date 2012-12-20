// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Video.h instead.

#import <CoreData/CoreData.h>


extern const struct VideoAttributes {
	__unsafe_unretained NSString *source;
	__unsafe_unretained NSString *sourceId;
	__unsafe_unretained NSString *starCount;
	__unsafe_unretained NSString *starredByUser;
	__unsafe_unretained NSString *thumbnailURL;
	__unsafe_unretained NSString *title;
	__unsafe_unretained NSString *uniqueId;
} VideoAttributes;

extern const struct VideoRelationships {
	__unsafe_unretained NSString *channelVideos;
	__unsafe_unretained NSString *channels;
} VideoRelationships;

extern const struct VideoFetchedProperties {
} VideoFetchedProperties;

@class VideoInstance;
@class Channel;









@interface VideoID : NSManagedObjectID {}
@end

@interface _Video : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (VideoID*)objectID;





@property (nonatomic, strong) NSString* source;



//- (BOOL)validateSource:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* sourceId;



//- (BOOL)validateSourceId:(id*)value_ error:(NSError**)error_;





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





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* uniqueId;



//- (BOOL)validateUniqueId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) VideoInstance *channelVideos;

//- (BOOL)validateChannelVideos:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *channels;

- (NSMutableSet*)channelsSet;





@end

@interface _Video (CoreDataGeneratedAccessors)

- (void)addChannels:(NSSet*)value_;
- (void)removeChannels:(NSSet*)value_;
- (void)addChannelsObject:(Channel*)value_;
- (void)removeChannelsObject:(Channel*)value_;

@end

@interface _Video (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveSource;
- (void)setPrimitiveSource:(NSString*)value;




- (NSString*)primitiveSourceId;
- (void)setPrimitiveSourceId:(NSString*)value;




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




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




- (NSString*)primitiveUniqueId;
- (void)setPrimitiveUniqueId:(NSString*)value;





- (VideoInstance*)primitiveChannelVideos;
- (void)setPrimitiveChannelVideos:(VideoInstance*)value;



- (NSMutableSet*)primitiveChannels;
- (void)setPrimitiveChannels:(NSMutableSet*)value;


@end
