// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Channel.m instead.

#import "_Channel.h"

const struct ChannelAttributes ChannelAttributes = {
	.categoryId = @"categoryId",
	.channelDescription = @"channelDescription",
	.coverThumbnailLargeURL = @"coverThumbnailLargeURL",
	.coverThumbnailSmallURL = @"coverThumbnailSmallURL",
	.eCommerceURL = @"eCommerceURL",
	.lastUpdated = @"lastUpdated",
	.popular = @"popular",
	.position = @"position",
	.resourceURL = @"resourceURL",
	.subscribedByUser = @"subscribedByUser",
	.subscribersCount = @"subscribersCount",
	.title = @"title",
	.viewId = @"viewId",
	.wallpaperURL = @"wallpaperURL",
};

const struct ChannelRelationships ChannelRelationships = {
	.channelOwner = @"channelOwner",
	.subscribers = @"subscribers",
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
	
	if ([key isEqualToString:@"popularValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"popular"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"positionValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"position"];
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






@dynamic coverThumbnailLargeURL;






@dynamic coverThumbnailSmallURL;






@dynamic eCommerceURL;






@dynamic lastUpdated;






@dynamic popular;



- (BOOL)popularValue {
	NSNumber *result = [self popular];
	return [result boolValue];
}

- (void)setPopularValue:(BOOL)value_ {
	[self setPopular:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitivePopularValue {
	NSNumber *result = [self primitivePopular];
	return [result boolValue];
}

- (void)setPrimitivePopularValue:(BOOL)value_ {
	[self setPrimitivePopular:[NSNumber numberWithBool:value_]];
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





@dynamic resourceURL;






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

	

@dynamic subscribers;

	
- (NSMutableSet*)subscribersSet {
	[self willAccessValueForKey:@"subscribers"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"subscribers"];
  
	[self didAccessValueForKey:@"subscribers"];
	return result;
}
	

@dynamic videoInstances;

	
- (NSMutableOrderedSet*)videoInstancesSet {
	[self willAccessValueForKey:@"videoInstances"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"videoInstances"];
  
	[self didAccessValueForKey:@"videoInstances"];
	return result;
}
	






@end
