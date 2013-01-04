#import "VideoInstance.h"


@interface VideoInstance ()

// Private interface goes here.

@end


@implementation VideoInstance

// Custom logic goes here.


- (NSNumber *) daysAgo
{
    NSTimeInterval timeIntervalSeconds = [NSDate.date timeIntervalSinceDate: self.dateAdded];
    
    return [NSNumber numberWithInt: timeIntervalSeconds/86400];
}

@end
