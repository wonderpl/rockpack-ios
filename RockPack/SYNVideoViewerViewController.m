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
#import "NSIndexPath+Arithmetic.h"
#import "SYNVideoPlaybackViewController.h"
#import "SYNVideoThumbnailSmallCell.h"
#import "SYNVideoViewerViewController.h"
#import "UIFont+SYNFont.h"
#import "Video.h"
#import "VideoInstance.h"

#define kThumbnailContentOffset 438
#define kThumbnailCellWidth 147

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

#pragma mark - Initialisation

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


#pragma mark - View lifecycle

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
    
    // Create the video playback view controller, and insert it in the right place in the view hierarchy
    self.videoPlaybackViewController = [[SYNVideoPlaybackViewController alloc] initWithFrame: CGRectMake(142, 71, 740, 416)];
    
    [self.view insertSubview: self.videoPlaybackViewController.view
                aboveSubview: self.panelImageView];
    
    // Set the video playlist (using the fetchedResults controller passed in)
    [self.videoPlaybackViewController setPlaylistWithFetchedResultsController: self.fetchedResultsController
                                                            selectedIndexPath: self.currentSelectedIndexPath
                                                                     autoPlay: TRUE];
    
    // Update all the labels corresponding to the selected videos
    [self updateVideoDetailsForIndexPath: self.currentSelectedIndexPath];
    
    // We need to scroll the current thumbnail before the view appears (with no animation)
    [self.videoThumbnailCollectionView scrollToItemAtIndexPath: self.currentSelectedIndexPath
                                              atScrollPosition: UICollectionViewScrollPositionCenteredHorizontally
                                                      animated: NO];
}


- (void) viewWillDisappear: (BOOL) animated
{
    // Let's make sure that we stop playing the current video
    self.videoPlaybackViewController = nil;
    
    [super viewWillDisappear: animated];
}


- (void) playVideoAtIndexPath: (NSIndexPath *) indexPath
{
    // We should start playing the selected video and scroll the thumbnnail so that it appears under the arrow
    [self.videoPlaybackViewController playVideoAtIndex: indexPath];
    [self updateVideoDetailsForIndexPath: indexPath];
    [self scrollToCellAtIndexPath: indexPath];
    
    self.currentSelectedIndexPath = indexPath;
}


#pragma mark - Update details

- (void) updateVideoDetailsForIndexPath: (NSIndexPath *) indexPath
{
    VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
    self.channelCreatorLabel.text = videoInstance.channel.channelOwner.name;
    self.channelTitleLabel.text = videoInstance.channel.title;
    self.videoTitleLabel.text = videoInstance.title;
    self.numberOfRocksLabel.text = videoInstance.video.starCount.stringValue;
}


// The built in UICollectionView scroll to index doesn't work correctly with contentOffset set to non-zero, so roll our own here
- (void) scrollToCellAtIndexPath: (NSIndexPath *) indexPath
{
    [self.videoThumbnailCollectionView scrollToItemAtIndexPath: indexPath
                                              atScrollPosition: UICollectionViewScrollPositionCenteredHorizontally
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


#pragma mark - UICollectionViewDelegateFlowLayout delegates

// These are required to make the scrollToItemAtIndexPath work correctly, as if you use content insets, it does not
// work as expected
- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout*) collectionViewLayout
                   referenceSizeForHeaderInSection: (NSInteger) section
{
    // Only add a header onto the first section
    if (section == 0)
        return CGSizeMake (438.0f, 0.0f);
    else
        return CGSizeZero;
}

- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout*) collectionViewLayout
                   referenceSizeForFooterInSection: (NSInteger) section
{
    // Only add a footer onto the last section
    if (section == (self.fetchedResultsController.sections.count - 1))
        return CGSizeMake (438.0f, 0.0f);
    else
        return CGSizeZero;
}

#pragma mark - Video view

- (IBAction) userTouchedPreviousVideoButton: (id) sender
{
    NSIndexPath *newIndexPath = [self.currentSelectedIndexPath previousIndexPathUsingFetchedResultsController: self.fetchedResultsController];
    
    [self playVideoAtIndexPath: newIndexPath];
}

- (IBAction) userTouchedNextVideoButton: (id) sender
{
    NSIndexPath *newIndexPath = [self.currentSelectedIndexPath nextIndexPathUsingFetchedResultsController: self.fetchedResultsController];
    
    [self playVideoAtIndexPath: newIndexPath];
}


@end
