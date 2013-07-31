#import "FeedItem.h"
#import "VideoInstance.h"
#import "Channel.h"
#import "AppConstants.h"
#import "ChannelOwner.h"

@interface FeedItem ()

// Private interface goes here.

@end


@implementation FeedItem


+ (FeedItem *) instanceFromResource: (AbstractCommon *) object
{
    FeedItem *instance = [FeedItem insertInManagedObjectContext: object.managedObjectContext];
    
    instance.uniqueId = object.uniqueId;
    
    
    
    // pass date according to type
    
    instance.itemTypeValue = FeedItemTypeLeaf;
    
    if ([object isKindOfClass:[VideoInstance class]]) {
        
        VideoInstance* videoInstance = (VideoInstance*)object;
        instance.dateAdded = videoInstance.dateAdded;
        instance.resourceType = FeedItemResourceTypeVideo;
        instance.positionValue = videoInstance.positionValue;
        
    }
    else if ([object isKindOfClass:[Channel class]]) {
        
        Channel* channel = (Channel*)object;
        instance.dateAdded = channel.datePublished;
        instance.resourceTypeValue = FeedItemResourceTypeChannel;
        instance.positionValue = channel.positionValue;
        
    }
    
    instance.resourceId = object.uniqueId;
    
    instance.itemCountValue = 1;
    
    instance.viewId = object.viewId;
    
    instance.coverIndexes = @"1";
    
    return instance;
}



+ (FeedItem *) instanceFromDictionary: (NSDictionary *) dictionary
                               withId: (NSString*)aid
            usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    if(!aid || !dictionary || ![dictionary isKindOfClass:[NSDictionary class]])
        return nil;
    
    
    FeedItem *instance = [FeedItem insertInManagedObjectContext: managedObjectContext];
    
    instance.uniqueId = aid;
    
    [instance setAttributesFromDictionary: dictionary];
    
    return instance;
}

- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
{
    NSString* n_title = dictionary[@"title"];
    if(n_title && [n_title isKindOfClass:[NSString class]])
        self.title = n_title;
    
    self.itemTypeValue = FeedItemTypeAggregate;
    
    NSString* n_type = dictionary[@"type"]; // "type": "video" | "channel"
    if(n_type) {
        if([n_type isEqualToString:@"video"]) {
            self.resourceTypeValue = FeedItemResourceTypeVideo;
        }
        else if([n_type isEqualToString:@"channel"]) {
            self.resourceTypeValue = FeedItemResourceTypeChannel;
        }
    }
    
    
    NSNumber* n_count = dictionary[@"count"];
    if(n_count && [n_count isKindOfClass:[NSNumber class]])
        self.itemCountValue = n_count.integerValue;
    
    self.positionValue = INT_MAX; // heuristic, place it at the end
    
    
}
-(NSArray*)coverIndexArray
{
    return [self.coverIndexes componentsSeparatedByString:@":"];
    
}
-(NSString*)description
{
    NSString* typeString = self.itemTypeValue == FeedItemTypeAggregate ? @"AGR" : @"FDI";
    NSString* resourceString = self.resourceTypeValue == FeedItemResourceTypeChannel ? @"Channel" : @"VideoInstance";
    return [NSString stringWithFormat:@"[FeedItem %@ (type:'%@', title:'%@', rsc:'%@', count:%i)]", self.uniqueId, typeString, self.title, resourceString, self.itemCountValue];
}

@end
