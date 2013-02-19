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
#import "Channel.h"
#import "ChannelOwner.h"
#import "NSObject+Blocks.h"
#import "SYNAbstractViewController.h"
#import "SYNBottomTabViewController.h"
//#import "SYNChannelSelectorCell.h"
#import "SYNChannelsDetailsCreationViewController.h"
#import "SYNNetworkEngine.h"
#import "SYNVideoQueueCell.h"
#import "SYNVideoSelection.h"
#import "SYNVideoThumbnailWideCell.h"
#import "SYNVideoViewerViewController.h"
#import "UIFont+SYNFont.h"
#import "Video.h"
#import "VideoInstance.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNAbstractViewController ()  <UITextFieldDelegate>

@property (getter = isVideoQueueVisible) BOOL videoQueueVisible;
@property (nonatomic, assign) BOOL shouldPlaySound;
@property (nonatomic, strong) IBOutlet UICollectionView *videoQueueCollectionView;
@property (nonatomic, strong) IBOutlet UIImageView *channelOverlayView;
@property (nonatomic, strong) IBOutlet UITextField *channelNameTextField;
@property (nonatomic, strong) MKNetworkOperation *draggedImageLoadingOperation;
@property (nonatomic, strong) NSFetchedResultsController *channelFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *videoInstanceFetchedResultsController;
@property (nonatomic, strong) NSTimer *videoQueueAnimationTimer;
@property (nonatomic, strong) SYNVideoViewerViewController *videoViewerViewController;
@property (nonatomic, strong) UIButton *videoQueueDeleteButton;
@property (nonatomic, strong) UIButton *videoQueueExistingButton;
@property (nonatomic, strong) UIButton *videoQueueNewButton;
@property (nonatomic, strong) UIImageView *videoQueueMessageView;
@property (nonatomic, strong) UIImageView *videoQueuePanelView;
@property (nonatomic, strong) UIView *dropZoneView;

@end


@implementation SYNAbstractViewController

// Need to explicitly synthesise these as we are using the real ivars below
@synthesize channelFetchedResultsController = _channelFetchedResultsController;
@synthesize videoInstanceFetchedResultsController = _videoInstanceFetchedResultsController;

#pragma mark - Custom accessor methods

- (void) setVideoQueueAnimationTimer: (NSTimer*) timer
{
    // We need to invalidate our timeer before setting a new one (so that the old one doen't fire anyway)
    [_videoQueueAnimationTimer invalidate];
    _videoQueueAnimationTimer = timer;
}



#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (self.hasVideoQueue)
    {
        // Initialise common views
        // Overall view to slide in and out of view
//        self.videoQueueView = [[UIView alloc] initWithFrame: CGRectMake(0, 577+kVideoQueueEffectiveHeight, 1024, kVideoQueueEffectiveHeight)];
        self.videoQueueView = [[UIView alloc] initWithFrame: CGRectMake(0, 573+kVideoQueueEffectiveHeight, 1024, kVideoQueueEffectiveHeight)];
        
        // Panel view
        self.videoQueuePanelView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 1024, 115)];
        self.videoQueuePanelView.image = [UIImage imageNamed: @"PanelVideoQueue.png"];
        [self.videoQueueView addSubview: self.videoQueuePanelView];
        
        // Buttons
        
        self.videoQueueDeleteButton = [UIButton buttonWithType: UIButtonTypeCustom];
        self.videoQueueDeleteButton.frame = CGRectMake(949, 35, 50, 50);
        
        [self.videoQueueDeleteButton setImage: [UIImage imageNamed: @"ButtonVideoWellDelete.png"]
                                     forState: UIControlStateNormal];
        
        [self.videoQueueDeleteButton setImage: [UIImage imageNamed: @"ButtonVideoWellDeleteHighlighted.png"]
                                     forState: UIControlStateHighlighted];
        
        [self.videoQueueDeleteButton addTarget: self
                                        action: @selector(clearVideoQueue)
                              forControlEvents: UIControlEventTouchUpInside];
        
        [self.videoQueueView addSubview: self.videoQueueDeleteButton];
        
        self.videoQueueNewButton = [UIButton buttonWithType: UIButtonTypeCustom];
        self.videoQueueNewButton.frame = CGRectMake(663, 35, 50, 50);
        
        [self.videoQueueNewButton setImage: [UIImage imageNamed: @"ButtonVideoWellNew.png"]
                                  forState: UIControlStateNormal];
        
        [self.videoQueueNewButton setImage: [UIImage imageNamed: @"ButtonVideoWellNewHighlighted.png"]
                                  forState: UIControlStateSelected];
        
        [self.videoQueueNewButton addTarget: self
                                    action: @selector(createChannelFromVideoQueue)
                          forControlEvents: UIControlEventTouchUpInside];
        
        [self.videoQueueView addSubview: self.videoQueueNewButton];
        
        self.videoQueueExistingButton = [UIButton buttonWithType: UIButtonTypeCustom];
        self.videoQueueExistingButton.frame = CGRectMake(806, 35, 50, 50);
        
        [self.videoQueueExistingButton setImage: [UIImage imageNamed: @"ButtonVideoWellExisting.png"]
                                     forState: UIControlStateNormal];
        
        [self.videoQueueExistingButton setImage: [UIImage imageNamed: @"ButtonVideoWellExistingHighlighted.png"]
                                     forState: UIControlStateHighlighted];
        
        [self.videoQueueView addSubview: self.videoQueueExistingButton];
        
        // Message view
        self.videoQueueMessageView = [[UIImageView alloc] initWithFrame: CGRectMake(60, 47, 411, 31)];
        self.videoQueueMessageView.image = [UIImage imageNamed: @"MessageDragAndDrop.png"];
        
        
        // Disable message if we already have items in the queue (from another screen)
        if (SYNVideoSelection.sharedVideoSelectionArray.count != 0)
        {
            self.videoQueueMessageView.alpha = 0.0f;
        }
        
        [self.videoQueueView addSubview: self.videoQueueMessageView];
        
        // Video Queue collection view
        
        // Need to create a layout first
        UICollectionViewFlowLayout *standardFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        standardFlowLayout.itemSize = CGSizeMake(127.0f , 73.0f);
        standardFlowLayout.minimumInteritemSpacing = 0.0f;
        standardFlowLayout.minimumLineSpacing = 15.0f;
        standardFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
         standardFlowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
//        self.videoQueueCollectionView = [[UICollectionView alloc] initWithFrame: CGRectMake(10, 26, 478, 73)
//                                                          collectionViewLayout: standardFlowLayout];
        
        // Make this of zero width initially
        self.videoQueueCollectionView = [[UICollectionView alloc] initWithFrame: CGRectMake(kVideoQueueWidth + kVideoQueueOffsetX, 26, 0, 73)
                                                           collectionViewLayout: standardFlowLayout];
        
        self.videoQueueCollectionView.delegate = self;
        self.videoQueueCollectionView.dataSource = self;
        
        self.videoQueueCollectionView.backgroundColor = [UIColor clearColor];
//            self.videoQueueCollectionView.backgroundColor = [UIColor blueColor];
        // Register cells
        UINib *videoQueueCellNib = [UINib nibWithNibName: @"SYNVideoQueueCell"
                                                 bundle: nil];
        
        [self.videoQueueCollectionView registerNib: videoQueueCellNib
                       forCellWithReuseIdentifier: @"VideoQueueCell"];
        
        [self.videoQueueView addSubview: self.videoQueueCollectionView];
        
        // Drop zone
        self.dropZoneView = [[UIView alloc] initWithFrame: CGRectMake(20, 640, 127, 73)];
        [self.videoQueueView addSubview: self.dropZoneView];
        
        [self.view addSubview: self.videoQueueView];
    }
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    if (self.hasVideoQueue)
    {
        // Disable message if we already have items in the queue (from another screen)
        if (SYNVideoSelection.sharedVideoSelectionArray.count != 0)
        {
            self.videoQueueMessageView.alpha = 0.0f;
        }
        else
        {
            self.videoQueueMessageView.alpha = 1.0f;
        }
        
        [self.videoQueueCollectionView reloadData];
    }
}

- (void) viewDidDisappear: (BOOL) animated
{
    [super viewDidDisappear: animated];
    
    if (self.hasVideoQueue)
    {
        [self hideVideoQueue: NO];
    }
}


#pragma mark - Core Data support




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
                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    // Add any sort descriptors and predicates
    fetchRequest.predicate = self.videoInstanceFetchedResultsControllerPredicate;
    fetchRequest.sortDescriptors = self.videoInstanceFetchedResultsControllerSortDescriptors;
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    self.videoInstanceFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                             managedObjectContext: appDelegate.mainManagedObjectContext
                                                                               sectionNameKeyPath: self.videoInstanceFetchedResultsControllerSectionNameKeyPath
                                                                                        cacheName: nil];
    _videoInstanceFetchedResultsController.delegate = self;
    
    ZAssert([_videoInstanceFetchedResultsController performFetch: &error], @"videoInstanceFetchedResultsController:performFetch failed: %@\n%@", [error localizedDescription], [error userInfo]);
    
    return _videoInstanceFetchedResultsController;
}

- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{
    NSLog (@"controller updated");
    
    [self reloadCollectionViews];
}



#pragma mark - Abstract Accessors

- (NSPredicate *) videoInstanceFetchedResultsControllerPredicate
{
    AssertOrLog (@"Abstract class called 'videoInstanceFetchedResultsControllerPredicate'");
    return nil;
}

- (NSArray *) videoInstanceFetchedResultsControllerSortDescriptors
{
    AssertOrLog (@"Abstract class called 'videoInstanceFetchedResultsControllerSortDescriptors'");
    return nil;
}

- (NSString *) videoInstanceFetchedResultsControllerSectionNameKeyPath
{
    AssertOrLog (@"Abstract class called 'videoInstanceFetchedResultsControllerSectionNameKeyPath'");
    return nil;
}

- (NSPredicate *) channelFetchedResultsControllerPredicate
{
    AssertOrLog (@"Abstract class called 'channelFetchedResultsControllerPredicate'");
    return nil;
}


- (NSArray *) channelFetchedResultsControllerSortDescriptors
{
    AssertOrLog (@"Abstract class called 'channelFetchedResultsControllerSortDescriptors'");
    return nil;
}


-(void)reloadCollectionViews
{
    AssertOrLog (@"Abstract class called 'reloadCollectionViews'");
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
                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    // Add any sort descriptors and predicates
    fetchRequest.predicate = self.channelFetchedResultsControllerPredicate;
    fetchRequest.sortDescriptors = self.channelFetchedResultsControllerSortDescriptors;
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    self.channelFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                               managedObjectContext: appDelegate.mainManagedObjectContext
                                                                                 sectionNameKeyPath: nil
                                                                                          cacheName: nil];
    _channelFetchedResultsController.delegate = self;
    
    ZAssert([_channelFetchedResultsController performFetch: &error], @"channelFetchedResultsController:performFetch failed: %@\n%@", [error localizedDescription], [error userInfo]);
    
    return _channelFetchedResultsController;
}



// Helper method: Save the current DB state
- (void) saveDB
{
    NSError *error = nil;
    
    if (![appDelegate.mainManagedObjectContext save: &error])
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


#pragma mark - Animation support

// Special animation of pushing new view controller onto UINavigationController's stack
- (void) animatedPushViewController: (UIViewController *) vc
{
    self.view.alpha = 1.0f;
    vc.view.alpha = 0.0f;
    
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
    
    
    SYNBottomTabViewController *bottomTabViewController = appDelegate.viewController;
    
    // Show back button
    [bottomTabViewController showBackButton];
}


- (IBAction) animatedPopViewController
{
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
    
    // Hide back button
    
    
    SYNBottomTabViewController *bottomTabViewController = appDelegate.viewController;
    [bottomTabViewController hideBackButton];
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
//    rockItButton.selected = !rockItButton.selected;
    
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
            SYNVideoThumbnailWideCell *videoThumbnailCell = (SYNVideoThumbnailWideCell *)[self.videoThumbnailCollectionView cellForItemAtIndexPath: indexPath];
            
            [self updateVideoCellRockItButtonAndCount: videoThumbnailCell
                                             selected: videoInstance.video.starredByUserValue];
//            videoThumbnailCell.rockItButton.selected = videoInstance.video.starredByUserValue;
            videoThumbnailCell.rockItNumber.text = [NSString stringWithFormat: @"%@", videoInstance.video.starCount];
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
    [self showVideoQueue: TRUE];
    [self startVideoQueueDismissalTimer];
    
    UIView *v = addItButton.superview.superview;
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: v.center];
    VideoInstance *videoInstance = [self.videoInstanceFetchedResultsController objectAtIndexPath: indexPath];
    [self animateVideoAdditionToVideoQueue: videoInstance];
}


- (IBAction) userTouchedVideoShareItButton: (UIButton *) addItButton
{
    
    
    SYNBottomTabViewController *bottomTabViewController = appDelegate.viewController;
    
    // Need to slide rockie talkie out
    [bottomTabViewController toggleShareMenu];
}


// Called by invisible button on video view cell
- (void) displayVideoViewerFromView: (UIGestureRecognizer *) sender
{
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: [sender locationInView: self.videoThumbnailCollectionView]];

    VideoInstance *videoInstance = [self.videoInstanceFetchedResultsController objectAtIndexPath: indexPath];
    
    [self displayVideoViewer: videoInstance];
}


- (void) displayVideoViewer: (VideoInstance *) videoInstance
{
    
    
    SYNBottomTabViewController *bottomTabViewController = appDelegate.viewController;
    
    self.videoViewerViewController = [[SYNVideoViewerViewController alloc] initWithVideoInstance: videoInstance];
    
    self.videoViewerViewController.view.alpha = 0.0f;
    [bottomTabViewController.view addSubview: self.videoViewerViewController.view];
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         self.videoViewerViewController.view.alpha = 1.0f;
     }
     completion: ^(BOOL finished)
     {
         [self.videoViewerViewController.closeButton addTarget: self
                                                        action: @selector(dismissVideoViewer)
                                              forControlEvents: UIControlEventTouchUpInside];
     }];
}

- (IBAction) dismissVideoViewer
{
    [UIView animateWithDuration: 0.25f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         self.videoViewerViewController.view.alpha = 0.0f;
     }
     completion: ^(BOOL finished)
     {
         [self.videoViewerViewController.view removeFromSuperview];
         self.videoViewerViewController = nil;
     }];

}


#pragma mark - Initialisation


- (NSInteger) collectionView: (UICollectionView *) cv
      numberOfItemsInSection: (NSInteger) section
{
    if (cv == self.videoQueueCollectionView)
    {
        return SYNVideoSelection.sharedVideoSelectionArray.count;
    }
    else
    {
        // Signal that we do not handle this collection view
        return -1;
    }
}

- (void) updateVideoCellRockItButtonAndCount: (SYNVideoThumbnailWideCell *) videoThumbnailCell
                                    selected: (BOOL) selected
{
    videoThumbnailCell.rockItButton.selected = selected;
    
    if (selected)
    {
        videoThumbnailCell.rockItNumber.textColor = [UIColor colorWithRed: 0.894f green: 0.945f blue: 0.965f alpha: 1.0f];
    }
    else
    {
        videoThumbnailCell.rockItNumber.textColor = [UIColor colorWithRed: 0.510f green: 0.553f blue: 0.569f alpha: 1.0f];
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
        
        videoThumbnailCell.videoImageViewImage = videoInstance.video.thumbnailURL;
        videoThumbnailCell.channelImageViewImage = videoInstance.channel.coverThumbnailSmallURL;
        videoThumbnailCell.videoTitle.text = videoInstance.title;
        videoThumbnailCell.channelName.text = videoInstance.channel.title;
        videoThumbnailCell.userName.text = videoInstance.channel.channelOwner.name;
        videoThumbnailCell.rockItNumber.text = [NSString stringWithFormat: @"%@", videoInstance.video.starCount];
        
        [self updateVideoCellRockItButtonAndCount: videoThumbnailCell
                                         selected: videoInstance.video.starredByUserValue];
        
//        videoThumbnailCell.rockItButton.selected = videoInstance.video.starredByUserValue;
        videoThumbnailCell.viewControllerDelegate = self;
        
        cell = videoThumbnailCell;
    }
    else if (cv == self.videoQueueCollectionView)
    {
        SYNVideoQueueCell *videoQueueCell = [cv dequeueReusableCellWithReuseIdentifier: @"VideoQueueCell"
                                                               forIndexPath: indexPath];
        
        VideoInstance *videoInstance = [SYNVideoSelection.sharedVideoSelectionArray objectAtIndex: indexPath.item];
        
        // Load the image asynchronously
        videoQueueCell.VideoImageViewImage = videoInstance.video.thumbnailURL;
        
        [self.draggedView setImageFromURL: [NSURL URLWithString: videoInstance.video.thumbnailURL]
                         placeHolderImage: nil];
        
        cell = videoQueueCell;
    }

    return cell;
}


- (BOOL) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPathAbstract: (NSIndexPath *) indexPath
{
    // Assume for now, that we can handle this
    BOOL handledInAbstractView = TRUE;
    
    if (cv == self.videoQueueCollectionView)
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

//- (IBAction) createChannelFromVideoQueue
//{
//    UIViewController *pvc = self.parentViewController;
//    
//    [pvc.view addSubview: self.channelChooserView];
//    
//    self.channelNameTextField.text = @"";
//    [self.channelNameTextField becomeFirstResponder];
//    
//    [UIView animateWithDuration: kCreateChannelPanelAnimationDuration
//                          delay: 0.0f
//                        options: UIViewAnimationOptionCurveEaseInOut
//                     animations: ^
//     {
//         // Contract thumbnail view
//         self.channelChooserView.alpha = 1.0f;
//     }
//                     completion: ^(BOOL finished)
//     {
//     }];
//    
//    // TODO: Work out why scrolling to position 1 actually scrolls to position 5 (suspect some dodgy maths in the 3rd party cover flow)
//    NSIndexPath *startIndexPath = [NSIndexPath indexPathForRow: 0 inSection: 0];
//    [self.channelCoverCarouselCollectionView scrollToItemAtIndexPath: startIndexPath
//                                                    atScrollPosition: UICollectionViewScrollPositionCenteredHorizontally
//                                                            animated: NO];
//    
//    // Only play the scrolling click (after we have scrolled to the right position in the list,
//    // which might not have finished in this run loop
//    [NSObject performBlock: ^
//     {
//         self.shouldPlaySound = TRUE;
//     }
//     afterDelay: 0.1f];
//}

- (IBAction) createChannelFromVideoQueue
{
    
    Channel *newChannel = [Channel insertInManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    newChannel.channelOwner = appDelegate.channelOwnerMe;
    
    // TODO: Make these window offsets less hard-coded

    for (VideoInstance *videoInstance in SYNVideoSelection.sharedVideoSelectionArray)
    {
        [[newChannel videoInstancesSet] addObject: videoInstance];
    }

    SYNChannelsDetailsCreationViewController *channelCreationVC = [[SYNChannelsDetailsCreationViewController alloc] initWithChannel: newChannel];
    
    [self animatedPushViewController: channelCreationVC];
}


- (IBAction) longPressThumbnail: (UIGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        [self showVideoQueue: TRUE];
        
        // figure out which item in the table was selected
        NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: [sender locationInView: self.videoThumbnailCollectionView]];
        
        VideoInstance *videoInstance = [self.videoInstanceFetchedResultsController objectAtIndexPath: indexPath];
        
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
        // TODO: Unhardcode this
        CGRect frame = CGRectMake(self.initialDragCenter.x - 63, self.initialDragCenter.y - 36, 123, 69);
        self.draggedView = [[UIImageView alloc] initWithFrame: frame];
        self.draggedView.alpha = 0.7;
 
        // Load the image asynchronously
        [self.draggedView setImageFromURL: [NSURL URLWithString: videoInstance.video.thumbnailURL]
                         placeHolderImage: nil];
        
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
        [self startVideoQueueDismissalTimer];
        
        // and let's figure out where we dropped it
        //        CGPoint point = [sender locationInView: self.dropZoneView];
        CGPoint point = [sender locationInView: self.view];
        
        // If we have dropped it in the right place, then add it to our image well
        if ([self pointInVideoQueue: point])
            
        {
            // Hide the dragged thumbnail and add new image to image well
            [self.draggedView removeFromSuperview];
            
            VideoInstance *videoInstance = [self.videoInstanceFetchedResultsController objectAtIndexPath: self.draggedIndexPath];
            [self animateVideoAdditionToVideoQueue: videoInstance];
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


// Assume no image well by default
- (BOOL) hasVideoQueue
{
    return FALSE;
}


// Assume that the video queue is not visible on first entry to the tab
- (BOOL) isVideoQueueVisibleOnStart;
{
    return FALSE;
}

- (void) startVideoQueueDismissalTimer
{
    self.videoQueueAnimationTimer = [NSTimer scheduledTimerWithTimeInterval: kVideoQueueOnScreenDuration
                                                                    target: self
                                                                  selector: @selector(videoQueueTimerCallback)
                                                                  userInfo: nil
                                                                   repeats: NO];
}

- (void) videoQueueTimerCallback
{
    [self hideVideoQueue: TRUE];
}

- (void) showVideoQueue: (BOOL) animated
{
    if (self.isVideoQueueVisible == FALSE)
    {
        self.videoQueueVisible = TRUE;
        
        if (animated)
        {
            // Slide video queue view upwards (and contract any other dependent visible views)
            [UIView animateWithDuration: kVideoQueueAnimationDuration
                                  delay: 0.0f
                                options: UIViewAnimationOptionCurveEaseInOut
                             animations: ^
             {
                 [self slideVideoQueueUp];
             }
             completion: ^(BOOL finished)
             {
             }];
        }
        else
        {
            [self slideVideoQueueUp];
        }
    }
}


- (void) hideVideoQueue: (BOOL) animated
{
    if (self.videoQueueVisible == TRUE)
    {
        self.videoQueueAnimationTimer = nil;
        self.videoQueueVisible = FALSE;
        
        if (animated)
        {
            [UIView animateWithDuration: kCreateChannelPanelAnimationDuration
                                  delay: 0.0f
                                options: UIViewAnimationOptionCurveEaseInOut
                             animations: ^
             {
                 // Slide video queue view downwards (and expand any other dependent visible views)
                 [self slideVideoQueueDown];
             }
             completion: ^(BOOL finished)
             {
             }];
        }
        else
        {
            [self slideVideoQueueDown];
        }
    }
}

- (void) slideVideoQueueUp
{
    CGRect videoQueueViewFrame = self.videoQueueView.frame;
    videoQueueViewFrame.origin.y -= kVideoQueueEffectiveHeight;
    self.videoQueueView.frame = videoQueueViewFrame;
}

- (void) slideVideoQueueDown
{
    CGRect videoQueueViewFrame = self.videoQueueView.frame;
    videoQueueViewFrame.origin.y += kVideoQueueEffectiveHeight;
    self.videoQueueView.frame = videoQueueViewFrame;
}

- (IBAction) clearVideoQueue
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
         self.videoQueueMessageView.alpha = 1.0f;
         
     }
                     completion: ^(BOOL finished)
     {
     }];
    
    [SYNVideoSelection.sharedVideoSelectionArray removeAllObjects];
    
    [self.videoQueueCollectionView reloadData];
}




//
//// User has pressed the Done button, so create a new channel
//- (BOOL) textFieldShouldReturn: (UITextField *) textField
//{
//    [self addChannelWithTitle: textField.text];
//    
//    return YES;
//}
//
//- (void) textFieldDidEndEditing: (UITextField *) textField
//{
//    self.channelChooserView.alpha = 0.0f;
//}
//
//- (void) addChannelWithTitle: (NSString *) title
//{
//    Channel *newChannel = [Channel insertInManagedObjectContext: self.mainManagedObjectContext];
//    
//    NSError *error = nil;
//    NSEntityDescription *channelOwnerEntity = [NSEntityDescription entityForName: @"ChannelOwner"
//                                                   inManagedObjectContext: self.mainManagedObjectContext];
//    
//    // Find out how many Video objects we have in the database
//    NSFetchRequest *channelOwnerFetchRequest = [[NSFetchRequest alloc] init];
//    [channelOwnerFetchRequest setEntity: channelOwnerEntity];
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == 666"];
//    [channelOwnerFetchRequest setPredicate: predicate];
//    
//    NSArray *channelOwnerEntries = [self.mainManagedObjectContext executeFetchRequest: channelOwnerFetchRequest
//                                                                     error: &error];
//    
//    DebugLog(@"unique id = %@", ((ChannelOwner *)channelOwnerEntries[0]).uniqueId);
//    
//    newChannel.channelOwner = (ChannelOwner *)channelOwnerEntries[0];
//    
//    newChannel.title = title;
//    newChannel.rockedByUserValue = FALSE;
//    newChannel.rockCountValue = 0;
//    newChannel.rockedByUserValue = TRUE;
//    
//    // TODO: Make these window offsets less hard-coded
//    NSIndexPath *indexPath = [self.channelCoverCarouselCollectionView indexPathForItemAtPoint: CGPointMake (450 + self.channelCoverCarouselCollectionView.contentOffset.x,
//                                                                                                            70 + self.channelCoverCarouselCollectionView.contentOffset.y)];
//    
//    Channel *coverChannel = [self.channelFetchedResultsController objectAtIndexPath: indexPath];
//    
//    newChannel.thumbnailURL = coverChannel.thumbnailURL;
//    newChannel.wallpaperURL = coverChannel.wallpaperURL;
//    newChannel.channelDescription = coverChannel.channelDescription;
//    
//    for (VideoInstance *videoInstance in SYNVideoSelection.sharedVideoSelectionArray)
//    {
//        [[newChannel videoInstancesSet] addObject: videoInstance];
//    }
//    
//    SYNAppDelegate *delegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
//    [delegate saveContext: kSaveAsynchronously];
//    
//    [self.channelNameTextField resignFirstResponder];
//    [self clearVideoQueue];
//}

#pragma mark - Image well support

- (void) animateVideoAdditionToVideoQueue: (VideoInstance *) videoInstance
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
        self.videoQueueNewButton.enabled = TRUE;
        self.videoQueueNewButton.selected = TRUE;
        self.videoQueueDeleteButton.enabled = TRUE;
        
        [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^
         {
             // Contract thumbnail view
             self.videoQueueMessageView.alpha = 0.0f;
             
         }
                         completion: ^(BOOL finished)
         {
         }];
    }
    
    
    // OK, here goes
    
    // First, increase the size of the view by the size of the new cell to be added (+margin)
    CGRect videoQueueViewFrame = self.videoQueueCollectionView.frame;
    videoQueueViewFrame.size.width += 142;
    
    self.videoQueueCollectionView.frame = videoQueueViewFrame;
    
    [SYNVideoSelection.sharedVideoSelectionArray addObject: videoInstance];
    
    [self.videoQueueCollectionView reloadData];
    
    [self performSelector: @selector(animateVideoAdditionToVideoQueue2:)
               withObject: videoInstance
               afterDelay: 0.0f];
}

- (void) animateVideoAdditionToVideoQueue2: (VideoInstance *) videoInstance
{    
    NSLog (@"Collection %f, frame %f, offset %f, target %f", self.videoQueueCollectionView.contentSize.width, self.videoQueueCollectionView.frame.size.width, self.videoQueueCollectionView.contentOffset.x, (float)kVideoQueueWidth);
    
    if (self.videoQueueCollectionView.contentSize.width + 15 > kVideoQueueWidth + 142)
    {
        CGPoint contentOffset = self.videoQueueCollectionView.contentOffset;
        contentOffset.x = self.videoQueueCollectionView.contentSize.width - kVideoQueueWidth;
        self.videoQueueCollectionView.contentOffset = contentOffset;
    }
    
    
    // Animate the view out onto the screen
    [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                          delay: 0.5f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         // Slide origin back
         CGRect videoQueueCollectionViewFrame = self.videoQueueCollectionView.frame;
         videoQueueCollectionViewFrame.origin.x -= 142;
         
         CGPoint contentOffset = self.videoQueueCollectionView.contentOffset;
         
         if (self.videoQueueCollectionView.contentSize.width > kVideoQueueWidth)
         {
             videoQueueCollectionViewFrame.origin.x = kVideoQueueOffsetX;
             videoQueueCollectionViewFrame.size.width = kVideoQueueWidth;

             
             contentOffset.x = self.videoQueueCollectionView.contentSize.width - kVideoQueueWidth + 15;
         }
         
         self.videoQueueCollectionView.contentOffset = contentOffset;
         self.videoQueueCollectionView.frame = videoQueueCollectionViewFrame;
     }
     completion: ^(BOOL finished)
     {
//         if (self.videoQueueCollectionView.contentSize.width > kVideoQueueWidth)
//         {
//             CGPoint contentOffset = self.videoQueueCollectionView.contentOffset;
//             contentOffset.x = self.videoQueueCollectionView.contentSize.width + 15 - kVideoQueueWidth;
//             self.videoQueueCollectionView.contentOffset = contentOffset;
//         }
     }];
}

- (void) highlightVideoQueue: (BOOL) showHighlight
{
    if (showHighlight)
    {
        self.videoQueuePanelView.image = [UIImage imageNamed: @"PanelVideoQueueHighlighted.png"];
    }
    else
    {
        self.videoQueuePanelView.image = [UIImage imageNamed: @"PanelVideoQueue.png"];
    }
}


- (BOOL) pointInVideoQueue: (CGPoint) point
{
    return CGRectContainsPoint(self.videoQueueView.frame, point);
}

//         if (self.videoQueueCollectionView.contentSize.width > kVideoQueueWidth)
//         {
//             CGPoint contentOffset = self.videoQueueCollectionView.contentOffset;
//             contentOffset.x = self.videoQueueCollectionView.contentSize.width + 15 - kVideoQueueWidth;
//             self.videoQueueCollectionView.contentOffset = contentOffset;
//         }
//         else
//         {
//             CGPoint contentOffset = self.videoQueueCollectionView.contentOffset;
//             NSLog (@"width=%f", self.videoQueueCollectionView.frame.size.width);
//             contentOffset.x = self.videoQueueCollectionView.contentSize.width + 15 - self.videoQueueCollectionView.frame.size.width;
//             self.videoQueueCollectionView.contentOffset = contentOffset;
//         }

@end
