// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Category.h instead.

#import <CoreData/CoreData.h>
#import "AbstractCommon.h"

extern const struct CategoryAttributes {
	__unsafe_unretained NSString *name;
} CategoryAttributes;

extern const struct CategoryRelationships {
	__unsafe_unretained NSString *subcategories;
} CategoryRelationships;

extern const struct CategoryFetchedProperties {
} CategoryFetchedProperties;

@class Subcategory;



@interface CategoryID : NSManagedObjectID {}
@end

@interface _Category : AbstractCommon {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CategoryID*)objectID;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *subcategories;

- (NSMutableSet*)subcategoriesSet;





@end

@interface _Category (CoreDataGeneratedAccessors)

- (void)addSubcategories:(NSSet*)value_;
- (void)removeSubcategories:(NSSet*)value_;
- (void)addSubcategoriesObject:(Subcategory*)value_;
- (void)removeSubcategoriesObject:(Subcategory*)value_;

@end

@interface _Category (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (NSMutableSet*)primitiveSubcategories;
- (void)setPrimitiveSubcategories:(NSMutableSet*)value;


@end
