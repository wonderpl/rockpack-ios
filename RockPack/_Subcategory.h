// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Subcategory.h instead.

#import <CoreData/CoreData.h>
#import "AbstractCommon.h"

extern const struct SubcategoryAttributes {
	__unsafe_unretained NSString *name;
} SubcategoryAttributes;

extern const struct SubcategoryRelationships {
	__unsafe_unretained NSString *category;
} SubcategoryRelationships;

extern const struct SubcategoryFetchedProperties {
} SubcategoryFetchedProperties;

@class Category;



@interface SubcategoryID : NSManagedObjectID {}
@end

@interface _Subcategory : AbstractCommon {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SubcategoryID*)objectID;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Category *category;

//- (BOOL)validateCategory:(id*)value_ error:(NSError**)error_;





@end

@interface _Subcategory (CoreDataGeneratedAccessors)

@end

@interface _Subcategory (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (Category*)primitiveCategory;
- (void)setPrimitiveCategory:(Category*)value;


@end
