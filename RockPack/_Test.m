// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Test.m instead.

#import "_Test.h"

const struct TestAttributes TestAttributes = {
	.testBool = @"testBool",
	.testNumber = @"testNumber",
	.testString = @"testString",
};

const struct TestRelationships TestRelationships = {
};

const struct TestFetchedProperties TestFetchedProperties = {
};

@implementation TestID
@end

@implementation _Test

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Test" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Test";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Test" inManagedObjectContext:moc_];
}

- (TestID*)objectID {
	return (TestID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"testBoolValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"testBool"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"testNumberValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"testNumber"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"testStringValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"testString"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic testBool;



- (BOOL)testBoolValue {
	NSNumber *result = [self testBool];
	return [result boolValue];
}

- (void)setTestBoolValue:(BOOL)value_ {
	[self setTestBool:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveTestBoolValue {
	NSNumber *result = [self primitiveTestBool];
	return [result boolValue];
}

- (void)setPrimitiveTestBoolValue:(BOOL)value_ {
	[self setPrimitiveTestBool:[NSNumber numberWithBool:value_]];
}





@dynamic testNumber;



- (int64_t)testNumberValue {
	NSNumber *result = [self testNumber];
	return [result longLongValue];
}

- (void)setTestNumberValue:(int64_t)value_ {
	[self setTestNumber:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveTestNumberValue {
	NSNumber *result = [self primitiveTestNumber];
	return [result longLongValue];
}

- (void)setPrimitiveTestNumberValue:(int64_t)value_ {
	[self setPrimitiveTestNumber:[NSNumber numberWithLongLong:value_]];
}





@dynamic testString;



- (int64_t)testStringValue {
	NSNumber *result = [self testString];
	return [result longLongValue];
}

- (void)setTestStringValue:(int64_t)value_ {
	[self setTestString:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveTestStringValue {
	NSNumber *result = [self primitiveTestString];
	return [result longLongValue];
}

- (void)setPrimitiveTestStringValue:(int64_t)value_ {
	[self setPrimitiveTestString:[NSNumber numberWithLongLong:value_]];
}










@end
