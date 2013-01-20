// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Channel.m instead.

#import "_Channel.h"

const struct ChannelAttributes ChannelAttributes = {
	.categoryId = @"categoryId",
	.channelDescription = @"channelDescription",
	.index = @"index",
	.lastUpdated = @"lastUpdated",
	.rockCount = @"rockCount",
	.rockedByUser = @"rockedByUser",
	.thumbnailURL = @"thumbnailURL",
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
	
	if ([key isEqualToString:@"indexValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"index"];
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

	return keyPaths;
}




@dynamic categoryId;






@dynamic channelDescription;






@dynamic index;



- (int64_t)indexValue {
	NSNumber *result = [self index];
	return [result longLongValue];
}

- (void)setIndexValue:(int64_t)value_ {
	[self setIndex:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveIndexValue {
	NSNumber *result = [self primitiveIndex];
	return [result longLongValue];
}

- (void)setPrimitiveIndexValue:(int64_t)value_ {
	[self setPrimitiveIndex:[NSNumber numberWithLongLong:value_]];
}





@dynamic lastUpdated;






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





@dynamic thumbnailURL;






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
