// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SubGenre.m instead.

#import "_SubGenre.h"

const struct SubGenreAttributes SubGenreAttributes = {
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
	

	return keyPaths;
}




@dynamic genre;

	






@end
