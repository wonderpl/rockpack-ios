// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ChannelCover.h instead.

#import <CoreData/CoreData.h>


extern const struct ChannelCoverAttributes {
	__unsafe_unretained NSString *bottomRightX;
	__unsafe_unretained NSString *bottomRightY;
	__unsafe_unretained NSString *imageUrl;
	__unsafe_unretained NSString *topLeftX;
	__unsafe_unretained NSString *topLeftY;
} ChannelCoverAttributes;

extern const struct ChannelCoverRelationships {
	__unsafe_unretained NSString *channel;
} ChannelCoverRelationships;

extern const struct ChannelCoverFetchedProperties {
} ChannelCoverFetchedProperties;

@class Channel;







@interface ChannelCoverID : NSManagedObjectID {}
@end

@interface _ChannelCover : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ChannelCoverID*)objectID;





@property (nonatomic, strong) NSNumber* bottomRightX;



@property float bottomRightXValue;
- (float)bottomRightXValue;
- (void)setBottomRightXValue:(float)value_;

//- (BOOL)validateBottomRightX:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* bottomRightY;



@property float bottomRightYValue;
- (float)bottomRightYValue;
- (void)setBottomRightYValue:(float)value_;

//- (BOOL)validateBottomRightY:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* imageUrl;



//- (BOOL)validateImageUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* topLeftX;



@property float topLeftXValue;
- (float)topLeftXValue;
- (void)setTopLeftXValue:(float)value_;

//- (BOOL)validateTopLeftX:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* topLeftY;



@property float topLeftYValue;
- (float)topLeftYValue;
- (void)setTopLeftYValue:(float)value_;

//- (BOOL)validateTopLeftY:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Channel *channel;

//- (BOOL)validateChannel:(id*)value_ error:(NSError**)error_;





@end

@interface _ChannelCover (CoreDataGeneratedAccessors)

@end

@interface _ChannelCover (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveBottomRightX;
- (void)setPrimitiveBottomRightX:(NSNumber*)value;

- (float)primitiveBottomRightXValue;
- (void)setPrimitiveBottomRightXValue:(float)value_;




- (NSNumber*)primitiveBottomRightY;
- (void)setPrimitiveBottomRightY:(NSNumber*)value;

- (float)primitiveBottomRightYValue;
- (void)setPrimitiveBottomRightYValue:(float)value_;




- (NSString*)primitiveImageUrl;
- (void)setPrimitiveImageUrl:(NSString*)value;




- (NSNumber*)primitiveTopLeftX;
- (void)setPrimitiveTopLeftX:(NSNumber*)value;

- (float)primitiveTopLeftXValue;
- (void)setPrimitiveTopLeftXValue:(float)value_;




- (NSNumber*)primitiveTopLeftY;
- (void)setPrimitiveTopLeftY:(NSNumber*)value;

- (float)primitiveTopLeftYValue;
- (void)setPrimitiveTopLeftYValue:(float)value_;





- (Channel*)primitiveChannel;
- (void)setPrimitiveChannel:(Channel*)value;


@end
