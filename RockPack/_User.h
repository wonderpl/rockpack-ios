// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.h instead.

#import <CoreData/CoreData.h>
#import "ChannelOwner.h"

extern const struct UserAttributes {
	__unsafe_unretained NSString *current;
	__unsafe_unretained NSString *dateOfBirth;
	__unsafe_unretained NSString *emailAddress;
	__unsafe_unretained NSString *firstName;
	__unsafe_unretained NSString *lastName;
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





@property (nonatomic, strong) NSString* lastName;



//- (BOOL)validateLastName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* username;



//- (BOOL)validateUsername:(id*)value_ error:(NSError**)error_;






@end

@interface _User (CoreDataGeneratedAccessors)

@end

@interface _User (CoreDataGeneratedPrimitiveAccessors)


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




- (NSString*)primitiveLastName;
- (void)setPrimitiveLastName:(NSString*)value;




- (NSString*)primitiveUsername;
- (void)setPrimitiveUsername:(NSString*)value;




@end
