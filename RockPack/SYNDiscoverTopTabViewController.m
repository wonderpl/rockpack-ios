//
//  SYNDiscoverTopTabViewController.m
//  RockPack
//
//  Created by Nick Banks on 16/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "AudioToolbox/AudioToolbox.h"
#import "CCoverflowCollectionViewLayout.h"
#import "Channel.h"
#import "NSObject+Blocks.h"
#import "SYNBottomTabViewController.h"
#import "SYNChannelSelectorCell.h"
#import "SYNChannelsDB.h"
#import "SYNDiscoverTopTabViewController.h"
#import "SYNImageWellCell.h"
#import "SYNVideoDB.h"
#import "SYNVideoThumbnailCell.h"
#import "SYNWallpackCarouseHorizontallLayout.h"
#import "SYNWallpackCarouselCell.h"
#import "UIFont+SYNFont.h"
#import "Video.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>

@interface SYNDiscoverTopTabViewController ()

@property (nonatomic, assign) BOOL inDrag;
@property (nonatomic, assign) BOOL shouldPlaySound;
@property (nonatomic, assign) CGPoint initialDragCenter;
@property (nonatomic, assign, getter = isLargeVideoViewExpanded) BOOL largeVideoViewExpanded;
@property (nonatomic, strong) IBOutlet UIButton *imageWellAddButton;
@property (nonatomic, strong) IBOutlet UIButton *imageWellDeleteButton;
@property (nonatomic, strong) IBOutlet UIButton *rockItButton;
@property (nonatomic, strong) IBOutlet UIButton *shareItButton;
@property (nonatomic, strong) IBOutlet UICollectionView *channelCoverCarouselCollectionView;
@property (nonatomic, strong) IBOutlet UICollectionView *imageWellCollectionView;
@property (nonatomic, strong) IBOutlet UICollectionView *videoThumbnailCollectionView;
@property (nonatomic, strong) IBOutlet UIImageView *imageWellMessageView;
@property (nonatomic, strong) IBOutlet UIImageView *imageWellPanelView;
@property (nonatomic, strong) IBOutlet UILabel *rockItLabel;
@property (nonatomic, strong) IBOutlet UILabel *rockItNumberLabel;
@property (nonatomic, strong) IBOutlet UILabel *shareItLabel;
@property (nonatomic, strong) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UITextField *channelNameTextField;
@property (nonatomic, strong) IBOutlet UIView *channelChooserView;
@property (nonatomic, strong) IBOutlet UIView *dropZoneView;
@property (nonatomic, strong) IBOutlet UIView *largeVideoPanelView;
@property (nonatomic, strong) IBOutlet UIView *videoPlaceholderView;
@property (nonatomic, strong) MPMoviePlayerController *mainVideoPlayerController;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, strong) NSIndexPath *draggedIndexPath;
@property (nonatomic, strong) NSMutableArray *imageWellArray;
@property (nonatomic, strong) NSMutableArray *selectionsArray;
@property (nonatomic, strong) UIImageView *draggedView;

@end

@implementation SYNDiscoverTopTabViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Initialise arrays with default capacities
    self.imageWellArray = [[NSMutableArray alloc] initWithCapacity: 100];
    self.selectionsArray = [[NSMutableArray alloc] initWithCapacity: 100];

    // Set the labels to use the custom font
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: 24.0f];
    self.subtitleLabel.font = [UIFont rockpackFontOfSize: 17.0f];
    self.rockItLabel.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.shareItLabel.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.rockItNumberLabel.font = [UIFont boldRockpackFontOfSize: 20.0f];

    // Init video thumbnail collection view
    UINib *videoThumbnailCellNib = [UINib nibWithNibName: @"SYNVideoThumbnailCell"
                                             bundle: nil];

    [self.videoThumbnailCollectionView registerNib: videoThumbnailCellNib
         forCellWithReuseIdentifier: @"ThumbnailCell"];
    
    // Add dragging to video thumbnail view
    UILongPressGestureRecognizer *longPressOnThumbnailView = [[UILongPressGestureRecognizer alloc] initWithTarget: self
                                                                                                           action: @selector(longPressThumbnail:)];
    
    [self.videoThumbnailCollectionView addGestureRecognizer: longPressOnThumbnailView];

    // Init image well collection view
    UINib *imageWellCellNib = [UINib nibWithNibName: @"SYNImageWellCell"
                                             bundle: nil];

    [self.imageWellCollectionView registerNib: imageWellCellNib
         forCellWithReuseIdentifier: @"ImageWellCell"];

    // Set caroulsel collection view to use custom layout algorithm
    CCoverflowCollectionViewLayout *channelCoverCarouselHorizontalLayout = [[CCoverflowCollectionViewLayout alloc] init];
    self.channelCoverCarouselCollectionView.collectionViewLayout = channelCoverCarouselHorizontalLayout;

    // Set up our carousel
    [self.channelCoverCarouselCollectionView registerClass: [SYNChannelSelectorCell class]
              forCellWithReuseIdentifier: @"SYNChannelSelectorCell"];

    self.channelCoverCarouselCollectionView.decelerationRate = UIScrollViewDecelerationRateNormal; 
}


- (void) viewWillAppear: (BOOL) animated
{
    // TODO: Remove this video download hack once we have real data from the API
    [[SYNVideoDB sharedVideoDBManager] downloadContentIfRequiredDisplayingHUDInView: self.view];
    [SYNChannelsDB sharedChannelsDBManager];

    // Set the first video
    [self setLargeVideoToIndexPath: [NSIndexPath indexPathForRow: 0
                                                       inSection: 0]];
}


#pragma mark - Core Data support

// The following 2 methods are called by the abstract class' getFetchedResults controller methods
- (NSPredicate *) videoFetchedResultsControllerPredicate
{
    // No predicate
    return nil;
}


- (NSArray *) videoFetchedResultsControllerSortDescriptors
{
    // TODO: This is currently sorted by title, but I suspect that we need to be more sophisticated
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"title"
                                                                   ascending: YES];
    return @[sortDescriptor];
}


- (NSPredicate *) channelFetchedResultsControllerPredicate
{
    // Don't show any user generated channels
    return [NSPredicate predicateWithFormat: @"userGenerated == FALSE"];
}


- (NSArray *) channelFetchedResultsControllerSortDescriptors
{
    // Sort by index
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"index"
                                                                   ascending: YES];
    return @[sortDescriptor];
}


- (void) setLargeVideoToIndexPath: (NSIndexPath *) indexPath
{
    self.currentIndexPath = indexPath;
    
    [self updateLargeVideoDetailsForIndexPath: indexPath];
    
    Video *video = [self.videoFetchedResultsController objectAtIndexPath: indexPath];
    NSURL *videoURL = video.localVideoURL;
    
    self.mainVideoPlayerController = [[MPMoviePlayerController alloc] initWithContentURL: videoURL];
    
    self.mainVideoPlayerController.shouldAutoplay = NO;
    [self.mainVideoPlayerController prepareToPlay];
    
    [[self.mainVideoPlayerController view] setFrame: [self.videoPlaceholderView bounds]]; // Frame must match parent view
    
    [self.videoPlaceholderView addSubview: [self.mainVideoPlayerController view]];
    
    // Add dragging to large video view
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget: self
                                                                                            action: @selector(longPressLargeVideo:)];
    [self.mainVideoPlayerController.view addGestureRecognizer: longPress];
    
    [self.mainVideoPlayerController pause];
    
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
        CGRect frame = CGRectMake(self.initialDragCenter.x - 63, self.initialDragCenter.y - 36, 127, 72);
        self.draggedView = [[UIImageView alloc] initWithFrame: frame];
        self.draggedView.alpha = 0.7;
        
        self.draggedView.image = [self.videoFetchedResultsController objectAtIndexPath: self.currentIndexPath];
        
        // now add the item to the view
        [self.view addSubview: self.draggedView];
        
        // Highlight the image well
        self.imageWellPanelView.image = [UIImage imageNamed: @"PanelImageWellHighlighted.png"];
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
        self.imageWellPanelView.image = [UIImage imageNamed: @"PanelImageWell.png"];
        
        // and let's figure out where we dropped it
        CGPoint point = [sender locationInView: self.dropZoneView];
        
        // If we have dropped it in the right place, then add it to our image well
        if (CGRectContainsPoint(self.imageWellPanelView.bounds, point))
            
        {
            // Hide the dragged thumbnail and add new image to image well
            [self.draggedView removeFromSuperview];
            [self addToImageWellFromLargeVideo: nil];
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


- (IBAction) longPressThumbnail: (UIGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        // figure out which item in the table was selected
        NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: [sender locationInView: self.videoThumbnailCollectionView]];
        Video *video = [self.videoFetchedResultsController objectAtIndexPath: indexPath];
        
        if (!indexPath)
        {
            self.inDrag = NO;
            return;
        }
        
        self.inDrag = YES;
        self.draggedIndexPath = indexPath;

        // Store the initial drag point, just in case we have to animate it back if the user misses the drop zone
        self.initialDragCenter = [sender locationInView: self.view];
        
        // Hardcoded for now, eeek!
        CGRect frame = CGRectMake(self.initialDragCenter.x - 63, self.initialDragCenter.y - 36, 127, 72);
        self.draggedView = [[UIImageView alloc] initWithFrame: frame];
        self.draggedView.alpha = 0.7;
        self.draggedView.image = video.keyframeImage;
        
        // now add the item to the view
        [self.view addSubview: self.draggedView];
        
        // Highlight the image well
        self.imageWellPanelView.image = [UIImage imageNamed: @"PanelImageWellHighlighted.png"];
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
        self.imageWellPanelView.image = [UIImage imageNamed: @"PanelImageWell.png"];
        
        // and let's figure out where we dropped it
        CGPoint point = [sender locationInView: self.dropZoneView];
        
        // If we have dropped it in the right place, then add it to our image well
        if (CGRectContainsPoint(self.imageWellPanelView.bounds, point))
            
        {
            // Hide the dragged thumbnail and add new image to image well
            [self.draggedView removeFromSuperview];

            [self animateImageWellAdditionWithVideoForIndexPath: self.draggedIndexPath];

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


- (void) updateLargeVideoDetailsForIndexPath: (NSIndexPath *) indexPath
{
    Video *video = [self.videoFetchedResultsController objectAtIndexPath: indexPath];
    
    self.titleLabel.text = video.title;
    self.subtitleLabel.text = video.subtitle;
    
    [self updateLargeVideoRockpackForIndexPath: indexPath];
}

- (void) updateLargeVideoRockpackForIndexPath: (NSIndexPath *) indexPath
{
    Video *video = [self.videoFetchedResultsController objectAtIndexPath: indexPath];
    
    self.rockItNumberLabel.text = [NSString stringWithFormat: @"%@", video.totalRocks];
    self.rockItButton.selected = video.rockedByUserValue;
}


- (void) viewDidAppear: (BOOL) animated
{
    [self.videoThumbnailCollectionView reloadData];
    [self.imageWellCollectionView reloadData];
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
    Video *video = [self.videoFetchedResultsController objectAtIndexPath: indexPath];
    
    if (video.rockedByUserValue == TRUE)
    {
        // Currently highlighted, so decrement
        video.rockedByUserValue = FALSE;
        video.totalRocksValue -= 1;
    }
    else
    {
        // Currently highlighted, so increment
        video.rockedByUserValue = TRUE;
        video.totalRocksValue += 1;
    }
    
//    [self updateLargeVideoDetailsForIndexPath: self.currentIndexPath];
    
    [self saveDB];
}


- (IBAction) toggleLargeRockItButton: (UIButton *) button
{
    button.selected = !button.selected;
    
    [self toggleRockItAtIndex: self.currentIndexPath];
    [self updateLargeVideoDetailsForIndexPath: self.currentIndexPath];
    [self.videoThumbnailCollectionView reloadData];
    
    [self saveDB];
}


// Buttons activated from scrolling list of thumbnails

- (IBAction) toggleThumbnailRockItButton: (UIButton *) rockItButton
{
    rockItButton.selected = !rockItButton.selected;
    
    // Get to cell it self (from button subview)
    UIView *v = rockItButton.superview.superview;
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: v.center];
    
    // Bail if we don't have an index path
    if (!indexPath)
    {
        return;
    }
    
    [self toggleRockItAtIndex: indexPath];
    [self updateLargeVideoRockpackForIndexPath: self.currentIndexPath];
    
    Video *video = [self.videoFetchedResultsController objectAtIndexPath: indexPath];
    SYNVideoThumbnailCell *cell = (SYNVideoThumbnailCell *)[self.videoThumbnailCollectionView cellForItemAtIndexPath: indexPath];
    
    cell.rockItButton.selected = video.rockedByUserValue;
    cell.rockItNumber.text = [NSString stringWithFormat: @"%@", video.totalRocks];
}


- (IBAction) touchThumbnailAddItButton: (UIButton *) addItButton
{
    UIView *v = addItButton.superview.superview;
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: v.center];
    
    
    SYNVideoThumbnailCell *cell = (SYNVideoThumbnailCell *)[self.videoThumbnailCollectionView cellForItemAtIndexPath: indexPath];
    
//    cell.addItButton.enabled = FALSE;
    
    [self animateImageWellAdditionWithVideoForIndexPath: indexPath];
}

#pragma mark - Large video view gesture handler

- (IBAction) swipeLargeVideoViewLeft: (UISwipeGestureRecognizer *) swipeGesture
{
#ifdef FULL_SCREEN_THUMBNAILS
#ifdef SOUND_ENABLED
    // Play a suitable sound
    NSString *soundPath = [[NSBundle mainBundle] pathForResource: @"Scroll"
                                                          ofType: @"aif"];
    
    NSURL *soundURL = [NSURL fileURLWithPath: soundPath];
    SystemSoundID sound;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
    AudioServicesPlaySystemSound(sound);
#endif
    
    // Animate the view out onto the screen
    [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         // Slide off large video view
         CGRect largeVideoPanelFrame = self.largeVideoPanelView.frame;
         largeVideoPanelFrame.origin.x = -1024;
         self.largeVideoPanelView.frame =  largeVideoPanelFrame;
         
         // Expand thumbnail view
         CGRect thumbailViewFrame = self.thumbnailView.frame;
         thumbailViewFrame.origin.x = 0;
         thumbailViewFrame.size.width = 1024;
         self.thumbnailView.frame =  thumbailViewFrame;
     }
                     completion: ^(BOOL finished)
     {
         // Fix hidden video view
         CGRect largeVideoPanelFrame = self.largeVideoPanelView.frame;
         largeVideoPanelFrame.origin.x = -1024;
         self.largeVideoPanelView.frame =  largeVideoPanelFrame;
         
         // Fix expanded thumbnail view
         CGRect thumbailViewFrame = self.thumbnailView.frame;
         thumbailViewFrame.origin.x = 0;
         thumbailViewFrame.size.width = 1024;
         self.thumbnailView.frame =  thumbailViewFrame;
         
         // Allow it to be expanded again
         self.largeVideoViewExpanded = FALSE;
     }];
#endif
}

#pragma mark - Large video view open animation

- (IBAction) animateLargeVideoViewRight: (id) sender
{
#ifdef FULL_SCREEN_THUMBNAILS
#ifdef SOUND_ENABLED
    // Play a suitable sound
    NSString *soundPath = [[NSBundle mainBundle] pathForResource: @"Scroll"
                                                          ofType: @"aif"];
    
    NSURL *soundURL = [NSURL fileURLWithPath: soundPath];
    SystemSoundID sound;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
    AudioServicesPlaySystemSound(sound);
#endif
    
    // Animate the view out onto the screen
    [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         // Slide on large video view
         CGRect largeVideoPanelFrame = self.largeVideoPanelView.frame;
         largeVideoPanelFrame.origin.x = 0;
         self.largeVideoPanelView.frame =  largeVideoPanelFrame;
         
         // Contract thumbnail view
         CGRect thumbailViewFrame = self.thumbnailView.frame;
         thumbailViewFrame.origin.x = 512;
         thumbailViewFrame.size.width = 512;
         self.thumbnailView.frame =  thumbailViewFrame;
         
     }
                     completion: ^(BOOL finished)
     {
         // Fix on-screen video view
         CGRect largeVideoPanelFrame = self.largeVideoPanelView.frame;
         largeVideoPanelFrame.origin.x = 0;
         self.largeVideoPanelView.frame =  largeVideoPanelFrame;
         
         // Fix contracted thumbnail view
         CGRect thumbailViewFrame = self.thumbnailView.frame;
         thumbailViewFrame.origin.x = 512;
         thumbailViewFrame.size.width = 512;
         self.thumbnailView.frame =  thumbailViewFrame;
     }];
#endif
}


#pragma mark - Collection view support

- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    if (view == self.channelCoverCarouselCollectionView)
    {
        return 10;
    }
    else if (view == self.videoThumbnailCollectionView)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.videoFetchedResultsController sections][section];
        return [sectionInfo numberOfObjects];
    }
    else
    {
        return self.imageWellArray.count;
    }
}

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) cv
{
    return 1;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (cv == self.channelCoverCarouselCollectionView)
    {
#ifdef SOUND_ENABLED
        // Play a suitable sound
        NSString *soundPath = [[NSBundle mainBundle] pathForResource: @"Scroll"
                                                              ofType: @"aif"];
        
        if (self.shouldPlaySound == TRUE)
        {
            NSURL *soundURL = [NSURL fileURLWithPath: soundPath];
            SystemSoundID sound;
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
            AudioServicesPlaySystemSound(sound);
        }
#endif
        
        SYNChannelSelectorCell *cell = [cv dequeueReusableCellWithReuseIdentifier: @"SYNChannelSelectorCell"
                                                                      forIndexPath: indexPath];
        
        NSString *imageName = [NSString stringWithFormat: @"ChannelCreationCover%d.png", (indexPath.row % 10) + 1];

        // Now add a 2 pixel transparent edge on the image (which dramatically reduces jaggies on transformation)        
        UIImage *image = [UIImage imageNamed: imageName];
        CGRect imageRect = CGRectMake( 0 , 0 , image.size.width + 4 , image.size.height + 4 );
        
        UIGraphicsBeginImageContext(imageRect.size);
        [image drawInRect: CGRectMake(imageRect.origin.x + 2, imageRect.origin.y + 2, imageRect.size.width - 4, imageRect.size.height - 4)];
        CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationHigh);
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    
        cell.imageView.image = image;
        
        cell.imageView.layer.shouldRasterize = YES;
        cell.imageView.layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;
        cell.imageView.clipsToBounds = NO;
        cell.imageView.layer.masksToBounds = NO;
        
        // End of clever jaggie reduction
        
        return cell;
    }
    else if (cv == self.videoThumbnailCollectionView)
    {
        Video *video = [self.videoFetchedResultsController objectAtIndexPath: indexPath];
        
        SYNVideoThumbnailCell *cell = [cv dequeueReusableCellWithReuseIdentifier: @"ThumbnailCell"
                                                               forIndexPath: indexPath];
        
        cell.imageView.image = video.keyframeImage;
        
        cell.maintitle.text = video.title;
        
        cell.subtitle.text = video.subtitle;
        
        cell.rockItNumber.text = [NSString stringWithFormat: @"%@", video.totalRocks];
        
        cell.rockItButton.selected = video.rockedByUserValue;
        
        // Wire the Done button up to the correct method in the sign up controller
        
        [cell.rockItButton removeTarget: nil
                                 action: @selector(toggleThumbnailRockItButton:)
                       forControlEvents: UIControlEventTouchUpInside];
		
		[cell.rockItButton addTarget: self
                              action: @selector(toggleThumbnailRockItButton:)
                    forControlEvents: UIControlEventTouchUpInside];
        
        [cell.addItButton removeTarget: nil
                                 action: @selector(touchThumbnailAddItButton:)
                       forControlEvents: UIControlEventTouchUpInside];
		
		[cell.addItButton addTarget: self
                              action: @selector(touchThumbnailAddItButton:)
                    forControlEvents: UIControlEventTouchUpInside];
        
        return cell;
    }
    else
    {
        SYNImageWellCell *cell = [cv dequeueReusableCellWithReuseIdentifier: @"ImageWellCell"
                                                               forIndexPath: indexPath];
        
        cell.imageView.image = [self.imageWellArray objectAtIndex: indexPath.row];
        
        return cell;
    }
}


- (void) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (cv == self.channelCoverCarouselCollectionView)
    {
//#warning "Need to select wallpack here"
        NSLog (@"Need to select wallpack here");
    }
    else if (cv == self.videoThumbnailCollectionView)
    {
#ifdef FULL_SCREEN_THUMBNAILS
        if (self.isLargeVideoViewExpanded == FALSE)
        {
            [self animateLargeVideoViewRight: nil];
            self.largeVideoViewExpanded = TRUE;
        }
#endif
        self.currentIndexPath = indexPath;
        
        [self setLargeVideoToIndexPath: indexPath];
    }
    else
    {
        NSLog (@"Selecting image well cell does nothing");
    }
}

#pragma mark - Image well support


- (IBAction) addToImageWellFromLargeVideo: (id) sender
{
    [self animateImageWellAdditionWithVideoForIndexPath: self.currentIndexPath];
}

- (void) animateImageWellAdditionWithVideoForIndexPath: (NSIndexPath *) indexPath
{
#ifdef SOUND_ENABLED
    // Play a suitable sound
    NSString *soundPath = [[NSBundle mainBundle] pathForResource: @"Select"
                                                          ofType: @"aif"];
    
    NSURL *soundURL = [NSURL fileURLWithPath: soundPath];
    SystemSoundID sound;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
    AudioServicesPlaySystemSound(sound);
#endif
    
    // If this is the first thing we are adding then fade out the message
    if (self.imageWellArray.count == 0)
    {
        self.imageWellAddButton.enabled = TRUE;
        self.imageWellAddButton.selected = TRUE;
        self.imageWellDeleteButton.enabled = TRUE;
        
        [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^
         {
             // Contract thumbnail view
             self.imageWellMessageView.alpha = 0.0f;
             
         }
                         completion: ^(BOOL finished)
         {
         }];
    }

    [self.selectionsArray addObject: indexPath];
    
    // Add image at front
    Video *video = [self.videoFetchedResultsController objectAtIndexPath: indexPath];
    UIImage *image = video.keyframeImage;
    
    [self.imageWellArray insertObject: image
                         atIndex: 0];
    
    CGRect imageWellView = self.imageWellCollectionView.frame;
    imageWellView.origin.x -= 142;
    imageWellView.size.width += 142;
    self.imageWellCollectionView.frame = imageWellView;
    
    [self.imageWellCollectionView reloadData];
    
    [self.imageWellCollectionView scrollToItemAtIndexPath: [NSIndexPath indexPathForRow: 0 inSection: 0]
                               atScrollPosition: UICollectionViewScrollPositionLeft
                                       animated: NO];
    
    // Animate the view out onto the screen
    [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                          delay: 0.5f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         // Contract thumbnail view
         CGRect imageWellView = self.imageWellCollectionView.frame;
         imageWellView.origin.x += 142;
         imageWellView.size.width -= 142;
         self.imageWellCollectionView.frame =  imageWellView;
         
     }
                     completion: ^(BOOL finished)
     {
     }];
}


- (IBAction) clearImageWell
{
#ifdef SOUND_ENABLED
    // Play a suitable sound
    NSString *soundPath = [[NSBundle mainBundle] pathForResource: @"Trash"
                                                          ofType: @"aif"];
    
    NSURL *soundURL = [NSURL fileURLWithPath: soundPath];
    SystemSoundID sound;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
    AudioServicesPlaySystemSound(sound);
#endif
    
    [self.selectionsArray removeAllObjects];
    
    [self.imageWellArray removeAllObjects];
    [self.imageWellCollectionView reloadData];
    
    self.imageWellAddButton.enabled = FALSE;
    self.imageWellDeleteButton.enabled = FALSE;
    self.imageWellAddButton.selected = FALSE;
    
    [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         // Contract thumbnail view
         self.imageWellMessageView.alpha = 1.0f;
         
     }
                     completion: ^(BOOL finished)
     {
     }];
}


- (IBAction) addImagewellToRockpack: (id) sender
{
    UIViewController *pvc = self.parentViewController;
    
    [pvc.view addSubview: self.channelChooserView];
    
    self.channelNameTextField.text = @"";
    [self.channelNameTextField becomeFirstResponder];
    
    [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         // Contract thumbnail view
         self.channelChooserView.alpha = 1.0f;
     }
                     completion: ^(BOOL finished)
     {
     }];
    
    // TODO: Work out why scrolling to position 1 actually scrolls to position 5 (suspect some dodgy maths in the 3rd party cover flow)
    NSIndexPath *startIndexPath = [NSIndexPath indexPathForRow: 0 inSection: 0];
    [self.channelCoverCarouselCollectionView scrollToItemAtIndexPath: startIndexPath
                                  atScrollPosition: UICollectionViewScrollPositionCenteredHorizontally
                                          animated: NO];
    
    // Only play the scrolling click (after we have scrolled to the right position in the list,
    // which might not have finished in this run loop
    [NSObject performBlock: ^
     {
         self.shouldPlaySound = TRUE;
     }
                afterDelay: 0.1f];
}

- (void) scrollViewDidEndDecelerating: (UICollectionView *) cv
{
//    NSIndexPath *indexPath = [self.channelCoverCarousel indexPathForItemAtPoint: CGPointMake (450 + self.channelCoverCarousel.contentOffset.x,
//                                                                                              70 + self.channelCoverCarousel.contentOffset.y)];
}

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{    
    Channel *newChannel = [Channel insertInManagedObjectContext: self.managedObjectContext];
    
    newChannel.title = textField.text;
    newChannel.subtitle = @"CHANNEL";
    newChannel.rockedByUserValue = FALSE;
    newChannel.totalRocksValue = 0;
    newChannel.userGeneratedValue = TRUE;
    
    // TODO: Make these window offsets less hard-coded
    NSIndexPath *indexPath = [self.channelCoverCarouselCollectionView indexPathForItemAtPoint: CGPointMake (450 + self.channelCoverCarouselCollectionView.contentOffset.x,
                                                                                                     70 + self.channelCoverCarouselCollectionView.contentOffset.y)];
    
    Channel *coverChannel = [self.channelFetchedResultsController objectAtIndexPath: indexPath];
    
    newChannel.keyframeURL = coverChannel.keyframeURL;
    
    newChannel.wallpaperURL = coverChannel.wallpaperURL;
    
    newChannel.biog = coverChannel.biog;
    
    NSString *biogTitle = coverChannel.title;
    
    NSString *biogSubtitle = coverChannel.subtitle;;
    
    newChannel.biogTitle = [NSString stringWithFormat: @"%@ - %@", biogTitle, biogSubtitle];
    for (NSIndexPath *indexPath in self.selectionsArray)
    {
        // Get video 
        Video *video = [self.videoFetchedResultsController objectAtIndexPath: indexPath];      
        [[newChannel videosSet] addObject: video];
    }
    
    [self.channelNameTextField resignFirstResponder];
    [self clearImageWell];

    return YES;
}

- (void) textFieldDidEndEditing: (UITextField *) textField
{
    self.channelChooserView.alpha = 0.0f;
}

@end
