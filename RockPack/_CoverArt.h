// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CoverArt.h instead.

#import <CoreData/CoreData.h>
#import "AbstractCommon.h"

extern const struct CoverArtAttributes {
	__unsafe_unretained NSString *coverRef;
	__unsafe_unretained NSString *position;
	__unsafe_unretained NSString *thumbnailURL;
	__unsafe_unretained NSString *viewId;
} CoverArtAttributes;

extern const struct CoverArtRelationships {
} CoverArtRelationships;

extern const struct CoverArtFetchedProperties {
} CoverArtFetchedProperties;







@interface CoverArtID : NSManagedObjectID {}
@end

@interface _CoverArt : AbstractCommon {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CoverArtID*)objectID;





@property (nonatomic, strong) NSString* coverRef;



//- (BOOL)validateCoverRef:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* position;



@property int64_t positionValue;
- (int64_t)positionValue;
- (void)setPositionValue:(int64_t)value_;

//- (BOOL)validatePosition:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* thumbnailURL;



//- (BOOL)validateThumbnailURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* viewId;



//- (BOOL)validateViewId:(id*)value_ error:(NSError**)error_;






@end

@interface _CoverArt (CoreDataGeneratedAccessors)

@end

@interface _CoverArt (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCoverRef;
- (void)setPrimitiveCoverRef:(NSString*)value;




- (NSNumber*)primitivePosition;
- (void)setPrimitivePosition:(NSNumber*)value;

- (int64_t)primitivePositionValue;
- (void)setPrimitivePositionValue:(int64_t)value_;




- (NSString*)primitiveThumbnailURL;
- (void)setPrimitiveThumbnailURL:(NSString*)value;




- (NSString*)primitiveViewId;
- (void)setPrimitiveViewId:(NSString*)value;




@end
