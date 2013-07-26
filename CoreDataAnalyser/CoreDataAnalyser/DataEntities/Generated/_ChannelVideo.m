// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ChannelVideo.m instead.

#import "_ChannelVideo.h"

const struct ChannelVideoAttributes ChannelVideoAttributes = {
	.addedToChannel = @"addedToChannel",
	.channelVideoId = @"channelVideoId",
};

const struct ChannelVideoRelationships ChannelVideoRelationships = {
	.channel = @"channel",
	.video = @"video",
};

const struct ChannelVideoFetchedProperties ChannelVideoFetchedProperties = {
};

@implementation ChannelVideoID
@end

@implementation _ChannelVideo

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

- (ChannelVideoID*)objectID {
	return (ChannelVideoID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"channelVideoIdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"channelVideoId"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic addedToChannel;






@dynamic channelVideoId;



- (int64_t)channelVideoIdValue {
	NSNumber *result = [self channelVideoId];
	return [result longLongValue];
}

- (void)setChannelVideoIdValue:(int64_t)value_ {
	[self setChannelVideoId:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveChannelVideoIdValue {
	NSNumber *result = [self primitiveChannelVideoId];
	return [result longLongValue];
}

- (void)setPrimitiveChannelVideoIdValue:(int64_t)value_ {
	[self setPrimitiveChannelVideoId:[NSNumber numberWithLongLong:value_]];
}





@dynamic channel;

	

@dynamic video;

	






@end
