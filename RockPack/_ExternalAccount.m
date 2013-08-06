// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ExternalAccount.m instead.

#import "_ExternalAccount.h"

const struct ExternalAccountAttributes ExternalAccountAttributes = {
	.expiration = @"expiration",
	.flags = @"flags",
	.permissions = @"permissions",
	.system = @"system",
	.token = @"token",
	.uid = @"uid",
	.url = @"url",
};

const struct ExternalAccountRelationships ExternalAccountRelationships = {
	.accountOwner = @"accountOwner",
};

const struct ExternalAccountFetchedProperties ExternalAccountFetchedProperties = {
};

@implementation ExternalAccountID
@end

@implementation _ExternalAccount

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ExternalAccount" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ExternalAccount";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ExternalAccount" inManagedObjectContext:moc_];
}

- (ExternalAccountID*)objectID {
	return (ExternalAccountID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"flagsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"flags"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic expiration;






@dynamic flags;



- (int32_t)flagsValue {
	NSNumber *result = [self flags];
	return [result intValue];
}

- (void)setFlagsValue:(int32_t)value_ {
	[self setFlags:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveFlagsValue {
	NSNumber *result = [self primitiveFlags];
	return [result intValue];
}

- (void)setPrimitiveFlagsValue:(int32_t)value_ {
	[self setPrimitiveFlags:[NSNumber numberWithInt:value_]];
}





@dynamic permissions;






@dynamic system;






@dynamic token;






@dynamic uid;






@dynamic url;






@dynamic accountOwner;

	






@end
