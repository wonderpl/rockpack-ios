//
//  SYNHomeTopTabViewController.m
//  rockpack
//
//  Created by Nick Banks on 07/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "Channel.h"
#import "ChannelOwner.h"
#import "SYNHomeSectionHeaderView.h"
#import "SYNHomeTopTabViewController.h"
#import "SYNVideoThumbnailWideCell.h"
#import "Video.h"
#import "VideoInstance.h"

#define FAKE_MULTIPLE_SECTIONS

@interface SYNHomeTopTabViewController ()

@property (nonatomic, strong) NSMutableArray *videosArray;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

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

- (void) refreshVideoThumbnails
{
    [self.refreshControl beginRefreshing];
    
    self.timer = [NSTimer timerWithTimeInterval: 2.0f
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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"title"
                                                                   ascending: YES];
    return @[sortDescriptor];
}

#pragma mark - Collection view support

- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
#ifdef FAKE_MULTIPLE_SECTIONS
    return 6;
#else
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.videoInstanceFetchedResultsController sections][section];
    
    return [sectionInfo numberOfObjects];
#endif

}

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) cv
{
#ifdef FAKE_MULTIPLE_SECTIONS
    return 5;
#else
    return self.videoInstanceFetchedResultsController.sections.count;
#endif
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    NSIndexPath *adjustedIndexPath;
#ifdef FAKE_MULTIPLE_SECTIONS
    int section = (indexPath.section % 2) ? 0 : 6;
    adjustedIndexPath = [NSIndexPath indexPathForItem: indexPath.row + section
                                            inSection: 0];
#else
    adjustedIndexPath = indexPath;
#endif
    
    SYNVideoThumbnailWideCell *cell = [cv dequeueReusableCellWithReuseIdentifier: @"SYNVideoThumbnailWideCell"
                                                                forIndexPath: indexPath];
    if ((indexPath.row < 3) && (indexPath.section == 0))
    {
        cell.focus = TRUE;
    }
    
    if (cv == self.videoThumbnailCollectionView)
    {
        // No, but it was our collection view
        VideoInstance *videoInstance = [self.videoInstanceFetchedResultsController objectAtIndexPath: adjustedIndexPath];
        
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
    else
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
- (UICollectionReusableView *) collectionView: (UICollectionView *) cv
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
    SYNHomeSectionHeaderView *sectionSupplementaryView = [cv dequeueReusableSupplementaryViewOfKind: kind
                                                                                withReuseIdentifier: @"SYNHomeSectionHeaderView"
                                                                                       forIndexPath: indexPath];
    NSString *sectionText;
    BOOL focus = FALSE;
    
    switch (indexPath.section)
    {
        case 0:
            sectionText = @"TODAY";
            focus = TRUE;
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
    
    sectionSupplementaryView.focus = focus;
    sectionSupplementaryView.sectionTitleLabel.text = sectionText;
    
    return sectionSupplementaryView;
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


@end
