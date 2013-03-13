// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to AccessInfo.h instead.

#import <CoreData/CoreData.h>


extern const struct AccessInfoAttributes {
	__unsafe_unretained NSString *accessToken;
	__unsafe_unretained NSString *expiryTime;
	__unsafe_unretained NSString *refreshToken;
	__unsafe_unretained NSString *resourceUrl;
	__unsafe_unretained NSString *tokenType;
	__unsafe_unretained NSString *userId;
} AccessInfoAttributes;

extern const struct AccessInfoRelationships {
	__unsafe_unretained NSString *user;
} AccessInfoRelationships;

extern const struct AccessInfoFetchedProperties {
} AccessInfoFetchedProperties;

@class User;








@interface AccessInfoID : NSManagedObjectID {}
@end

@interface _AccessInfo : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (AccessInfoID*)objectID;





@property (nonatomic, strong) NSString* accessToken;



//- (BOOL)validateAccessToken:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* expiryTime;



@property int64_t expiryTimeValue;
- (int64_t)expiryTimeValue;
- (void)setExpiryTimeValue:(int64_t)value_;

//- (BOOL)validateExpiryTime:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* refreshToken;



//- (BOOL)validateRefreshToken:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* resourceUrl;



//- (BOOL)validateResourceUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* tokenType;



//- (BOOL)validateTokenType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* userId;



//- (BOOL)validateUserId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) User *user;

//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;





@end

@interface _AccessInfo (CoreDataGeneratedAccessors)

@end

@interface _AccessInfo (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAccessToken;
- (void)setPrimitiveAccessToken:(NSString*)value;




- (NSNumber*)primitiveExpiryTime;
- (void)setPrimitiveExpiryTime:(NSNumber*)value;

- (int64_t)primitiveExpiryTimeValue;
- (void)setPrimitiveExpiryTimeValue:(int64_t)value_;




- (NSString*)primitiveRefreshToken;
- (void)setPrimitiveRefreshToken:(NSString*)value;




- (NSString*)primitiveResourceUrl;
- (void)setPrimitiveResourceUrl:(NSString*)value;




- (NSString*)primitiveTokenType;
- (void)setPrimitiveTokenType:(NSString*)value;




- (NSString*)primitiveUserId;
- (void)setPrimitiveUserId:(NSString*)value;





- (User*)primitiveUser;
- (void)setPrimitiveUser:(User*)value;


@end
