// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to VideoInstance.h instead.

#import <CoreData/CoreData.h>
#import "AbstractCommon.h"

extern const struct VideoInstanceAttributes {
	__unsafe_unretained NSString *dateAdded;
	__unsafe_unretained NSString *title;
} VideoInstanceAttributes;

extern const struct VideoInstanceRelationships {
	__unsafe_unretained NSString *channel;
	__unsafe_unretained NSString *video;
} VideoInstanceRelationships;

extern const struct VideoInstanceFetchedProperties {
} VideoInstanceFetchedProperties;

@class Channel;
@class Video;




@interface VideoInstanceID : NSManagedObjectID {}
@end

@interface _VideoInstance : AbstractCommon {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (VideoInstanceID*)objectID;





@property (nonatomic, strong) NSDate* dateAdded;



//- (BOOL)validateDateAdded:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Channel *channel;

//- (BOOL)validateChannel:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) Video *video;

//- (BOOL)validateVideo:(id*)value_ error:(NSError**)error_;





@end

@interface _VideoInstance (CoreDataGeneratedAccessors)

@end

@interface _VideoInstance (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveDateAdded;
- (void)setPrimitiveDateAdded:(NSDate*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (Channel*)primitiveChannel;
- (void)setPrimitiveChannel:(Channel*)value;



- (Video*)primitiveVideo;
- (void)setPrimitiveVideo:(Video*)value;


@end
