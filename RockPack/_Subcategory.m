// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Subcategory.m instead.

#import "_Subcategory.h"

const struct SubcategoryAttributes SubcategoryAttributes = {
	.name = @"name",
};

const struct SubcategoryRelationships SubcategoryRelationships = {
	.category = @"category",
};

const struct SubcategoryFetchedProperties SubcategoryFetchedProperties = {
};

@implementation SubcategoryID
@end

@implementation _Subcategory

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Subcategory" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Subcategory";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Subcategory" inManagedObjectContext:moc_];
}

- (SubcategoryID*)objectID {
	return (SubcategoryID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic name;






@dynamic category;

	






@end
