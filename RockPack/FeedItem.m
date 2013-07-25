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
    
    instance.resourceId = object.uniqueId;
    
    instance.itemCountValue = 1;
    
    instance.viewId = object.viewId;
    
    instance.coverIndexes = @"1";
    
    return instance;
}



+ (FeedItem *) instanceFromDictionary: (NSDictionary *) dictionary
            usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    if(!dictionary || ![dictionary isKindOfClass:[NSDictionary class]])
        return nil;
    
    NSString *uniqueId = dictionary[@"id"];
    
    if (!uniqueId)
        return nil;
    
    FeedItem *instance = [FeedItem insertInManagedObjectContext: managedObjectContext];
    
    instance.uniqueId = uniqueId;
    
    [instance setAttributesFromDictionary: dictionary];
    
    return instance;
}

- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
{
    self.title = dictionary[@"title"] ? dictionary[@"title"] : @"";
    self.resourceType = dictionary[@"type"] ? dictionary[@"type"] : @"";
    self.itemCountValue = dictionary[@"count"] ? ((NSNumber*)dictionary[@"count"]).integerValue : 0;
    NSArray* covers = dictionary[@"covers"];
    if(covers && covers.count > 0)
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
