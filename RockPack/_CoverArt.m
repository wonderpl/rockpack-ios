// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CoverArt.m instead.

#import "_CoverArt.h"

const struct CoverArtAttributes CoverArtAttributes = {
	.coverRef = @"coverRef",
	.offsetX = @"offsetX",
	.offsetY = @"offsetY",
	.position = @"position",
	.thumbnailURL = @"thumbnailURL",
	.viewId = @"viewId",
};

const struct CoverArtRelationships CoverArtRelationships = {
};

const struct CoverArtFetchedProperties CoverArtFetchedProperties = {
};

@implementation CoverArtID
@end

@implementation _CoverArt

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CoverArt" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CoverArt";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CoverArt" inManagedObjectContext:moc_];
}

- (CoverArtID*)objectID {
	return (CoverArtID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"offsetXValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"offsetX"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"offsetYValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"offsetY"];
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




@dynamic coverRef;






@dynamic offsetX;



- (float)offsetXValue {
	NSNumber *result = [self offsetX];
	return [result floatValue];
}

- (void)setOffsetXValue:(float)value_ {
	[self setOffsetX:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveOffsetXValue {
	NSNumber *result = [self primitiveOffsetX];
	return [result floatValue];
}

- (void)setPrimitiveOffsetXValue:(float)value_ {
	[self setPrimitiveOffsetX:[NSNumber numberWithFloat:value_]];
}





@dynamic offsetY;



- (float)offsetYValue {
	NSNumber *result = [self offsetY];
	return [result floatValue];
}

- (void)setOffsetYValue:(float)value_ {
	[self setOffsetY:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveOffsetYValue {
	NSNumber *result = [self primitiveOffsetY];
	return [result floatValue];
}

- (void)setPrimitiveOffsetYValue:(float)value_ {
	[self setPrimitiveOffsetY:[NSNumber numberWithFloat:value_]];
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





@dynamic thumbnailURL;






@dynamic viewId;











@end
