// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to VideoInstance.m instead.

#import "_VideoInstance.h"

const struct VideoInstanceAttributes VideoInstanceAttributes = {
	.dateAdded = @"dateAdded",
	.dateOfDayAdded = @"dateOfDayAdded",
	.fresh = @"fresh",
	.markedForDeletion = @"markedForDeletion",
	.position = @"position",
	.title = @"title",
	.uniqueId = @"uniqueId",
	.viewId = @"viewId",
};

const struct VideoInstanceRelationships VideoInstanceRelationships = {
	.channel = @"channel",
	.video = @"video",
};

const struct VideoInstanceFetchedProperties VideoInstanceFetchedProperties = {
};

@implementation VideoInstanceID
@end

@implementation _VideoInstance

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"VideoInstance" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"VideoInstance";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"VideoInstance" inManagedObjectContext:moc_];
}

- (VideoInstanceID*)objectID {
	return (VideoInstanceID*)[super objectID];
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
	if ([key isEqualToString:@"positionValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"position"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic dateAdded;






@dynamic dateOfDayAdded;






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





@dynamic position;



- (int64_t)positionValue {
	NSNumber *result = [self position];
	return [result longLongValue];
}

- (void)setPositionValue:(int64_t)value_ {
	[self setPosition:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitivePositionValue {
	NSNumber *result = [self primitivePosition];
	return [result longLongValue];
}

- (void)setPrimitivePositionValue:(int64_t)value_ {
	[self setPrimitivePosition:[NSNumber numberWithLongLong:value_]];
}





@dynamic title;






@dynamic uniqueId;






@dynamic viewId;






@dynamic channel;

	

@dynamic video;

	






@end
