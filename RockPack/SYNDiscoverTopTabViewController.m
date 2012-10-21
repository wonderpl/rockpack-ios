//
//  SYNDiscoverTopTabViewController.m
//  RockPack
//
//  Created by Nick Banks on 16/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppContants.h"
#import "AudioToolbox/AudioToolbox.h"
#import "NSObject+Blocks.h"
#import "SYNBottomTabViewController.h"
#import "SYNDiscoverTopTabViewController.h"
#import "SYNImageWellCell.h"
#import "SYNSelection.h"
#import "SYNSelectionDB.h"
#import "SYNThumbnailCell.h"
#import "SYNVideoDB.h"
#import "SYNWallpackCarouseHorizontallLayout.h"
#import "SYNWallpackCarouselCell.h"
#import "UIFont+SYNFont.h"
#import <MediaPlayer/MediaPlayer.h>

@interface SYNDiscoverTopTabViewController ()

@property (nonatomic, assign) BOOL inDrag;
@property (nonatomic, assign) BOOL shouldPlaySound;
@property (nonatomic, assign) int currentIndex;
@property (nonatomic, assign) int currentOffset;
@property (nonatomic, assign, getter = isLargeVideoViewExpanded) BOOL largeVideoViewExpanded;
@property (nonatomic, strong) IBOutlet UIButton *imageWellAddButton;
@property (nonatomic, strong) IBOutlet UIButton *imageWellDeleteButton;
@property (nonatomic, strong) IBOutlet UIButton *packItButton;
@property (nonatomic, strong) IBOutlet UIButton *rockItButton;
@property (nonatomic, strong) IBOutlet UICollectionView *imageWellView;
@property (nonatomic, strong) IBOutlet UICollectionView *thumbnailView;
@property (nonatomic, strong) IBOutlet UICollectionView *wallpackCarousel;
@property (nonatomic, strong) IBOutlet UIImageView *imageWellMessage;
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
@property (nonatomic, strong) NSIndexPath *draggedIndexPath;
@property (nonatomic, strong) NSMutableArray *imageWell;
@property (nonatomic, strong) NSMutableArray *selections;
@property (nonatomic, strong) SYNVideoDB *videoDB;
@property (nonatomic, strong) SYNSelectionDB *selectionDB;
@property (nonatomic, strong) UIImageView *draggedView;

@end

@implementation SYNDiscoverTopTabViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.imageWell = [[NSMutableArray alloc] initWithCapacity: 100];
    self.selections = [[NSMutableArray alloc] initWithCapacity: 100];
    
    self.videoDB = [SYNVideoDB sharedVideoDBManager];
    self.selectionDB = [SYNSelectionDB sharedSelectionDBManager];
    
#ifdef FULL_SCREEN_THUMBNAILS
    
}
#endif

    self.maintitle.font = [UIFont boldRockpackFontOfSize: 24.0f];
    self.subtitle.font = [UIFont rockpackFontOfSize: 17.0f];
    self.packIt.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.rockIt.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.packItNumber.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.rockItNumber.font = [UIFont boldRockpackFontOfSize: 20.0f];

    // Init collection view
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNThumbnailCell"
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


- (void) viewWillAppear: (BOOL) animated
{
    // Set the first video
    [self setLargeVideoIndex: self.currentIndex
                  withOffset: self.currentOffset];
}


- (void) setLargeVideoIndex: (int) index
                 withOffset: (int) offset
{
    self.currentIndex = index;
    self.currentOffset = offset;
    
    [self updateLargeVideoDetailsForIndex: index
                               withOffset: offset];
    
    NSURL *videoURL = [self.videoDB videoURLForIndex: index
                                          withOffset: offset];
    
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
        
        // get the text of the item to be dragged
        
        CGPoint point = [sender locationInView: self.view];
        
        // Hardcoded for now, eeek!
        CGRect frame = CGRectMake(point.x - 63, point.y - 36, 127, 72);
        self.draggedView = [[UIImageView alloc] initWithFrame: frame];
        self.draggedView.alpha = 0.7;
        self.draggedView.image = [self.videoDB thumbnailForIndex: self.currentIndex
                                                      withOffset: self.currentOffset];
        
        // now add the item to the view
        [self.view addSubview: self.draggedView];
    }
    else if (sender.state == UIGestureRecognizerStateChanged && self.inDrag)
    {
        // we dragged it, so let's update the coordinates of the dragged view
        CGPoint point = [sender locationInView: self.view];
        self.draggedView.center = point;
    }
    else if (sender.state == UIGestureRecognizerStateEnded && self.inDrag)
    {
        // we dropped, so remove it from the view
        
        [self.draggedView removeFromSuperview];
        
        // and let's figure out where we dropped it
        CGPoint point = [sender locationInView: self.dropZoneView];
        
        // If we have dropped it in the right place, then add it to our image well
        if (CGRectContainsPoint(self.dropZoneView.bounds, point))
            
        {
            [self addToImageWellFromLargeVideo: nil];
        }
    }
}

- (IBAction) longPressThumbnail: (UIGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        // figure out which item in the table was selected
        
        NSIndexPath *indexPath = [self.thumbnailView indexPathForItemAtPoint: [sender locationInView: self.thumbnailView]];
        
        if (!indexPath)
        {
            self.inDrag = NO;
            return;
        }
        
        self.inDrag = YES;
        self.draggedIndexPath = indexPath;
        
        // get the text of the item to be dragged
        
        CGPoint point = [sender locationInView: self.view];
        
        // Hardcoded for now, eeek!
        CGRect frame = CGRectMake(point.x - 63, point.y - 36, 127, 72);
        self.draggedView = [[UIImageView alloc] initWithFrame: frame];
        self.draggedView.alpha = 0.7;
        self.draggedView.image = [self.videoDB thumbnailForIndex: indexPath.row
                                                      withOffset: self.currentOffset];
        
        // now add the item to the view
        [self.view addSubview: self.draggedView];
    }
    else if (sender.state == UIGestureRecognizerStateChanged && self.inDrag)
    {
        // we dragged it, so let's update the coordinates of the dragged view
        
        CGPoint point = [sender locationInView: self.view];
        self.draggedView.center = point;
    }
    else if (sender.state == UIGestureRecognizerStateEnded && self.inDrag)
    {
        // we dropped, so remove it from the view
        
        [self.draggedView removeFromSuperview];
        
        // and let's figure out where we dropped it
        CGPoint point = [sender locationInView: self.dropZoneView];
        
        // If we have dropped it in the right place, then add it to our image well
        if (CGRectContainsPoint(self.dropZoneView.bounds, point))
            
        {
            [self animateImageWellAdditionWithVideoForIndex: self.draggedIndexPath.row
                                                 withOffset: self.currentOffset];
        }
    }
}


- (void) updateLargeVideoDetailsForIndex: (int) index
                              withOffset: (int) offset
{
    self.maintitle.text = [self.videoDB titleForIndex: index
                                           withOffset: offset];
    
    self.subtitle.text = [self.videoDB subtitleForIndex: index
                                             withOffset: offset];
    
    self.packItNumber.text = [NSString stringWithFormat: @"%d", [self.videoDB packItNumberForIndex: index
                                                                                        withOffset: offset]];
    
    self.rockItNumber.text = [NSString stringWithFormat: @"%d", [self.videoDB rockItNumberForIndex: index
                                                                                        withOffset: offset]];
    self.packItButton.selected = ([self.videoDB packItForIndex: index
                                                    withOffset: offset]) ? TRUE : FALSE;
    
    self.rockItButton.selected = ([self.videoDB rockItForIndex: index
                                                    withOffset: offset]) ? TRUE : FALSE;
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
        self.currentOffset = newSelectedIndex;
        
        [self setLargeVideoIndex: 0
                      withOffset: self.currentOffset];
        
        [self.thumbnailView reloadData];
    }
}

- (IBAction) toggleLargeRockItButton: (id)sender
{
    int number = [self.videoDB rockItNumberForIndex: self.currentIndex
                                         withOffset: self.currentOffset];
    
    BOOL isTrue = [self.videoDB rockItForIndex: self.currentIndex
                                    withOffset: self.currentOffset];
    
    if (isTrue)
    {
        number--;
        
        [self.videoDB setRockIt: FALSE
                       forIndex: self.currentIndex
                     withOffset: self.currentOffset];
    }
    else
    {
        number++;
        
        [self.videoDB setRockIt: TRUE
                       forIndex: self.currentIndex
                     withOffset: self.currentOffset];
    }
    
    [self.videoDB setRockItNumber: number
                         forIndex: self.currentIndex
                       withOffset: self.currentOffset];
    
    [self updateLargeVideoDetailsForIndex: self.currentIndex
                               withOffset: self.currentOffset];
    
    [self.thumbnailView reloadData];
}

- (IBAction) toggleLargePackItButton: (id)sender
{
    int number = [self.videoDB packItNumberForIndex: self.currentIndex
                                         withOffset: self.currentOffset];
    
    BOOL isTrue = [self.videoDB packItForIndex: self.currentIndex
                                    withOffset: self.currentOffset];
    
    if (isTrue)
    {
        number--;
        
        [self.videoDB setPackIt: FALSE
                       forIndex: self.currentIndex
                     withOffset: self.currentOffset];
    }
    else
    {
        number++;
        
        [self.videoDB setPackIt: TRUE
                       forIndex: self.currentIndex
                     withOffset: self.currentOffset];
    }
    
    [self.videoDB setPackItNumber: number
                         forIndex: self.currentIndex
                       withOffset: self.currentOffset];
    
    [self updateLargeVideoDetailsForIndex: self.currentIndex
                               withOffset: self.currentOffset];
    
    [self.thumbnailView reloadData];
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
        return self.videoDB.numberOfVideos;
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
        SYNThumbnailCell *cell = [cv dequeueReusableCellWithReuseIdentifier: @"ThumbnailCell"
                                                               forIndexPath: indexPath];
        
        cell.imageView.image = [self.videoDB thumbnailForIndex: indexPath.row
                                                    withOffset: self.currentOffset];
        
        cell.maintitle.text = [self.videoDB titleForIndex: indexPath.row
                                               withOffset: self.currentOffset];
        
        cell.subtitle.text = [self.videoDB subtitleForIndex: indexPath.row
                                                 withOffset: self.currentOffset];
        
        cell.packItNumber.text = [NSString stringWithFormat: @"%d", [self.videoDB packItNumberForIndex: indexPath.row
                                                                                            withOffset: self.currentOffset]];
        
        cell.rockItNumber.text = [NSString stringWithFormat: @"%d", [self.videoDB rockItNumberForIndex: indexPath.row
                                                                                            withOffset: self.currentOffset]];
        cell.packItButton.selected = ([self.videoDB packItForIndex: indexPath.row
                                                        withOffset: self.currentOffset]) ? TRUE : FALSE;
        
        cell.rockItButton.selected = ([self.videoDB rockItForIndex: indexPath.row
                                                        withOffset: self.currentOffset]) ? TRUE : FALSE;
        
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
#warning "Need to select wallpack here"
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
        self.currentIndex = indexPath.row;
        
        [self setLargeVideoIndex: self.currentIndex
                      withOffset: self.currentOffset];
    }
    else
    {
        NSLog (@"Selecting image well cell does nothing");
    }
}

#pragma mark - Image well support


- (IBAction) addToImageWellFromLargeVideo: (id) sender
{
    [self animateImageWellAdditionWithVideoForIndex: self.currentIndex
                                         withOffset: self.currentOffset];
}

- (void) animateImageWellAdditionWithVideoForIndex: (int) index
                                        withOffset: (int) offset
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
    
    SYNSelection *selection = [[SYNSelection alloc] initWithIndex: index
                                                        andOffset: offset];
    
    [self.selections insertObject: selection
                         atIndex: 0];
    
    // Add image at front
    UIImage *image = [self.videoDB thumbnailForIndex: index
                                          withOffset: offset];
    
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
    [[SYNSelectionDB sharedSelectionDBManager] setSelections: self.selections];
    
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
                                  atScrollPosition: UICollectionViewScrollPositionCenteredVertically
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
    NSIndexPath *indexPath = [cv indexPathForItemAtPoint: CGPointMake(100.0f, cv.contentOffset.y + 250.0f)];
    
    NSString *imageName = [NSString stringWithFormat: @"LargeWallpack_%d.jpg", indexPath.row % 10];
    //    self.wallpackPreview.image = [UIImage imageNamed: imageName];
    //
    //    self.wallpackTitle.text = [self.wallpackTitles objectAtIndex: indexPath.row % 11];
    //    self.wallpackPrice.text = [self.wallpackPrices objectAtIndex: indexPath.row % 11];
}

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    self.selectionDB.selectionTitle = textField.text;
    
    [self.channelNameField resignFirstResponder];
    [self clearImageWell];
    
    
//	[[NSNotificationCenter defaultCenter] postNotificationName: @"SelectMyRockPackTab"
//					             									                object: nil];
    
    return YES;
}

- (void) textFieldDidEndEditing: (UITextField *) textField
{
    self.channelChooserView.alpha = 0.0f;
}

@end
