#import "ChannelCover.h"
#import "NSDictionary+Validation.h"

#define kImageSizeStringReplace @"thumbnail_medium"

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
    
    // example: protocol:http url:media.dev.rockpack.com/images/channel/thumbnail_medium/0f56V2vz5QpNotonBaRX2Q.jpg
    instance.imageUrl = [dictionary objectForKey:@"thumbnail_url" withDefault:@"http://localhost/no_thumb.jpg"];
    
    NSLog(@"* Image URL: %@", instance.imageLargeUrl);
    
    NSArray* aoiArray = [dictionary objectForKey:@"aoi"];
    if(aoiArray && [aoiArray isKindOfClass:[NSArray class]]) // can be nil
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
    return [self.imageUrl stringByReplacingOccurrencesOfString:kImageSizeStringReplace withString:@"thumbnail_small"];
}
-(NSString*)imageMidiumUrl
{
    return self.imageUrl; // by default it is set for medium
}
-(NSString*)imageLargeUrl
{
    return [self.imageUrl stringByReplacingOccurrencesOfString:kImageSizeStringReplace withString:@"thumbnail_large"];;
}
@end
