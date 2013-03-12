// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.h instead.

#import <CoreData/CoreData.h>


extern const struct UserAttributes {
	__unsafe_unretained NSString *forename;
	__unsafe_unretained NSString *surname;
	__unsafe_unretained NSString *thumbnailURL;
} UserAttributes;

extern const struct UserRelationships {
	__unsafe_unretained NSString *accessInfo;
} UserRelationships;

extern const struct UserFetchedProperties {
} UserFetchedProperties;

@class AccessInfo;





@interface UserID : NSManagedObjectID {}
@end

@interface _User : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (UserID*)objectID;





@property (nonatomic, strong) NSString* forename;



//- (BOOL)validateForename:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* surname;



//- (BOOL)validateSurname:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* thumbnailURL;



//- (BOOL)validateThumbnailURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) AccessInfo *accessInfo;

//- (BOOL)validateAccessInfo:(id*)value_ error:(NSError**)error_;





@end

@interface _User (CoreDataGeneratedAccessors)

@end

@interface _User (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveForename;
- (void)setPrimitiveForename:(NSString*)value;




- (NSString*)primitiveSurname;
- (void)setPrimitiveSurname:(NSString*)value;




- (NSString*)primitiveThumbnailURL;
- (void)setPrimitiveThumbnailURL:(NSString*)value;





- (AccessInfo*)primitiveAccessInfo;
- (void)setPrimitiveAccessInfo:(AccessInfo*)value;


@end
