// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Video.m instead.

#import "_Video.h"

const struct VideoAttributes VideoAttributes = {
	.keyframeURL = @"keyframeURL",
	.rockedByUser = @"rockedByUser",
	.sourceIndex = @"sourceIndex",
	.subtitle = @"subtitle",
	.title = @"title",
	.totalRocks = @"totalRocks",
	.videoURL = @"videoURL",
};

const struct VideoRelationships VideoRelationships = {
	.channels = @"channels",
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
	
	if ([key isEqualToString:@"rockedByUserValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rockedByUser"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"sourceIndexValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sourceIndex"];
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





@dynamic sourceIndex;



- (int64_t)sourceIndexValue {
	NSNumber *result = [self sourceIndex];
	return [result longLongValue];
}

- (void)setSourceIndexValue:(int64_t)value_ {
	[self setSourceIndex:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveSourceIndexValue {
	NSNumber *result = [self primitiveSourceIndex];
	return [result longLongValue];
}

- (void)setPrimitiveSourceIndexValue:(int64_t)value_ {
	[self setPrimitiveSourceIndex:[NSNumber numberWithLongLong:value_]];
}





@dynamic subtitle;






@dynamic title;






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





@dynamic videoURL;






@dynamic channels;

	
- (NSMutableSet*)channelsSet {
	[self willAccessValueForKey:@"channels"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"channels"];
  
	[self didAccessValueForKey:@"channels"];
	return result;
}
	






@end
