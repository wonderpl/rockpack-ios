//
//  SYNHomeTopTabViewController.m
//  rockpack
//
//  Created by Nick Banks on 07/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "NSDate-Utilities.h"
#import "SYNAppDelegate.h"
#import "SYNHomeRootViewController.h"
#import "SYNHomeSectionHeaderView.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNNetworkEngine.h"
#import "SYNVideoThumbnailWideCell.h"
#import "Video.h"
#import "VideoInstance.h"

@interface SYNHomeRootViewController ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) SYNHomeSectionHeaderView *supplementaryViewWithRefreshButton;
@property (nonatomic, assign) BOOL refreshing;

@end


@implementation SYNHomeRootViewController

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    SYNIntegralCollectionViewFlowLayout *standardFlowLayout = [[SYNIntegralCollectionViewFlowLayout alloc] init];
    standardFlowLayout.itemSize = CGSizeMake(507.0f , 182.0f);
    standardFlowLayout.minimumInteritemSpacing = 0.0f;
    standardFlowLayout.minimumLineSpacing = 0.0f;
    standardFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    standardFlowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    self.videoThumbnailCollectionView.collectionViewLayout = standardFlowLayout;
    
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame: CGRectMake(0, -44, 320, 44)];
    
    [self.refreshControl addTarget: self
                            action: @selector(refreshVideoThumbnails)
                  forControlEvents: UIControlEventValueChanged];
    
    
    [self.videoThumbnailCollectionView addSubview: self.refreshControl];

    // Init collection view
    UINib *videoThumbnailCellNib = [UINib nibWithNibName: @"SYNVideoThumbnailWideCell"
                                                  bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: videoThumbnailCellNib
                        forCellWithReuseIdentifier: @"SYNVideoThumbnailWideCell"];
    
    // Register collection view header view
    UINib *headerViewNib = [UINib nibWithNibName: @"SYNHomeSectionHeaderView"
                                          bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: headerViewNib
                        forSupplementaryViewOfKind: UICollectionElementKindSectionHeader
                               withReuseIdentifier: @"SYNHomeSectionHeaderView"];
    
    [self refreshVideoThumbnails];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(reloadCollectionViews)
                                                 name: kDataUpdated
                                               object: nil];

}


- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kDataUpdated
                                                  object: nil];
}


- (void) reloadCollectionViews
{
    [self.videoThumbnailCollectionView reloadData];
}

- (BOOL) hasVideoQueue
{
    return TRUE;
}

- (void) refreshVideoThumbnails
{
    [self startRefreshCycle];
    
    [appDelegate.networkEngine updateHomeScreenOnCompletion: ^
    {
         // TODO: Might want to put in some error reporting here
         [self endRefreshCycle];
     }
     onError: ^(NSError *error)
     {
         [self endRefreshCycle];
     }];
}

- (void) startRefreshCycle
{
    self.refreshing = TRUE;
    [self.supplementaryViewWithRefreshButton spinRefreshButton: TRUE];
    [self.refreshControl beginRefreshing];
}

- (void) endRefreshCycle
{
    self.refreshing = FALSE;
    [self.supplementaryViewWithRefreshButton spinRefreshButton: FALSE];
    [self.refreshControl endRefreshing];
}


#pragma mark - Core Data support


// Not sure that
- (NSPredicate *) channelFetchedResultsControllerPredicate
{
    // Don't show any user generated channels
    return [NSPredicate predicateWithFormat: @"viewId != \"Home\""];
}


- (NSArray *) channelFetchedResultsControllerSortDescriptors
{
    // Sort by index
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"position"
                                                                   ascending: YES];
    return @[sortDescriptor];
}


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
    return @"dateAddedIgnoringTime";
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


//- (void) collectionView: (UICollectionView *) collectionView
//         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
//{
//    // XXX
//    VideoInstance *videoInstance = [self.videoInstanceFetchedResultsController objectAtIndexPath: indexPath];
//    
//    [self displayVideoViewer: videoInstance];
//}

- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout*) collectionViewLayout
                   referenceSizeForHeaderInSection: (NSInteger) section
{
    if (collectionView == self.videoThumbnailCollectionView)
    {
        return CGSizeMake(1024, 65);
    }
    else
    {
        return CGSizeMake(0, 0);
    }
}


// Used for the collection view header
- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
    UICollectionReusableView *sectionSupplementaryView = nil;
    
    if (collectionView == self.videoThumbnailCollectionView)
    {
        // Work out the day
        id<NSFetchedResultsSectionInfo> sectionInfo = [[self.videoInstanceFetchedResultsController sections] objectAtIndex: indexPath.section];
        
        // In the 'name' attribut of the sectionInfo we have actually the keypath data (i.e in this case Date without time)
        
        // TODO: We might want to optimise this instead of creating a new date formatter each time
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
        
        NSDate *date = [dateFormatter dateFromString: sectionInfo.name];
        
        SYNHomeSectionHeaderView *headerSupplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind: kind
                                                                                               withReuseIdentifier: @"SYNHomeSectionHeaderView"
                                                                                                      forIndexPath: indexPath];
        NSString *sectionText;
        BOOL focus = FALSE;
        BOOL refreshButtonHidden = TRUE;
        
        if (indexPath.section == 0)
        {
            // When highlighting is required again, then set to TRUE
            focus = FALSE;
            
            // We need to store this away, so can control animations (but must nil when goes out of scope)
            self.supplementaryViewWithRefreshButton = headerSupplementaryView;
            
            refreshButtonHidden = FALSE;
            
            if (self.refreshing == TRUE)
            {
                [self.supplementaryViewWithRefreshButton spinRefreshButton: TRUE];
            }
        }
        
        // Unavoidably long if-then-else
        if ([date isToday])
        {
            sectionText = @"TODAY";
        }
        else if ([date isYesterday])
        {
            sectionText = @"YESTERDAY";
        }
        else if ([date isLast7Days])
        {
            sectionText = date.weekdayString;
        }
        else if ([date isThisYear])
        {
            sectionText = date.shortDateWithOrdinalString;
        }
        else
        {
            sectionText = date.shortDateWithOrdinalStringAndYear;
        }
        
        // Special case, remember the first section view
        headerSupplementaryView.viewControllerDelegate = self;
        headerSupplementaryView.focus = focus;
        headerSupplementaryView.refreshView.hidden = refreshButtonHidden;
        headerSupplementaryView.sectionTitleLabel.text = sectionText;
        
        sectionSupplementaryView = headerSupplementaryView;
    }

    return sectionSupplementaryView;
}

- (void) collectionView: (UICollectionView *) collectionView
       didEndDisplayingSupplementaryView: (UICollectionReusableView *) view
       forElementOfKind: (NSString *) elementKind
            atIndexPath: (NSIndexPath *) indexPath
{
    if (collectionView == self.videoThumbnailCollectionView)
    {
        if (indexPath.section == 0)
        {
            // If out first section header leave the screen, then we need to ensure that we don't try and manipulate it
            //  in future (as it will no longer exist)
            self.supplementaryViewWithRefreshButton = nil;
        }
    }
    else
    {
        // We should not be expecting any other supplementary views
        AssertOrLog(@"No valid collection view found");
    }
}


#pragma mark - UI Actions

- (IBAction) userTouchedRefreshButton: (id) sender
{
    if (self.refreshing == FALSE)
    {
        self.refreshing = TRUE;
        [self refreshVideoThumbnails];
    }
}



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

- (IBAction) toggleVideoShareItButton: (UIButton *) rockItButton
{
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
