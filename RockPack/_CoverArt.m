// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CoverArt.m instead.

#import "_CoverArt.h"

const struct CoverArtAttributes CoverArtAttributes = {
	.coverRef = @"coverRef",
	.position = @"position",
	.thumbnailURL = @"thumbnailURL",
	.userUpload = @"userUpload",
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
	
	if ([key isEqualToString:@"positionValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"position"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"userUploadValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"userUpload"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic coverRef;






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






@dynamic userUpload;



- (BOOL)userUploadValue {
	NSNumber *result = [self userUpload];
	return [result boolValue];
}

- (void)setUserUploadValue:(BOOL)value_ {
	[self setUserUpload:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveUserUploadValue {
	NSNumber *result = [self primitiveUserUpload];
	return [result boolValue];
}

- (void)setPrimitiveUserUploadValue:(BOOL)value_ {
	[self setPrimitiveUserUpload:[NSNumber numberWithBool:value_]];
}










@end
