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
#import "SYNCategoryItemView.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNVideoQueueCell.h"
#import "SYNVideoThumbnailWideCell.h"
#import "SYNVideosRootViewController.h"
#import "Subcategory.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+ImageProcessing.h"
#import "Video.h"
#import "VideoInstance.h"
#import <MediaPlayer/MediaPlayer.h>


@interface SYNVideosRootViewController () <UIGestureRecognizerDelegate,
                                           UIScrollViewDelegate,
                                           UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIButton *rockItButton;
@property (nonatomic, strong) IBOutlet UIImageView *channelImageView;
@property (nonatomic, strong) IBOutlet UIImageView *panelImageView;
@property (nonatomic, strong) IBOutlet UILabel *channelLabel;
@property (nonatomic, strong) IBOutlet UILabel *rockItLabel;
@property (nonatomic, strong) IBOutlet UILabel *rockItNumberLabel;
@property (nonatomic, strong) IBOutlet UILabel *shareItLabel;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *displayNameLabel;

@property (nonatomic, strong) SYNLargeVideoPanelViewController* largeVideoPanelController;


@end

@implementation SYNVideosRootViewController

#pragma mark - Init

- (id) initWithViewId: (NSString *) vid
{
    if ((self = [super initWithNibName: @"SYNVideosRootViewController"
                               bundle: nil]))
    {
        viewId = vid;
        
        
    }
    
    return self;
}


#pragma mark - View lifecycle

-(void)loadView
{
    SYNIntegralCollectionViewFlowLayout *standardFlowLayout = [[SYNIntegralCollectionViewFlowLayout alloc] init];
    standardFlowLayout.itemSize = CGSizeMake(507.0f , 182.0f);
    standardFlowLayout.minimumInteritemSpacing = 0.0f;
    standardFlowLayout.minimumLineSpacing = 0.0f;
    standardFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    standardFlowLayout.sectionInset = UIEdgeInsetsMake(0, 2, 0, 2);
    
    
    CGRect videoCollectionViewFrame = CGRectMake(512.0, 92.0, 512.0, 594.0);
    
    self.videoThumbnailCollectionView = [[UICollectionView alloc] initWithFrame:videoCollectionViewFrame collectionViewLayout:standardFlowLayout];
    self.videoThumbnailCollectionView.delegate = self;
    self.videoThumbnailCollectionView.dataSource = self;
    self.videoThumbnailCollectionView.backgroundColor = [UIColor clearColor];
    [self.videoThumbnailCollectionView registerNib: [UINib nibWithNibName: @"SYNVideoThumbnailWideCell" bundle: nil]
                        forCellWithReuseIdentifier: @"SYNVideoThumbnailWideCell"];
    
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1024.0, 748.0)];
    [self.view addSubview:self.videoThumbnailCollectionView];
    
    
    self.largeVideoPanelController = [[SYNLargeVideoPanelViewController alloc] init];
    
}


-(void)setLargeVideoPanelController:(SYNLargeVideoPanelViewController *)largeVideoPanelController
{
    if(!largeVideoPanelController)
        return;
    
    
    _largeVideoPanelController = largeVideoPanelController;
    
    self.largeVideoPanelView = self.largeVideoPanelController.view;
    
    CGRect vFrame = self.largeVideoPanelView.frame;
    vFrame.origin.y = 88.0;
    self.largeVideoPanelView.frame = vFrame;
    
    [self.view addSubview:self.largeVideoPanelView];
    
    self.rockItButton = self.largeVideoPanelController.rockItButtonLarge;
    
    // add it button
    
    [self.rockItButton addTarget:self
                          action:@selector(toggleLargeVideoPanelStarItButton:)
                forControlEvents:UIControlEventTouchUpInside];
    
    [self.largeVideoPanelController.channelImageButton addTarget:self
                                                          action:@selector(userTouchedLargeVideoChannelButton:)
                                                forControlEvents:UIControlEventTouchUpInside];
    
    self.channelImageView = self.largeVideoPanelController.channelImageView;
    
    self.displayNameLabel = self.largeVideoPanelController.displayNameLabel;
    self.channelLabel = self.largeVideoPanelController.channelLabel;
    self.titleLabel = self.largeVideoPanelController.titleLabel;
    self.panelImageView = self.largeVideoPanelController.backgroundImageView;
    
}

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    
    // Request Video Q to show at all times
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kVideoQueueShow
                                                        object:self
                                                      userInfo:@{@"lock" : @(YES)}];
    
    
    
    [appDelegate.networkEngine updateVideosScreenForCategory: @"all"];
    

    [self reloadCollectionViews];
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *) fetchedResultsController
{
    if (fetchedResultsController != nil)
        return fetchedResultsController;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.entity = [NSEntityDescription entityForName: @"VideoInstance"
                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat: [NSString stringWithFormat: @"viewId == \"%@\"", viewId]];
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"position" ascending: YES]];
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                        managedObjectContext: appDelegate.mainManagedObjectContext
                                                                          sectionNameKeyPath: nil
                                                                                   cacheName: nil];
    fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    
    ZAssert([fetchedResultsController performFetch: &error], @"Videos Root FetchRequest failed: %@\n%@", [error localizedDescription], [error userInfo]);
    
    return fetchedResultsController;
}


#pragma mark - Reload


- (void) reloadCollectionViews
{
    [self.videoThumbnailCollectionView reloadData];
    
    NSArray *videoInstances = self.fetchedResultsController.fetchedObjects;
    // Set the first video
    if (videoInstances.count > 0)
    {       
        [self.largeVideoPanelController setPlaylistWithFetchedResultsController: self.fetchedResultsController
                                                                selectedIndexPath: self.currentIndexPath
                                                                         autoPlay: TRUE];
        
        
        
        [self setLargeVideoToIndexPath: [NSIndexPath indexPathForRow: 0
                                                           inSection: 0]];
    }
}

- (BOOL) hasVideoQueue
{
    return TRUE;
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
            id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
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


#pragma mark - User interface

- (void) setLargeVideoToIndexPath: (NSIndexPath *) indexPath
{
    if ([self.currentIndexPath isEqual: indexPath] == FALSE)
    {        
        self.currentIndexPath = indexPath;
        
        [self.largeVideoPanelController playVideoAtIndex: indexPath];
        [self updateLargeVideoDetailsForIndexPath: indexPath];
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
        
        Video *video = [self.fetchedResultsController objectAtIndexPath: self.currentIndexPath];
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
//            [self.draggedView removeFromSuperview];
//            [self addToVideoQueueFromLargeVideo: nil];
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


// TODO: Remove
- (IBAction) addToVideoQueueFromLargeVideo: (id) sender
{
    
    VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: self.currentIndexPath];
    [[NSNotificationCenter defaultCenter] postNotificationName:kVideoQueueAdd
                                                        object:self
                                                      userInfo:@{@"VideoInstance" : videoInstance}];
}


- (void) updateLargeVideoDetailsForIndexPath: (NSIndexPath *) indexPath
{
    VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    self.titleLabel.text = videoInstance.title;
    self.channelLabel.text = videoInstance.channel.title;
    self.displayNameLabel.text = videoInstance.channel.channelOwner.displayName;
    
    [self.channelImageView setAsynchronousImageFromURL: [NSURL URLWithString: videoInstance.channel.coverThumbnailSmallURL]
                                      placeHolderImage: nil];
    
    [self updateLargeVideoRockpackForIndexPath: indexPath];
}


- (void) updateLargeVideoRockpackForIndexPath: (NSIndexPath *) indexPath
{
    VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
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




- (void) updateOtherOnscreenVideoAssetsForIndexPath: (NSIndexPath *) indexPath
{
    if ([indexPath isEqual: self.currentIndexPath])
    {
        [self updateLargeVideoRockpackForIndexPath: self.currentIndexPath];
    }
}



- (void) toggleLargeVideoPanelStarItButton: (UIButton *) button
{
    // called for a press to the large video panel's star button
    
    button.selected = !button.selected;
    NSString *action = nil;
    
    VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: self.currentIndexPath];
    
    if (videoInstance.video.starredByUserValue == TRUE)
    {
        // Currently highlighted, so decrement
        videoInstance.video.starredByUserValue = FALSE;
        videoInstance.video.starCountValue -= 1;
        action = @"unstar";
    }
    else
    {
        // Currently highlighted, so increment
        videoInstance.video.starredByUserValue = TRUE;
        videoInstance.video.starCountValue += 1;
        action = @"star";
    }
    
    
    [self.videoThumbnailCollectionView reloadData];
    
    [self saveDB];
    
    // Update the star/unstar status on the server
    [appDelegate.oAuthNetworkEngine recordActivityForUserId: appDelegate.currentOAuth2Credentials.userId
                                                     action: action
                                            videoInstanceId: videoInstance.uniqueId
                                          completionHandler: ^(NSDictionary *responseDictionary)
     {
         DebugLog(@"Record action successful");
     }
     errorHandler: ^(NSDictionary* errorDictionary)
     {
         DebugLog(@"Record action failed");
     }];
}


- (IBAction) userTouchedLargeVideoChannelButton: (UIButton *) channelButton
{    
    // Bail if we don't have an index path
    if (self.currentIndexPath)
    {
        VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: self.currentIndexPath];
        
        [self viewChannelDetails:videoInstance.channel];
    }
}


- (void) handleMainTap: (UITapGestureRecognizer *) recogniser
{
    [super handleMainTap:recogniser];
    
    if(tabExpanded || ![self showSubcategories])
        return;
    
    [UIView animateWithDuration: 0.4
                          delay: 0.0
                        options :UIViewAnimationCurveEaseInOut
                     animations: ^
    {
        CGRect videoThumbnailCollectionViewFrame = self.videoThumbnailCollectionView.frame;
        videoThumbnailCollectionViewFrame.origin.y += kCategorySecondRowHeight;
        videoThumbnailCollectionViewFrame.size.height -= kCategorySecondRowHeight;
        self.videoThumbnailCollectionView.frame = videoThumbnailCollectionViewFrame;
        
        CGPoint currentLargeVideoCenter = self.largeVideoPanelView.center;
        [self.largeVideoPanelView setCenter: CGPointMake(currentLargeVideoCenter.x, currentLargeVideoCenter.y + kCategorySecondRowHeight)];
    }
    completion: ^(BOOL result)
    {
        tabExpanded = YES;
    }];
}


- (BOOL) showSubcategories
{
    return NO;
}


- (void) handleNewTabSelectionWithId: (NSString *) selectionId
{
    
    [appDelegate.networkEngine updateVideosScreenForCategory: selectionId];
}

@end
