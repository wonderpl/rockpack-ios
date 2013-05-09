// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Genre.h instead.

#import <CoreData/CoreData.h>
#import "TabItem.h"

extern const struct GenreAttributes {
} GenreAttributes;

extern const struct GenreRelationships {
	__unsafe_unretained NSString *subgenres;
} GenreRelationships;

extern const struct GenreFetchedProperties {
} GenreFetchedProperties;

@class SubGenre;


@interface GenreID : NSManagedObjectID {}
@end

@interface _Genre : TabItem {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (GenreID*)objectID;





@property (nonatomic, strong) NSSet *subgenres;

- (NSMutableSet*)subgenresSet;





@end

@interface _Genre (CoreDataGeneratedAccessors)

- (void)addSubgenres:(NSSet*)value_;
- (void)removeSubgenres:(NSSet*)value_;
- (void)addSubgenresObject:(SubGenre*)value_;
- (void)removeSubgenresObject:(SubGenre*)value_;

@end

@interface _Genre (CoreDataGeneratedPrimitiveAccessors)



- (NSMutableSet*)primitiveSubgenres;
- (void)setPrimitiveSubgenres:(NSMutableSet*)value;


@end
