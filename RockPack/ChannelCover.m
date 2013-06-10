#import "ChannelCover.h"
#import "NSDictionary+Validation.h"
#import "AppConstants.h"



@implementation ChannelCover

+ (ChannelCover *) instanceFromChannelCover:(ChannelCover *)channelCover
                  usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    ChannelCover* instance = [ChannelCover insertInManagedObjectContext: managedObjectContext];
    instance.startU = channelCover.startU;
    instance.startV = channelCover.startV;
    instance.endU = channelCover.endU;
    instance.endV = channelCover.endV;
    instance.imageUrl = channelCover.imageUrl;
    return instance;
}

+ (ChannelCover *) instanceFromDictionary: (NSDictionary *) dictionary
                usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    if (![dictionary isKindOfClass: [NSDictionary class]])
        return nil;

    ChannelCover* instance = [ChannelCover insertInManagedObjectContext: managedObjectContext];
    
    // example: protocol:http url:media.dev.rockpack.com/images/channel/thumbnail_medium/0f56V2vz5QpNotonBaRX2Q.jpg
    instance.imageUrl = [dictionary objectForKey: @"thumbnail_url"
                                     withDefault: @"http://localhost/no_thumb.jpg"];

    NSArray* aoiArray = [dictionary objectForKey: @"aoi"];
    
    if (aoiArray && [aoiArray isKindOfClass:[NSArray class]]) // can be nil
    {
        
        instance.startU = (NSNumber*)aoiArray[0];
        instance.startV = (NSNumber*)aoiArray[1];
        instance.endU = (NSNumber*)aoiArray[2];
        instance.endV = (NSNumber*)aoiArray[3];
    }
    else
    {
        // map to the whole image
        instance.startU = [NSNumber numberWithFloat: 0.0];
        instance.startV = [NSNumber numberWithFloat: 0.0];
        instance.endU = [NSNumber numberWithFloat: 1.0];
        instance.endV = [NSNumber numberWithFloat: 1.0];
    }
    
    return instance;
}


- (NSString*) imageSmallUrl
{
    return [self.imageUrl stringByReplacingOccurrencesOfString: kImageSizeStringReplace
                                                    withString: @"thumbnail_small"];
}


- (NSString*) imageMediumUrl
{
    return self.imageUrl; // by default it is set for medium
}


- (NSString*) imageLargeUrl
{
    return [self.imageUrl stringByReplacingOccurrencesOfString: kImageSizeStringReplace
                                                    withString: @"thumbnail_large"];
}


- (NSString*) imageBackgroundUrl
{
    return [self.imageUrl stringByReplacingOccurrencesOfString: kImageSizeStringReplace
                                                    withString: @"background"];
}


- (NSString*) imageBackgroundPortraitUrl
{
    return [self.imageUrl stringByReplacingOccurrencesOfString: kImageSizeStringReplace
                                                    withString:@"background_portrait"];
}


- (CGPoint) imageRatioCenter
{
    return CGPointMake((self.startUValue + self.endUValue) / 2, (self.startVValue + self.endVValue) / 2);
}


- (CGRect) cropFrameLandscape
{
    return CGRectZero;
}


- (CGRect) cropFramePortrait
{
    return CGRectZero;
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"%@", self.imageMediumUrl];
}

@end
