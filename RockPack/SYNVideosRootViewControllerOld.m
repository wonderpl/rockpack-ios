//
//  SYNVideosTopLevelViewController.m
//  rockpack
//
//  Created by Nick Banks on 24/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "NSDate-Utilities.h"
#import "SYNAppDelegate.h"
#import "SYNHomeSectionHeaderView.h"
#import "SYNNetworkEngine.h"
#import "SYNVideoThumbnailWideCell.h"
#import "SYNVideosRootViewControllerOld.h"
#import "Video.h"
#import "VideoInstance.h"

@interface SYNVideosRootViewControllerOld ()

@end

@implementation SYNVideosRootViewControllerOld

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];

    // Init collection view
    UINib *videoThumbnailCellNib = [UINib nibWithNibName: @"SYNVideoThumbnailWideCell"
                                                  bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: videoThumbnailCellNib
                        forCellWithReuseIdentifier: @"SYNVideoThumbnailWideCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
											                         selector: @selector(reloadCollectionViews)
												                             name: kDataUpdated
											                           object: nil];
    
    // TODO: Remove this video download hack once we have real data from the API
    SYNAppDelegate *appDelegate = UIApplication.sharedApplication.delegate;
    
    [appDelegate.networkEngine updateHomeScreen];
    [appDelegate.networkEngine updateChannelsScreen];
}


- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self
													                                name: kDataUpdated
												                              object: nil];
}

- (BOOL) hasVideoQueue
{
    return TRUE;
}


#pragma mark - Core Data support

// The following 2 methods are called by the abstract class' getFetchedResults controller methods
- (NSPredicate *) videoInstanceFetchedResultsControllerPredicate
{
    //    // No predicate
    //    return nil;
    return [NSPredicate predicateWithFormat: @"viewId == \"Home\""];
}


- (NSArray *) videoInstanceFetchedResultsControllerSortDescriptors
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"dateAdded"
                                                                   ascending: NO];
    return @[sortDescriptor];
}

- (NSString *) videoInstanceFetchedResultsControllerSectionNameKeyPath
{
    //    return @"daysAgo";
    return nil;
}


- (void) reloadCollectionViews
{
    [self.videoThumbnailCollectionView reloadData];
}

#pragma mark - Collection view support

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    if (collectionView == self.videoThumbnailCollectionView)
    {
        return self.videoInstanceFetchedResultsController.sections.count;
    }
    else
    {
        return 1;
    }
}

- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger) section
{
    // See if this can be handled in our abstract base class
    int items = [super collectionView: collectionView
               numberOfItemsInSection:  section];
    
    if (items < 0)
    {
        if (collectionView == self.videoThumbnailCollectionView)
        {
            id <NSFetchedResultsSectionInfo> sectionInfo = [self.videoInstanceFetchedResultsController sections][section];
            return [sectionInfo numberOfObjects];
        }
        else
        {
            AssertOrLog(@"No valid collection view found");
        }
    }
    
    return items;
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


#pragma mark - UI Actions

- (IBAction) toggleVideoRockItButton: (UIButton *) rockItButton
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
    
    [self toggleVideoRockItAtIndex: indexPath];
    
    VideoInstance *videoInstance = [self.videoInstanceFetchedResultsController objectAtIndexPath: indexPath];
    SYNVideoThumbnailWideCell *cell = (SYNVideoThumbnailWideCell *)[self.videoThumbnailCollectionView cellForItemAtIndexPath: indexPath];
    
    cell.rockItButton.selected = videoInstance.video.starredByUserValue;
    cell.rockItNumber.text = [NSString stringWithFormat: @"%@", videoInstance.video.starCount];
}


- (IBAction) touchVideoAddItButton: (UIButton *) addItButton
{
    DebugLog (@"No implementation yet");
}


#pragma mark - Video Queue animation

- (void) slideVideoQueueUp
{
    CGRect videoQueueViewFrame = self.videoQueueView.frame;
    videoQueueViewFrame.origin.y -= kVideoQueueEffectiveHeight;
    self.videoQueueView.frame = videoQueueViewFrame;
    
    CGRect viewFrame = self.videoThumbnailCollectionView.frame;
    viewFrame.size.height -= kVideoQueueEffectiveHeight;
    self.videoThumbnailCollectionView.frame = viewFrame;
}


- (void) slideVideoQueueDown
{
    CGRect videoQueueViewFrame = self.videoQueueView.frame;
    videoQueueViewFrame.origin.y += kVideoQueueEffectiveHeight;
    self.videoQueueView.frame = videoQueueViewFrame;
    
    // Slide video queue view downwards (and expand any other dependent visible views)
    CGRect viewFrame = self.videoThumbnailCollectionView.frame;
    viewFrame.size.height += kVideoQueueEffectiveHeight;
    self.videoThumbnailCollectionView.frame = viewFrame;
}


@end
