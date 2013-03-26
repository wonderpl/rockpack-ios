// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.m instead.

#import "_User.h"

const struct UserAttributes UserAttributes = {
	.activityUrl = @"activityUrl",
	.coverartUrl = @"coverartUrl",
	.current = @"current",
	.dateOfBirth = @"dateOfBirth",
	.emailAddress = @"emailAddress",
	.firstName = @"firstName",
	.gender = @"gender",
	.lastName = @"lastName",
	.locale = @"locale",
	.subscriptionsUrl = @"subscriptionsUrl",
	.username = @"username",
};

const struct UserRelationships UserRelationships = {
};

const struct UserFetchedProperties UserFetchedProperties = {
};

@implementation UserID
@end

@implementation _User

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"User";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"User" inManagedObjectContext:moc_];
}

- (UserID*)objectID {
	return (UserID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"currentValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"current"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"genderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"gender"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic activityUrl;






@dynamic coverartUrl;






@dynamic current;



- (BOOL)currentValue {
	NSNumber *result = [self current];
	return [result boolValue];
}

- (void)setCurrentValue:(BOOL)value_ {
	[self setCurrent:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveCurrentValue {
	NSNumber *result = [self primitiveCurrent];
	return [result boolValue];
}

- (void)setPrimitiveCurrentValue:(BOOL)value_ {
	[self setPrimitiveCurrent:[NSNumber numberWithBool:value_]];
}





@dynamic dateOfBirth;






@dynamic emailAddress;






@dynamic firstName;






@dynamic gender;



- (BOOL)genderValue {
	NSNumber *result = [self gender];
	return [result boolValue];
}

- (void)setGenderValue:(BOOL)value_ {
	[self setGender:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveGenderValue {
	NSNumber *result = [self primitiveGender];
	return [result boolValue];
}

- (void)setPrimitiveGenderValue:(BOOL)value_ {
	[self setPrimitiveGender:[NSNumber numberWithBool:value_]];
}





@dynamic lastName;






@dynamic locale;






@dynamic subscriptionsUrl;






@dynamic username;











@end
