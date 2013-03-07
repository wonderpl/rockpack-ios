// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TabItem.h instead.

#import <CoreData/CoreData.h>
#import "AbstractCommon.h"

extern const struct TabItemAttributes {
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *priority;
} TabItemAttributes;

extern const struct TabItemRelationships {
} TabItemRelationships;

extern const struct TabItemFetchedProperties {
} TabItemFetchedProperties;





@interface TabItemID : NSManagedObjectID {}
@end

@interface _TabItem : AbstractCommon {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TabItemID*)objectID;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* priority;



@property int32_t priorityValue;
- (int32_t)priorityValue;
- (void)setPriorityValue:(int32_t)value_;

//- (BOOL)validatePriority:(id*)value_ error:(NSError**)error_;






@end

@interface _TabItem (CoreDataGeneratedAccessors)

@end

@interface _TabItem (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitivePriority;
- (void)setPrimitivePriority:(NSNumber*)value;

- (int32_t)primitivePriorityValue;
- (void)setPrimitivePriorityValue:(int32_t)value_;




@end
