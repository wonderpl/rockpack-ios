#import "Channel.h"
#import "ChannelOwner.h"
#import "VideoInstance.h"


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

// This is very important, we need to set the delete rule to 'Nullify' and then custom delete our connected NSManagedObjects
// dependent on whether they are only referenced by us

// Not sure if we should delete connected Channel/ChannelInstances at the same time
- (void) prepareForDeletion
{
    // Delete any channelOwners that are only associated with this channel
    if (self.channelOwner.channels.count == 1)
    {
        DebugLog(@"Single reference to ChannelOwner, will be deleted");
        [self.managedObjectContext deleteObject: self.channelOwner];
    }
    else
    {
        DebugLog(@"Multiple references to ChannelOwner object, not deleted");
    }
    
    // Delete any VideoInstances that are associated with this channel (I am assuming that as they only have a to-one relationship
    // with a channel, then they are only associated with that particular channel and can't exist independently
    for (VideoInstance *videoInstance in self.videoInstances)
    {
        [self.managedObjectContext deleteObject: videoInstance];
    }
}

@end
