// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to VideoInstance.m instead.

#import "_VideoInstance.h"

const struct VideoInstanceAttributes VideoInstanceAttributes = {
	.dateAdded = @"dateAdded",
	.title = @"title",
	.uniqueId = @"uniqueId",
};

const struct VideoInstanceRelationships VideoInstanceRelationships = {
	.channel = @"channel",
	.video = @"video",
};

const struct VideoInstanceFetchedProperties VideoInstanceFetchedProperties = {
};

@implementation VideoInstanceID
@end

@implementation _VideoInstance

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"VideoInstance" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"VideoInstance";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"VideoInstance" inManagedObjectContext:moc_];
}

- (VideoInstanceID*)objectID {
	return (VideoInstanceID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic dateAdded;






@dynamic title;






@dynamic uniqueId;






@dynamic channel;

	

@dynamic video;

	






@end
