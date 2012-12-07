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

@end

@implementation SYNHomeTopTabViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Init collection view
    UINib *videoThumbnailCellNib = [UINib nibWithNibName: @"SYNVideoThumbnailCell"
                                             bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: videoThumbnailCellNib
         forCellWithReuseIdentifier: @"ThumbnailCell"];
    
    // Register collection view header view
    UINib *headerViewNib = [UINib nibWithNibName: @"SYNHomeSectionHeaderView"
                                          bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: headerViewNib
                        forCellWithReuseIdentifier: @"SYNHomeSectionHeaderView"];
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
    
    SYNVideoThumbnailCell *cell = [cv dequeueReusableCellWithReuseIdentifier: @"ThumbnailCell"
                                                                forIndexPath: indexPath];
    if ((indexPath.row < 3) && (indexPath.section == 0))
    {
        cell.highlighted = TRUE;
    }
    
    cell.imageView.image = video.keyframeImage;
    
    cell.maintitle.text = video.title;
    
    cell.subtitle.text = video.subtitle;
    
    cell.packItNumber.text = [NSString stringWithFormat: @"%@", video.totalPacks];
    
    cell.rockItNumber.text = [NSString stringWithFormat: @"%@", video.totalRocks];
    
    cell.packItButton.selected = video.packedByUserValue;
    
    cell.rockItButton.selected = video.rockedByUserValue;
    
    // Wire the Done button up to the correct method in the sign up controller
    [cell.packItButton removeTarget: nil
                             action: @selector(toggleThumbnailPackItButton:)
                   forControlEvents: UIControlEventTouchUpInside];
    
    [cell.packItButton addTarget: self
                          action: @selector(toggleThumbnailPackItButton:)
                forControlEvents: UIControlEventTouchUpInside];
    
    [cell.rockItButton removeTarget: nil
                             action: @selector(toggleThumbnailRockItButton:)
                   forControlEvents: UIControlEventTouchUpInside];
    
    [cell.rockItButton addTarget: self
                          action: @selector(toggleThumbnailRockItButton:)
                forControlEvents: UIControlEventTouchUpInside];
    
    [cell.addItButton removeTarget: nil
                            action: @selector(touchThumbnailAddItButton:)
                  forControlEvents: UIControlEventTouchUpInside];
    
    [cell.addItButton addTarget: self
                         action: @selector(touchThumbnailAddItButton:)
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
    return CGSizeMake(0, 44);
}


// Used for the collection view header
- (UICollectionReusableView *) collectionView: (UICollectionView *) cv
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
    SYNHomeSectionHeaderView *reusableView = [cv dequeueReusableCellWithReuseIdentifier: @"SYNHomeSectionHeaderView"
                                                                           forIndexPath: indexPath];
    NSString *sectionText;
    BOOL highlighted = FALSE;
    
    switch (indexPath.section)
    {
        case 0:
            sectionText = @"TODAY";
            highlighted = TRUE;
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
    
    reusableView.highlighted = highlighted;
    reusableView.sectionTitleLabel.text = sectionText;
    
    return reusableView;
}

@end
