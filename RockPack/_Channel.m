// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Channel.m instead.

#import "_Channel.h"

const struct ChannelAttributes ChannelAttributes = {
	.categoryId = @"categoryId",
	.channelDescription = @"channelDescription",
	.coverBackgroundURL = @"coverBackgroundURL",
	.coverThumbnailLargeURL = @"coverThumbnailLargeURL",
	.coverThumbnailSmallURL = @"coverThumbnailSmallURL",
	.lastUpdated = @"lastUpdated",
	.position = @"position",
	.resourceURL = @"resourceURL",
	.rockCount = @"rockCount",
	.rockedByUser = @"rockedByUser",
	.subscribedByUser = @"subscribedByUser",
	.subscribersCount = @"subscribersCount",
	.title = @"title",
	.viewId = @"viewId",
	.wallpaperURL = @"wallpaperURL",
};

const struct ChannelRelationships ChannelRelationships = {
	.channelOwner = @"channelOwner",
	.videoInstances = @"videoInstances",
};

const struct ChannelFetchedProperties ChannelFetchedProperties = {
};

@implementation ChannelID
@end

@implementation _Channel

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Channel" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Channel";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Channel" inManagedObjectContext:moc_];
}

- (ChannelID*)objectID {
	return (ChannelID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"positionValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"position"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"rockCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rockCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"rockedByUserValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rockedByUser"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"subscribedByUserValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"subscribedByUser"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"subscribersCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"subscribersCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic categoryId;






@dynamic channelDescription;






@dynamic coverBackgroundURL;






@dynamic coverThumbnailLargeURL;






@dynamic coverThumbnailSmallURL;






@dynamic lastUpdated;






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





@dynamic resourceURL;






@dynamic rockCount;



- (int64_t)rockCountValue {
	NSNumber *result = [self rockCount];
	return [result longLongValue];
}

- (void)setRockCountValue:(int64_t)value_ {
	[self setRockCount:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveRockCountValue {
	NSNumber *result = [self primitiveRockCount];
	return [result longLongValue];
}

- (void)setPrimitiveRockCountValue:(int64_t)value_ {
	[self setPrimitiveRockCount:[NSNumber numberWithLongLong:value_]];
}





@dynamic rockedByUser;



- (BOOL)rockedByUserValue {
	NSNumber *result = [self rockedByUser];
	return [result boolValue];
}

- (void)setRockedByUserValue:(BOOL)value_ {
	[self setRockedByUser:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveRockedByUserValue {
	NSNumber *result = [self primitiveRockedByUser];
	return [result boolValue];
}

- (void)setPrimitiveRockedByUserValue:(BOOL)value_ {
	[self setPrimitiveRockedByUser:[NSNumber numberWithBool:value_]];
}





@dynamic subscribedByUser;



- (BOOL)subscribedByUserValue {
	NSNumber *result = [self subscribedByUser];
	return [result boolValue];
}

- (void)setSubscribedByUserValue:(BOOL)value_ {
	[self setSubscribedByUser:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveSubscribedByUserValue {
	NSNumber *result = [self primitiveSubscribedByUser];
	return [result boolValue];
}

- (void)setPrimitiveSubscribedByUserValue:(BOOL)value_ {
	[self setPrimitiveSubscribedByUser:[NSNumber numberWithBool:value_]];
}





@dynamic subscribersCount;



- (int64_t)subscribersCountValue {
	NSNumber *result = [self subscribersCount];
	return [result longLongValue];
}

- (void)setSubscribersCountValue:(int64_t)value_ {
	[self setSubscribersCount:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveSubscribersCountValue {
	NSNumber *result = [self primitiveSubscribersCount];
	return [result longLongValue];
}

- (void)setPrimitiveSubscribersCountValue:(int64_t)value_ {
	[self setPrimitiveSubscribersCount:[NSNumber numberWithLongLong:value_]];
}





@dynamic title;






@dynamic viewId;






@dynamic wallpaperURL;






@dynamic channelOwner;

	

@dynamic videoInstances;

	
- (NSMutableOrderedSet*)videoInstancesSet {
	[self willAccessValueForKey:@"videoInstances"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"videoInstances"];
  
	[self didAccessValueForKey:@"videoInstances"];
	return result;
}
	






@end
