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
#import "SYNAbstractViewController.h"
#import "SYNMasterViewController.h"
#import "SYNPassthroughView.h"
#import "SYNVideoPlaybackViewController.h"
#import "SYNVideoThumbnailSmallCell.h"
#import "SYNVideoViewerThumbnailLayout.h"
#import "SYNVideoViewerThumbnailLayoutAttributes.h"
#import "SYNVideoViewerViewController.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+ImageProcessing.h"
#import "Video.h"
#import "VideoInstance.h"
#import <MediaPlayer/MediaPlayer.h>

#define kThumbnailContentOffset 438
#define kThumbnailCellWidth 147

@interface SYNVideoViewerViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, getter = isVideoExpanded) BOOL videoExpanded;
@property (nonatomic, strong) IBOutlet SYNVideoPlaybackViewController *videoPlaybackViewController;
@property (nonatomic, strong) IBOutlet UIButton *nextVideoButton;
@property (nonatomic, strong) IBOutlet UIButton *previousVideoButton;
@property (nonatomic, strong) IBOutlet UIButton *starButton;
@property (nonatomic, strong) IBOutlet UICollectionView *videoThumbnailCollectionView;
@property (nonatomic, strong) IBOutlet UIImageView *channelThumbnailImageView;
@property (nonatomic, strong) IBOutlet UIImageView *panelImageView;
@property (nonatomic, strong) IBOutlet UILabel *channelCreatorLabel;
@property (nonatomic, strong) IBOutlet UILabel *channelTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *followLabel;
@property (nonatomic, strong) IBOutlet UILabel *numberOfStarsLabel;
@property (nonatomic, strong) IBOutlet UILabel *numberOfSharesLabel;
@property (nonatomic, strong) IBOutlet UILabel *videoTitleLabel;
@property (nonatomic, strong) IBOutlet UIView *blackPanelView;
@property (nonatomic, strong) IBOutlet SYNPassthroughView *chromeView;
@property (nonatomic, strong) IBOutlet UIView *swipeView;
@property (nonatomic, strong) NSIndexPath *currentSelectedIndexPath;
@property (nonatomic, strong) SYNVideoViewerThumbnailLayout *layout;

@end

@implementation SYNVideoViewerViewController 

#pragma mark - Initialisation

- (id) initWithFetchedResultsController: (NSFetchedResultsController *) initFetchedResultsController
                      selectedIndexPath: (NSIndexPath *) selectedIndexPath;
{
  	if ((self = [super init]))
    {
		self.fetchedResultsController = initFetchedResultsController;
        self.currentSelectedIndexPath = selectedIndexPath;
	}
    
	return self;
}


#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Google Analytics support
    self.trackedViewName = @"Video Viewer";
    
    // Set custom fonts
    self.channelTitleLabel.font = [UIFont rockpackFontOfSize: 15.0f];
    self.channelCreatorLabel.font = [UIFont rockpackFontOfSize: 12.0f];
    self.followLabel.font = [UIFont boldRockpackFontOfSize: 14.0f];
    self.videoTitleLabel.font = [UIFont boldRockpackFontOfSize: 25.0f];
    self.numberOfStarsLabel.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.numberOfSharesLabel.font = [UIFont boldRockpackFontOfSize: 20.0f];

    // Regster video thumbnail cell
    UINib *videoThumbnailCellNib = [UINib nibWithNibName: @"SYNVideoThumbnailSmallCell"
                                                  bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: videoThumbnailCellNib
                        forCellWithReuseIdentifier: @"SYNVideoThumbnailSmallCell"];
    
    // Set custom flow layout to handle the chroma highlighting
    
    // Add a custom flow layout to our thumbail collection view (with the right size and spacing)
    self.layout = [[SYNVideoViewerThumbnailLayout alloc] init];
    self.layout.itemSize = CGSizeMake(147.0f , 106.0f);
    self.layout.minimumInteritemSpacing = 0.0f;
    self.layout.minimumLineSpacing = 0.0f;
    self.layout.scrollDirection =  UICollectionViewScrollDirectionHorizontal;
    self.layout.selectedItemIndexPath = self.currentSelectedIndexPath;
    
    self.videoThumbnailCollectionView.collectionViewLayout = self.layout;
    
    self.blackPanelView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 1024, 768)];
    self.blackPanelView.backgroundColor = [UIColor blackColor];
    self.blackPanelView.alpha = 0.0f;

    
    [self.view insertSubview: self.blackPanelView
                aboveSubview: self.panelImageView];
    
    // Create the video playback view controller, and insert it in the right place in the view hierarchy
    self.videoPlaybackViewController = [[SYNVideoPlaybackViewController alloc] initWithFrame: CGRectMake(142, 71, 739, 416)];

    [self.view insertSubview: self.videoPlaybackViewController.view
                aboveSubview: self.blackPanelView];
    
    UISwipeGestureRecognizer* rightSwipeRecogniser = [[UISwipeGestureRecognizer alloc] initWithTarget: self
                                                                                               action: @selector(userTouchedPreviousVideoButton:)];
    
    rightSwipeRecogniser.delegate = self;
    [rightSwipeRecogniser setDirection: UISwipeGestureRecognizerDirectionRight];
    [self.swipeView addGestureRecognizer:rightSwipeRecogniser];
    
    UISwipeGestureRecognizer* leftSwipeRecogniser = [[UISwipeGestureRecognizer alloc] initWithTarget: self
                                                                                              action: @selector(userTouchedNextVideoButton:)];
    
    leftSwipeRecogniser.delegate = self;
    [leftSwipeRecogniser setDirection: UISwipeGestureRecognizerDirectionLeft];
    [self.swipeView addGestureRecognizer: leftSwipeRecogniser];
    
    UITapGestureRecognizer* tapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                                    action: @selector(userTappedVideo)];
    
    tapRecogniser.delegate = self;
    [self.swipeView addGestureRecognizer: tapRecogniser];
    
    VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: self.currentSelectedIndexPath];
    
    [self.channelThumbnailImageView setAsynchronousImageFromURL: [NSURL URLWithString: videoInstance.channel.coverThumbnailSmallURL]
                                               placeHolderImage: nil];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
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
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
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
    self.channelCreatorLabel.text = videoInstance.channel.channelOwner.displayName;
    self.channelTitleLabel.text = videoInstance.channel.title;
    self.videoTitleLabel.text = videoInstance.title;
    self.numberOfStarsLabel.text = videoInstance.video.starCount.stringValue;
    self.starButton.selected = videoInstance.video.starredByUserValue;
}


// The built in UICollectionView scroll to index doesn't work correctly with contentOffset set to non-zero, so roll our own here
- (void) scrollToCellAtIndexPath: (NSIndexPath *) indexPath
{
    [self.videoThumbnailCollectionView scrollToItemAtIndexPath: indexPath
                                              atScrollPosition: UICollectionViewScrollPositionCenteredHorizontally
                                                      animated: YES];
}


#pragma mark - Collection view support

- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger) section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    
    DebugLog (@"Items in section %d", sectionInfo.numberOfObjects);
    
    return sectionInfo.numberOfObjects;
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    DebugLog (@"Section %d", self.fetchedResultsController.sections.count);
    return self.fetchedResultsController.sections.count;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNVideoThumbnailSmallCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNVideoThumbnailSmallCell"
                                                                                 forIndexPath: indexPath];
    
    VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
    cell.titleLabel.text = videoInstance.title;
    
    SYNVideoViewerThumbnailLayoutAttributes* attributes = (SYNVideoViewerThumbnailLayoutAttributes *)[self.layout layoutAttributesForItemAtIndexPath: indexPath];
    
    BOOL thumbnailIsColour = attributes.isHighlighted;
    
    if (thumbnailIsColour)
    {
        cell.colour = TRUE;
    }
    else
    {
        cell.colour = FALSE;
    }
    
    cell.videoImageViewImage = videoInstance.video.thumbnailURL;
    
    return cell;
}


- (void) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    // We should start playing the selected vide and scroll the thumbnnail so that it appears under the arrow
    [self playVideoAtIndexPath: indexPath];
}


#pragma mark - UICollectionViewDelegateFlowLayout delegates

// A better solution than the previous implementation that used referenceSizeForHeaderInSection and referenceSizeForFooterInSection
- (UIEdgeInsets) collectionView: (UICollectionView *) collectionView
                         layout: (UICollectionViewLayout*) collectionViewLayout
         insetForSectionAtIndex: (NSInteger)section
{
    int sectionCount = self.fetchedResultsController.sections.count;
    
    if (section == 0)
    {
        if (sectionCount > 1)
        {
            // Leading inset on first section
            return UIEdgeInsetsMake (0, 438, 0, 0);
        }
        else
        {
            // We only have one section, so add both trailing and leading insets
            return UIEdgeInsetsMake (0, 438, 0, 438 );
        }
    }
    else if (section == (sectionCount - 1))
    {
        // Trailing inset on last section
        return UIEdgeInsetsMake (0, 0, 0, 438);
    }
    else
    {
        // No insets on other sections
        return UIEdgeInsetsMake (0, 0, 0, 0);
    }
}


#pragma mark - User actions

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


- (IBAction) userTouchedVideoAddItButton: (UIButton *) addItButton
{
    
    VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: self.currentSelectedIndexPath];
    [self animateVideoAdditionToVideoQueue: videoInstance];
}


- (BOOL) hasVideoQueue
{
    return TRUE;
}

// Required to ensure that the video queue bar appears in the right (vertical) place
- (BOOL) hasTabBar
{
    return FALSE;
}


- (IBAction) toggleStarButton: (UIButton *) button
{
    button.selected = !button.selected;
    
    VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: self.currentSelectedIndexPath];
    
    if (videoInstance.video.starredByUserValue == TRUE)
    {
        // Currently highlighted, so decrement
        videoInstance.video.starredByUserValue = FALSE;
        videoInstance.video.starCountValue -= 1;
    }
    else
    {
        // Currently highlighted, so increment
        videoInstance.video.starredByUserValue = TRUE;
        videoInstance.video.starCountValue += 1;
    }

    [self updateVideoDetailsForIndexPath: self.currentSelectedIndexPath];
    
    [self saveDB];
}


// We need to override the standard setter so that we can update our flow layout for highlighting (colour / monochrome)
- (void) setCurrentSelectedIndexPath: (NSIndexPath *) currentSelectedIndexPath
{
    // Deselect the old thumbnail (if there is one, and it is not the same as the new one)
    if (_currentSelectedIndexPath && (_currentSelectedIndexPath != currentSelectedIndexPath))
    {
        SYNVideoThumbnailSmallCell *oldCell = (SYNVideoThumbnailSmallCell *)[self.videoThumbnailCollectionView cellForItemAtIndexPath: _currentSelectedIndexPath];
        
        // This will trigger a nice face out animation to monochrome
        oldCell.colour = FALSE;
    }
    
    // Now fade up the new image to full colour
    SYNVideoThumbnailSmallCell *newCell = (SYNVideoThumbnailSmallCell *)[self.videoThumbnailCollectionView cellForItemAtIndexPath: currentSelectedIndexPath];

    newCell.colour = TRUE;
    
    _currentSelectedIndexPath = currentSelectedIndexPath;
    self.layout.selectedItemIndexPath = currentSelectedIndexPath;
    
    
    // Now set the channel thumbail for the new
    VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: currentSelectedIndexPath];
    
    [self.channelThumbnailImageView setAsynchronousImageFromURL: [NSURL URLWithString: videoInstance.channel.coverThumbnailSmallURL]
                                               placeHolderImage: nil];
}


- (void) userCreatedNewChannel
{
    [self.overlayParent removeVideoOverlayController];
}


- (IBAction) userTouchedCloseButton: (id) sender
{
    // Call the close method on our parent
    [self.overlayParent removeVideoOverlayController];
}


// The user touched the invisible button above the channel thumbnail, taking the user to the channel page
- (IBAction) userTouchedChannelButton: (id) sender
{
    [self.overlayParent removeVideoOverlayController];

    // Get the video instance for the currently selected video
    VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: self.currentSelectedIndexPath];
    
    [(SYNAbstractViewController *)self.overlayParent.originViewController viewChannelDetails: videoInstance.channel];
}


// The user touched the invisible button above the user details, taking the user to the profile page
- (IBAction) userTouchedProfileButton: (id) sender
{
    [self.overlayParent removeVideoOverlayController];
    
    // Get the video instance for the currently selected video
    VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: self.currentSelectedIndexPath];
    
    [(SYNAbstractViewController *)self.overlayParent.originViewController viewProfileDetails: videoInstance.channel.channelOwner];
}


- (void) userTappedVideo
{
    if (self.isVideoExpanded)
    {
        [UIView transitionWithView: self.view
                          duration: 0.5f
                           options: UIViewAnimationOptionCurveEaseInOut
                        animations: ^ {
                            self.blackPanelView.alpha = 0.0f;
                            self.chromeView.alpha = 1.0f;
                            self.swipeView.frame =  CGRectMake(172, 142, 676, 295);
                            self.videoPlaybackViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                            self.videoPlaybackViewController.view.center = CGPointMake(512, 279);
                            self.videoPlaybackViewController.shuttleBarView.alpha = 1.0f;
                        }
                        completion: nil];
    }
    else
    {
        [UIView transitionWithView: self.view
                          duration: 0.5f
                           options: UIViewAnimationOptionCurveEaseInOut
                        animations: ^ {
                            self.blackPanelView.alpha = 1.0f;
                            self.chromeView.alpha = 0.0f;
                            self.swipeView.frame =  CGRectMake(0, 0, 1024, 768);
                            self.videoPlaybackViewController.view.transform = CGAffineTransformMakeScale(1.384f, 1.384f);
                            self.videoPlaybackViewController.view.center = CGPointMake(512, 374);
                            self.videoPlaybackViewController.shuttleBarView.alpha = 0.0f;
                        }
                        completion: nil];
    }

    self.videoExpanded = !self.videoExpanded;
}


@end
