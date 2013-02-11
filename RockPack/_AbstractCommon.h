// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to AbstractCommon.h instead.

#import <CoreData/CoreData.h>


extern const struct AbstractCommonAttributes {
	__unsafe_unretained NSString *uniqueId;
} AbstractCommonAttributes;

extern const struct AbstractCommonRelationships {
} AbstractCommonRelationships;

extern const struct AbstractCommonFetchedProperties {
} AbstractCommonFetchedProperties;




@interface AbstractCommonID : NSManagedObjectID {}
@end

@interface _AbstractCommon : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (AbstractCommonID*)objectID;





@property (nonatomic, strong) NSString* uniqueId;



//- (BOOL)validateUniqueId:(id*)value_ error:(NSError**)error_;






@end

@interface _AbstractCommon (CoreDataGeneratedAccessors)

@end

@interface _AbstractCommon (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveUniqueId;
- (void)setPrimitiveUniqueId:(NSString*)value;




@end
