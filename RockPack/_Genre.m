// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Genre.m instead.

#import "_Genre.h"

const struct GenreAttributes GenreAttributes = {
	.fresh = @"fresh",
	.markedForDeletion = @"markedForDeletion",
	.name = @"name",
	.priority = @"priority",
	.uniqueId = @"uniqueId",
	.viewId = @"viewId",
};

const struct GenreRelationships GenreRelationships = {
	.subgenres = @"subgenres",
};

const struct GenreFetchedProperties GenreFetchedProperties = {
};

@implementation GenreID
@end

@implementation _Genre

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Genre" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Genre";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Genre" inManagedObjectContext:moc_];
}

- (GenreID*)objectID {
	return (GenreID*)[super objectID];
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
	if ([key isEqualToString:@"priorityValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"priority"];
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





@dynamic name;






@dynamic priority;



- (int32_t)priorityValue {
	NSNumber *result = [self priority];
	return [result intValue];
}

- (void)setPriorityValue:(int32_t)value_ {
	[self setPriority:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitivePriorityValue {
	NSNumber *result = [self primitivePriority];
	return [result intValue];
}

- (void)setPrimitivePriorityValue:(int32_t)value_ {
	[self setPrimitivePriority:[NSNumber numberWithInt:value_]];
}





@dynamic uniqueId;






@dynamic viewId;






@dynamic subgenres;

	
- (NSMutableOrderedSet*)subgenresSet {
	[self willAccessValueForKey:@"subgenres"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"subgenres"];
  
	[self didAccessValueForKey:@"subgenres"];
	return result;
}
	






@end
