// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Channel.m instead.

#import "_Channel.h"

const struct ChannelAttributes ChannelAttributes = {
	.keyframeURL = @"keyframeURL",
	.packedByUser = @"packedByUser",
	.rockedByUser = @"rockedByUser",
	.subtitle = @"subtitle",
	.title = @"title",
	.totalPacks = @"totalPacks",
	.totalRocks = @"totalRocks",
	.wallpaperURL = @"wallpaperURL",
};

const struct ChannelRelationships ChannelRelationships = {
	.videos = @"videos",
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
	
	if ([key isEqualToString:@"packedByUserValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"packedByUser"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"rockedByUserValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rockedByUser"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"totalPacksValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"totalPacks"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"totalRocksValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"totalRocks"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic keyframeURL;






@dynamic packedByUser;



- (BOOL)packedByUserValue {
	NSNumber *result = [self packedByUser];
	return [result boolValue];
}

- (void)setPackedByUserValue:(BOOL)value_ {
	[self setPackedByUser:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitivePackedByUserValue {
	NSNumber *result = [self primitivePackedByUser];
	return [result boolValue];
}

- (void)setPrimitivePackedByUserValue:(BOOL)value_ {
	[self setPrimitivePackedByUser:[NSNumber numberWithBool:value_]];
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





@dynamic subtitle;






@dynamic title;






@dynamic totalPacks;



- (int64_t)totalPacksValue {
	NSNumber *result = [self totalPacks];
	return [result longLongValue];
}

- (void)setTotalPacksValue:(int64_t)value_ {
	[self setTotalPacks:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveTotalPacksValue {
	NSNumber *result = [self primitiveTotalPacks];
	return [result longLongValue];
}

- (void)setPrimitiveTotalPacksValue:(int64_t)value_ {
	[self setPrimitiveTotalPacks:[NSNumber numberWithLongLong:value_]];
}





@dynamic totalRocks;



- (int64_t)totalRocksValue {
	NSNumber *result = [self totalRocks];
	return [result longLongValue];
}

- (void)setTotalRocksValue:(int64_t)value_ {
	[self setTotalRocks:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveTotalRocksValue {
	NSNumber *result = [self primitiveTotalRocks];
	return [result longLongValue];
}

- (void)setPrimitiveTotalRocksValue:(int64_t)value_ {
	[self setPrimitiveTotalRocks:[NSNumber numberWithLongLong:value_]];
}





@dynamic wallpaperURL;






@dynamic videos;

	
- (NSMutableSet*)videosSet {
	[self willAccessValueForKey:@"videos"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"videos"];
  
	[self didAccessValueForKey:@"videos"];
	return result;
}
	






@end
