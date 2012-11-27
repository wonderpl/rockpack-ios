//
//  SYNDiscoverTopTabViewController.m
//  RockPack
//
//  Created by Nick Banks on 16/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "AudioToolbox/AudioToolbox.h"
#import "NSObject+Blocks.h"
#import "SYNBottomTabViewController.h"
#import "SYNDiscoverTopTabViewController.h"
#import "SYNImageWellCell.h"
#import "SYNSelection.h"
#import "SYNSelectionDB.h"
#import "SYNVideoThumbnailCell.h"
#import "SYNVideoDB.h"
#import "SYNWallpackCarouseHorizontallLayout.h"
#import "SYNWallpackCarouselCell.h"
#import "UIFont+SYNFont.h"
#import "Video.h"
#import <MediaPlayer/MediaPlayer.h>

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
@property (nonatomic, strong) IBOutlet UICollectionView *wallpackCarousel;
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
@property (nonatomic, strong) NSFetchedResultsController *videoFetchedResultsController;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, strong) NSIndexPath *draggedIndexPath;
@property (nonatomic, strong) NSMutableArray *imageWell;
@property (nonatomic, strong) NSMutableArray *selections;
@property (nonatomic, strong) SYNSelectionDB *selectionDB;
@property (nonatomic, strong) SYNVideoDB *videoDB;
@property (nonatomic, strong) UIImageView *draggedView;

@end

@implementation SYNDiscoverTopTabViewController

@synthesize videoFetchedResultsController = _videoFetchedResultsController;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.imageWell = [[NSMutableArray alloc] initWithCapacity: 100];
    self.selections = [[NSMutableArray alloc] initWithCapacity: 100];
    
    self.videoDB = [SYNVideoDB sharedVideoDBManager];
    self.selectionDB = [SYNSelectionDB sharedSelectionDBManager];

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

    SYNWallpackCarouseHorizontallLayout *wallpackCarouselHorizontalLayout = [[SYNWallpackCarouseHorizontallLayout alloc] init];
    self.wallpackCarousel.collectionViewLayout = wallpackCarouselHorizontalLayout;

    // Set up our carousel
    [self.wallpackCarousel registerClass: [SYNWallpackCarouselCell class]
              forCellWithReuseIdentifier: @"SYNWallpackCarouselCell"];

    self.wallpackCarousel.decelerationRate = UIScrollViewDecelerationRateNormal;

    // Add dragging to thumbnail view
    UILongPressGestureRecognizer *longPressOnThumbnailView = [[UILongPressGestureRecognizer alloc] initWithTarget: self
                                                                                                           action: @selector(longPressThumbnail:)];

    [self.thumbnailView addGestureRecognizer: longPressOnThumbnailView];
    
    
}

#pragma mark - CoreDate support
- (void) viewWillAppear: (BOOL) animated
{
    // Set the first video
    [self setLargeVideoToIndexPath: [NSIndexPath indexPathForRow: 0 inSection: 0]];
    
    [[SYNVideoDB sharedVideoDBManager] downloadContentIfRequiredDisplayingHUDInView: self.view];
}


- (NSFetchedResultsController *) videoFetchedResultsController
{
    // Return cached version if we have already created one
    if (_videoFetchedResultsController != nil)
    {
        return _videoFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName: @"Video"
                                              inManagedObjectContext: self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"title"
                                                                   ascending: YES];
    
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors: sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *newFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                                                  managedObjectContext: self.managedObjectContext
                                                                                                    sectionNameKeyPath: nil
                                                                                                             cacheName: @"Discover"];
    newFetchedResultsController.delegate = self;
    self.videoFetchedResultsController = newFetchedResultsController;
    
    NSError *error = nil;
    if (![_videoFetchedResultsController performFetch: &error])
    {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _videoFetchedResultsController;
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
}


- (IBAction) toggleLargeRockItButton: (id)sender
{
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
}


- (IBAction) toggleLargePackItButton: (id)sender
{
    [self togglePackItAtIndex: self.currentIndexPath];
    [self updateLargeVideoDetailsForIndexPath: self.currentIndexPath];
    [self.thumbnailView reloadData];
}


// Buttons activated from scrolling list of thumbnails

- (IBAction) toggleThumbnailRockItButton: (UIButton *) rockItButton
{
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
    if (view == self.wallpackCarousel)
    {
        return 5000;
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
    if (cv == self.wallpackCarousel)
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
        
        SYNWallpackCarouselCell *cell = [cv dequeueReusableCellWithReuseIdentifier: @"SYNWallpackCarouselCell"
                                                                      forIndexPath: indexPath];
        
        NSString *imageName = [NSString stringWithFormat: @"Wallpack_%d.png", indexPath.row % 10];
        cell.image = [UIImage imageNamed: imageName];
        
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
    if (cv == self.wallpackCarousel)
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


- (IBAction) addImagewellToRockPack: (id) sender
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
    
    NSIndexPath *startIndexPath = [NSIndexPath indexPathForRow: 1500 inSection: 0];
    
    [self.wallpackCarousel scrollToItemAtIndexPath: startIndexPath
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
    NSIndexPath *indexPath = [cv indexPathForItemAtPoint: CGPointMake(cv.contentOffset.x + 250.0f, 100.0f)];

    self.selectionDB.wallpackIndex = indexPath.row % 10;
}

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    self.selectionDB.selectionTitle = textField.text;
    self.selectionDB.selections = self.selections;
    
    [self.channelNameField resignFirstResponder];
    [self clearImageWell];

    return YES;
}

- (void) textFieldDidEndEditing: (UITextField *) textField
{
    self.channelChooserView.alpha = 0.0f;
}

@end
