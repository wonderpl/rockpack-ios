// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ChannelCover.m instead.

#import "_ChannelCover.h"

const struct ChannelCoverAttributes ChannelCoverAttributes = {
	.backgroundURL = @"backgroundURL",
	.carouselURL = @"carouselURL",
	.coverRef = @"coverRef",
	.position = @"position",
	.viewId = @"viewId",
};

const struct ChannelCoverRelationships ChannelCoverRelationships = {
};

const struct ChannelCoverFetchedProperties ChannelCoverFetchedProperties = {
};

@implementation ChannelCoverID
@end

@implementation _ChannelCover

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ChannelCover" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ChannelCover";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ChannelCover" inManagedObjectContext:moc_];
}

- (ChannelCoverID*)objectID {
	return (ChannelCoverID*)[super objectID];
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




@dynamic backgroundURL;






@dynamic carouselURL;






@dynamic coverRef;






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





@dynamic viewId;











@end
