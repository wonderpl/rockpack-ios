#import "Video.h"


@interface Video ()

// Private interface goes here.

@end


@implementation Video

- (UIImage *) keyframeImage
{
    return [UIImage imageNamed: self.keyframeURL];
}

@end
