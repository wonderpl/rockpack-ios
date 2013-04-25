// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ChanneCover.m instead.

#import "_ChanneCover.h"

const struct ChanneCoverAttributes ChanneCoverAttributes = {
	.backgroundURL = @"backgroundURL",
	.carouselURL = @"carouselURL",
	.coverRef = @"coverRef",
	.createdByUser = @"createdByUser",
	.position = @"position",
};

const struct ChanneCoverRelationships ChanneCoverRelationships = {
};

const struct ChanneCoverFetchedProperties ChanneCoverFetchedProperties = {
};

@implementation ChanneCoverID
@end

@implementation _ChanneCover

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ChanneCover" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ChanneCover";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ChanneCover" inManagedObjectContext:moc_];
}

- (ChanneCoverID*)objectID {
	return (ChanneCoverID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"createdByUserValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"createdByUser"];
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




@dynamic backgroundURL;






@dynamic carouselURL;






@dynamic coverRef;






@dynamic createdByUser;



- (BOOL)createdByUserValue {
	NSNumber *result = [self createdByUser];
	return [result boolValue];
}

- (void)setCreatedByUserValue:(BOOL)value_ {
	[self setCreatedByUser:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveCreatedByUserValue {
	NSNumber *result = [self primitiveCreatedByUser];
	return [result boolValue];
}

- (void)setPrimitiveCreatedByUserValue:(BOOL)value_ {
	[self setPrimitiveCreatedByUser:[NSNumber numberWithBool:value_]];
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










@end
