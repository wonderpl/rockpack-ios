#import "_ChannelCover.h"

@interface ChannelCover : _ChannelCover {}


+ (ChannelCover *) instanceFromDictionary: (NSDictionary *) dictionary
                usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext;

@property (nonatomic, readonly) NSString* imageSmallUrl;
@property (nonatomic, readonly) NSString* imageMidiumUrl;
@property (nonatomic, readonly) NSString* imageLargeUrl;

@property (nonatomic, readonly) NSString* imageBackgroundUrl;
@property (nonatomic, readonly) NSString* imageBackgroundPortraitUrl;

@property (nonatomic, readonly) CGPoint imageRatioCenter;
@property (nonatomic, readonly) CGRect cropFrameLandscape;
@property (nonatomic, readonly) CGRect cropFramePortrait;

@end
