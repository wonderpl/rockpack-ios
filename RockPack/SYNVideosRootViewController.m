//
//  SYNDiscoverTopTabViewController.m
//  RockPack
//
//  Created by Nick Banks on 16/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "AudioToolbox/AudioToolbox.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "SYNAppDelegate.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNNetworkEngine.h"
#import "SYNVideoDB.h"
#import "SYNVideoPlaybackViewController.h"
#import "SYNVideoQueueCell.h"
#import "SYNVideoThumbnailWideCell.h"
#import "SYNVideosRootViewController.h"
#import "SYNWallpackCarouseHorizontallLayout.h"
#import "UIFont+SYNFont.h"
#import "Video.h"
#import "VideoInstance.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Subcategory.h"
#import "SYNCategoryItemView.h"

@interface SYNVideosRootViewController () <UIGestureRecognizerDelegate,
                                           UIScrollViewDelegate,
                                           UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIButton *rockItButton;
@property (nonatomic, strong) IBOutlet UIButton *shareItButton;
@property (nonatomic, strong) IBOutlet UIImageView *channelImageView;
@property (nonatomic, strong) IBOutlet UIImageView *panelImageView;
@property (nonatomic, strong) IBOutlet UILabel *channelLabel;
@property (nonatomic, strong) IBOutlet UILabel *rockItLabel;
@property (nonatomic, strong) IBOutlet UILabel *rockItNumberLabel;
@property (nonatomic, strong) IBOutlet UILabel *shareItLabel;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *userNameLabel;
@property (nonatomic, strong) IBOutlet UIView *largeVideoPanelView;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, strong) IBOutlet SYNVideoPlaybackViewController *videoPlaybackViewController;

@end

@implementation SYNVideosRootViewController

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    SYNIntegralCollectionViewFlowLayout *standardFlowLayout = [[SYNIntegralCollectionViewFlowLayout alloc] init];
    standardFlowLayout.itemSize = CGSizeMake(507.0f , 182.0f);
    standardFlowLayout.minimumInteritemSpacing = 0.0f;
    standardFlowLayout.minimumLineSpacing = 0.0f;
    standardFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    standardFlowLayout.sectionInset = UIEdgeInsetsMake(0, 2, 0, 2);
    
    self.videoThumbnailCollectionView.collectionViewLayout = standardFlowLayout;

    // Set the labels to use the custom font
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: 17.0f];
    self.channelLabel.font = [UIFont rockpackFontOfSize: 14.0f];
    self.userNameLabel.font = [UIFont rockpackFontOfSize: 12.0f];
    self.rockItLabel.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.shareItLabel.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.rockItNumberLabel.font = [UIFont boldRockpackFontOfSize: 20.0f];

    // Init video thumbnail collection view
    UINib *videoThumbnailCellNib = [UINib nibWithNibName: @"SYNVideoThumbnailWideCell"
                                                  bundle: nil];

    [self.videoThumbnailCollectionView registerNib: videoThumbnailCellNib
                        forCellWithReuseIdentifier: @"SYNVideoThumbnailWideCell"];
    
    // New video playback view controller
    self.videoPlaybackViewController = [[SYNVideoPlaybackViewController alloc] initWithFrame: CGRectMake(13, 11, 494, 278)];
    
    [self.largeVideoPanelView insertSubview: self.videoPlaybackViewController.view
                               aboveSubview: self.panelImageView];

}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [appDelegate.networkEngine updateVideosScreenForCategory:@"all"];
    
    // Set the first video
    if (self.videoInstanceFetchedResultsController.fetchedObjects.count > 0)
    {
        [self setLargeVideoToIndexPath: [NSIndexPath indexPathForRow: 0 inSection: 0]];
    }
}




- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    [self reloadCollectionViews];
}


- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];
    
}


- (void) reloadCollectionViews
{
    [self.videoThumbnailCollectionView reloadData];
    
    NSArray *videoInstances = self.videoInstanceFetchedResultsController.fetchedObjects;
    // Set the first video
    if (videoInstances.count > 0)
    {
        [self.videoPlaybackViewController setPlaylistWithVideoInstanceArray: videoInstances
                                                                   autoPlay: FALSE];
        
        [self setLargeVideoToIndexPath: [NSIndexPath indexPathForRow: 0 inSection: 0]];
    }
}

- (BOOL) hasVideoQueue
{
    return TRUE;
}


#pragma mark - Core Data support




- (NSArray *) videoInstanceFetchedResultsControllerSortDescriptors
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"position" ascending: YES];
    return @[sortDescriptor];
}

- (NSString *)videoInstanceFetchedResultsControllerSectionNameKeyPath
{
    
    return nil;
}


#pragma mark - Collection view support

- (NSInteger) collectionView: (UICollectionView *)collectionView numberOfItemsInSection: (NSInteger) section
{
    // See if this can be handled in our abstract base class
    int items = [super collectionView: collectionView
               numberOfItemsInSection:  section];
    
    if (items < 0)
    {
        if (collectionView == self.videoThumbnailCollectionView)
        {
            id <NSFetchedResultsSectionInfo> sectionInfo = [self.videoInstanceFetchedResultsController sections][section];
            items = [sectionInfo numberOfObjects];
        }
        else
        {
            AssertOrLog(@"No valid collection view found");
        }
    }
    
    return items;
}

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    // See if this can be handled in our abstract base class
    UICollectionViewCell *cell = [super collectionView: collectionView
                                cellForItemAtIndexPath: indexPath];
    
    // Do we have a valid cell?
    if (!cell)
    {
        AssertOrLog(@"No valid collection view found");
    }
    
    return cell;
}


- (void) collectionView: (UICollectionView *) collectionView
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    // See if this can be handled in our abstract base class
    BOOL handledInSuperview = [super collectionView: (UICollectionView *) collectionView
                   didSelectItemAtIndexPathAbstract: (NSIndexPath *) indexPath];
    
    if (!handledInSuperview)
    {
        // Check to see if is one that we can handle
        if (collectionView == self.videoThumbnailCollectionView)
        {
            [self setLargeVideoToIndexPath: indexPath];
        }
        else
        {
            AssertOrLog(@"Trying to select unexpected collection view");
        }
    }
}


#pragma mark - User interface

- (void) setLargeVideoToIndexPath: (NSIndexPath *) indexPath
{
    if ([self.currentIndexPath isEqual: indexPath] == FALSE)
    {        
        self.currentIndexPath = indexPath;
        
        [self.videoPlaybackViewController playVideoAtIndex: indexPath.row];   
    }
}


- (IBAction) longPressLargeVideo: (UIGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        // figure out which item in the table was selected
        
        self.inDrag = YES;
        
        // Store the initial drag point, just in case we have to animate it back if the user misses the drop zone
        self.initialDragCenter = [sender locationInView: self.view];
        
        // Hardcoded for now, eeek!
        CGRect frame = CGRectMake(self.initialDragCenter.x - 63, self.initialDragCenter.y - 36, 123, 69);
        self.draggedView = [[UIImageView alloc] initWithFrame: frame];
        self.draggedView.alpha = 0.7;
        
        Video *video = [self.videoInstanceFetchedResultsController objectAtIndexPath: self.currentIndexPath];
        self.draggedView.image = video.thumbnailImage;
        
        // now add the item to the view
        [self.view addSubview: self.draggedView];
        
        // Highlight the image well
        [self highlightVideoQueue: TRUE];
    }
    else if (sender.state == UIGestureRecognizerStateChanged && self.inDrag)
    {
        // we dragged it, so let's update the coordinates of the dragged view
        CGPoint point = [sender locationInView: self.view];
        self.draggedView.center = point;
    }
    else if (sender.state == UIGestureRecognizerStateEnded && self.inDrag)
    {
        // Un-highlight the image well
        [self highlightVideoQueue: FALSE];
        
        // and let's figure out where we dropped it
//        CGPoint point = [sender locationInView: self.dropZoneView];
        CGPoint point = [sender locationInView: self.view];
        
        // If we have dropped it in the right place, then add it to our image well
        if ([self pointInVideoQueue: point])
            
        {
            // Hide the dragged thumbnail and add new image to image well
            [self.draggedView removeFromSuperview];
            [self addToVideoQueueFromLargeVideo: nil];
        }
        else
        {
            [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                                  delay: 0.0f
                                options: UIViewAnimationOptionCurveEaseInOut
                             animations: ^
             {
                 // Contract thumbnail view
                 self.draggedView.center = self.initialDragCenter;
                 
             }
                             completion: ^(BOOL finished)
             {
                 [self.draggedView removeFromSuperview];
             }];
        }
    }
}

- (void) displayVideoViewerFromView: (UIGestureRecognizer *) sender
{
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: [sender locationInView: self.videoThumbnailCollectionView]];
    
    [self setLargeVideoToIndexPath: indexPath];
}

- (IBAction) addToVideoQueueFromLargeVideo: (id) sender
{
    [self showVideoQueue: TRUE];
    [self startVideoQueueDismissalTimer];
    
    VideoInstance *videoInstance = [self.videoInstanceFetchedResultsController objectAtIndexPath: self.currentIndexPath];
    [self animateVideoAdditionToVideoQueue: videoInstance];
}


- (void) updateLargeVideoDetailsForIndexPath: (NSIndexPath *) indexPath
{
    VideoInstance *videoInstance = [self.videoInstanceFetchedResultsController objectAtIndexPath: indexPath];
    
    self.titleLabel.text = videoInstance.title;
    self.channelLabel.text = videoInstance.channel.title;
    self.userNameLabel.text = videoInstance.channel.channelOwner.name;
    
    [self.channelImageView setImageFromURL: [NSURL URLWithString: videoInstance.channel.coverThumbnailSmallURL]
                          placeHolderImage: nil];
    
    [self updateLargeVideoRockpackForIndexPath: indexPath];
}


- (void) updateLargeVideoRockpackForIndexPath: (NSIndexPath *) indexPath
{
    VideoInstance *videoInstance = [self.videoInstanceFetchedResultsController objectAtIndexPath: indexPath];
    
    self.rockItNumberLabel.text = [NSString stringWithFormat: @"%@", videoInstance.video.starCount];
    self.rockItButton.selected = videoInstance.video.starredByUserValue;
}



- (void) setSelectedIndex: (NSUInteger) newSelectedIndex
                 animated: (BOOL) animated
{
    if (newSelectedIndex != NSNotFound)
    {
        [self highlightTab: newSelectedIndex];
        
        // We need to change the search criteria here to relect the change in genre
        
        [self.videoThumbnailCollectionView reloadData];
    }
}


- (void) toggleRockItAtIndex: (NSIndexPath *) indexPath
{
    VideoInstance *videoInstance = [self.videoInstanceFetchedResultsController objectAtIndexPath: indexPath];
    
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
    
    [self saveDB];
}


- (void) updateOtherOnscreenVideoAssetsForIndexPath: (NSIndexPath *) indexPath
{
    if ([indexPath isEqual: self.currentIndexPath])
    {
        [self updateLargeVideoRockpackForIndexPath: self.currentIndexPath];
    }
}



- (IBAction) toggleLargeVideoPanelStarItButton: (UIButton *) button
{
    button.selected = !button.selected;
    
    [self toggleRockItAtIndex: self.currentIndexPath];
    [self updateLargeVideoDetailsForIndexPath: self.currentIndexPath];
    [self.videoThumbnailCollectionView reloadData];
    
    [self saveDB];
}


// Buttons activated from scrolling list of thumbnails

#pragma mark - Video queue animation

- (void) slideVideoQueueUp
{
     CGRect videoQueueViewFrame = self.videoQueueView.frame;
     videoQueueViewFrame.origin.y -= kVideoQueueEffectiveHeight;
     self.videoQueueView.frame = videoQueueViewFrame;

     CGRect viewFrame = self.largeVideoPanelView.frame;
     viewFrame.size.height -= kVideoQueueEffectiveHeight;
     self.largeVideoPanelView.frame = viewFrame;

     viewFrame = self.videoThumbnailCollectionView.frame;
     viewFrame.size.height -= kVideoQueueEffectiveHeight;
     self.videoThumbnailCollectionView.frame = viewFrame;
}


- (void) slideVideoQueueDown
{
    CGRect videoQueueViewFrame = self.videoQueueView.frame;
    videoQueueViewFrame.origin.y += kVideoQueueEffectiveHeight;
    self.videoQueueView.frame = videoQueueViewFrame;
    
    // Slide video queue view downwards (and expand any other dependent visible views)
    CGRect viewFrame = self.largeVideoPanelView.frame;
    viewFrame.size.height += kVideoQueueEffectiveHeight;
    self.largeVideoPanelView.frame = viewFrame;
    
    viewFrame = self.videoThumbnailCollectionView.frame;
    viewFrame.size.height += kVideoQueueEffectiveHeight;
    self.videoThumbnailCollectionView.frame = viewFrame;
}


-(void)handleMainTap:(UITapGestureRecognizer *)recogniser
{
    [super handleMainTap:recogniser];
    
    if(tabExpanded)
        return;
    
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
        CGPoint currentVideoCenter = self.videoThumbnailCollectionView.center;
        [self.videoThumbnailCollectionView setCenter:CGPointMake(currentVideoCenter.x, currentVideoCenter.y + 35)];
        
        CGPoint currentLargeVideoCenter = self.largeVideoPanelView.center;
        [self.largeVideoPanelView setCenter:CGPointMake(currentLargeVideoCenter.x, currentLargeVideoCenter.y + 35.0)];
    }  completion:^(BOOL result){
        tabExpanded = YES;
    }];
}


-(void)handleNewTabSelectionWithId:(NSString *)selectionId
{
    
    [appDelegate.networkEngine updateVideosScreenForCategory:selectionId];
}

@end
