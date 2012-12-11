//
//  SYNHomeTopTabViewController.m
//  rockpack
//
//  Created by Nick Banks on 07/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNHomeTopTabViewController.h"
#import "SYNHomeSectionHeaderView.h"
#import "SYNVideoThumbnailCell.h"
#import "Video.h"

#define FAKE_MULTIPLE_SECTIONS

@interface SYNHomeTopTabViewController ()

@property (nonatomic, strong) IBOutlet UICollectionView *videoThumbnailCollectionView;
@property (nonatomic, strong) NSMutableArray *videos;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSTimer *timer;

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
    UINib *videoThumbnailCellNib = [UINib nibWithNibName: @"SYNVideoThumbnailCell"
                                             bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: videoThumbnailCellNib
         forCellWithReuseIdentifier: @"SYNVideoThumbnailCell"];
    
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
- (NSPredicate *) videoFetchedResultsControllerPredicate
{
    // No predicate
    return nil;
}


- (NSArray *) videoFetchedResultsControllerSortDescriptors
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
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.videoFetchedResultsController sections][section];
    
    return [sectionInfo numberOfObjects];
#endif

}

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) cv
{
#ifdef FAKE_MULTIPLE_SECTIONS
    return 5;
#else
    return self.videoFetchedResultsController.sections.count;
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
    
    Video *video = [self.videoFetchedResultsController objectAtIndexPath: adjustedIndexPath];
    
    SYNVideoThumbnailCell *cell = [cv dequeueReusableCellWithReuseIdentifier: @"SYNVideoThumbnailCell"
                                                                forIndexPath: indexPath];
    if ((indexPath.row < 3) && (indexPath.section == 0))
    {
        cell.focus = TRUE;
    }
    
    cell.imageView.image = video.keyframeImage;
    
    cell.maintitle.text = video.title;
    
    cell.subtitle.text = video.subtitle;
    
    cell.rockItNumber.text = [NSString stringWithFormat: @"%@", video.totalRocks];

    cell.rockItButton.selected = video.rockedByUserValue;
    
    // Wire the Done button up to the correct method in the sign up controller    
    [cell.rockItButton removeTarget: nil
                             action: @selector(toggleVideoThumbnailRockItButton:)
                   forControlEvents: UIControlEventTouchUpInside];
    
    [cell.rockItButton addTarget: self
                          action: @selector(toggleVideoThumbnailRockItButton:)
                forControlEvents: UIControlEventTouchUpInside];
    
    [cell.addItButton removeTarget: nil
                            action: @selector(touchVideoThumbnailAddItButton:)
                  forControlEvents: UIControlEventTouchUpInside];
    
    [cell.addItButton addTarget: self
                         action: @selector(touchVideoThumbnailAddItButton:)
               forControlEvents: UIControlEventTouchUpInside];
    
    return cell;
}


- (void) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    NSLog (@"Selecting image well cell does nothing");
}

- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout*) collectionViewLayout
                   referenceSizeForHeaderInSection: (NSInteger) section
{
    return CGSizeMake(1024, 44);
}


// Used for the collection view header
- (UICollectionReusableView *) collectionView: (UICollectionView *) cv
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
    SYNHomeSectionHeaderView *reusableView = [cv dequeueReusableSupplementaryViewOfKind: kind
                                                                    withReuseIdentifier: @"SYNHomeSectionHeaderView"
                                                                           forIndexPath: indexPath];
    
////    NSLog (@"About to display supplementary view %@, %@, %@", cv,kind,indexPath);
//    SYNHomeSectionHeaderView *reusableView = [cv dequeueReusableCellWithReuseIdentifier: 
//                                                                           forIndexPath: indexPath];
////    NSLog (@"Displayed supplementary");
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
    
    reusableView.focus = focus;
    reusableView.sectionTitleLabel.text = sectionText;
    
    return reusableView;
}

- (IBAction) toggleVideoThumbnailRockItButton: (UIButton *) rockItButton
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
    
    Video *video = [self.videoFetchedResultsController objectAtIndexPath: indexPath];
    SYNVideoThumbnailCell *cell = (SYNVideoThumbnailCell *)[self.videoThumbnailCollectionView cellForItemAtIndexPath: indexPath];
    
    cell.rockItButton.selected = video.rockedByUserValue;
    cell.rockItNumber.text = [NSString stringWithFormat: @"%@", video.totalRocks];
}

- (IBAction) toggleThumbnailShareItButton: (UIButton *) rockItButton
{
}


- (IBAction) touchVideoThumbnailAddItButton: (UIButton *) addItButton
{
    NSLog (@"No implementation yet");
}


@end
