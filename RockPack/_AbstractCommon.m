// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to AbstractCommon.m instead.

#import "_AbstractCommon.h"

const struct AbstractCommonAttributes AbstractCommonAttributes = {
	.uniqueId = @"uniqueId",
};

const struct AbstractCommonRelationships AbstractCommonRelationships = {
};

const struct AbstractCommonFetchedProperties AbstractCommonFetchedProperties = {
};

@implementation AbstractCommonID
@end

@implementation _AbstractCommon

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"AbstractCommon" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"AbstractCommon";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"AbstractCommon" inManagedObjectContext:moc_];
}

- (AbstractCommonID*)objectID {
	return (AbstractCommonID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic uniqueId;











@end
