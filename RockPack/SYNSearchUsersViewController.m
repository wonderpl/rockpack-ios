//
//  SYNSearchUsersViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 08/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "GAI.h"
#import "SYNDeviceManager.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNSearchTabView.h"
#import "SYNSearchUsersViewController.h"
#import "SYNUserThumbnailCell.h"
#import "SYNFeedMessagesView.h"

@interface SYNSearchUsersViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) NSString *searchTerm;
//@property (nonatomic, weak) MKNetworkOperation* runningSearchOperation;
@property (nonatomic, strong) SYNFeedMessagesView* emptyGenreMessageView;


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

- (void) viewDidLoad
{
    // Register Footer
    UINib *footerViewNib = [UINib nibWithNibName: @"SYNChannelFooterMoreView"
                                          bundle: nil];
    
    [self.usersThumbnailCollectionView registerNib: footerViewNib
                        forSupplementaryViewOfKind: UICollectionElementKindSectionFooter
                               withReuseIdentifier: @"SYNChannelFooterMoreView"];
}


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


- (void) removeEmptyGenreMessage
{
    if (!self.emptyGenreMessageView)
        return;
    
    [self.emptyGenreMessageView removeFromSuperview];
}


- (void) displayEmptyGenreMessage: (NSString*) messageKey
                        andLoader: (BOOL) isLoader
{
    
    if (self.emptyGenreMessageView)
    {
        [self.emptyGenreMessageView removeFromSuperview];
        self.emptyGenreMessageView = nil;
    }
    
    self.emptyGenreMessageView = [SYNFeedMessagesView withMessage:NSLocalizedString(messageKey ,nil) andLoader:isLoader];
    
    CGRect messageFrame = self.emptyGenreMessageView.frame;
    messageFrame.origin.y = ([[SYNDeviceManager sharedInstance] currentScreenHeight] * 0.5) - (messageFrame.size.height * 0.5) - self.view.frame.origin.y;
    messageFrame.origin.x = ([[SYNDeviceManager sharedInstance] currentScreenWidth] * 0.5) - (messageFrame.size.width * 0.5);
    
    messageFrame = CGRectIntegral(messageFrame);
    self.emptyGenreMessageView.frame = messageFrame;
    self.emptyGenreMessageView.autoresizingMask =
    UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    [self.view addSubview: self.emptyGenreMessageView];
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
    
    request.entity = [NSEntityDescription entityForName: @"ChannelOwner"
                                 inManagedObjectContext: appDelegate.searchManagedObjectContext];
    
    request.predicate = [NSPredicate predicateWithFormat: @"viewId == %@", self.viewId];
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey: @"position"
                                                              ascending: YES]];
    request.fetchBatchSize = 20;
    
    NSError *error = nil;
    NSArray *resultsArray = [appDelegate.searchManagedObjectContext executeFetchRequest: request
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
    
    [self removeEmptyGenreMessage];
    
    [self displayEmptyGenreMessage:@"Searching for People" andLoader:YES];
    
    self.dataRequestRange = NSMakeRange(0, kAPIInitialBatchSize);
    
    [appDelegate.networkEngine searchUsersForTerm: term
                                         andRange: self.dataRequestRange
                                      byAppending: NO
                                       onComplete: ^(int itemsCount) {
                                           self.dataItemsAvailable = itemsCount;
                                           
                                           if (self.itemToUpdate)
                                           {
                                               [self.itemToUpdate
                                                setNumberOfItems: self.dataItemsAvailable
                                                animated: YES];
                                           }
                                           
                                           [self removeEmptyGenreMessage];
                                           
                                           if (itemsCount == 0)
                                           {
                                               [self displayEmptyGenreMessage:[NSString stringWithFormat:@"'%@' is not on Rockpack. Yet.",term] andLoader:NO];
                                           }
                                       }];
    
    self.searchTerm = term;
}


#pragma mark - Paging support

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
                                                   [self.itemToUpdate
                                                    setNumberOfItems: self.dataItemsAvailable
                                                    animated: YES];
                                               }
                                           }];
    }
}

-(EntityType)associatedEntity
{
    return EntityTypeUser;
}

@end
