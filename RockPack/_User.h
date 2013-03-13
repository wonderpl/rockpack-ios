// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.h instead.

#import <CoreData/CoreData.h>


extern const struct UserAttributes {
	__unsafe_unretained NSString *dateOfBirth;
	__unsafe_unretained NSString *emailAddress;
	__unsafe_unretained NSString *firstName;
	__unsafe_unretained NSString *lastName;
	__unsafe_unretained NSString *thumbnailURL;
	__unsafe_unretained NSString *userName;
	__unsafe_unretained NSString *userid;
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





@property (nonatomic, strong) NSDate* dateOfBirth;



//- (BOOL)validateDateOfBirth:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* emailAddress;



//- (BOOL)validateEmailAddress:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* firstName;



//- (BOOL)validateFirstName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* lastName;



//- (BOOL)validateLastName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* thumbnailURL;



//- (BOOL)validateThumbnailURL:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* userName;



//- (BOOL)validateUserName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* userid;



//- (BOOL)validateUserid:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) AccessInfo *accessInfo;

//- (BOOL)validateAccessInfo:(id*)value_ error:(NSError**)error_;





@end

@interface _User (CoreDataGeneratedAccessors)

@end

@interface _User (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveDateOfBirth;
- (void)setPrimitiveDateOfBirth:(NSDate*)value;




- (NSString*)primitiveEmailAddress;
- (void)setPrimitiveEmailAddress:(NSString*)value;




- (NSString*)primitiveFirstName;
- (void)setPrimitiveFirstName:(NSString*)value;




- (NSString*)primitiveLastName;
- (void)setPrimitiveLastName:(NSString*)value;




- (NSString*)primitiveThumbnailURL;
- (void)setPrimitiveThumbnailURL:(NSString*)value;




- (NSString*)primitiveUserName;
- (void)setPrimitiveUserName:(NSString*)value;




- (NSString*)primitiveUserid;
- (void)setPrimitiveUserid:(NSString*)value;





- (AccessInfo*)primitiveAccessInfo;
- (void)setPrimitiveAccessInfo:(AccessInfo*)value;


@end
