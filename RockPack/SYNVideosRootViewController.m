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
#import "SYNChannelFooterMoreView.h"
#import <MediaPlayer/MediaPlayer.h>


@interface SYNVideosRootViewController () <UIGestureRecognizerDelegate,
                                           UIScrollViewDelegate,
                                           UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIButton *starButton;
@property (nonatomic, strong) IBOutlet UIImageView *channelImageView;
@property (nonatomic, strong) IBOutlet UIImageView *panelImageView;
@property (nonatomic, strong) IBOutlet UILabel *channelLabel;
@property (nonatomic, strong) IBOutlet UILabel *starLabel;
@property (nonatomic, strong) IBOutlet UILabel *starNumberLabel;
@property (nonatomic, strong) IBOutlet UILabel *shareItLabel;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *displayNameLabel;

@property (nonatomic, strong) SYNLargeVideoPanelViewController* largeVideoPanelController;

@property (nonatomic) NSRange videosRequestCurrentRange;


@end

@implementation SYNVideosRootViewController

#pragma mark - Init

- (id) initWithViewId: (NSString *) vid
{
    if ((self = [super initWithNibName: @"SYNVideosRootViewController"
                               bundle: nil])) {
        viewId = vid;
    }
    
    return self;
}


#pragma mark - View lifecycle

- (void) loadView
{
    CGRect videoCollectionViewFrame = CGRectMake(512.0, 87.0, 512.0, 569.0);
    
    SYNIntegralCollectionViewFlowLayout *standardFlowLayout = [[SYNIntegralCollectionViewFlowLayout alloc] init];
    standardFlowLayout.itemSize = CGSizeMake(507.0f , 182.0f);
    standardFlowLayout.minimumInteritemSpacing = 0.0f;
    standardFlowLayout.minimumLineSpacing = 0.0f;
    standardFlowLayout.footerReferenceSize = CGSizeMake(videoCollectionViewFrame.size.width, 64.0);
    standardFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    standardFlowLayout.sectionInset = UIEdgeInsetsMake(6, 2, 5, 2);
    
    self.videoThumbnailCollectionView = [[UICollectionView alloc] initWithFrame:videoCollectionViewFrame collectionViewLayout:standardFlowLayout];
    self.videoThumbnailCollectionView.delegate = self;
    self.videoThumbnailCollectionView.dataSource = self;
    self.videoThumbnailCollectionView.backgroundColor = [UIColor clearColor];
    [self.videoThumbnailCollectionView registerNib: [UINib nibWithNibName: @"SYNVideoThumbnailWideCell" bundle: nil]
                        forCellWithReuseIdentifier: @"SYNVideoThumbnailWideCell"];
    
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1024.0, 748.0)];
    [self.view addSubview:self.videoThumbnailCollectionView];
    
    
    self.largeVideoPanelController = [[SYNLargeVideoPanelViewController alloc] init];
    
    [self.largeVideoPanelController.disaplyNameButton addTarget:self action:@selector(channelOwnerLabelPressed:) forControlEvents:UIControlEventTouchUpInside];
}


- (void) channelOwnerLabelPressed: (UIButton*) button
{
    
    VideoInstance* currentlyPlayingVideoInstance = self.largeVideoPanelController.videoInstance;
    [self viewProfileDetails: currentlyPlayingVideoInstance.channel.channelOwner];
}


- (void) setLargeVideoPanelController: (SYNLargeVideoPanelViewController *) largeVideoPanelController
{
    if(!largeVideoPanelController)
        return;
    
    
    _largeVideoPanelController = largeVideoPanelController;
    
    self.largeVideoPanelView = self.largeVideoPanelController.view;
    
    CGRect vFrame = self.largeVideoPanelView.frame;
    vFrame.origin.y = 88.0;
    self.largeVideoPanelView.frame = vFrame;
    
    [self.view addSubview:self.largeVideoPanelView];
    
    self.starButton = self.largeVideoPanelController.starButtonLarge;
    
    // add it button
    
    [self.starButton addTarget: self
                        action: @selector(toggleLargeVideoPanelStarButton:)
              forControlEvents: UIControlEventTouchUpInside];
    
    [self.largeVideoPanelController.channelImageButton addTarget: self
                                                          action: @selector(userTouchedLargeVideoChannelButton:)
                                                forControlEvents: UIControlEventTouchUpInside];
    
    self.channelImageView = self.largeVideoPanelController.channelImageView;
    
    self.displayNameLabel = self.largeVideoPanelController.displayNameLabel;
    self.channelLabel = self.largeVideoPanelController.channelLabel;
    self.titleLabel = self.largeVideoPanelController.titleLabel;
    self.panelImageView = self.largeVideoPanelController.backgroundImageView;
    
}

 
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Google Analytics support
    self.trackedViewName = @"Videos - Root";
    
    // Register Footer
    UINib *footerViewNib = [UINib nibWithNibName: @"SYNChannelFooterMoreView"
                                          bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib:footerViewNib
                        forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                               withReuseIdentifier:@"SYNChannelFooterMoreView"];
    
    [appDelegate.networkEngine updateVideosScreenForCategory: @"all"];
}


- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    
    
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


#pragma mark - Collection View Delegate

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


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    
    if(collectionView != self.videoThumbnailCollectionView)
        return nil;
    
    SYNChannelFooterMoreView *channelMoreFooter;
    
    UICollectionReusableView* supplementaryView;
    
    if (kind == UICollectionElementKindSectionHeader)
    {
        // nothing yet
    }
    
    
    if (kind == UICollectionElementKindSectionFooter)
    {
        channelMoreFooter = [self.videoThumbnailCollectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                  withReuseIdentifier:@"SYNChannelFooterMoreView"
                                                                                         forIndexPath:indexPath];
        
        [channelMoreFooter.loadMoreButton addTarget:self
                                             action:@selector(loadMoreChannels:)
                                   forControlEvents:UIControlEventTouchUpInside];
        
        supplementaryView = channelMoreFooter;
    }
    
    
    return supplementaryView;
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}

- (void) userTouchedProfileButton: (UIButton *) profileButton
{
    // Get to cell it self (from button subview)
    UIView *v = profileButton.superview.superview.superview;
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: v.center];
    
    // Bail if we don't have an index path
    if (indexPath)
    {
        VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
        
        [self viewProfileDetails: videoInstance.channel.channelOwner];
    }
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
    self.displayNameLabel.text = [NSString stringWithFormat:@"%@", videoInstance.channel.channelOwner.displayName];;

    
    [self.channelImageView setAsynchronousImageFromURL: [NSURL URLWithString: videoInstance.channel.coverThumbnailSmallURL]
                                      placeHolderImage: nil];
    
    [self updateLargeVideoRockpackForIndexPath: indexPath];
}


- (void) updateLargeVideoRockpackForIndexPath: (NSIndexPath *) indexPath
{
    VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    self.starNumberLabel.text = [NSString stringWithFormat: @"%@", videoInstance.video.starCount];
    self.starButton.selected = videoInstance.video.starredByUserValue;
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
