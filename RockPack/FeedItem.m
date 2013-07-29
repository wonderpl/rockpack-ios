#import "FeedItem.h"
#import "VideoInstance.h"
#import "Channel.h"
#import "ChannelOwner.h"

@interface FeedItem ()

// Private interface goes here.

@end


@implementation FeedItem

+ (FeedItem *) instanceFromResource: (AbstractCommon *) object
{
    FeedItem *instance = [FeedItem insertInManagedObjectContext: object.managedObjectContext];
    
    instance.uniqueId = object.uniqueId;
    
    instance.resourceType = NSStringFromClass([object class]);
    
    // pass date according to type
    
    if ([object isKindOfClass:[VideoInstance class]]) {
        instance.dateAdded = ((VideoInstance*)object).dateAdded;
    }
    else if ([object isKindOfClass:[Channel class]]) {
        instance.dateAdded = ((Channel*)object).datePublished;
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
    
    NSString* n_type = dictionary[@"type"];
    if(n_type && [n_type isKindOfClass:[NSString class]])
        self.resourceType = n_type;
    
    NSNumber* n_count = dictionary[@"count"];
    if(n_count && [n_count isKindOfClass:[NSNumber class]])
        self.itemCountValue = n_count.integerValue;
    
    NSArray* covers = dictionary[@"covers"];
    if(covers && [covers isKindOfClass:[NSArray class]] && covers.count > 0)
    {
        NSMutableString* coverIndexesString = [[NSMutableString alloc] init];
        for (NSNumber* coverIndex in covers)
        {
            [coverIndexesString appendFormat:@"%@:", [coverIndex stringValue]];
            
        }
        [coverIndexesString deleteCharactersInRange:NSMakeRange(coverIndexesString.length - 2, 1)]; // delete last ':'
        
        self.coverIndexes = [NSString stringWithString:coverIndexesString];
    }
}
@end
