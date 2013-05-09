// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ChannelCover.h instead.

#import <CoreData/CoreData.h>
#import "AbstractCommon.h"

extern const struct ChannelCoverAttributes {
	__unsafe_unretained NSString *backgroundURL;
	__unsafe_unretained NSString *carouselURL;
	__unsafe_unretained NSString *coverRef;
	__unsafe_unretained NSString *offsetX;
	__unsafe_unretained NSString *offsetY;
	__unsafe_unretained NSString *position;
	__unsafe_unretained NSString *viewId;
} ChannelCoverAttributes;

extern const struct ChannelCoverRelationships {
} ChannelCoverRelationships;

extern const struct ChannelCoverFetchedProperties {
} ChannelCoverFetchedProperties;










@interface ChannelCoverID : NSManagedObjectID {}
@end

@interface _ChannelCover : AbstractCommon {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ChannelCoverID*)objectID;





@property (nonatomic, strong) NSString* backgroundURL;



//- (BOOL)validateBackgroundURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* carouselURL;



//- (BOOL)validateCarouselURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* coverRef;



//- (BOOL)validateCoverRef:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* offsetX;



@property float offsetXValue;
- (float)offsetXValue;
- (void)setOffsetXValue:(float)value_;

//- (BOOL)validateOffsetX:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* offsetY;



@property float offsetYValue;
- (float)offsetYValue;
- (void)setOffsetYValue:(float)value_;

//- (BOOL)validateOffsetY:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* position;



@property int64_t positionValue;
- (int64_t)positionValue;
- (void)setPositionValue:(int64_t)value_;

//- (BOOL)validatePosition:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* viewId;



//- (BOOL)validateViewId:(id*)value_ error:(NSError**)error_;






@end

@interface _ChannelCover (CoreDataGeneratedAccessors)

@end

@interface _ChannelCover (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveBackgroundURL;
- (void)setPrimitiveBackgroundURL:(NSString*)value;




- (NSString*)primitiveCarouselURL;
- (void)setPrimitiveCarouselURL:(NSString*)value;




- (NSString*)primitiveCoverRef;
- (void)setPrimitiveCoverRef:(NSString*)value;




- (NSNumber*)primitiveOffsetX;
- (void)setPrimitiveOffsetX:(NSNumber*)value;

- (float)primitiveOffsetXValue;
- (void)setPrimitiveOffsetXValue:(float)value_;




- (NSNumber*)primitiveOffsetY;
- (void)setPrimitiveOffsetY:(NSNumber*)value;

- (float)primitiveOffsetYValue;
- (void)setPrimitiveOffsetYValue:(float)value_;




- (NSNumber*)primitivePosition;
- (void)setPrimitivePosition:(NSNumber*)value;

- (int64_t)primitivePositionValue;
- (void)setPrimitivePositionValue:(int64_t)value_;




- (NSString*)primitiveViewId;
- (void)setPrimitiveViewId:(NSString*)value;




@end
