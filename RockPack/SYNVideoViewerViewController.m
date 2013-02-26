//
//  SYNVideoViewerViewController.m
//  rockpack
//
//  Created by Nick Banks on 23/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//


#import "Channel.h"
#import "ChannelOwner.h"
#import "LXReorderableCollectionViewFlowLayout.h"
#import "SYNVideoPlaybackViewController.h"
#import "SYNVideoThumbnailSmallCell.h"
#import "SYNVideoViewerViewController.h"
#import "UIFont+SYNFont.h"
#import "Video.h"
#import "VideoInstance.h"

@interface SYNVideoViewerViewController () 


@property (nonatomic, strong) IBOutlet SYNVideoPlaybackViewController *videoPlaybackViewController;
@property (nonatomic, strong) IBOutlet UIButton *nextVideoButton;
@property (nonatomic, strong) IBOutlet UIButton *previousVideoButton;
@property (nonatomic, strong) IBOutlet UICollectionView *videoThumbnailCollectionView;
@property (nonatomic, strong) IBOutlet UIImageView *panelImageView;
@property (nonatomic, strong) IBOutlet UILabel *channelCreatorLabel;
@property (nonatomic, strong) IBOutlet UILabel *channelTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *followLabel;
@property (nonatomic, strong) IBOutlet UILabel *numberOfRocksLabel;
@property (nonatomic, strong) IBOutlet UILabel *numberOfSharesLabel;
@property (nonatomic, strong) IBOutlet UILabel *videoTitleLabel;
@property (nonatomic, strong) NSMutableArray *videoInstancesArray;
@property (nonatomic, strong) VideoInstance *videoInstance;


@end

@implementation SYNVideoViewerViewController

#pragma mark - View lifecycle

- (id) initWithVideoInstance: (VideoInstance *) videoInstance
{
	
	if ((self = [super init]))
    {
		self.videoInstance = videoInstance;
//        self.videoInstancesArray = [NSMutableArray arrayWithArray: self.channel.videoInstancesSet.array];

	}
    
	return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.channelTitleLabel.font = [UIFont rockpackFontOfSize: 15.0f];
    self.channelCreatorLabel.font = [UIFont rockpackFontOfSize: 12.0f];
    self.followLabel.font = [UIFont boldRockpackFontOfSize: 14.0f];
    self.videoTitleLabel.font = [UIFont boldRockpackFontOfSize: 25.0f];
    self.numberOfRocksLabel.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.numberOfSharesLabel.font = [UIFont boldRockpackFontOfSize: 20.0f];

    
    self.channelCreatorLabel.text = self.videoInstance.channel.channelOwner.name;
    self.channelTitleLabel.text = self.videoInstance.channel.title;
    self.videoTitleLabel.text = self.videoInstance.title;
    self.numberOfRocksLabel.text = self.videoInstance.video.starCount.stringValue;
    
    // Add a custom flow layout to our thumbail collection view (with the right size and spacing)
    LXReorderableCollectionViewFlowLayout *layout = [[LXReorderableCollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(258.0f , 179.0f);
    layout.minimumInteritemSpacing = 0.0f;
    layout.minimumLineSpacing = 0.0f;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.videoThumbnailCollectionView.collectionViewLayout = layout;
    
    // Regster video thumbnail cell
    UINib *videoThumbnailCellNib = [UINib nibWithNibName: @"SYNVideoThumbnailSmallCell"
                                                  bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: videoThumbnailCellNib
                        forCellWithReuseIdentifier: @"SYNVideoThumbnailSmallCell"];
    
    // New video playback view controller
    self.videoPlaybackViewController = [[SYNVideoPlaybackViewController alloc] initWithFrame: CGRectMake(142, 71, 740, 416)];
    
    [self.view insertSubview: self.videoPlaybackViewController.view
                aboveSubview: self.panelImageView];
    
    [self.videoPlaybackViewController setPlaylistWithVideoInstanceArray: videoInstances
                                                               autoPlay: FALSE];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
}


// Don't call these here as called when going full-screen

- (void) viewWillDisappear: (BOOL) animated
{    
    [super viewWillDisappear: animated];
}


#pragma mark - Collection view support

- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    NSLog (@"Number of items %d", self.videoInstancesArray.count);
    return self.videoInstancesArray.count;
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) cv
{
    return 1;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNVideoThumbnailSmallCell *cell = [cv dequeueReusableCellWithReuseIdentifier: @"SYNVideoThumbnailSmallCell"
                                                                       forIndexPath: indexPath];
    
    VideoInstance *videoInstance = self.videoInstancesArray[indexPath.item];
    cell.videoImageViewImage = videoInstance.video.thumbnailURL;
    cell.titleLabel.text = videoInstance.title;
    
    return cell;
}


- (void) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    
}


- (void) collectionView: (UICollectionView *) cv
                 layout: (UICollectionViewLayout *) layout
        itemAtIndexPath: (NSIndexPath *) fromIndexPath
    willMoveToIndexPath: (NSIndexPath *) toIndexPath
{
    // Actually swap the video thumbnails around in the visible list
//    id fromItem = self.videoInstancesArray[fromIndexPath.item];
//    id fromObject = self.channel.videoInstances[fromIndexPath.item];
//    
//    [self.videoInstancesArray removeObjectAtIndex: fromIndexPath.item];
//    [self.channel.videoInstancesSet removeObjectAtIndex: fromIndexPath.item];
//    
//    [self.videoInstancesArray insertObject: fromItem atIndex: toIndexPath.item];
//    [self.channel.videoInstancesSet insertObject: fromObject atIndex: toIndexPath.item];
//    
//    [self saveDB];
}



#pragma mark - Video view

- (IBAction) userTouchedPreviousVideoButton: (id) sender
{
    
}

- (IBAction) userTouchedNextVideoButton: (id) sender
{
    
}


@end
