// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ChanneCover.h instead.

#import <CoreData/CoreData.h>
#import "AbstractCommon.h"

extern const struct ChanneCoverAttributes {
	__unsafe_unretained NSString *backgroundURL;
	__unsafe_unretained NSString *carouselURL;
	__unsafe_unretained NSString *coverRef;
	__unsafe_unretained NSString *createdByUser;
	__unsafe_unretained NSString *position;
} ChanneCoverAttributes;

extern const struct ChanneCoverRelationships {
} ChanneCoverRelationships;

extern const struct ChanneCoverFetchedProperties {
} ChanneCoverFetchedProperties;








@interface ChanneCoverID : NSManagedObjectID {}
@end

@interface _ChanneCover : AbstractCommon {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ChanneCoverID*)objectID;





@property (nonatomic, strong) NSString* backgroundURL;



//- (BOOL)validateBackgroundURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* carouselURL;



//- (BOOL)validateCarouselURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* coverRef;



//- (BOOL)validateCoverRef:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* createdByUser;



@property BOOL createdByUserValue;
- (BOOL)createdByUserValue;
- (void)setCreatedByUserValue:(BOOL)value_;

//- (BOOL)validateCreatedByUser:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* position;



@property int64_t positionValue;
- (int64_t)positionValue;
- (void)setPositionValue:(int64_t)value_;

//- (BOOL)validatePosition:(id*)value_ error:(NSError**)error_;






@end

@interface _ChanneCover (CoreDataGeneratedAccessors)

@end

@interface _ChanneCover (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveBackgroundURL;
- (void)setPrimitiveBackgroundURL:(NSString*)value;




- (NSString*)primitiveCarouselURL;
- (void)setPrimitiveCarouselURL:(NSString*)value;




- (NSString*)primitiveCoverRef;
- (void)setPrimitiveCoverRef:(NSString*)value;




- (NSNumber*)primitiveCreatedByUser;
- (void)setPrimitiveCreatedByUser:(NSNumber*)value;

- (BOOL)primitiveCreatedByUserValue;
- (void)setPrimitiveCreatedByUserValue:(BOOL)value_;




- (NSNumber*)primitivePosition;
- (void)setPrimitivePosition:(NSNumber*)value;

- (int64_t)primitivePositionValue;
- (void)setPrimitivePositionValue:(int64_t)value_;




@end
