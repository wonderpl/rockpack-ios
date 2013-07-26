// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Friend.m instead.

#import "_Friend.h"

const struct FriendAttributes FriendAttributes = {
	.externalSystem = @"externalSystem",
	.externalUID = @"externalUID",
	.hasIOSDevice = @"hasIOSDevice",
	.resourceURL = @"resourceURL",
};

const struct FriendRelationships FriendRelationships = {
};

const struct FriendFetchedProperties FriendFetchedProperties = {
};

@implementation FriendID
@end

@implementation _Friend

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Friend" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Friend";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Friend" inManagedObjectContext:moc_];
}

- (FriendID*)objectID {
	return (FriendID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"hasIOSDeviceValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"hasIOSDevice"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic externalSystem;






@dynamic externalUID;






@dynamic hasIOSDevice;



- (BOOL)hasIOSDeviceValue {
	NSNumber *result = [self hasIOSDevice];
	return [result boolValue];
}

- (void)setHasIOSDeviceValue:(BOOL)value_ {
	[self setHasIOSDevice:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveHasIOSDeviceValue {
	NSNumber *result = [self primitiveHasIOSDevice];
	return [result boolValue];
}

- (void)setPrimitiveHasIOSDeviceValue:(BOOL)value_ {
	[self setPrimitiveHasIOSDevice:[NSNumber numberWithBool:value_]];
}





@dynamic resourceURL;











@end
