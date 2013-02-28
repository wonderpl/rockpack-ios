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

#define kThumbnailContentOffset 438

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
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSIndexPath *currentSelectedIndexPath;
@property (nonatomic, strong) NSMutableArray *videoInstancesArray;


@end

@implementation SYNVideoViewerViewController

#pragma mark - View lifecycle

- (id) initWithFetchedResultsController: (NSFetchedResultsController *) fetchedResultsController
                      selectedIndexPath: (NSIndexPath *) selectedIndexPath;
{
  	if ((self = [super init]))
    {
		self.fetchedResultsController = fetchedResultsController;
        self.currentSelectedIndexPath = selectedIndexPath;
	}
    
	return self;
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Set custom fonts
    self.channelTitleLabel.font = [UIFont rockpackFontOfSize: 15.0f];
    self.channelCreatorLabel.font = [UIFont rockpackFontOfSize: 12.0f];
    self.followLabel.font = [UIFont boldRockpackFontOfSize: 14.0f];
    self.videoTitleLabel.font = [UIFont boldRockpackFontOfSize: 25.0f];
    self.numberOfRocksLabel.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.numberOfSharesLabel.font = [UIFont boldRockpackFontOfSize: 20.0f];

    // Regster video thumbnail cell
    UINib *videoThumbnailCellNib = [UINib nibWithNibName: @"SYNVideoThumbnailSmallCell"
                                                  bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: videoThumbnailCellNib
                        forCellWithReuseIdentifier: @"SYNVideoThumbnailSmallCell"];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    self.videoPlaybackViewController = [[SYNVideoPlaybackViewController alloc] initWithFrame: CGRectMake(142, 71, 740, 416)];
    
    [self.view insertSubview: self.videoPlaybackViewController.view
                aboveSubview: self.panelImageView];
    
    [self.videoPlaybackViewController setPlaylistWithFetchedResultsController: self.fetchedResultsController
                                                            selectedIndexPath: self.currentSelectedIndexPath
                                                                     autoPlay: TRUE];
    
    [self updateVideoDetailsForIndexPath: self.currentSelectedIndexPath];
    
    // Horrendous hack
    [self.videoThumbnailCollectionView scrollToItemAtIndexPath: self.currentSelectedIndexPath
                                              atScrollPosition: UICollectionViewScrollPositionLeft
                                                      animated: NO];
    
//    [self.videoThumbnailCollectionView setContentOffset: CGPointMake (self.videoThumbnailCollectionView.contentOffset.x  - kThumbnailContentOffset, 0)
//                                               animated: YES];
}


// Don't call these here as called when going full-screen

- (void) viewWillDisappear: (BOOL) animated
{
    self.videoPlaybackViewController = nil;
    
    [super viewWillDisappear: animated];
}


- (void) playVideoAtIndexPath: (NSIndexPath *) indexPath
{
    // We should start playing the selected vide and scroll the thumbnnail so that it appears under the arrow
    [self.videoPlaybackViewController playVideoAtIndex: indexPath];
    [self updateVideoDetailsForIndexPath: indexPath];
    [self scrollToCellAtIndexPath: indexPath];
    
    self.currentSelectedIndexPath = indexPath;
}

#pragma mark - Update details

- (void) updateVideoDetailsForIndexPath: (NSIndexPath *) indexPath
{
    // Set initial label text
    VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
    self.channelCreatorLabel.text = videoInstance.channel.channelOwner.name;
    self.channelTitleLabel.text = videoInstance.channel.title;
    self.videoTitleLabel.text = videoInstance.title;
    self.numberOfRocksLabel.text = videoInstance.video.starCount.stringValue;
}


// The built in UICollectionView scroll to index doesn't work correctly with contentOffset set to non-zero, so roll our own here
- (void) scrollToCellAtIndexPath: (NSIndexPath *) indexPath
{
    UICollectionViewCell *cell = [self.videoThumbnailCollectionView cellForItemAtIndexPath: indexPath];
    
    // Use the content offset (which is designed to place the center of the first cell under the arrow)
    [self.videoThumbnailCollectionView setContentOffset: CGPointMake (cell.frame.origin.x - kThumbnailContentOffset, 0)
                                               animated: YES];
}


#pragma mark - Collection view support

- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    
    DebugLog (@"Items in section %d", sectionInfo.numberOfObjects);
    
    return sectionInfo.numberOfObjects;
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) cv
{
    DebugLog (@"Section %d", self.fetchedResultsController.sections.count);
    return self.fetchedResultsController.sections.count;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNVideoThumbnailSmallCell *cell = [cv dequeueReusableCellWithReuseIdentifier: @"SYNVideoThumbnailSmallCell"
                                                                       forIndexPath: indexPath];
    
    VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
    cell.videoImageViewImage = videoInstance.video.thumbnailURL;
    cell.titleLabel.text = videoInstance.title;
    
    return cell;
}


- (void) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    // We should start playing the selected vide and scroll the thumbnnail so that it appears under the arrow
    [self playVideoAtIndexPath: indexPath];
}


#pragma mark - Video view

- (IBAction) userTouchedPreviousVideoButton: (id) sender
{
    
}

- (IBAction) userTouchedNextVideoButton: (id) sender
{
    
}


@end
