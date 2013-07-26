// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to AbstractCommon.m instead.

#import "_AbstractCommon.h"

const struct AbstractCommonAttributes AbstractCommonAttributes = {
	.fresh = @"fresh",
	.markedForDeletion = @"markedForDeletion",
	.uniqueId = @"uniqueId",
	.viewId = @"viewId",
};

const struct AbstractCommonRelationships AbstractCommonRelationships = {
};

const struct AbstractCommonFetchedProperties AbstractCommonFetchedProperties = {
};

@implementation AbstractCommonID
@end

@implementation _AbstractCommon

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"AbstractCommon" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"AbstractCommon";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"AbstractCommon" inManagedObjectContext:moc_];
}

- (AbstractCommonID*)objectID {
	return (AbstractCommonID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"freshValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"fresh"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"markedForDeletionValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"markedForDeletion"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic fresh;



- (BOOL)freshValue {
	NSNumber *result = [self fresh];
	return [result boolValue];
}

- (void)setFreshValue:(BOOL)value_ {
	[self setFresh:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveFreshValue {
	NSNumber *result = [self primitiveFresh];
	return [result boolValue];
}

- (void)setPrimitiveFreshValue:(BOOL)value_ {
	[self setPrimitiveFresh:[NSNumber numberWithBool:value_]];
}





@dynamic markedForDeletion;



- (BOOL)markedForDeletionValue {
	NSNumber *result = [self markedForDeletion];
	return [result boolValue];
}

- (void)setMarkedForDeletionValue:(BOOL)value_ {
	[self setMarkedForDeletion:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveMarkedForDeletionValue {
	NSNumber *result = [self primitiveMarkedForDeletion];
	return [result boolValue];
}

- (void)setPrimitiveMarkedForDeletionValue:(BOOL)value_ {
	[self setPrimitiveMarkedForDeletion:[NSNumber numberWithBool:value_]];
}





@dynamic uniqueId;






@dynamic viewId;











@end
