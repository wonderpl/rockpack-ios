// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Video.m instead.

#import "_Video.h"

const struct VideoAttributes VideoAttributes = {
	.categoryId = @"categoryId",
	.source = @"source",
	.sourceId = @"sourceId",
	.starCount = @"starCount",
	.starredByUser = @"starredByUser",
	.thumbnailURL = @"thumbnailURL",
};

const struct VideoRelationships VideoRelationships = {
	.videoInstance = @"videoInstance",
};

const struct VideoFetchedProperties VideoFetchedProperties = {
};

@implementation VideoID
@end

@implementation _Video

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Video" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Video";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Video" inManagedObjectContext:moc_];
}

- (VideoID*)objectID {
	return (VideoID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"starCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"starCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"starredByUserValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"starredByUser"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic categoryId;






@dynamic source;






@dynamic sourceId;






@dynamic starCount;



- (int64_t)starCountValue {
	NSNumber *result = [self starCount];
	return [result longLongValue];
}

- (void)setStarCountValue:(int64_t)value_ {
	[self setStarCount:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveStarCountValue {
	NSNumber *result = [self primitiveStarCount];
	return [result longLongValue];
}

- (void)setPrimitiveStarCountValue:(int64_t)value_ {
	[self setPrimitiveStarCount:[NSNumber numberWithLongLong:value_]];
}





@dynamic starredByUser;



- (BOOL)starredByUserValue {
	NSNumber *result = [self starredByUser];
	return [result boolValue];
}

- (void)setStarredByUserValue:(BOOL)value_ {
	[self setStarredByUser:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveStarredByUserValue {
	NSNumber *result = [self primitiveStarredByUser];
	return [result boolValue];
}

- (void)setPrimitiveStarredByUserValue:(BOOL)value_ {
	[self setPrimitiveStarredByUser:[NSNumber numberWithBool:value_]];
}





@dynamic thumbnailURL;






@dynamic videoInstance;

	
- (NSMutableSet*)videoInstanceSet {
	[self willAccessValueForKey:@"videoInstance"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"videoInstance"];
  
	[self didAccessValueForKey:@"videoInstance"];
	return result;
}
	






@end
