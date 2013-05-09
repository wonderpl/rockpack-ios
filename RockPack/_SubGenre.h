// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SubGenre.h instead.

#import <CoreData/CoreData.h>
#import "TabItem.h"

extern const struct SubGenreAttributes {
} SubGenreAttributes;

extern const struct SubGenreRelationships {
	__unsafe_unretained NSString *genre;
} SubGenreRelationships;

extern const struct SubGenreFetchedProperties {
} SubGenreFetchedProperties;

@class Genre;


@interface SubGenreID : NSManagedObjectID {}
@end

@interface _SubGenre : TabItem {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SubGenreID*)objectID;





@property (nonatomic, strong) Genre *genre;

//- (BOOL)validateGenre:(id*)value_ error:(NSError**)error_;





@end

@interface _SubGenre (CoreDataGeneratedAccessors)

@end

@interface _SubGenre (CoreDataGeneratedPrimitiveAccessors)



- (Genre*)primitiveGenre;
- (void)setPrimitiveGenre:(Genre*)value;


@end
