//
//  SYNVideoQueue.m
//  rockpack
//
//  Created by Michael Michailidis on 22/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
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

@property (nonatomic, assign) BOOL isEmpty;

@end

@implementation SYNVideoQueue

@synthesize isEmpty;

-(id)init
{
    if (self = [super init])
    {
        
        self.appDelegate = (SYNAppDelegate*)UIApplication.sharedApplication.delegate;
        self.isEmpty = YES;
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
    
}


#pragma mark - Notification Handlers

- (void) handleVideoQueueAddRequest:(NSNotification*)notification
{
    
    VideoInstance* videoInstanceToAdd = (VideoInstance*) notification.userInfo[kVideoInstance];
    [self addVideoToQueue: videoInstanceToAdd fromButton:notification.userInfo[@"button"]];
    videoInstanceToAdd.selectedForVideoQueue = YES;
}


- (void) handleVideoQueueRemoveRequest:(NSNotification*)notification
{
    
    VideoInstance* videoInstanceToAdd = (VideoInstance*) notification.userInfo[kVideoInstance];
    [self removeFromVideoQueue: videoInstanceToAdd];
    videoInstanceToAdd.selectedForVideoQueue = NO;
}

-(void)handleVideoQueueClearRequest:(NSNotification*)notification
{
    
    if(!self.currentlyCreatingChannel)
        return;
    
    
    for (VideoInstance* currentVideoInstance in self.currentlyCreatingChannel.videoInstances)
    {
        [self.appDelegate.channelsManagedObjectContext deleteObject:currentVideoInstance];
    }
    
    [self.appDelegate.channelsManagedObjectContext deleteObject:self.currentlyCreatingChannel];
    
    [self.appDelegate saveChannelsContext];
    
    self.currentlyCreatingChannel = nil;
    
    self.isEmpty = YES;
}

#pragma mark - 

- (void) addVideoToQueue: (VideoInstance *) videoInstance
{
    [self addVideoToQueue:videoInstance fromButton:nil];
}

- (void) addVideoToQueue: (VideoInstance *) videoInstance fromButton:(UIButton*)button
{
    if (!videoInstance)
    {
        DebugLog(@"Trying to add a nil video instance into the queue through: 'addVideoToQueue:'");
        return;
    }

    
    if (!self.currentlyCreatingChannel) // create channel if there is none
    {
        self.currentlyCreatingChannel = [Channel insertInManagedObjectContext: self.appDelegate.channelsManagedObjectContext];
        
        User* meOnAnotherContext = [User instanceFromUser:self.appDelegate.currentUser
                                usingManagedObjectContext:self.currentlyCreatingChannel.managedObjectContext];
        
        self.currentlyCreatingChannel.channelOwner = (ChannelOwner*)meOnAnotherContext;
        
        self.currentlyCreatingChannel.categoryId = @"";
        
        // Set the channel's unique Id to something temporary so that we can perform queries for the videoinstances it contains
        self.currentlyCreatingChannel.uniqueId = kNewChannelPlaceholderId;
        
        [self.appDelegate saveChannelsContext];
    }
    else // if there is a channel remove all videos
    {
        for (VideoInstance* existingInstance in self.currentlyCreatingChannel.videoInstances)
        {
            [self.appDelegate.channelsManagedObjectContext deleteObject:existingInstance];
        }
    }
    
    VideoInstance* copyOfVideoInstance = [VideoInstance instanceFromVideoInstance: videoInstance
                                                        usingManagedObjectContext: self.appDelegate.channelsManagedObjectContext
                                                              ignoringObjectTypes: kIgnoreChannelObjects];
    
    
    
    [self.currentlyCreatingChannel addVideoInstancesObject:copyOfVideoInstance];
    
    self.isEmpty = NO;
    NSDictionary* userinfo = @{};
    if(button)
    {
        userinfo = @{@"button":button};
    }
        [[NSNotificationCenter defaultCenter] postNotificationName:kNoteAddToChannelRequest object:self userInfo:userinfo];
    
    
    
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
    
    if(self.currentlyCreatingChannel.videoInstances.count == 0)
        self.isEmpty = YES;
    
}


- (void) clearVideoQueue
{
    
    if(!self.currentlyCreatingChannel) // no channel no queue
        return;
    
    
    for (VideoInstance* currentVideoInstance in self.currentlyCreatingChannel.videoInstances) {
        [self.appDelegate.channelsManagedObjectContext deleteObject:currentVideoInstance];
    }
    
    
    [self.appDelegate saveChannelsContext];
    
    
    self.isEmpty = YES;
    
    
    
}






@end
