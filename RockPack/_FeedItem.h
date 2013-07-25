// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FeedItem.h instead.

#import <CoreData/CoreData.h>
#import "AbstractCommon.h"

extern const struct FeedItemAttributes {
	__unsafe_unretained NSString *coverIndexes;
	__unsafe_unretained NSString *itemCount;
	__unsafe_unretained NSString *resourceId;
	__unsafe_unretained NSString *resourceType;
	__unsafe_unretained NSString *title;
} FeedItemAttributes;

extern const struct FeedItemRelationships {
	__unsafe_unretained NSString *aggregate;
	__unsafe_unretained NSString *feedItems;
} FeedItemRelationships;

extern const struct FeedItemFetchedProperties {
} FeedItemFetchedProperties;

@class FeedItem;
@class FeedItem;







@interface FeedItemID : NSManagedObjectID {}
@end

@interface _FeedItem : AbstractCommon {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (FeedItemID*)objectID;





@property (nonatomic, strong) NSString* coverIndexes;



//- (BOOL)validateCoverIndexes:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* itemCount;



@property int32_t itemCountValue;
- (int32_t)itemCountValue;
- (void)setItemCountValue:(int32_t)value_;

//- (BOOL)validateItemCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* resourceId;



//- (BOOL)validateResourceId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* resourceType;



//- (BOOL)validateResourceType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* title;



//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) FeedItem *aggregate;

//- (BOOL)validateAggregate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *feedItems;

- (NSMutableSet*)feedItemsSet;





@end

@interface _FeedItem (CoreDataGeneratedAccessors)

- (void)addFeedItems:(NSSet*)value_;
- (void)removeFeedItems:(NSSet*)value_;
- (void)addFeedItemsObject:(FeedItem*)value_;
- (void)removeFeedItemsObject:(FeedItem*)value_;

@end

@interface _FeedItem (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCoverIndexes;
- (void)setPrimitiveCoverIndexes:(NSString*)value;




- (NSNumber*)primitiveItemCount;
- (void)setPrimitiveItemCount:(NSNumber*)value;

- (int32_t)primitiveItemCountValue;
- (void)setPrimitiveItemCountValue:(int32_t)value_;




- (NSString*)primitiveResourceId;
- (void)setPrimitiveResourceId:(NSString*)value;




- (NSString*)primitiveResourceType;
- (void)setPrimitiveResourceType:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (FeedItem*)primitiveAggregate;
- (void)setPrimitiveAggregate:(FeedItem*)value;



- (NSMutableSet*)primitiveFeedItems;
- (void)setPrimitiveFeedItems:(NSMutableSet*)value;


@end
