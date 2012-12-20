#import "Channel.h"


@interface Channel ()

// Private interface goes here.

@end


@implementation Channel

- (UIImage *) thumbnailImage
{
    return [UIImage imageNamed: self.thumbnailURL];
}

- (UIImage *) wallpaperImage
{
    return [UIImage imageNamed: self.wallpaperURL];
}

@end
