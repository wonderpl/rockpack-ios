#import "ChannelCover.h"
#import "NSDictionary+Validation.h"

@interface ChannelCover ()

// Private interface goes here.

@end


@implementation ChannelCover

@synthesize imageLargeUrl, imageMidiumUrl, imageSmallUrl;

+ (ChannelCover *) instanceFromDictionary: (NSDictionary *) dictionary
                usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    if (![dictionary isKindOfClass: [NSDictionary class]])
        return nil;
    
    
    
    ChannelCover* instance = [ChannelCover insertInManagedObjectContext:managedObjectContext];
    
    instance.imageUrl = [dictionary objectForKey:@"thumbnail_url" withDefault:@"http://localhost/no_thumb.jpg"];
    
    NSArray* aoiArray = [dictionary objectForKey:@"aoi"];
    if(aoiArray) // can be nil
    {
        instance.topLeftX = (NSNumber*)aoiArray[0];
        instance.topLeftY = (NSNumber*)aoiArray[1];
        instance.bottomRightX = (NSNumber*)aoiArray[2];
        instance.bottomRightY = (NSNumber*)aoiArray[3];
    }
    
    return instance;
    
}
-(NSString*)imageSmallUrl
{
    return nil;
}
-(NSString*)imageMidiumUrl
{
    return nil;
}
-(NSString*)imageLargeUrl
{
    return nil;
}
@end
