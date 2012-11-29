#import "Channel.h"


@interface Channel ()

// Private interface goes here.

@end


@implementation Channel

- (UIImage *) keyframeImage
{
    return [UIImage imageNamed: self.keyframeURL];
}

- (UIImage *) wallpaperImage
{
    return [UIImage imageNamed: self.wallpaperURL];
}

@end
