//
//  SYNSearchChannelsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 27/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "GAI.h"
#import "MKNetworkOperation.h"
#import "SYNChannelDetailViewController.h"
#import "SYNSearchChannelsViewController.h"
#import "SYNSearchRootViewController.h"
#import "SYNSearchTabView.h"
#import "SYNFeedMessagesView.h"
#import "SYNDeviceManager.h"
#import "SYNAppDelegate.h"

@interface SYNSearchChannelsViewController ()

@property (nonatomic, weak) NSString* searchTerm;
@property (nonatomic, weak) MKNetworkOperation* runningSearchOperation;
@property (nonatomic, strong) SYNFeedMessagesView* emptyGenreMessageView;

@end


@implementation SYNSearchChannelsViewController

@synthesize runningNetworkOperation = _runningNetworkOperation;

#pragma mark - Object lifecycle

- (void) dealloc
{
    // Stop observing everything (less error-prone than trying to remove observers individually
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}


#pragma mark - View lifecycle

- (id) initWithViewId: (NSString *) vid
{
    if ((self = [super initWithViewId: vid]))
    {
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleDataModelChange:)
                                                     name: NSManagedObjectContextObjectsDidChangeNotification
                                                   object: appDelegate.searchManagedObjectContext];
    }
    
    return self;
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear:animated];
  
    [self displayChannelsForGenre];
}


- (void) removeEmptyGenreMessage
{
    if (!self.emptyGenreMessageView)
        return;
    
    [self.emptyGenreMessageView removeFromSuperview];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGRect collectionFrame = self.channelThumbnailCollectionView.frame;
    if (IS_IPHONE)
    {
        collectionFrame.origin.y += 10.0;
        collectionFrame.size.height -= 10.0;
    }
    else
    {
        collectionFrame.origin.y += 5.0;
        collectionFrame.size.height -= 5.0;
    }
    self.channelThumbnailCollectionView.frame = collectionFrame;
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


- (void) handleDataModelChange: (NSNotification*) dataNotification
{
        
    // this is mainly for the number refresh at the tabs
    [self displayChannelsForGenre];
}


#pragma mark - Overloading Methods

// override the loading of channels form superclass, genre is NOT used in this class but is passed for the overloading to work //
-(void)displayChannelsForGenre
{
    [self displayChannelsForGenre:nil];
}

- (void) displayChannelsForGenre: (Genre*) genre
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName: @"Channel"
                                   inManagedObjectContext: appDelegate.searchManagedObjectContext]];
    
    
    [request setPredicate: [NSPredicate predicateWithFormat: @"viewId == %@", self.viewId]];
    
    request.fetchBatchSize = 20;
    
    NSSortDescriptor *positionDescriptor = [[NSSortDescriptor alloc] initWithKey: @"position"
                                                                       ascending: YES];
    
    [request setSortDescriptors:@[positionDescriptor]];
    
    NSError *error = nil;
    NSArray *resultsArray = [appDelegate.searchManagedObjectContext executeFetchRequest: request
                                                                                  error: &error];
    
    
    if (!resultsArray)
        return;
    
    channels = [NSMutableArray arrayWithArray: resultsArray];
    
    [self.channelThumbnailCollectionView reloadData];
}


- (void) loadChannelsForGenre: (Genre*) genre
{
    // override superclass method as there are no genres here
}

- (void) loadChannelsForGenre: (Genre*) genre
                  byAppending: (BOOL) append
{
    // override superclass method as there are no genres here
}


- (void) loadMoreChannels
{
    // Check to see if we have loaded all items already
    if (self.moreItemsToLoad == TRUE)
    {
        self.loadingMoreContent = YES;
        
        [self incrementRangeForNextRequest];
        
        [appDelegate.networkEngine searchChannelsForTerm: self.searchTerm
                                                andRange: self.dataRequestRange
                                              onComplete: ^(int itemsCount) {
                                                  self.dataItemsAvailable = itemsCount;
                                                  self.loadingMoreContent = NO;
                                              }];
    }
}


#pragma mark - Perform Search

- (void) performNewSearchWithTerm: (NSString *) term
{
    if (!appDelegate)
    {
        appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    }
    
    [self removeEmptyGenreMessage];
    
    [self displayEmptyGenreMessage:@"Searching for Packs" andLoader:YES];
    
    self.dataRequestRange = NSMakeRange(0, kAPIInitialBatchSize);
    
    [appDelegate.networkEngine searchChannelsForTerm: term
                                            andRange: self.dataRequestRange
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
                                                  [self displayEmptyGenreMessage:[NSString stringWithFormat:@"There are no packs called '%@'.\nWhy not make one?",term] andLoader:NO];
                                              }
                                          }];
    
    self.searchTerm = term;
}


#pragma mark - UICollectionView Delegate

- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (self.isAnimating) // prevent double clicking
    {
        return;
    }
    
    Channel *channel = (Channel *) (self->channels[indexPath.row]);
    
    SYNChannelDetailViewController *channelVC = [[SYNChannelDetailViewController alloc] initWithChannel: channel
                                                                                              usingMode: kChannelDetailsModeDisplay];
    
    [appDelegate.viewStackManager
     pushController: channelVC];
}


- (void) setRunningSearchOperation: (MKNetworkOperation *) runningSearchOperation
{
    if (_runningNetworkOperation)
    {
        [_runningNetworkOperation cancel];
    }
    
    _runningNetworkOperation = runningSearchOperation;
}


#pragma mark - Helper Methods

- (CGSize) itemSize
{
    return IS_IPHONE ? CGSizeMake(152.0f, 152.0f) : CGSizeMake(251.0, 274.0);
}

@end
