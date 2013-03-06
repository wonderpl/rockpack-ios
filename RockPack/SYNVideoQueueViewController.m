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

#define kQueueSelectedImage @"PanelVideoQueueHighlighted.png"
#define kQueueDefaultImage @"PanelVideoQueue.png"

@interface SYNVideoQueueViewController ()

@property (nonatomic, readonly) SYNVideoQueueView* videoQueueView;
@property (nonatomic) BOOL isVisible;
@property (nonatomic) NSMutableArray* selectedVideos;

@property (nonatomic, strong) NSTimer *videoQueueAnimationTimer;

@end

@implementation SYNVideoQueueViewController

@dynamic videoQueueView;

@synthesize delegate;

-(void)loadView
{
    SYNVideoQueueView* videoQView = [[SYNVideoQueueView alloc] init];
    videoQView.videoQueueCollectionView.dataSource = self;
    videoQView.videoQueueCollectionView.delegate = self;
    self.view = videoQView;
    
    self.selectedVideos = [NSMutableArray array];
    
    self.isVisible = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.videoQueueView.deleteButton addTarget:self action: @selector(clearVideoQueue) forControlEvents: UIControlEventTouchUpInside];
    
    [self.videoQueueView.channelButton addTarget:self action: @selector(createChannelFromVideoQueue) forControlEvents: UIControlEventTouchUpInside];
    
    [self reloadData];
	
}

-(void)createChannelFromVideoQueue
{
    
    
    [self.delegate createChannelFromVideoQueue];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(Channel*)getChannelFromCurrentQueue
{
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    Channel *newChannel = [Channel insertInManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    newChannel.channelOwner = appDelegate.channelOwnerMe;
    
    newChannel.viewId = @"ChannelDetails";
    
    
    // Currently cerating a unique string as an id for the channel to be fetched in the channels details controller.
    
    newChannel.uniqueId = [self getUUID];
    
    for (VideoInstance *videoInstance in self.selectedVideos)
    {
        [[newChannel videoInstancesSet] addObject: videoInstance];
    }
    
    return newChannel;

}

-(NSString *)getUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

#pragma mark - UICollectionViewDelegate Methods

- (NSInteger) collectionView: (UICollectionView *) cv numberOfItemsInSection: (NSInteger) section {
    
    return self.selectedVideos.count;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) cv cellForItemAtIndexPath: (NSIndexPath *) indexPath
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

-(SYNVideoQueueView*)videoQueueView
{
    return (SYNVideoQueueView*)self.view;
}

#pragma mark - Delegate

-(void)setDelegate:(id<SYNVideoQueueDelegate>)del
{
    delegate = del;
    
    
}

- (void) clearVideoQueue
{
    
    [self.videoQueueView showMessage:YES];
    
    self.videoQueueView.channelButton.enabled = NO;
    self.videoQueueView.channelButton.selected = NO;
    self.videoQueueView.deleteButton.enabled = NO;
    
    [self.selectedVideos removeAllObjects];
    
    [self.videoQueueView clearVideoQueue];
}

-(void)reloadData
{
    [self.videoQueueView.videoQueueCollectionView reloadData];
}


#pragma mark - Animation Methods

- (void) showVideoQueue: (BOOL) animated;
{
    if (!self.isVisible)
        [self hideShowVideoQueue:YES animated:animated];
    
    self.isVisible = YES;
    [self startVideoQueueDismissalTimer];  
}


- (void) hideVideoQueue: (BOOL) animated;
{
    if (self.isVisible)
        [self hideShowVideoQueue:NO animated:animated];
    
    self.isVisible = NO;
    self.videoQueueAnimationTimer = nil;
}


-(void)hideShowVideoQueue:(BOOL)show animated:(BOOL)animated
{
    CGRect videoQueueViewFrame = self.videoQueueView.frame;
    
    if(show)
        videoQueueViewFrame.origin.y -= kVideoQueueEffectiveHeight;
    else
        videoQueueViewFrame.origin.y += kVideoQueueEffectiveHeight;
    
    if (animated)
    {
        [UIView animateWithDuration: kCreateChannelPanelAnimationDuration
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^{
                             
                             
                             self.videoQueueView.frame = videoQueueViewFrame;
                         }
                         completion: ^(BOOL finished) {
                             
                         }];
    }
    else
    {
        self.videoQueueView.frame = videoQueueViewFrame;
    }
}

- (void) addVideoToQueue: (VideoInstance *) videoInstance
{
    [[SYNSoundPlayer sharedInstance] playSoundByName:kSoundSelect];
    
    [self showVideoQueue:YES];
    
    if (self.selectedVideos.count == 0)
    {
        self.videoQueueView.channelButton.enabled = YES;
        self.videoQueueView.channelButton.selected = YES;
        self.videoQueueView.deleteButton.enabled = YES;
        
        [self.videoQueueView showMessage:NO];
    }
    
    
    [self.selectedVideos addObject: videoInstance];
    
    [self.videoQueueView addVideoToQueue:videoInstance];
    
    
}

-(void)setHighlighted:(BOOL)value
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
    [self hideVideoQueue: TRUE];
}

@end
