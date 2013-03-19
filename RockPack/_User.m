// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.m instead.

#import "_User.h"

const struct UserAttributes UserAttributes = {
	.current = @"current",
	.dateOfBirth = @"dateOfBirth",
	.emailAddress = @"emailAddress",
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

	return keyPaths;
}




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






@dynamic username;











@end
