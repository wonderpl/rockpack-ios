// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.h instead.

#import <CoreData/CoreData.h>
#import "ChannelOwner.h"

extern const struct UserAttributes {
	__unsafe_unretained NSString *activityUrl;
	__unsafe_unretained NSString *coverartUrl;
	__unsafe_unretained NSString *current;
	__unsafe_unretained NSString *dateOfBirth;
	__unsafe_unretained NSString *emailAddress;
	__unsafe_unretained NSString *firstName;
	__unsafe_unretained NSString *fullNameIsPublic;
	__unsafe_unretained NSString *gender;
	__unsafe_unretained NSString *lastName;
	__unsafe_unretained NSString *locale;
	__unsafe_unretained NSString *subscriptionsUrl;
	__unsafe_unretained NSString *username;
} UserAttributes;

extern const struct UserRelationships {
} UserRelationships;

extern const struct UserFetchedProperties {
} UserFetchedProperties;















@interface UserID : NSManagedObjectID {}
@end

@interface _User : ChannelOwner {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (UserID*)objectID;





@property (nonatomic, strong) NSString* activityUrl;



//- (BOOL)validateActivityUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* coverartUrl;



//- (BOOL)validateCoverartUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* current;



@property BOOL currentValue;
- (BOOL)currentValue;
- (void)setCurrentValue:(BOOL)value_;

//- (BOOL)validateCurrent:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateOfBirth;



//- (BOOL)validateDateOfBirth:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* emailAddress;



//- (BOOL)validateEmailAddress:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* firstName;



//- (BOOL)validateFirstName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* fullNameIsPublic;



@property BOOL fullNameIsPublicValue;
- (BOOL)fullNameIsPublicValue;
- (void)setFullNameIsPublicValue:(BOOL)value_;

//- (BOOL)validateFullNameIsPublic:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* gender;



@property BOOL genderValue;
- (BOOL)genderValue;
- (void)setGenderValue:(BOOL)value_;

//- (BOOL)validateGender:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* lastName;



//- (BOOL)validateLastName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* locale;



//- (BOOL)validateLocale:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* subscriptionsUrl;



//- (BOOL)validateSubscriptionsUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* username;



//- (BOOL)validateUsername:(id*)value_ error:(NSError**)error_;






@end

@interface _User (CoreDataGeneratedAccessors)

@end

@interface _User (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveActivityUrl;
- (void)setPrimitiveActivityUrl:(NSString*)value;




- (NSString*)primitiveCoverartUrl;
- (void)setPrimitiveCoverartUrl:(NSString*)value;




- (NSNumber*)primitiveCurrent;
- (void)setPrimitiveCurrent:(NSNumber*)value;

- (BOOL)primitiveCurrentValue;
- (void)setPrimitiveCurrentValue:(BOOL)value_;




- (NSDate*)primitiveDateOfBirth;
- (void)setPrimitiveDateOfBirth:(NSDate*)value;




- (NSString*)primitiveEmailAddress;
- (void)setPrimitiveEmailAddress:(NSString*)value;




- (NSString*)primitiveFirstName;
- (void)setPrimitiveFirstName:(NSString*)value;




- (NSNumber*)primitiveFullNameIsPublic;
- (void)setPrimitiveFullNameIsPublic:(NSNumber*)value;

- (BOOL)primitiveFullNameIsPublicValue;
- (void)setPrimitiveFullNameIsPublicValue:(BOOL)value_;




- (NSNumber*)primitiveGender;
- (void)setPrimitiveGender:(NSNumber*)value;

- (BOOL)primitiveGenderValue;
- (void)setPrimitiveGenderValue:(BOOL)value_;




- (NSString*)primitiveLastName;
- (void)setPrimitiveLastName:(NSString*)value;




- (NSString*)primitiveLocale;
- (void)setPrimitiveLocale:(NSString*)value;




- (NSString*)primitiveSubscriptionsUrl;
- (void)setPrimitiveSubscriptionsUrl:(NSString*)value;




- (NSString*)primitiveUsername;
- (void)setPrimitiveUsername:(NSString*)value;




@end
