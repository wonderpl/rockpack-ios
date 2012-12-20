#import "Video.h"


@interface Video ()

// Private interface goes here.

@end


@implementation Video

- (UIImage *) thumbnailImage
{
    return [UIImage imageNamed: self.thumbnailURL];
}

- (NSURL *) localVideoURL
{
    return [NSURL fileURLWithPath: [NSHomeDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"/Documents/%@.mp4", self.sourceId, nil]]];
}

@end
