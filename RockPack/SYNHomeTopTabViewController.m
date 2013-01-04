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
#import "SYNHomeSectionHeaderView.h"
#import "SYNHomeTopTabViewController.h"
#import "SYNVideoThumbnailWideCell.h"
#import "Video.h"
#import "VideoInstance.h"

@interface SYNHomeTopTabViewController ()

@property (nonatomic, strong) NSMutableArray *videosArray;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) SYNHomeSectionHeaderView *supplementaryViewWithRefreshButton;
@property (nonatomic, assign) BOOL refreshing;

@end


@implementation SYNHomeTopTabViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
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
}

- (BOOL) hasImageWell
{
    return TRUE;
}

- (void) refreshVideoThumbnails
{
    self.refreshing = TRUE;
    [self.supplementaryViewWithRefreshButton spinRefreshButton: TRUE];
    
    [self.refreshControl beginRefreshing];
    
    self.timer = [NSTimer timerWithTimeInterval: 5.0f
                            target: self
                          selector: @selector(refreshVideoThumbnailsFinished)
                          userInfo: nil
                           repeats: NO];
    
    NSRunLoop * theRunLoop = [NSRunLoop currentRunLoop];
    
    [theRunLoop addTimer: self.timer
                 forMode: NSDefaultRunLoopMode];
}

- (void) refreshVideoThumbnailsFinished
{
    [self.supplementaryViewWithRefreshButton spinRefreshButton: FALSE];
    self.refreshing = FALSE;
    [self.refreshControl endRefreshing];
}

#pragma mark - Core Data support

// The following 2 methods are called by the abstract class' getFetchedResults controller methods
- (NSPredicate *) videoInstanceFetchedResultsControllerPredicate
{
    // No predicate
    return nil;
}


- (NSArray *) videoInstanceFetchedResultsControllerSortDescriptors
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"dateAdded"
                                                                   ascending: YES];
    return @[sortDescriptor];
}

- (NSString *) videoInstanceFetchedResultsControllerSectionNameKeyPath
{
    return @"daysAgo";
}

- (NSArray *) otherViewsToResizeOnImageWellExpandOrContract
{
    return @[self.videoThumbnailCollectionView];
//    return @[self.largeVideoPanelView];
}

#pragma mark - Collection view support

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) cv
{
    if (cv == self.videoThumbnailCollectionView)
    {
        return self.videoInstanceFetchedResultsController.sections.count;
    }
    else
    {
        return 1;
    }
}

- (NSInteger) collectionView: (UICollectionView *) cv
      numberOfItemsInSection: (NSInteger) section
{
    // See if this can be handled in our abstract base class
    int items = [super collectionView: cv
               numberOfItemsInSection:  section];
    
    if (items < 0)
    {
        if (cv == self.videoThumbnailCollectionView)
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


- (void) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    DebugLog (@"Selecting image well cell does nothing");
}

- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout*) collectionViewLayout
                   referenceSizeForHeaderInSection: (NSInteger) section
{
    return CGSizeMake(1024, 65);
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
        id<NSFetchedResultsSectionInfo> thing = [[self.videoInstanceFetchedResultsController sections] objectAtIndex: indexPath.section];
        
        DebugLog(@"name %@, indexTitle %@", thing.name, thing.indexTitle);
        
        SYNHomeSectionHeaderView *headerSupplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind: kind
                                                                                               withReuseIdentifier: @"SYNHomeSectionHeaderView"
                                                                                                      forIndexPath: indexPath];
        NSString *sectionText;
        BOOL focus = FALSE;
        BOOL refreshButtonHidden = TRUE;
        
        switch (indexPath.section)
        {
            case 0:
                sectionText = @"TODAY";
                focus = TRUE;
                // We need to store this away, so can control animations (but must nil when goes out of scope)
                self.supplementaryViewWithRefreshButton = headerSupplementaryView;
                refreshButtonHidden = FALSE;
                if (self.refreshing == TRUE)
                {
                    [self.supplementaryViewWithRefreshButton spinRefreshButton: TRUE];
                }
                
                break;
                
            case 1:
                sectionText = @"YESTERDAY";
                break;
                
            case 2:
                sectionText = @"SUNDAY";
                break;
                
            case 3:
                sectionText = @"3rd DEC";
                break;
                
            case 4:
                sectionText = @"28th NOV";
                break;
                
            default:
                break;
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

- (void) shiftImageWellUp
{
    CGRect imageWellFrame = self.imageWellView.frame;
    imageWellFrame.origin.y -= kImageWellEffectiveHeight;
    self.imageWellView.frame = imageWellFrame;
    
    CGRect viewFrame = self.videoThumbnailCollectionView.frame;
    viewFrame.size.height -= kImageWellEffectiveHeight;
    self.videoThumbnailCollectionView.frame = viewFrame;
}


- (void) shiftImageWellDown
{
    CGRect imageWellFrame = self.imageWellView.frame;
    imageWellFrame.origin.y += kImageWellEffectiveHeight;
    self.imageWellView.frame = imageWellFrame;
    
    // Slide imagewell view downwards (and expand any other dependent visible views)
    CGRect viewFrame = self.videoThumbnailCollectionView.frame;
    viewFrame.size.height += kImageWellEffectiveHeight;
    self.videoThumbnailCollectionView.frame = viewFrame;
}


@end
