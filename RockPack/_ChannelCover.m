// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ChannelCover.m instead.

#import "_ChannelCover.h"

const struct ChannelCoverAttributes ChannelCoverAttributes = {
	.endU = @"endU",
	.endV = @"endV",
	.imageUrl = @"imageUrl",
	.startU = @"startU",
	.startV = @"startV",
};

const struct ChannelCoverRelationships ChannelCoverRelationships = {
	.channel = @"channel",
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
	
	if ([key isEqualToString:@"endUValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"endU"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"endVValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"endV"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"startUValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"startU"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"startVValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"startV"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic endU;



- (float)endUValue {
	NSNumber *result = [self endU];
	return [result floatValue];
}

- (void)setEndUValue:(float)value_ {
	[self setEndU:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveEndUValue {
	NSNumber *result = [self primitiveEndU];
	return [result floatValue];
}

- (void)setPrimitiveEndUValue:(float)value_ {
	[self setPrimitiveEndU:[NSNumber numberWithFloat:value_]];
}





@dynamic endV;



- (float)endVValue {
	NSNumber *result = [self endV];
	return [result floatValue];
}

- (void)setEndVValue:(float)value_ {
	[self setEndV:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveEndVValue {
	NSNumber *result = [self primitiveEndV];
	return [result floatValue];
}

- (void)setPrimitiveEndVValue:(float)value_ {
	[self setPrimitiveEndV:[NSNumber numberWithFloat:value_]];
}





@dynamic imageUrl;






@dynamic startU;



- (float)startUValue {
	NSNumber *result = [self startU];
	return [result floatValue];
}

- (void)setStartUValue:(float)value_ {
	[self setStartU:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveStartUValue {
	NSNumber *result = [self primitiveStartU];
	return [result floatValue];
}

- (void)setPrimitiveStartUValue:(float)value_ {
	[self setPrimitiveStartU:[NSNumber numberWithFloat:value_]];
}





@dynamic startV;



- (float)startVValue {
	NSNumber *result = [self startV];
	return [result floatValue];
}

- (void)setStartVValue:(float)value_ {
	[self setStartV:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveStartVValue {
	NSNumber *result = [self primitiveStartV];
	return [result floatValue];
}

- (void)setPrimitiveStartVValue:(float)value_ {
	[self setPrimitiveStartV:[NSNumber numberWithFloat:value_]];
}





@dynamic channel;

	






@end
