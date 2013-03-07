// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TabItem.m instead.

#import "_TabItem.h"

const struct TabItemAttributes TabItemAttributes = {
	.name = @"name",
	.priority = @"priority",
};

const struct TabItemRelationships TabItemRelationships = {
};

const struct TabItemFetchedProperties TabItemFetchedProperties = {
};

@implementation TabItemID
@end

@implementation _TabItem

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TabItem" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TabItem";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TabItem" inManagedObjectContext:moc_];
}

- (TabItemID*)objectID {
	return (TabItemID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"priorityValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"priority"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic name;






@dynamic priority;



- (int32_t)priorityValue {
	NSNumber *result = [self priority];
	return [result intValue];
}

- (void)setPriorityValue:(int32_t)value_ {
	[self setPriority:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitivePriorityValue {
	NSNumber *result = [self primitivePriority];
	return [result intValue];
}

- (void)setPrimitivePriorityValue:(int32_t)value_ {
	[self setPrimitivePriority:[NSNumber numberWithInt:value_]];
}










@end
