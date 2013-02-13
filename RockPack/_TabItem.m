// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TabItem.m instead.

#import "_TabItem.h"

const struct TabItemAttributes TabItemAttributes = {
	.name = @"name",
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
	

	return keyPaths;
}




@dynamic name;











@end
