// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Video.h instead.

#import <CoreData/CoreData.h>


extern const struct VideoAttributes {
	__unsafe_unretained NSString *channelName;
	__unsafe_unretained NSString *keyframeURL;
	__unsafe_unretained NSString *rockedByUser;
	__unsafe_unretained NSString *sourceIndex;
	__unsafe_unretained NSString *totalRocks;
	__unsafe_unretained NSString *userName;
	__unsafe_unretained NSString *videoTitle;
	__unsafe_unretained NSString *videoURL;
} VideoAttributes;

extern const struct VideoRelationships {
	__unsafe_unretained NSString *channels;
} VideoRelationships;

extern const struct VideoFetchedProperties {
} VideoFetchedProperties;

@class Channel;










@interface VideoID : NSManagedObjectID {}
@end

@interface _Video : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (VideoID*)objectID;





@property (nonatomic, strong) NSString* channelName;



//- (BOOL)validateChannelName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* keyframeURL;



//- (BOOL)validateKeyframeURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* rockedByUser;



@property BOOL rockedByUserValue;
- (BOOL)rockedByUserValue;
- (void)setRockedByUserValue:(BOOL)value_;

//- (BOOL)validateRockedByUser:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sourceIndex;



@property int64_t sourceIndexValue;
- (int64_t)sourceIndexValue;
- (void)setSourceIndexValue:(int64_t)value_;

//- (BOOL)validateSourceIndex:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* totalRocks;



@property int64_t totalRocksValue;
- (int64_t)totalRocksValue;
- (void)setTotalRocksValue:(int64_t)value_;

//- (BOOL)validateTotalRocks:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* userName;



//- (BOOL)validateUserName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* videoTitle;



//- (BOOL)validateVideoTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* videoURL;



//- (BOOL)validateVideoURL:(id*)value_ error:(NSError**)error_;





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


- (NSString*)primitiveChannelName;
- (void)setPrimitiveChannelName:(NSString*)value;




- (NSString*)primitiveKeyframeURL;
- (void)setPrimitiveKeyframeURL:(NSString*)value;




- (NSNumber*)primitiveRockedByUser;
- (void)setPrimitiveRockedByUser:(NSNumber*)value;

- (BOOL)primitiveRockedByUserValue;
- (void)setPrimitiveRockedByUserValue:(BOOL)value_;




- (NSNumber*)primitiveSourceIndex;
- (void)setPrimitiveSourceIndex:(NSNumber*)value;

- (int64_t)primitiveSourceIndexValue;
- (void)setPrimitiveSourceIndexValue:(int64_t)value_;




- (NSNumber*)primitiveTotalRocks;
- (void)setPrimitiveTotalRocks:(NSNumber*)value;

- (int64_t)primitiveTotalRocksValue;
- (void)setPrimitiveTotalRocksValue:(int64_t)value_;




- (NSString*)primitiveUserName;
- (void)setPrimitiveUserName:(NSString*)value;




- (NSString*)primitiveVideoTitle;
- (void)setPrimitiveVideoTitle:(NSString*)value;




- (NSString*)primitiveVideoURL;
- (void)setPrimitiveVideoURL:(NSString*)value;





- (NSMutableSet*)primitiveChannels;
- (void)setPrimitiveChannels:(NSMutableSet*)value;


@end
