//
//  SYNAbstractViewController.m
//  rockpack
//
//  Created by Nick Banks on 27/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//
//  Abstract view controller to provide functionality common to all Rockpack view controllers
//
//  To keep the code as DRY as possible, we put as much common stuff in here as possible

#import "AppConstants.h"
#import "AudioToolbox/AudioToolbox.h"
#import "CCoverflowCollectionViewLayout.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "NSObject+Blocks.h"
#import "SYNAbstractViewController.h"
#import "SYNAppDelegate.h"
#import "SYNBottomTabViewController.h"
#import "SYNChannelSelectorCell.h"
#import "SYNImageWellCell.h"
#import "SYNVideoSelection.h"
#import "SYNVideoThumbnailWideCell.h"
#import "UIFont+SYNFont.h"
#import "Video.h"
#import "VideoInstance.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNAbstractViewController ()  <UITextFieldDelegate>

@property (getter = isImageWellVisible) BOOL imageWellVisible;
@property (nonatomic, assign) BOOL shouldPlaySound;
@property (nonatomic, strong) IBOutlet UICollectionView *channelCoverCarouselCollectionView;
@property (nonatomic, strong) IBOutlet UICollectionView *imageWellCollectionView;
@property (nonatomic, strong) IBOutlet UIImageView *channelOverlayView;
@property (nonatomic, strong) IBOutlet UITextField *channelNameTextField;
@property (nonatomic, strong) IBOutlet UIView *channelChooserView;
@property (nonatomic, strong) NSFetchedResultsController *channelFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *videoInstanceFetchedResultsController;
@property (nonatomic, strong) NSTimer *imageWellAnimationTimer;
@property (nonatomic, strong) UIButton *imageWellAddButton;
@property (nonatomic, strong) UIButton *imageWellDeleteButton;
@property (nonatomic, strong) UIButton *imageWellShuffleButton;
@property (nonatomic, strong) UIImageView *imageWellMessageView;
@property (nonatomic, strong) UIImageView *imageWellPanelView;
@property (nonatomic, strong) UIView *dropZoneView;

@end


@implementation SYNAbstractViewController

// Need to explicitly synthesise these as we are using the real ivars below
@synthesize channelFetchedResultsController = _channelFetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize videoInstanceFetchedResultsController = _videoInstanceFetchedResultsController;

#pragma mark - Custom accessor methods

- (void) setImageWellAnimationTimer: (NSTimer*) timer
{
    // We need to invalidate our timeer before setting a new one (so that the old one doen't fire anyway)
    [_imageWellAnimationTimer invalidate];
    _imageWellAnimationTimer = timer;
}

#pragma mark - Initialisation

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    if (self.hasImageWell)
    {
        // Initialise common views
        // Overall view to slide in and out of view
        self.imageWellView = [[UIView alloc] initWithFrame: CGRectMake(0, 577+kImageWellEffectiveHeight, 1024, 111)];
        
        // Panel view
        self.imageWellPanelView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 1024, 111)];
        self.imageWellPanelView.image = [UIImage imageNamed: @"PanelImageWell.png"];
        [self.imageWellView addSubview: self.imageWellPanelView];
        
        // Buttons
        
        self.imageWellDeleteButton = [UIButton buttonWithType: UIButtonTypeCustom];
        self.imageWellDeleteButton.frame = CGRectMake(786, 37, 50, 42);
        
        [self.imageWellDeleteButton setImage: [UIImage imageNamed: @"ButtonVideoWellDelete.png"]
                                    forState: UIControlStateNormal];
        
        [self.imageWellDeleteButton setImage: [UIImage imageNamed: @"ButtonVideoWellDeleteHighlighted.png"]
                                    forState: UIControlStateHighlighted];
        
        [self.imageWellDeleteButton addTarget: self
                                       action: @selector(clearImageWell)
                             forControlEvents: UIControlEventTouchUpInside];
        
        [self.imageWellView addSubview: self.imageWellDeleteButton];
        
        self.imageWellAddButton = [UIButton buttonWithType: UIButtonTypeCustom];
        self.imageWellAddButton.frame = CGRectMake(850, 36, 50, 42);
        
        [self.imageWellAddButton setImage: [UIImage imageNamed: @"ButtonVideoWellAdd.png"]
                                 forState: UIControlStateNormal];
        
        [self.imageWellAddButton setImage: [UIImage imageNamed: @"ButtonVideoWellAddHighlighted.png"]
                                 forState: UIControlStateSelected];
        
        [self.imageWellAddButton addTarget: self
                                    action: @selector(createChannelFromImageWell)
                          forControlEvents: UIControlEventTouchUpInside];
        
        [self.imageWellView addSubview: self.imageWellAddButton];
        
        self.imageWellShuffleButton = [UIButton buttonWithType: UIButtonTypeCustom];
        self.imageWellShuffleButton.frame = CGRectMake(913, 37, 50, 42);
        
        [self.imageWellShuffleButton setImage: [UIImage imageNamed: @"ButtonVideoWellShuffle.png"]
                                     forState: UIControlStateNormal];
        
        [self.imageWellShuffleButton setImage: [UIImage imageNamed: @"ButtonVideoWellShuffleHighlighted.png"]
                                     forState: UIControlStateHighlighted];
        
        [self.imageWellView addSubview: self.imageWellShuffleButton];
        
        // Message view
        self.imageWellMessageView = [[UIImageView alloc] initWithFrame: CGRectMake(156, 47, 411, 31)];
        self.imageWellMessageView.image = [UIImage imageNamed: @"MessageDragAndDrop.png"];
        [self.imageWellView addSubview: self.imageWellMessageView];
        
        // Imagewell collection view
        
        // Need to create a layout first
        UICollectionViewFlowLayout *standardFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        standardFlowLayout.itemSize = CGSizeMake(127.0f , 72.0f);
        standardFlowLayout.minimumInteritemSpacing = 0.0f;
        standardFlowLayout.minimumLineSpacing = 15.0f;
        standardFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        self.imageWellCollectionView = [[UICollectionView alloc] initWithFrame: CGRectMake(157, 26, 608, 72)
                                                          collectionViewLayout: standardFlowLayout];
        
        self.imageWellCollectionView.delegate = self;
        self.imageWellCollectionView.dataSource = self;
        
        self.imageWellCollectionView.backgroundColor = [UIColor clearColor];
        

        // Register cells
        UINib *imageWellCellNib = [UINib nibWithNibName: @"SYNImageWellCell"
                                                 bundle: nil];
        
        [self.imageWellCollectionView registerNib: imageWellCellNib
                       forCellWithReuseIdentifier: @"ImageWellCell"];
        
        [self.imageWellView addSubview: self.imageWellCollectionView];
        
        // Drop zone
        self.dropZoneView = [[UIView alloc] initWithFrame: CGRectMake(14, 603, 125, 72)];
        [self.imageWellView addSubview: self.dropZoneView];
        
        [self.view addSubview: self.imageWellView];
        
        self.channelChooserView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 1024, 398)];
        
        self.channelOverlayView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 1024, 768)];
        self.channelOverlayView.image = [UIImage imageNamed: @"OverlayChannelCreate.png"];
        [self.channelChooserView addSubview: self.channelOverlayView];
        
        self.channelNameTextField = [[UITextField alloc] initWithFrame: CGRectMake(319, 330, 384, 35)];
        
        self.channelNameTextField.textAlignment = NSTextAlignmentCenter;
        self.channelNameTextField.textColor = [UIColor whiteColor];
        self.channelNameTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        self.channelNameTextField.returnKeyType = UIReturnKeyDone;
        self.channelNameTextField.font = [UIFont rockpackFontOfSize: 36.0f];
        self.channelNameTextField.delegate = self;
        [self.channelChooserView addSubview: self.channelNameTextField];
        
        // Carousel collection view
        
        // Set carousel collection view to use custom layout algorithm
        CCoverflowCollectionViewLayout *channelCoverCarouselHorizontalLayout = [[CCoverflowCollectionViewLayout alloc] init];
        channelCoverCarouselHorizontalLayout.cellSize = CGSizeMake(360.0f , 226.0f);
        channelCoverCarouselHorizontalLayout.cellSpacing = 40.0f;
        
        self.channelCoverCarouselCollectionView = [[UICollectionView alloc] initWithFrame: CGRectMake(62, 58, 900, 226)
                                                                     collectionViewLayout: channelCoverCarouselHorizontalLayout];

        self.channelCoverCarouselCollectionView.delegate = self;
        self.channelCoverCarouselCollectionView.dataSource = self;
        self.channelCoverCarouselCollectionView.backgroundColor = [UIColor clearColor];
        self.channelCoverCarouselCollectionView.showsHorizontalScrollIndicator = FALSE;
        
        // Set up our carousel
        [self.channelCoverCarouselCollectionView registerClass: [SYNChannelSelectorCell class]
                                    forCellWithReuseIdentifier: @"SYNChannelSelectorCell"];
        
        self.channelCoverCarouselCollectionView.decelerationRate = UIScrollViewDecelerationRateNormal;
        
        [self.channelChooserView addSubview: self.channelCoverCarouselCollectionView];
        
        // Initially hide this view
        self.channelChooserView.alpha = 0.0f;
        [self.view addSubview: self.channelChooserView];
    }
}


- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    [self.imageWellCollectionView reloadData];
}


#pragma mark - Core Data support

// Single cached MOC for all the view controllers
- (NSManagedObjectContext *) managedObjectContext
{
    static dispatch_once_t onceQueue;
    static NSManagedObjectContext *managedObjectContext = nil;
    
    dispatch_once(&onceQueue, ^
                  {
                      SYNAppDelegate *delegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
                      managedObjectContext = delegate.managedObjectContext;
                  });
    
    return managedObjectContext;
}


// Generalised version of videoInstanceFetchedResultsController, you can override the predicate and sort descriptors
// by overiding the videoInstanceFetchedResultsControllerPredicate and videoInstanceFetchedResultsControllerSortDescriptors methods
- (NSFetchedResultsController *) videoInstanceFetchedResultsController
{
    NSError *error = nil;
    
    // Return cached version if we have already created one
    if (_videoInstanceFetchedResultsController != nil)
    {
        return _videoInstanceFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    fetchRequest.entity = [NSEntityDescription entityForName: @"VideoInstance"
                                      inManagedObjectContext: self.managedObjectContext];
    
    // Add any sort descriptors and predicates
    fetchRequest.predicate = self.videoInstanceFetchedResultsControllerPredicate;
    fetchRequest.sortDescriptors = self.videoInstanceFetchedResultsControllerSortDescriptors;
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    self.videoInstanceFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                             managedObjectContext: self.managedObjectContext
                                                                               sectionNameKeyPath: nil
                                                                                        cacheName: nil];
    _videoInstanceFetchedResultsController.delegate = self;
    
    ZAssert([_videoInstanceFetchedResultsController performFetch: &error], @"videoInstanceFetchedResultsController:performFetch failed: %@\n%@", [error localizedDescription], [error userInfo]);
    
    return _videoInstanceFetchedResultsController;
}

- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{
    NSLog (@"controller updated");
}

// Abstract functions, should be overidden in subclasses
- (NSPredicate *) videoInstanceFetchedResultsControllerPredicate
{
    AssertOrLog (@"videoInstanceFetchedResultsControllerPredicate:Abstract function called");
    return nil;
}

- (NSArray *) videoInstanceFetchedResultsControllerSortDescriptors
{
    AssertOrLog (@"videoInstanceFetchedResultsControllerSortDescriptors:Abstract function called");
    return nil;
}

// Generalised version of channelFetchedResultsController, you can override the predicate and sort descriptors
// by overiding the channelFetchedResultsControllerPredicate and channelFetchedResultsControllerSortDescriptors methods
- (NSFetchedResultsController *) channelFetchedResultsController
{
    NSError *error = nil;
    
    // Return cached version if we have already created one
    if (_channelFetchedResultsController != nil)
    {
        return _channelFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    fetchRequest.entity = [NSEntityDescription entityForName: @"Channel"
                                      inManagedObjectContext: self.managedObjectContext];
    
    // Add any sort descriptors and predicates
    fetchRequest.predicate = self.channelFetchedResultsControllerPredicate;
    fetchRequest.sortDescriptors = self.channelFetchedResultsControllerSortDescriptors;
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    self.channelFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                               managedObjectContext: self.managedObjectContext
                                                                                 sectionNameKeyPath: nil
                                                                                          cacheName: nil];
    _channelFetchedResultsController.delegate = self;
    
    ZAssert([_channelFetchedResultsController performFetch: &error], @"channelFetchedResultsController:performFetch failed: %@\n%@", [error localizedDescription], [error userInfo]);
    
    return _channelFetchedResultsController;
}


// Abstract functions, should be overidden in subclasses
- (NSPredicate *) channelFetchedResultsControllerPredicate
{
    AssertOrLog (@"channelFetchedResultsControllerPredicate:Abstract function called");
    return nil;
}


- (NSArray *) channelFetchedResultsControllerSortDescriptors
{
    AssertOrLog (@"channelFetchedResultsControllerSortDescriptors:Abstract function called");
    return nil;
}


// Helper method: Save the current DB state
- (void) saveDB
{
    NSError *error = nil;
    
    if (![self.managedObjectContext save: &error])
    {
        NSArray* detailedErrors = [[error userInfo] objectForKey: NSDetailedErrorsKey];
        
        if ([detailedErrors count] > 0)
        {
            for(NSError* detailedError in detailedErrors)
            {
                DebugLog(@" DetailedError: %@", [detailedError userInfo]);
            }
        }
        
        // Bail out if save failed
        error = [NSError errorWithDomain: NSURLErrorDomain
                                    code: NSCoreDataError
                                userInfo: nil];
        
        @throw error;
    }  
}


#pragma - Animation support

// Special animation of pushing new view controller onto UINavigationController's stack
- (void) animatedPushViewController: (UIViewController *) vc
{
    self.view.alpha = 1.0f;
    vc.view.alpha = 0.0f;
    
//    [self.navigationController pushViewController: vc
//                                         animated: NO];
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         // Contract thumbnail view
         self.view.alpha = 0.0f;
         vc.view.alpha = 1.0f;
         
     }
                     completion: ^(BOOL finished)
     {
     }];
    
    [self.navigationController pushViewController: vc
                                         animated: NO];
}

- (IBAction) animatedPopViewController
{
    //	[self.navigationController popViewControllerAnimated: YES];
    
    UIViewController *parentVC = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2];
    parentVC.view.alpha = 0.0f;
    
    [self.navigationController popViewControllerAnimated: NO];
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         // Contract thumbnail view
         self.view.alpha = 0.0f;
         parentVC.view.alpha = 1.0f;
         
     }
                     completion: ^(BOOL finished)
     {
     }];
}

- (void) toggleVideoRockItAtIndex: (NSIndexPath *) indexPath
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
    
//    [self.videoThumbnailCollectionView reloadData];
}


- (void) toggleChannelRockItAtIndex: (NSIndexPath *) indexPath
{
    Channel *channel = [self.channelFetchedResultsController objectAtIndexPath: indexPath];
    
    if (channel.rockedByUserValue == TRUE)
    {
        // Currently highlighted, so decrement
        channel.rockedByUserValue = FALSE;
        channel.rockCountValue -= 1;
    }
    else
    {
        // Currently highlighted, so increment
        channel.rockedByUserValue = TRUE;
        channel.rockCountValue += 1;
    }
    
    [self saveDB];
}


- (IBAction) userTouchedVideoRockItButton: (UIButton *) rockItButton
{
    rockItButton.selected = !rockItButton.selected;
    
    // Get to cell it self (from button subview)
    UIView *v = rockItButton.superview.superview;
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: v.center];
    
    // Bail if we don't have an index path
    if (indexPath)
    {
        // Need to do this first as this changes the actual video object
        [self toggleVideoRockItAtIndex: indexPath];
        [self updateOtherOnscreenVideoAssetsForIndexPath: indexPath];
        
        if (self.shouldUpdateRockItStatus == TRUE)
        {
            VideoInstance *videoInstance = [self.videoInstanceFetchedResultsController objectAtIndexPath: indexPath];
            SYNVideoThumbnailWideCell *cell = (SYNVideoThumbnailWideCell *)[self.videoThumbnailCollectionView cellForItemAtIndexPath: indexPath];
            
            cell.rockItButton.selected = videoInstance.video.starredByUserValue;
            cell.rockItNumber.text = [NSString stringWithFormat: @"%@", videoInstance.video.starCount];
        }
    }
}


// This can be overridden if updating RockIt may cause the videoFetchedResults
- (BOOL) shouldUpdateRockItStatus
{
    return TRUE;
}


// This is intended to be subclassed where other video assets (i.e. a Large video view) have information that is dependent on Video attributes
- (void) updateOtherOnscreenVideoAssetsForIndexPath: (NSIndexPath *) indexPath
{
    // By default, do nothing
}


- (IBAction) userTouchedVideoAddItButton: (UIButton *) addItButton
{
    [self showImageWell: TRUE];
    [self startImageWellDismissalTimer];
    
    UIView *v = addItButton.superview.superview;
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: v.center];
    VideoInstance *videoInstance = [self.videoInstanceFetchedResultsController objectAtIndexPath: indexPath];
    [self animateImageWellAdditionWithVideo: videoInstance];
}

- (IBAction) userTouchedVideoShareItButton: (UIButton *) addItButton
{
    SYNAppDelegate *delegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    SYNBottomTabViewController *bottomTabViewController = delegate.viewController;
    
    if (bottomTabViewController.rockieTalkieButton.selected == FALSE)
    {
        // Need to slide rockie talkie out
        [bottomTabViewController swipeRockieTalkieRight: nil];
    }
}


#pragma mark - Initialisation


- (NSInteger) collectionView: (UICollectionView *) cv
      numberOfItemsInSection: (NSInteger) section
{
    if (cv == self.channelCoverCarouselCollectionView)
    {
        return 10;
    }
    else if (cv == self.imageWellCollectionView)
    {
        return SYNVideoSelection.sharedVideoSelectionArray.count;
    }
    else
    {
        // Signal that we do not handle this collection view
        return -1;
    }
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    UICollectionViewCell *cell = nil;
    
    if (cv == self.videoThumbnailCollectionView)
    {
        // No, but it was our collection view
        VideoInstance *videoInstance = [self.videoInstanceFetchedResultsController objectAtIndexPath: indexPath];
        
        SYNVideoThumbnailWideCell *videoThumbnailCell = [cv dequeueReusableCellWithReuseIdentifier: @"SYNVideoThumbnailWideCell"
                                                                                      forIndexPath: indexPath];
        
        videoThumbnailCell.videoImageView.image = videoInstance.video.thumbnailImage;
        videoThumbnailCell.channelImageView.image = videoInstance.channel.thumbnailImage;
        videoThumbnailCell.videoTitle.text = videoInstance.title;
        videoThumbnailCell.channelName.text = videoInstance.channel.title;
        videoThumbnailCell.userName.text = videoInstance.channel.channelOwner.name;
        videoThumbnailCell.rockItNumber.text = [NSString stringWithFormat: @"%@", videoInstance.video.starCount];
        videoThumbnailCell.rockItButton.selected = videoInstance.video.starredByUserValue;
        videoThumbnailCell.viewControllerDelegate = self;
        
        cell = videoThumbnailCell;
    }
    else if (cv == self.channelCoverCarouselCollectionView)
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
        
        SYNChannelSelectorCell *channelCarouselCell = [cv dequeueReusableCellWithReuseIdentifier: @"SYNChannelSelectorCell"
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
        
        channelCarouselCell.imageView.image = image;
        
        channelCarouselCell.imageView.layer.shouldRasterize = YES;
        channelCarouselCell.imageView.layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;
        channelCarouselCell.imageView.clipsToBounds = NO;
        channelCarouselCell.imageView.layer.masksToBounds = NO;
        
        // End of clever jaggie reduction
        
        cell = channelCarouselCell;
    }
    else if (cv == self.imageWellCollectionView)
    {
        SYNImageWellCell *imageWellCell = [cv dequeueReusableCellWithReuseIdentifier: @"ImageWellCell"
                                                               forIndexPath: indexPath];
        
        Video *video = [SYNVideoSelection.sharedVideoSelectionArray objectAtIndex: indexPath.row];
        imageWellCell.imageView.image = video.thumbnailImage;
        
        cell = imageWellCell;
    }

    return cell;
}


- (BOOL) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPathAbstract: (NSIndexPath *) indexPath
{
    // Assume for now, that we can handle this
    BOOL handledInAbstractView = TRUE;
    
    if (cv == self.channelCoverCarouselCollectionView)
    {
        //#warning "Need to select wallpack here"
        DebugLog (@"Selecting channel cover cell does nothing");
    }
    else if (cv == self.imageWellCollectionView)
    {
        DebugLog (@"Selecting image well cell does nothing");
    }
    else 
    {
        // OK, it turns out that we can't handle this (so indicate to caller)
        handledInAbstractView = FALSE;
    }
    
    return handledInAbstractView;
}

- (IBAction) createChannelFromImageWell
{
    UIViewController *pvc = self.parentViewController;
    
    [pvc.view addSubview: self.channelChooserView];
    
    self.channelNameTextField.text = @"";
    [self.channelNameTextField becomeFirstResponder];
    
    [UIView animateWithDuration: kCreateChannelPanelAnimationDuration
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


// Assume no image well by default
- (BOOL) hasImageWell
{
    return FALSE;
}


// Assume that the imagewell is not visible on first entry to the tab
- (BOOL) isImageWellVisibleOnStart;
{
    return FALSE;
}


// Assume that there are no other views to expand
- (NSArray *) otherViewsToResizeOnImageWellExpandOrContract
{
    return nil;
}

- (void) startImageWellDismissalTimer
{
    self.imageWellAnimationTimer = [NSTimer scheduledTimerWithTimeInterval: kImageWellOnScreenDuration
                                                                    target: self
                                                                  selector: @selector(imageWellTimerCallback)
                                                                  userInfo: nil
                                                                   repeats: NO];
}

- (void) imageWellTimerCallback
{
    [self hideImageWell: TRUE];
}

- (void) showImageWell: (BOOL) animated
{
    if (self.imageWellVisible == FALSE)
    {
        self.imageWellVisible = TRUE;
        
        if (animated)
        {
            // Slide imagewell view upwards (and contract any other dependent visible views)
            [UIView animateWithDuration: kImageWellAnimationDuration
                                  delay: 0.0f
                                options: UIViewAnimationOptionCurveEaseInOut
                             animations: ^
             {
                 [self shiftImageWellUp];
             }
             completion: ^(BOOL finished)
             {
             }];
        }
        else
        {
            [self shiftImageWellUp];
        }
    }
}


- (void) hideImageWell: (BOOL) animated
{
    if (self.imageWellVisible == TRUE)
    {
        self.imageWellVisible = FALSE;
        
        if (animated)
        {
            [UIView animateWithDuration: kCreateChannelPanelAnimationDuration
                                  delay: 0.0f
                                options: UIViewAnimationOptionCurveEaseInOut
                             animations: ^
             {
                 // Slide imagewell view downwards (and expand any other dependent visible views)
                 [self shiftImageWellDown];
             }
             completion: ^(BOOL finished)
             {
             }];
        }
        else
        {
            [self shiftImageWellDown];
        }
    }
}

- (void) shiftImageWellUp
{
    CGRect imageWellFrame = self.imageWellView.frame;
    imageWellFrame.origin.y -= kImageWellEffectiveHeight;
    self.imageWellView.frame = imageWellFrame;
}

- (void) shiftImageWellDown
{
    CGRect imageWellFrame = self.imageWellView.frame;
    imageWellFrame.origin.y += kImageWellEffectiveHeight;
    self.imageWellView.frame = imageWellFrame;
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
    
    [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         self.imageWellMessageView.alpha = 1.0f;
         
     }
                     completion: ^(BOOL finished)
     {
     }];
}


- (void) scrollViewDidEndDecelerating: (UICollectionView *) cv
{
    //    NSIndexPath *indexPath = [self.channelCoverCarousel indexPathForItemAtPoint: CGPointMake (450 + self.channelCoverCarousel.contentOffset.x,
    //                                                                                              70 + self.channelCoverCarousel.contentOffset.y)];
}


// User has pressed the Done button, so create a new channel
- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    [self addChannelWithTitle: textField.text];
    
    return YES;
}

- (void) textFieldDidEndEditing: (UITextField *) textField
{
    self.channelChooserView.alpha = 0.0f;
}

- (void) addChannelWithTitle: (NSString *) title
{
    Channel *newChannel = [Channel insertInManagedObjectContext: self.managedObjectContext];
    
    newChannel.title = title;
    newChannel.rockedByUserValue = FALSE;
    newChannel.rockCountValue = 0;
    newChannel.rockedByUserValue = TRUE;
    
    // TODO: Make these window offsets less hard-coded
    NSIndexPath *indexPath = [self.channelCoverCarouselCollectionView indexPathForItemAtPoint: CGPointMake (450 + self.channelCoverCarouselCollectionView.contentOffset.x,
                                                                                                            70 + self.channelCoverCarouselCollectionView.contentOffset.y)];
    
    Channel *coverChannel = [self.channelFetchedResultsController objectAtIndexPath: indexPath];
    
    newChannel.thumbnailURL = coverChannel.thumbnailURL;
    newChannel.wallpaperURL = coverChannel.wallpaperURL;
    newChannel.channelDescription = coverChannel.channelDescription;
    
    for (VideoInstance *videoInstance in SYNVideoSelection.sharedVideoSelectionArray)
    {
        [[newChannel videoInstanceSet] addObject: videoInstance];
    }
    
    [self.channelNameTextField resignFirstResponder];
    [self clearImageWell];
}

#pragma mark - Image well support

- (void) animateImageWellAdditionWithVideo: (VideoInstance *) videoInstance
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
    if (SYNVideoSelection.sharedVideoSelectionArray.count == 0)
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
    
    [SYNVideoSelection.sharedVideoSelectionArray insertObject: videoInstance
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

- (void) highlightImageWell: (BOOL) showHighlight
{
    if (showHighlight)
    {
        self.imageWellPanelView.image = [UIImage imageNamed: @"PanelImageWellHighlighted.png"];
    }
    else
    {
        self.imageWellPanelView.image = [UIImage imageNamed: @"PanelImageWell.png"];
    }
}


- (BOOL) pointInImageWell: (CGPoint) point
{
    return CGRectContainsPoint(self.imageWellView.frame, point);
}

@end
