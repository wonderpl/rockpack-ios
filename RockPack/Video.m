#import "Video.h"


@interface Video ()

// Private interface goes here.

@end


@implementation Video

- (UIImage *) keyframeImage
{
    return [UIImage imageNamed: self.keyframeURL];
}

- (NSURL *) localVideoURL
{
    return [NSURL fileURLWithPath: [NSHomeDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"/Documents/%@.mp4", self.videoURL, nil]]];
}

@end
