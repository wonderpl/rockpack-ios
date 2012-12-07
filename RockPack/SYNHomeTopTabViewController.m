//
//  SYNHomeTopTabViewController.m
//  rockpack
//
//  Created by Nick Banks on 07/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNHomeTopTabViewController.h"
#import "SYNHomeSectionHeaderView.h"

@interface SYNHomeTopTabViewController ()

@property (nonatomic, strong) IBOutlet UICollectionView *videoThumbnailCollectionView;

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



// Used for the collection view header
- (UICollectionReusableView *) collectionView: (UICollectionView *) cv
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
    SYNHomeSectionHeaderView *reusableView = [cv dequeueReusableCellWithReuseIdentifier: @"SYNHomeSectionHeaderView"
                                                                           forIndexPath: indexPath];
    
    reusableView.sectionTitleLabel.text = @"TODAY";
    
    return reusableView;
}

@end
