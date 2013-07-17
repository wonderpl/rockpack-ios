//
//  SYNSearchUsersViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 08/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNDeviceManager.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNSearchTabView.h"
#import "SYNSearchUsersViewController.h"
#import "SYNUserThumbnailCell.h"

@interface SYNSearchUsersViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) NSString *searchTerm;

@end


@implementation SYNSearchUsersViewController

#pragma mark - Object Lifecycle

- (id) initWithViewId: (NSString *) vid
{
    if ((self = [super initWithViewId: vid]))
    {
        appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleDataModelChange:)
                                                     name: NSManagedObjectContextObjectsDidChangeNotification
                                                   object: appDelegate.searchManagedObjectContext];
    }
    
    return self;
}


- (void) dealloc
{
    // Stop observing everything (less error-prone than trying to remove observers individually
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}


#pragma mark - View Lifecycle

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    // resize
    if (IS_IPAD)
    {
        [self setOffsetTop: 140.0f];
    }
    else
    {
        [self setOffsetTop: 120.0f];
    }
}


#pragma mark - Collection view

- (CGSize) itemSize
{
    return [SYNDeviceManager.sharedInstance isIPhone] ? CGSizeMake(120.0f, 152.0f) : CGSizeMake(251.0, 274.0);
}


#pragma mark - Core Data

- (void) handleDataModelChange: (NSNotification *) dataNotification
{
    [self displayUsers];
}


- (void) displayUsers
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity: [NSEntityDescription entityForName: @"ChannelOwner"
                                    inManagedObjectContext: appDelegate.searchManagedObjectContext]];
    
    
    [request setPredicate: [NSPredicate predicateWithFormat: @"viewId == %@", self.viewId]];
    
    NSArray *sortDescriptorsArray = @[[NSSortDescriptor sortDescriptorWithKey: @"position"
                                                                    ascending: YES]];
    [request setSortDescriptors: sortDescriptorsArray];
    
    request.fetchBatchSize = 20;
    
    NSError *error = nil;
    NSArray *resultsArray = [appDelegate.searchManagedObjectContext
                             executeFetchRequest: request
                             error: &error];
    
    if (!resultsArray)
    {
        return;
    }
    
    self.users = [NSMutableArray arrayWithArray: resultsArray];
    
    [self.usersThumbnailCollectionView reloadData];
}


- (void) performNewSearchWithTerm: (NSString *) term
{
    if (!appDelegate)
    {
        appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    }
    
    self.dataRequestRange = NSMakeRange(0, kAPIInitialBatchSize);

    [appDelegate.networkEngine searchUsersForTerm: term
                                         andRange: self.dataRequestRange
                                      byAppending: NO
                                       onComplete: ^(int itemsCount) {
                                           self.dataItemsAvailable = itemsCount;
                                           
                                           if (self.itemToUpdate)
                                           {
                                               [self.itemToUpdate setNumberOfItems: self.dataItemsAvailable
                                                                          animated: YES];
                                           }
                                       }];
    self.searchTerm = term;
}


#pragma mark - Paging support

- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height - kLoadMoreFooterViewHeight
        && self.isLoadingMoreContent == NO)
    {
        [self loadMoreUsers];
    }
}


- (void) loadMoreUsers
{
    // Check to see if we have loaded all items already
    if (self.moreItemsToLoad == TRUE)
    {
        self.loadingMoreContent = YES;
        
        [self incrementRangeForNextRequest];
        
        [appDelegate.networkEngine searchUsersForTerm: self.searchTerm
                                             andRange: self.dataRequestRange
                                          byAppending: YES
                                           onComplete: ^(int itemsCount) {
                                               self.dataItemsAvailable = itemsCount;
                                               self.loadingMoreContent = NO;
                                               
                                               if (self.itemToUpdate)
                                               {
                                                   [self.itemToUpdate setNumberOfItems: self.dataItemsAvailable
                                                                              animated: YES];
                                               }
                                           }];
    }
}


@end
