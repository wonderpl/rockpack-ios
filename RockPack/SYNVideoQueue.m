//
//  SYNVideoQueue.m
//  rockpack
//
//  Created by Michael Michailidis on 22/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNVideoQueue.h"
#import "AppConstants.h"
#import "VideoInstance.h"
#import "Video.h"
#import "SYNAppDelegate.h"
#import "SYNDeviceManager.h"

@interface SYNVideoQueue ()



@property (nonatomic, strong) NSTimer *videoQueueAnimationTimer;

@property (nonatomic, weak) SYNAppDelegate* appDelegate;

@end

@implementation SYNVideoQueue

-(id)init
{
    if (self = [super init])
    {
        
        self.appDelegate = (SYNAppDelegate*)UIApplication.sharedApplication.delegate;
        
        [self setup];
    }
    return self;
}

+(id)queue
{
    return [[self alloc] init];
}

-(BOOL)videoInstanceIsAddedToChannel:(VideoInstance*)videoInstance
{
    
    for (VideoInstance* channelInstance in self.currentlyCreatingChannel.videoInstances)
    {
        
        if([channelInstance.uniqueId isEqualToString:videoInstance.uniqueId])
        {
            return YES;
        }
        
    }
    
    
    
    return NO;
}
-(void)setup
{
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleVideoQueueAddRequest:)
                                                 name: kVideoQueueAdd
                                               object: nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleVideoQueueRemoveRequest:)
                                                 name: kVideoQueueRemove
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleVideoQueueClearRequest:)
                                                 name: kVideoQueueClear
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleVideoQueueClearRequest:)
                                                 name: kClearAllAddedCells
                                               object: nil];
}


#pragma mark - Notification Handlers

- (void) handleVideoQueueAddRequest:(NSNotification*)notification
{
    
    VideoInstance* videoInstanceToAdd = (VideoInstance*) notification.userInfo[@"VideoInstance"];
    [self addVideoToQueue: videoInstanceToAdd];
}


- (void) handleVideoQueueRemoveRequest:(NSNotification*)notification
{
    
    VideoInstance* videoInstanceToAdd = (VideoInstance*) notification.userInfo[@"VideoInstance"];
    [self removeFromVideoQueue: videoInstanceToAdd];
}

-(void)handleVideoQueueClearRequest:(NSNotification*)notification
{
    if(!self.currentlyCreatingChannel)
        return;
    
    
    for (VideoInstance* currentVideoInstance in self.currentlyCreatingChannel.videoInstances) {
        
        [self.appDelegate.channelsManagedObjectContext deleteObject:currentVideoInstance];
        
    }
    
    [self.appDelegate.channelsManagedObjectContext deleteObject:self.currentlyCreatingChannel];
    
    [self.appDelegate saveChannelsContext];
}

#pragma mark - 

- (void) addVideoToQueue: (VideoInstance *) videoInstance
{
    if (!videoInstance)
    {
        DebugLog(@"Trying to add a nil video instance into the queue through: 'addVideoToQueue:'");
        return;
    }
    
    BOOL isIPhone = [[SYNDeviceManager sharedInstance] isIPhone];
    
    if(isIPhone)
    {
        // Only one video isever added at a time on iPhone. Clear out any previously started queue.
        [self clearVideoQueue];
    }
    
    if(!self.currentlyCreatingChannel) // create channel if there is none
    {
        self.currentlyCreatingChannel = [Channel insertInManagedObjectContext: self.appDelegate.channelsManagedObjectContext];
        
        User* meOnAnotherContext = [User instanceFromUser:self.appDelegate.currentUser
                                        usingManagedObjectContext:self.currentlyCreatingChannel.managedObjectContext];
        
        self.currentlyCreatingChannel.channelOwner = (ChannelOwner*)meOnAnotherContext;
        self.currentlyCreatingChannel.viewId = @"ChannelCreation";
        self.currentlyCreatingChannel.categoryId = @"";
        
        // Set the channel's unique Id to something temporary so that we can perform queries for the videoinstances it contains
        self.currentlyCreatingChannel.uniqueId = kNewChannelPlaceholderId;
        
        [self.appDelegate saveChannelsContext];
        
    }
    else // if there is a channel check of the video is a duplicate
    {
        for (VideoInstance* existingInstance in self.currentlyCreatingChannel.videoInstances)
            if([existingInstance.video.uniqueId isEqualToString:videoInstance.video.uniqueId])
                return;
            
    }
    
    
    
    
    VideoInstance* copyOfVideoInstance = [VideoInstance instanceFromVideoInstance: videoInstance
                                                        usingManagedObjectContext: self.appDelegate.channelsManagedObjectContext];
    
    copyOfVideoInstance.channel = self.currentlyCreatingChannel;
    
    [self.currentlyCreatingChannel.videoInstancesSet addObject: copyOfVideoInstance];
    
    if(isIPhone)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNoteAddToChannelRequest object:self];
    }
    
    
    
}

-(void)removeFromVideoQueue:(VideoInstance*)videoInstance
{
   if(!self.currentlyCreatingChannel)
       return;
    
    // clear objects from core data
    
    for (VideoInstance* currentVideoInstance in self.currentlyCreatingChannel.videoInstances) {
        
        if([currentVideoInstance.uniqueId isEqualToString:videoInstance.uniqueId]) {
            
            [self.appDelegate.channelsManagedObjectContext deleteObject:currentVideoInstance];
            [self.appDelegate saveChannelsContext];
            
            break;
        }
    }
    
    
}


- (void) clearVideoQueue
{
    
    
    if(!self.currentlyCreatingChannel) // no channel no queue
        return;
    
    for (VideoInstance* currentVideoInstance in self.currentlyCreatingChannel.videoInstances) {
        [self.appDelegate.channelsManagedObjectContext deleteObject:currentVideoInstance];
    }
    
    [self.appDelegate.channelsManagedObjectContext deleteObject:self.currentlyCreatingChannel];
    
    self.currentlyCreatingChannel = nil;
    
    
    [self.appDelegate saveChannelsContext];
    
    
    
}





@end
