// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Test.h instead.

#import <CoreData/CoreData.h>


extern const struct TestAttributes {
	__unsafe_unretained NSString *testBool;
	__unsafe_unretained NSString *testNumber;
	__unsafe_unretained NSString *testString;
} TestAttributes;

extern const struct TestRelationships {
} TestRelationships;

extern const struct TestFetchedProperties {
} TestFetchedProperties;






@interface TestID : NSManagedObjectID {}
@end

@interface _Test : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TestID*)objectID;





@property (nonatomic, strong) NSNumber* testBool;



@property BOOL testBoolValue;
- (BOOL)testBoolValue;
- (void)setTestBoolValue:(BOOL)value_;

//- (BOOL)validateTestBool:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* testNumber;



@property int64_t testNumberValue;
- (int64_t)testNumberValue;
- (void)setTestNumberValue:(int64_t)value_;

//- (BOOL)validateTestNumber:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* testString;



@property int64_t testStringValue;
- (int64_t)testStringValue;
- (void)setTestStringValue:(int64_t)value_;

//- (BOOL)validateTestString:(id*)value_ error:(NSError**)error_;






@end

@interface _Test (CoreDataGeneratedAccessors)

@end

@interface _Test (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveTestBool;
- (void)setPrimitiveTestBool:(NSNumber*)value;

- (BOOL)primitiveTestBoolValue;
- (void)setPrimitiveTestBoolValue:(BOOL)value_;




- (NSNumber*)primitiveTestNumber;
- (void)setPrimitiveTestNumber:(NSNumber*)value;

- (int64_t)primitiveTestNumberValue;
- (void)setPrimitiveTestNumberValue:(int64_t)value_;




- (NSNumber*)primitiveTestString;
- (void)setPrimitiveTestString:(NSNumber*)value;

- (int64_t)primitiveTestStringValue;
- (void)setPrimitiveTestStringValue:(int64_t)value_;




@end
