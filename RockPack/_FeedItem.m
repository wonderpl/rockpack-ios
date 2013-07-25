// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FeedItem.m instead.

#import "_FeedItem.h"

const struct FeedItemAttributes FeedItemAttributes = {
	.coverIndexes = @"coverIndexes",
	.itemCount = @"itemCount",
	.resourceId = @"resourceId",
	.resourceType = @"resourceType",
	.title = @"title",
};

const struct FeedItemRelationships FeedItemRelationships = {
	.aggregate = @"aggregate",
	.feedItems = @"feedItems",
};

const struct FeedItemFetchedProperties FeedItemFetchedProperties = {
};

@implementation FeedItemID
@end

@implementation _FeedItem

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"FeedItem" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"FeedItem";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"FeedItem" inManagedObjectContext:moc_];
}

- (FeedItemID*)objectID {
	return (FeedItemID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"itemCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"itemCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic coverIndexes;






@dynamic itemCount;



- (int32_t)itemCountValue {
	NSNumber *result = [self itemCount];
	return [result intValue];
}

- (void)setItemCountValue:(int32_t)value_ {
	[self setItemCount:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveItemCountValue {
	NSNumber *result = [self primitiveItemCount];
	return [result intValue];
}

- (void)setPrimitiveItemCountValue:(int32_t)value_ {
	[self setPrimitiveItemCount:[NSNumber numberWithInt:value_]];
}





@dynamic resourceId;






@dynamic resourceType;






@dynamic title;






@dynamic aggregate;

	

@dynamic feedItems;

	
- (NSMutableSet*)feedItemsSet {
	[self willAccessValueForKey:@"feedItems"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"feedItems"];
  
	[self didAccessValueForKey:@"feedItems"];
	return result;
}
	






@end
