//
//  SYNVideoQueueViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 25/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNVideoQueueViewController.h"
#import "SYNVideoQueueView.h"
#import "SYNVideoQueueCell.h"
#import "AppConstants.h"
#import "SYNSoundPlayer.h"
#import <CoreData/CoreData.h>
#import "SYNAppDelegate.h"
#import "NSManagedObject+Copying.h"
    
#define kQueueSelectedImage @"PanelVideoQueueHighlighted.png"
#define kQueueDefaultImage @"PanelVideoQueue.png"

#define kQueueViewOffset 140.0

typedef enum _kQueueMoveDirection {
    kQueueMoveDirectionDown = 0,
    kQueueMoveDirectionUp
} kQueueMoveDirection;

@interface SYNVideoQueueViewController ()

@property (nonatomic, readonly) SYNVideoQueueView* videoQueueView;
@property (nonatomic) BOOL isVisible;
@property (nonatomic) NSMutableArray* selectedVideos;
@property (nonatomic) BOOL showingEmptyQueue;

@property (nonatomic, strong) NSTimer *videoQueueAnimationTimer;

@end

@implementation SYNVideoQueueViewController

@dynamic videoQueueView;

@synthesize delegate;
@synthesize showingEmptyQueue;

- (void) loadView
{
    SYNVideoQueueView* videoQView = [[SYNVideoQueueView alloc] init];
    videoQView.videoQueueCollectionView.dataSource = self;
    videoQView.videoQueueCollectionView.delegate = self;
    self.view = videoQView;
    
    self.selectedVideos = [NSMutableArray array];
    
    self.locked = NO;
    
    self.isVisible = NO;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.videoQueueView.deleteButton addTarget: self
                                         action: @selector(deleteLastVideoAdded)
                               forControlEvents: UIControlEventTouchUpInside];
    
    [self.videoQueueView.channelButton addTarget: self
                                          action: @selector(createChannelFromVideoQueue)
                                forControlEvents: UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleVideoQueueAddRequest:)
                                                 name: kVideoQueueAdd
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleVideoQueueHideRequest:)
                                                 name: kVideoQueueHide
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleVideoQueueShowRequest:)
                                                 name: kVideoQueueShow
                                               object: nil];
    
    [self reloadData];
	
}

#pragma mark - Notification Handlers

- (void) handleVideoQueueAddRequest:(NSNotification*)notification
{
    VideoInstance* videoInstanceToAdd = (VideoInstance*) notification.userInfo[@"VideoInstance"];
    [self addVideoToQueue: videoInstanceToAdd];
}


- (void) handleVideoQueueHideRequest: (NSNotification*) notification
{
    [self hideVideoQueue: YES];
}

- (void) handleVideoQueueShowRequest:(NSNotification*) notification
{
    NSDictionary* userInfo = notification.userInfo;
    
    if (userInfo)
    {
        NSNumber* lockValueObject = userInfo[@"lock"];
        BOOL lockValue = [lockValueObject boolValue];
        
        if (lockValue)
        {
            self.locked = YES;
        }
    }
    
    [self showVideoQueue:YES];
}


#pragma mark - Channel Handlers

- (void) createChannelFromVideoQueue
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kVideoQueueCreateChannel
                                                        object:self];
    
    [self.delegate createChannelFromVideoQueue];
    
    [self clearVideoQueue];
}


- (Channel*) getChannelFromCurrentQueue
{
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)UIApplication.sharedApplication.delegate;
    
    Channel *newChannel = [Channel insertInManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    newChannel.channelOwner = appDelegate.channelOwnerMe;
    newChannel.viewId = @"ChannelDetails";
    
    // Set the channel's unique Id to something temporary so that we can perform queries for the videoinstances it contains
    newChannel.uniqueId = kNewChannelPlaceholderId;
    
    for (VideoInstance *videoInstance in self.selectedVideos)
    {
        [newChannel.videoInstancesSet addObject: videoInstance];
    }
    
    return newChannel;
}

- (Channel*) copyChannelFromCurrentQueue
{
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)UIApplication.sharedApplication.delegate;
    
    Channel *newChannel = [Channel insertInManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    newChannel.channelOwner = appDelegate.channelOwnerMe;
    newChannel.viewId = @"ChannelDetails";
    
    // Set the channel's unique Id to something temporary so that we can perform queries for the videoinstances it contains
    newChannel.uniqueId = kNewChannelPlaceholderId;
    
    for (VideoInstance *videoInstance in self.selectedVideos)
    {
        VideoInstance *newVideoInstance = [videoInstance copyDeepWithZone: NSDefaultMallocZone()
                                           insertIntoManagedObjectContext: appDelegate.mainManagedObjectContext];
        
        [newChannel.videoInstancesSet addObject: newVideoInstance];
    }
    
    return newChannel;
}



#pragma mark - UICollectionViewDelegate Methods

- (NSInteger) collectionView: (UICollectionView *) cv
      numberOfItemsInSection: (NSInteger) section
{
    
    return self.selectedVideos.count;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    UICollectionViewCell *cell = nil;
    
    SYNVideoQueueCell *videoQueueCell = [cv dequeueReusableCellWithReuseIdentifier: @"VideoQueueCell"
                                                                      forIndexPath: indexPath];
    
    VideoInstance *videoInstance = (VideoInstance*)self.selectedVideos[indexPath.item];
    
    // Load the image asynchronously
    videoQueueCell.VideoImageViewImage = videoInstance.video.thumbnailURL;
    
    cell = videoQueueCell;
    
    return cell;
}


- (BOOL) collectionView: (UICollectionView *) cv didSelectItemAtIndexPathAbstract: (NSIndexPath *) indexPath
{
    BOOL handledInAbstractView = YES;
    DebugLog (@"Selecting image well cell does nothing");
    
    return handledInAbstractView;
}


- (SYNVideoQueueView*) videoQueueView
{
    return (SYNVideoQueueView*)self.view;
}


#pragma mark - Delegate

- (void) setDelegate: (id<SYNVideoQueueDelegate>) del
{
    delegate = del;
}


-(void)deleteLastVideoAdded
{
    [self.selectedVideos removeLastObject];
    
    if(self.selectedVideos.count == 0) {
        [self clearVideoQueue];
    } else {
        
        [self.videoQueueView showRemovedLastVideo];
    }
    
}


- (void) clearVideoQueue
{
    
    self.showingEmptyQueue = YES;
    
    [self.selectedVideos removeAllObjects];
    
    [self.videoQueueView clearVideoQueue];
}


-(void)reloadData
{
    [self.videoQueueView.videoQueueCollectionView reloadData];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [self.videoQueueAnimationTimer invalidate];
    self.videoQueueAnimationTimer = nil;
}


#pragma mark - Hide/Show Animation Methods

-(void)showVideoQueue
{
    [self showVideoQueue:YES];
}


- (void) showVideoQueue: (BOOL) animated;
{
    if(self.isVisible)
        return;
    
    [self moveVideoQueue:kQueueMoveDirectionUp animated:animated];
    
    if(self.selectedVideos.count == 0)
        self.showingEmptyQueue = YES;
    
    self.isVisible = YES;
    [self startVideoQueueDismissalTimer];
}


- (void) hideVideoQueue
{
    [self hideVideoQueue: YES];
}


- (void) hideVideoQueue: (BOOL) animated;
{
    
    if(!self.isVisible)
    {
        return;
    }
    
    [self moveVideoQueue: kQueueMoveDirectionDown
                animated: animated];
    
    self.isVisible = NO;
    self.locked = NO;
    self.videoQueueAnimationTimer = nil;
}


- (void) moveVideoQueue: (kQueueMoveDirection) direction
               animated: (BOOL) animated
{
    CGFloat offset = (direction == kQueueMoveDirectionUp) ? -(kQueueViewOffset) : kQueueViewOffset ;
    CGFloat timeDuration = (direction == kQueueMoveDirectionUp) ? 0.3 : 0.2;
    
    CGRect videoQRect = self.videoQueueView.frame;
    videoQRect.origin.y += offset;
    
    if (animated)
    {
        [UIView animateWithDuration: timeDuration
         delay: 0.0f
         options: UIViewAnimationOptionCurveEaseInOut
         animations: ^
         {
             self.videoQueueView.frame = CGRectIntegral(videoQRect);
         }
         completion: ^(BOOL finished)
         {   
         }];
    }
    else
    {
        self.videoQueueView.center = CGPointMake(self.videoQueueView.center.x, offset);
    }
}


- (void) addVideoToQueue: (VideoInstance *) videoInstance
{
    if (!videoInstance)
    {
        DebugLog(@"Trying to add a nil video instance into the queue through: 'addVideoToQueue:'");
        return;
    }
        
    [[SYNSoundPlayer sharedInstance] playSoundByName: kSoundSelect];
    
    [self showVideoQueue: YES];
    
    if(self.showingEmptyQueue)
        self.showingEmptyQueue = NO;
    
    [self.selectedVideos addObject: videoInstance];
    
    [self.videoQueueView addVideoToQueue: videoInstance];
}


- (void) setHighlighted: (BOOL) value
{
    self.videoQueueView.backgroundImageView.image = [UIImage imageNamed: (value ? kQueueSelectedImage : kQueueDefaultImage)];
}


- (void) setVideoQueueAnimationTimer: (NSTimer*) timer
{

    [_videoQueueAnimationTimer invalidate];
    _videoQueueAnimationTimer = timer;
    
}


- (void) startVideoQueueDismissalTimer
{
    self.videoQueueAnimationTimer = [NSTimer scheduledTimerWithTimeInterval: kVideoQueueOnScreenDuration
                                                                     target: self
                                                                   selector: @selector(videoQueueTimerCallback)
                                                                   userInfo: nil
                                                                    repeats: NO];
}


- (void) videoQueueTimerCallback
{
    if(self.locked)
        return;
    
    [self hideVideoQueue: TRUE];
}


- (void) setShowingEmptyQueue: (BOOL) ShowingEmptyQueueValue
{
    showingEmptyQueue = ShowingEmptyQueueValue;
    if(!showingEmptyQueue) // queue is not empty
    {
        self.videoQueueView.channelButton.enabled = YES;
        self.videoQueueView.channelButton.selected = YES;
        self.videoQueueView.deleteButton.enabled = YES;
        
        [self.videoQueueView showMessage:NO];
    }
    else // queue is empty
    {
        self.videoQueueView.channelButton.enabled = NO;
        self.videoQueueView.channelButton.selected = NO;
        self.videoQueueView.deleteButton.enabled = NO;
        
        [self.videoQueueView showMessage:YES];
    }
    
}

@end
