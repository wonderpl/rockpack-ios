// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ChannelVideo.h instead.

#import <CoreData/CoreData.h>


extern const struct ChannelVideoAttributes {
	__unsafe_unretained NSString *addedToChannel;
	__unsafe_unretained NSString *channelVideoId;
} ChannelVideoAttributes;

extern const struct ChannelVideoRelationships {
	__unsafe_unretained NSString *channel;
	__unsafe_unretained NSString *video;
} ChannelVideoRelationships;

extern const struct ChannelVideoFetchedProperties {
} ChannelVideoFetchedProperties;

@class Channel;
@class Video;




@interface ChannelVideoID : NSManagedObjectID {}
@end

@interface _ChannelVideo : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ChannelVideoID*)objectID;





@property (nonatomic, strong) NSDate* addedToChannel;



//- (BOOL)validateAddedToChannel:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* channelVideoId;



@property int64_t channelVideoIdValue;
- (int64_t)channelVideoIdValue;
- (void)setChannelVideoIdValue:(int64_t)value_;

//- (BOOL)validateChannelVideoId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Channel *channel;

//- (BOOL)validateChannel:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) Video *video;

//- (BOOL)validateVideo:(id*)value_ error:(NSError**)error_;





@end

@interface _ChannelVideo (CoreDataGeneratedAccessors)

@end

@interface _ChannelVideo (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveAddedToChannel;
- (void)setPrimitiveAddedToChannel:(NSDate*)value;




- (NSNumber*)primitiveChannelVideoId;
- (void)setPrimitiveChannelVideoId:(NSNumber*)value;

- (int64_t)primitiveChannelVideoIdValue;
- (void)setPrimitiveChannelVideoIdValue:(int64_t)value_;





- (Channel*)primitiveChannel;
- (void)setPrimitiveChannel:(Channel*)value;



- (Video*)primitiveVideo;
- (void)setPrimitiveVideo:(Video*)value;


@end
