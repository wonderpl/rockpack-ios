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
#import "SYNDiscoverTopTabViewController.h"
#import "SYNImageWellCell.h"
#import "SYNChannelsDB.h"
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
@property (nonatomic, strong) IBOutlet UIButton *packItButton;
@property (nonatomic, strong) IBOutlet UIButton *rockItButton;
@property (nonatomic, strong) IBOutlet UICollectionView *imageWellView;
@property (nonatomic, strong) IBOutlet UICollectionView *thumbnailView;
@property (nonatomic, strong) IBOutlet UICollectionView *channelCoverCarousel;
@property (nonatomic, strong) IBOutlet UIImageView *imageWellMessage;
@property (nonatomic, strong) IBOutlet UIImageView *imageWellPanelView;
@property (nonatomic, strong) IBOutlet UILabel *maintitle;
@property (nonatomic, strong) IBOutlet UILabel *packIt;
@property (nonatomic, strong) IBOutlet UILabel *packItNumber;
@property (nonatomic, strong) IBOutlet UILabel *rockIt;
@property (nonatomic, strong) IBOutlet UILabel *rockItNumber;
@property (nonatomic, strong) IBOutlet UILabel *subtitle;
@property (nonatomic, strong) IBOutlet UITextField *channelNameField;
@property (nonatomic, strong) IBOutlet UIView *channelChooserView;
@property (nonatomic, strong) IBOutlet UIView *dropZoneView;
@property (nonatomic, strong) IBOutlet UIView *largeVideoPanelView;
@property (nonatomic, strong) IBOutlet UIView *videoPlaceholderView;
@property (nonatomic, strong) MPMoviePlayerController *mainVideoPlayer;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, strong) NSIndexPath *draggedIndexPath;
@property (nonatomic, strong) NSMutableArray *imageWell;
@property (nonatomic, strong) NSMutableArray *selections;
@property (nonatomic, strong) UIImageView *draggedView;

@end

@implementation SYNDiscoverTopTabViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.imageWell = [[NSMutableArray alloc] initWithCapacity: 100];
    self.selections = [[NSMutableArray alloc] initWithCapacity: 100];

    self.maintitle.font = [UIFont boldRockpackFontOfSize: 24.0f];
    self.subtitle.font = [UIFont rockpackFontOfSize: 17.0f];
    self.packIt.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.rockIt.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.packItNumber.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.rockItNumber.font = [UIFont boldRockpackFontOfSize: 20.0f];

    // Init collection view
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNVideoThumbnailCell"
                                             bundle: nil];

    [self.thumbnailView registerNib: thumbnailCellNib
         forCellWithReuseIdentifier: @"ThumbnailCell"];

    UINib *imageWellCellNib = [UINib nibWithNibName: @"SYNImageWellCell"
                                             bundle: nil];

    [self.imageWellView registerNib: imageWellCellNib
         forCellWithReuseIdentifier: @"ImageWellCell"];

    CCoverflowCollectionViewLayout *channelCoverCarouselHorizontalLayout = [[CCoverflowCollectionViewLayout alloc] init];
    self.channelCoverCarousel.collectionViewLayout = channelCoverCarouselHorizontalLayout;

    // Set up our carousel
    [self.channelCoverCarousel registerClass: [SYNChannelSelectorCell class]
              forCellWithReuseIdentifier: @"SYNChannelSelectorCell"];

    self.channelCoverCarousel.decelerationRate = UIScrollViewDecelerationRateNormal;

    // Add dragging to thumbnail view
    UILongPressGestureRecognizer *longPressOnThumbnailView = [[UILongPressGestureRecognizer alloc] initWithTarget: self
                                                                                                           action: @selector(longPressThumbnail:)];

    [self.thumbnailView addGestureRecognizer: longPressOnThumbnailView];
    
    
}


- (void) viewWillAppear: (BOOL) animated
{
    [[SYNVideoDB sharedVideoDBManager] downloadContentIfRequiredDisplayingHUDInView: self.view];
    [SYNChannelsDB sharedChannelsDBManager];

    // Set the first video
    [self setLargeVideoToIndexPath: [NSIndexPath indexPathForRow: 0 inSection: 0]];
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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"title"
                                                                   ascending: YES];
    return @[sortDescriptor];
}


- (NSPredicate *) channelFetchedResultsControllerPredicate
{
    return [NSPredicate predicateWithFormat: @"userGenerated == FALSE"];
}


- (NSArray *) channelFetchedResultsControllerSortDescriptors
{
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
    
    self.mainVideoPlayer = [[MPMoviePlayerController alloc] initWithContentURL: videoURL];
    
    self.mainVideoPlayer.shouldAutoplay = NO;
    [self.mainVideoPlayer prepareToPlay];
    
    [[self.mainVideoPlayer view] setFrame: [self.videoPlaceholderView bounds]]; // Frame must match parent view
    
    [self.videoPlaceholderView addSubview: [self.mainVideoPlayer view]];
    
    // Add dragging to large video view
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget: self
                                                                                            action: @selector(longPressLargeVideo:)];
    [self.mainVideoPlayer.view addGestureRecognizer: longPress];
    
    [self.mainVideoPlayer pause];
    
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
        NSIndexPath *indexPath = [self.thumbnailView indexPathForItemAtPoint: [sender locationInView: self.thumbnailView]];
        Video *video = [self.videoFetchedResultsController objectAtIndexPath: indexPath];
        
        if (!indexPath)
        {
            self.inDrag = NO;
            return;
        }
        
        self.inDrag = YES;
        self.draggedIndexPath = indexPath;
        
        // get the text of the item to be dragged
        
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
    
    self.maintitle.text = video.title;
    self.subtitle.text = video.subtitle;
    
    [self updateLargeVideoRockpackForIndexPath: indexPath];
}

- (void) updateLargeVideoRockpackForIndexPath: (NSIndexPath *) indexPath
{
    Video *video = [self.videoFetchedResultsController objectAtIndexPath: indexPath];
    
    self.packItNumber.text = [NSString stringWithFormat: @"%@", video.totalPacks];
    self.rockItNumber.text = [NSString stringWithFormat: @"%@", video.totalRocks];
    self.packItButton.selected = video.packedByUserValue;
    self.rockItButton.selected = video.rockedByUserValue;
}

- (void) viewDidAppear: (BOOL) animated
{
    [self.thumbnailView reloadData];
    [self.imageWellView reloadData];
}


- (void) setSelectedIndex: (NSUInteger) newSelectedIndex
                 animated: (BOOL) animated
{
    if (newSelectedIndex != NSNotFound)
    {
        [self highlightTab: newSelectedIndex];
        
        // We need to change the search criteria here to relect the change in genre
        
        [self.thumbnailView reloadData];
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
    
    [self saveDB];
}


- (IBAction) toggleLargeRockItButton: (UIButton *) button
{
    button.selected = !button.selected;
    
    [self toggleRockItAtIndex: self.currentIndexPath];
    [self updateLargeVideoDetailsForIndexPath: self.currentIndexPath];
    [self.thumbnailView reloadData];
}


- (void) togglePackItAtIndex: (NSIndexPath *) indexPath
{
    Video *video = [self.videoFetchedResultsController objectAtIndexPath: indexPath];
    
    if (video.packedByUserValue == TRUE)
    {
        // Currently highlighted, so decrement
        video.packedByUserValue = FALSE;
        video.totalPacksValue -= 1;
    }
    else
    {
        // Currently highlighted, so increment
        video.packedByUserValue = TRUE;
        video.totalPacksValue += 1;
    }
    
    [self saveDB];
}


- (IBAction) toggleLargePackItButton: (UIButton *) button
{
    button.selected = !button.selected;

    [self togglePackItAtIndex: self.currentIndexPath];
    [self updateLargeVideoDetailsForIndexPath: self.currentIndexPath];
    [self.thumbnailView reloadData];
}


// Buttons activated from scrolling list of thumbnails

- (IBAction) toggleThumbnailRockItButton: (UIButton *) rockItButton
{
    rockItButton.selected = !rockItButton.selected;
    
    // Get to cell it self (from button subview)
    UIView *v = rockItButton.superview.superview;
    NSIndexPath *indexPath = [self.thumbnailView indexPathForItemAtPoint: v.center];
    
    // Bail if we don't have an index path
    if (!indexPath)
    {
        return;
    }
    
    [self toggleRockItAtIndex: indexPath];
    [self updateLargeVideoRockpackForIndexPath: self.currentIndexPath];
    
    Video *video = [self.videoFetchedResultsController objectAtIndexPath: indexPath];
    SYNVideoThumbnailCell *cell = (SYNVideoThumbnailCell *)[self.thumbnailView cellForItemAtIndexPath: indexPath];
    
    cell.rockItButton.selected = video.rockedByUserValue;
    cell.rockItNumber.text = [NSString stringWithFormat: @"%@", video.totalRocks];
}

- (IBAction) toggleThumbnailPackItButton: (UIButton *) packItButton
{
    packItButton.selected = !packItButton.selected;
    
    UIView *v = packItButton.superview.superview;
    NSIndexPath *indexPath = [self.thumbnailView indexPathForItemAtPoint: v.center];
    
    // Bail if we don't have an index path
    if (!indexPath)
    {
        return;
    }
    
    [self togglePackItAtIndex: indexPath];
    [self updateLargeVideoRockpackForIndexPath: self.currentIndexPath];
    
    Video *video = [self.videoFetchedResultsController objectAtIndexPath: indexPath];
    SYNVideoThumbnailCell *cell = (SYNVideoThumbnailCell *)[self.thumbnailView cellForItemAtIndexPath: indexPath];
    
    cell.packItButton.selected = video.packedByUserValue;
    cell.packItNumber.text = [NSString stringWithFormat: @"%@", video.totalPacks];
}


- (IBAction) touchThumbnailAddItButton: (UIButton *) addItButton
{
    UIView *v = addItButton.superview.superview;
    NSIndexPath *indexPath = [self.thumbnailView indexPathForItemAtPoint: v.center];
    

    
    SYNVideoThumbnailCell *cell = (SYNVideoThumbnailCell *)[self.thumbnailView cellForItemAtIndexPath: indexPath];
    
    cell.packItButton.enabled = FALSE;
    
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
    if (view == self.channelCoverCarousel)
    {
        return 10;
    }
    else if (view == self.thumbnailView)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.videoFetchedResultsController sections][section];
        return [sectionInfo numberOfObjects];
    }
    else
    {
        return self.imageWell.count;
    }
}

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) cv
{
    return 1;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (cv == self.channelCoverCarousel)
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
    else if (cv == self.thumbnailView)
    {
        Video *video = [self.videoFetchedResultsController objectAtIndexPath: indexPath];
        
        SYNVideoThumbnailCell *cell = [cv dequeueReusableCellWithReuseIdentifier: @"ThumbnailCell"
                                                               forIndexPath: indexPath];
        
        cell.imageView.image = video.keyframeImage;
        
        cell.maintitle.text = video.title;
        
        cell.subtitle.text = video.subtitle;
        
        cell.packItNumber.text = [NSString stringWithFormat: @"%@", video.totalPacks];
        
        cell.rockItNumber.text = [NSString stringWithFormat: @"%@", video.totalRocks];
        
        cell.packItButton.selected = video.packedByUserValue;
        
        cell.rockItButton.selected = video.rockedByUserValue;
        
        // Wire the Done button up to the correct method in the sign up controller
		[cell.packItButton removeTarget: nil
                                 action: @selector(toggleThumbnailPackItButton:)
                       forControlEvents: UIControlEventTouchUpInside];
		
		[cell.packItButton addTarget: self
                              action: @selector(toggleThumbnailPackItButton:)
                    forControlEvents: UIControlEventTouchUpInside];
        
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
        
        cell.imageView.image = [self.imageWell objectAtIndex: indexPath.row];
        
        return cell;
    }
}


- (void) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (cv == self.channelCoverCarousel)
    {
//#warning "Need to select wallpack here"
        NSLog (@"Need to select wallpack here");
    }
    else if (cv == self.thumbnailView)
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
    if (self.imageWell.count == 0)
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
             self.imageWellMessage.alpha = 0.0f;
             
         }
                         completion: ^(BOOL finished)
         {
         }];
    }

    [self.selections addObject: indexPath];
    
    // Add image at front
    Video *video = [self.videoFetchedResultsController objectAtIndexPath: indexPath];
    UIImage *image = video.keyframeImage;
    
    [self.imageWell insertObject: image
                         atIndex: 0];
    
    CGRect imageWellView = self.imageWellView.frame;
    imageWellView.origin.x -= 142;
    imageWellView.size.width += 142;
    self.imageWellView.frame = imageWellView;
    
    [self.imageWellView reloadData];
    
    [self.imageWellView scrollToItemAtIndexPath: [NSIndexPath indexPathForRow: 0 inSection: 0]
                               atScrollPosition: UICollectionViewScrollPositionLeft
                                       animated: NO];
    
    // Animate the view out onto the screen
    [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                          delay: 0.5f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         // Contract thumbnail view
         CGRect imageWellView = self.imageWellView.frame;
         imageWellView.origin.x += 142;
         imageWellView.size.width -= 142;
         self.imageWellView.frame =  imageWellView;
         
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
    
    [self.selections removeAllObjects];
    
    [self.imageWell removeAllObjects];
    [self.imageWellView reloadData];
    
    self.imageWellAddButton.enabled = FALSE;
    self.imageWellDeleteButton.enabled = FALSE;
    self.imageWellAddButton.selected = FALSE;
    
    [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         // Contract thumbnail view
         self.imageWellMessage.alpha = 1.0f;
         
     }
                     completion: ^(BOOL finished)
     {
     }];
}


- (IBAction) addImagewellToRockpack: (id) sender
{
    UIViewController *pvc = self.parentViewController;
    
    [pvc.view addSubview: self.channelChooserView];
    
    self.channelNameField.text = @"";
    [self.channelNameField becomeFirstResponder];
    
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
    [self.channelCoverCarousel scrollToItemAtIndexPath: startIndexPath
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
    newChannel.packedByUserValue = TRUE;
    newChannel.rockedByUserValue = FALSE;
    newChannel.totalPacksValue = 0;
    newChannel.totalRocksValue = 0;
    newChannel.userGeneratedValue = TRUE;
    
    // TODO: Make these window offsets less hard-coded
    NSIndexPath *indexPath = [self.channelCoverCarousel indexPathForItemAtPoint: CGPointMake (450 + self.channelCoverCarousel.contentOffset.x,
                                                                                                     70 + self.channelCoverCarousel.contentOffset.y)];
    
    Channel *coverChannel = [self.channelFetchedResultsController objectAtIndexPath: indexPath];
    
    newChannel.keyframeURL = coverChannel.keyframeURL;
    
    newChannel.wallpaperURL = coverChannel.wallpaperURL;
    
    newChannel.biog = coverChannel.biog;
    
    NSString *biogTitle = coverChannel.title;
    
    NSString *biogSubtitle = coverChannel.subtitle;;
    
    newChannel.biogTitle = [NSString stringWithFormat: @"%@ - %@", biogTitle, biogSubtitle];
    for (NSIndexPath *indexPath in self.selections)
    {
        // Get video 
        Video *video = [self.videoFetchedResultsController objectAtIndexPath: indexPath];      
        [[newChannel videosSet] addObject: video];
    }
    
    [self.channelNameField resignFirstResponder];
    [self clearImageWell];

    return YES;
}

- (void) textFieldDidEndEditing: (UITextField *) textField
{
    self.channelChooserView.alpha = 0.0f;
}

@end
