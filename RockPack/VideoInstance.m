#import "NSDate-Utilities.h"
#import "VideoInstance.h"
#import "Video.h"


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


- (NSDate *) dateAddedIgnoringTime
{
    return self.dateAdded.dateIgnoringTime;
}


// This is very important, we need to set the delete rule to 'Nullify' and then custom delete our connected NSManagedObjects
// dependent on whether they are only referenced by us

// Not sure if we should delete connected Channel/ChannelInstances at the same time
- (void) prepareForDeletion
{
    if (self.video.videoInstances.count == 1)
    {
        DebugLog(@"Single reference to Video, will be deleted");
        [self.managedObjectContext deleteObject: self.video];
    }
    else
    {
        DebugLog(@"Multiple references to Video object, not deleted");
    }
}

@end
