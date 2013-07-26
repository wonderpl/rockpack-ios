// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ChannelOwner.m instead.

#import "_ChannelOwner.h"

const struct ChannelOwnerAttributes ChannelOwnerAttributes = {
	.displayName = @"displayName",
	.position = @"position",
	.thumbnailURL = @"thumbnailURL",
	.username = @"username",
};

const struct ChannelOwnerRelationships ChannelOwnerRelationships = {
	.channels = @"channels",
	.subscriptions = @"subscriptions",
};

const struct ChannelOwnerFetchedProperties ChannelOwnerFetchedProperties = {
};

@implementation ChannelOwnerID
@end

@implementation _ChannelOwner

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ChannelOwner" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ChannelOwner";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ChannelOwner" inManagedObjectContext:moc_];
}

- (ChannelOwnerID*)objectID {
	return (ChannelOwnerID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"positionValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"position"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic displayName;






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






@dynamic username;






@dynamic channels;

	
- (NSMutableOrderedSet*)channelsSet {
	[self willAccessValueForKey:@"channels"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"channels"];
  
	[self didAccessValueForKey:@"channels"];
	return result;
}
	

@dynamic subscriptions;

	
- (NSMutableOrderedSet*)subscriptionsSet {
	[self willAccessValueForKey:@"subscriptions"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"subscriptions"];
  
	[self didAccessValueForKey:@"subscriptions"];
	return result;
}
	






@end
