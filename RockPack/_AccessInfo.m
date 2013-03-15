// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to AccessInfo.m instead.

#import "_AccessInfo.h"

const struct AccessInfoAttributes AccessInfoAttributes = {
	.accessToken = @"accessToken",
	.expiryTime = @"expiryTime",
	.refreshToken = @"refreshToken",
	.resourceUrl = @"resourceUrl",
	.tokenType = @"tokenType",
	.userId = @"userId",
};

const struct AccessInfoRelationships AccessInfoRelationships = {
	.user = @"user",
};

const struct AccessInfoFetchedProperties AccessInfoFetchedProperties = {
};

@implementation AccessInfoID
@end

@implementation _AccessInfo

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"AccessInfo" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"AccessInfo";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"AccessInfo" inManagedObjectContext:moc_];
}

- (AccessInfoID*)objectID {
	return (AccessInfoID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"expiryTimeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"expiryTime"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic accessToken;






@dynamic expiryTime;



- (int64_t)expiryTimeValue {
	NSNumber *result = [self expiryTime];
	return [result longLongValue];
}

- (void)setExpiryTimeValue:(int64_t)value_ {
	[self setExpiryTime:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveExpiryTimeValue {
	NSNumber *result = [self primitiveExpiryTime];
	return [result longLongValue];
}

- (void)setPrimitiveExpiryTimeValue:(int64_t)value_ {
	[self setPrimitiveExpiryTime:[NSNumber numberWithLongLong:value_]];
}





@dynamic refreshToken;






@dynamic resourceUrl;






@dynamic tokenType;






@dynamic userId;






@dynamic user;

	






@end
