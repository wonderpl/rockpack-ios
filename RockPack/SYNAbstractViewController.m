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
#import "SYNChannelsDetailsCreationViewController.h"
#import "SYNVideoQueueCell.h"
#import "SYNVideoSelection.h"
#import "SYNVideoThumbnailWideCell.h"
#import "SYNVideoViewerViewController.h"
#import "UIFont+SYNFont.h"
#import "Video.h"
#import "VideoInstance.h"
#import <QuartzCore/QuartzCore.h>
#import "SYNMasterViewController.h"
#import "SYNVideoQueueViewController.h"

@interface SYNAbstractViewController ()  <UITextFieldDelegate>

@property (getter = isVideoQueueVisible) BOOL videoQueueVisible;
@property (nonatomic, assign) BOOL shouldPlaySound;
@property (nonatomic, strong) IBOutlet UIImageView *channelOverlayView;
@property (nonatomic, strong) IBOutlet UITextField *channelNameTextField;


@property (nonatomic, strong) SYNVideoViewerViewController *videoViewerViewController;
@property (nonatomic, strong) UIView *dropZoneView;
@property (nonatomic, strong) SYNVideoQueueViewController* videoQVC;
@end


@implementation SYNAbstractViewController


@synthesize fetchedResultsController = fetchedResultsController;


#pragma mark - Custom accessor methods

-(id)init {
    DebugLog(@"WARNING: init called on Abstract View Controller, call initWithViewId instead");
    if(self = [self initWithViewId:@"NULL"]) {
        
    }
    return self;
}

-(id)initWithViewId:(NSString*)vid {
    if(self = [super init]) {
        viewId = vid;
    }
    return self;
}





#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (self.hasVideoQueue)
    {
        self.videoQVC = [[SYNVideoQueueViewController alloc] init];
        self.videoQVC.delegate = self;
        
        [self.view addSubview: self.videoQVC.view];
    }
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    if (self.hasVideoQueue)
    {
        
        [self.videoQVC reloadData];
        
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




- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{
    
    [self reloadCollectionViews];
}


-(void)reloadCollectionViews
{
    AssertOrLog (@"Abstract class called 'reloadCollectionViews'");
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
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNoteBackButtonShow object:self];
}


- (IBAction) animatedPopViewController
{
    UIViewController *parentVC = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2];
    parentVC.view.alpha = 0.0f;
    
    [self.navigationController popViewControllerAnimated: NO];
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
         // Contract thumbnail view
         self.view.alpha = 0.0f;
         parentVC.view.alpha = 1.0f;
         
     }
                     completion: ^(BOOL finished)
     {
     }];
    
    // Hide back button
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNoteBackButtonHide object:self];
}


- (void) toggleVideoRockItAtIndex: (NSIndexPath *) indexPath
{
    VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
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
    Channel *channel = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
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
            VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
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
    
    UIView *v = addItButton.superview.superview;
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: v.center];
    VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
    [self animateVideoAdditionToVideoQueue: videoInstance];
}


- (IBAction) userTouchedVideoShareItButton: (UIButton *) addItButton
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kNoteSharePanelRequested object: self];
    
    
}


// Called by invisible button on video view cell
- (void) displayVideoViewerFromView: (UIGestureRecognizer *) sender
{
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: [sender locationInView: self.videoThumbnailCollectionView]];

    [self displayVideoViewerWithSelectedIndexPath: indexPath];
}


- (void) displayVideoViewerWithSelectedIndexPath: (NSIndexPath *) selectedIndexPath
{
    SYNMasterViewController *bottomTabViewController = (SYNMasterViewController*)appDelegate.viewController;
    
    self.videoViewerViewController = [[SYNVideoViewerViewController alloc] initWithFetchedResultsController: self.fetchedResultsController
                                                                                          selectedIndexPath: (NSIndexPath *) selectedIndexPath];
    
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
    return -1;
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


- (UICollectionViewCell *) collectionView: (UICollectionView *) cv cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    UICollectionViewCell *cell = nil;
    
    if (cv == self.videoThumbnailCollectionView)
    {
        // No, but it was our collection view
        VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
        
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

    return cell;
}


- (BOOL) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPathAbstract: (NSIndexPath *) indexPath
{
    
    return NO;
}

// Create a channel pressed

- (void) createChannelFromVideoQueue
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
        
        VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
        
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
        
        // and let's figure out where we dropped it
        //        CGPoint point = [sender locationInView: self.dropZoneView];
        CGPoint point = [sender locationInView: self.view];
        
        // If we have dropped it in the right place, then add it to our image well
        if ([self pointInVideoQueue: point])
            
        {
            // Hide the dragged thumbnail and add new image to image well
            [self.draggedView removeFromSuperview];
            
            VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: self.draggedIndexPath];
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


- (void) showVideoQueue: (BOOL) animated
{
    [self.videoQVC showVideoQueue:animated];
}


- (void) hideVideoQueue: (BOOL) animated
{
    [self.videoQVC hideVideoQueue:animated];
}



#pragma mark - Add/Remove to video queue

- (void) animateVideoAdditionToVideoQueue: (VideoInstance *) videoInstance
{
    [self.videoQVC addVideoToQueue:videoInstance];
}


- (void) highlightVideoQueue: (BOOL) showHighlight
{
    [self.videoQVC setHighlighted:showHighlight];
}


- (BOOL) pointInVideoQueue: (CGPoint) point
{
    return CGRectContainsPoint(self.videoQVC.view.frame, point);
}



@end
