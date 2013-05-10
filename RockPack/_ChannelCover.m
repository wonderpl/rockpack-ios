// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ChannelCover.m instead.

#import "_ChannelCover.h"

const struct ChannelCoverAttributes ChannelCoverAttributes = {
	.bottomRightX = @"bottomRightX",
	.bottomRightY = @"bottomRightY",
	.imageUrl = @"imageUrl",
	.topLeftX = @"topLeftX",
	.topLeftY = @"topLeftY",
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
	
	if ([key isEqualToString:@"bottomRightXValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"bottomRightX"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"bottomRightYValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"bottomRightY"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"topLeftXValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"topLeftX"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"topLeftYValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"topLeftY"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic bottomRightX;



- (float)bottomRightXValue {
	NSNumber *result = [self bottomRightX];
	return [result floatValue];
}

- (void)setBottomRightXValue:(float)value_ {
	[self setBottomRightX:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveBottomRightXValue {
	NSNumber *result = [self primitiveBottomRightX];
	return [result floatValue];
}

- (void)setPrimitiveBottomRightXValue:(float)value_ {
	[self setPrimitiveBottomRightX:[NSNumber numberWithFloat:value_]];
}





@dynamic bottomRightY;



- (float)bottomRightYValue {
	NSNumber *result = [self bottomRightY];
	return [result floatValue];
}

- (void)setBottomRightYValue:(float)value_ {
	[self setBottomRightY:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveBottomRightYValue {
	NSNumber *result = [self primitiveBottomRightY];
	return [result floatValue];
}

- (void)setPrimitiveBottomRightYValue:(float)value_ {
	[self setPrimitiveBottomRightY:[NSNumber numberWithFloat:value_]];
}





@dynamic imageUrl;






@dynamic topLeftX;



- (float)topLeftXValue {
	NSNumber *result = [self topLeftX];
	return [result floatValue];
}

- (void)setTopLeftXValue:(float)value_ {
	[self setTopLeftX:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveTopLeftXValue {
	NSNumber *result = [self primitiveTopLeftX];
	return [result floatValue];
}

- (void)setPrimitiveTopLeftXValue:(float)value_ {
	[self setPrimitiveTopLeftX:[NSNumber numberWithFloat:value_]];
}





@dynamic topLeftY;



- (float)topLeftYValue {
	NSNumber *result = [self topLeftY];
	return [result floatValue];
}

- (void)setTopLeftYValue:(float)value_ {
	[self setTopLeftY:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveTopLeftYValue {
	NSNumber *result = [self primitiveTopLeftY];
	return [result floatValue];
}

- (void)setPrimitiveTopLeftYValue:(float)value_ {
	[self setPrimitiveTopLeftY:[NSNumber numberWithFloat:value_]];
}





@dynamic channel;

	






@end
