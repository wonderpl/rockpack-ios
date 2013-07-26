// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SubGenre.m instead.

#import "_SubGenre.h"

const struct SubGenreAttributes SubGenreAttributes = {
	.isDefault = @"isDefault",
};

const struct SubGenreRelationships SubGenreRelationships = {
	.genre = @"genre",
};

const struct SubGenreFetchedProperties SubGenreFetchedProperties = {
};

@implementation SubGenreID
@end

@implementation _SubGenre

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"SubGenre" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"SubGenre";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"SubGenre" inManagedObjectContext:moc_];
}

- (SubGenreID*)objectID {
	return (SubGenreID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"isDefaultValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isDefault"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic isDefault;



- (BOOL)isDefaultValue {
	NSNumber *result = [self isDefault];
	return [result boolValue];
}

- (void)setIsDefaultValue:(BOOL)value_ {
	[self setIsDefault:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsDefaultValue {
	NSNumber *result = [self primitiveIsDefault];
	return [result boolValue];
}

- (void)setPrimitiveIsDefaultValue:(BOOL)value_ {
	[self setPrimitiveIsDefault:[NSNumber numberWithBool:value_]];
}





@dynamic genre;

	






@end
