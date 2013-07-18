// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Genre.h instead.

#import <CoreData/CoreData.h>


extern const struct GenreAttributes {
	__unsafe_unretained NSString *fresh;
	__unsafe_unretained NSString *markedForDeletion;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *priority;
	__unsafe_unretained NSString *uniqueId;
	__unsafe_unretained NSString *viewId;
} GenreAttributes;

extern const struct GenreRelationships {
	__unsafe_unretained NSString *subgenres;
} GenreRelationships;

extern const struct GenreFetchedProperties {
} GenreFetchedProperties;

@class SubGenre;








@interface GenreID : NSManagedObjectID {}
@end

@interface _Genre : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (GenreID*)objectID;





@property (nonatomic, strong) NSNumber* fresh;



@property BOOL freshValue;
- (BOOL)freshValue;
- (void)setFreshValue:(BOOL)value_;

//- (BOOL)validateFresh:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* markedForDeletion;



@property BOOL markedForDeletionValue;
- (BOOL)markedForDeletionValue;
- (void)setMarkedForDeletionValue:(BOOL)value_;

//- (BOOL)validateMarkedForDeletion:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* priority;



@property int32_t priorityValue;
- (int32_t)priorityValue;
- (void)setPriorityValue:(int32_t)value_;

//- (BOOL)validatePriority:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* uniqueId;



//- (BOOL)validateUniqueId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* viewId;



//- (BOOL)validateViewId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSOrderedSet *subgenres;

- (NSMutableOrderedSet*)subgenresSet;





@end

@interface _Genre (CoreDataGeneratedAccessors)

- (void)addSubgenres:(NSOrderedSet*)value_;
- (void)removeSubgenres:(NSOrderedSet*)value_;
- (void)addSubgenresObject:(SubGenre*)value_;
- (void)removeSubgenresObject:(SubGenre*)value_;

@end

@interface _Genre (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveFresh;
- (void)setPrimitiveFresh:(NSNumber*)value;

- (BOOL)primitiveFreshValue;
- (void)setPrimitiveFreshValue:(BOOL)value_;




- (NSNumber*)primitiveMarkedForDeletion;
- (void)setPrimitiveMarkedForDeletion:(NSNumber*)value;

- (BOOL)primitiveMarkedForDeletionValue;
- (void)setPrimitiveMarkedForDeletionValue:(BOOL)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitivePriority;
- (void)setPrimitivePriority:(NSNumber*)value;

- (int32_t)primitivePriorityValue;
- (void)setPrimitivePriorityValue:(int32_t)value_;




- (NSString*)primitiveUniqueId;
- (void)setPrimitiveUniqueId:(NSString*)value;




- (NSString*)primitiveViewId;
- (void)setPrimitiveViewId:(NSString*)value;





- (NSMutableOrderedSet*)primitiveSubgenres;
- (void)setPrimitiveSubgenres:(NSMutableOrderedSet*)value;


@end
