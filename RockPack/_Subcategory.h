// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Subcategory.h instead.

#import <CoreData/CoreData.h>
#import "TabItem.h"

extern const struct SubcategoryAttributes {
} SubcategoryAttributes;

extern const struct SubcategoryRelationships {
	__unsafe_unretained NSString *category;
} SubcategoryRelationships;

extern const struct SubcategoryFetchedProperties {
} SubcategoryFetchedProperties;

@class Category;


@interface SubcategoryID : NSManagedObjectID {}
@end

@interface _Subcategory : TabItem {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SubcategoryID*)objectID;





@property (nonatomic, strong) Category *category;

//- (BOOL)validateCategory:(id*)value_ error:(NSError**)error_;





@end

@interface _Subcategory (CoreDataGeneratedAccessors)

@end

@interface _Subcategory (CoreDataGeneratedPrimitiveAccessors)



- (Category*)primitiveCategory;
- (void)setPrimitiveCategory:(Category*)value;


@end
