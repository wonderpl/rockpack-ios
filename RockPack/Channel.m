#import "Channel.h"


@interface Channel ()

// Private interface goes here.

@end


@implementation Channel

- (UIImage *) keyframeImage
{
    return [UIImage imageNamed: self.keyframeURL];
}

@end
