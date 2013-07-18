// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CoverArt.h instead.

#import <CoreData/CoreData.h>


extern const struct CoverArtAttributes {
	__unsafe_unretained NSString *coverRef;
	__unsafe_unretained NSString *fresh;
	__unsafe_unretained NSString *markedForDeletion;
	__unsafe_unretained NSString *position;
	__unsafe_unretained NSString *thumbnailURL;
	__unsafe_unretained NSString *uniqueId;
	__unsafe_unretained NSString *userUpload;
	__unsafe_unretained NSString *viewId;
} CoverArtAttributes;

extern const struct CoverArtRelationships {
} CoverArtRelationships;

extern const struct CoverArtFetchedProperties {
} CoverArtFetchedProperties;











@interface CoverArtID : NSManagedObjectID {}
@end

@interface _CoverArt : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CoverArtID*)objectID;





@property (nonatomic, strong) NSString* coverRef;



//- (BOOL)validateCoverRef:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* fresh;



@property BOOL freshValue;
- (BOOL)freshValue;
- (void)setFreshValue:(BOOL)value_;

//- (BOOL)validateFresh:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* markedForDeletion;



@property BOOL markedForDeletionValue;
- (BOOL)markedForDeletionValue;
- (void)setMarkedForDeletionValue:(BOOL)value_;

//- (BOOL)validateMarkedForDeletion:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* position;



@property int64_t positionValue;
- (int64_t)positionValue;
- (void)setPositionValue:(int64_t)value_;

//- (BOOL)validatePosition:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* thumbnailURL;



//- (BOOL)validateThumbnailURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* uniqueId;



//- (BOOL)validateUniqueId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* userUpload;



@property BOOL userUploadValue;
- (BOOL)userUploadValue;
- (void)setUserUploadValue:(BOOL)value_;

//- (BOOL)validateUserUpload:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* viewId;



//- (BOOL)validateViewId:(id*)value_ error:(NSError**)error_;






@end

@interface _CoverArt (CoreDataGeneratedAccessors)

@end

@interface _CoverArt (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCoverRef;
- (void)setPrimitiveCoverRef:(NSString*)value;




- (NSNumber*)primitiveFresh;
- (void)setPrimitiveFresh:(NSNumber*)value;

- (BOOL)primitiveFreshValue;
- (void)setPrimitiveFreshValue:(BOOL)value_;




- (NSNumber*)primitiveMarkedForDeletion;
- (void)setPrimitiveMarkedForDeletion:(NSNumber*)value;

- (BOOL)primitiveMarkedForDeletionValue;
- (void)setPrimitiveMarkedForDeletionValue:(BOOL)value_;




- (NSNumber*)primitivePosition;
- (void)setPrimitivePosition:(NSNumber*)value;

- (int64_t)primitivePositionValue;
- (void)setPrimitivePositionValue:(int64_t)value_;




- (NSString*)primitiveThumbnailURL;
- (void)setPrimitiveThumbnailURL:(NSString*)value;




- (NSString*)primitiveUniqueId;
- (void)setPrimitiveUniqueId:(NSString*)value;




- (NSNumber*)primitiveUserUpload;
- (void)setPrimitiveUserUpload:(NSNumber*)value;

- (BOOL)primitiveUserUploadValue;
- (void)setPrimitiveUserUploadValue:(BOOL)value_;




- (NSString*)primitiveViewId;
- (void)setPrimitiveViewId:(NSString*)value;




@end
