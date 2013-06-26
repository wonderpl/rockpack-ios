//
//  SYNSearchChannelsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 27/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "GAI.h"
#import "SYNSearchChannelsViewController.h"
#import "SYNSearchRootViewController.h"
#import "SYNSearchTabView.h"
#import "SYNDeviceManager.h"
#import "SYNDeviceManager.h"
#import "SYNChannelDetailViewController.h"
#import "MKNetworkOperation.h"

@interface SYNSearchChannelsViewController ()

@property (nonatomic, weak) NSString* searchTerm;

@property (nonatomic, weak) MKNetworkOperation* runningSearchOperation;

@end


@implementation SYNSearchChannelsViewController

@synthesize itemToUpdate;
@synthesize runningNetworkOperation = _runningNetworkOperation;

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
    
    if ([SYNDeviceManager.sharedInstance isIPhone]) {
        CGRect collectionFrame = self.channelThumbnailCollectionView.frame;
        collectionFrame.origin.y += 60.0;
        collectionFrame.size.height -= 60.0;
        self.channelThumbnailCollectionView.frame = collectionFrame;
    }
    
    else {
        
        CGRect collectionFrame = self.channelThumbnailCollectionView.frame;
        collectionFrame.origin.y += 5.0;
        collectionFrame.size.height -= 5.0;
        self.channelThumbnailCollectionView.frame = collectionFrame;
        
//        UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)self.channelThumbnailCollectionView.collectionViewLayout;
//        UIEdgeInsets insets= layout.sectionInset;
////        insets.top = 0.0f;
////        insets.bottom = -50.0f;
////        layout.sectionInset = insets;
        
    }
}


- (void) viewWillAppear: (BOOL) animated
{
    // override the data loading
    [self displayChannelsForGenre];
    
    // Google analytics support
    [GAI.sharedInstance.defaultTracker sendView: @"Search - Channels"];
    
    
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

- (void) loadMoreChannels: (UIButton*) sender
{
    NSInteger nextStart = self.dataRequestRange.location + self.dataRequestRange.length; // one is subtracted when the call happens for 0 indexing
    
    if(nextStart >= self.dataItemsAvailable)
        return;
    
    self.loadingMoreContent = YES;
    
    NSInteger nextSize = (nextStart + STANDARD_REQUEST_LENGTH) >= self.dataItemsAvailable ? (self.dataItemsAvailable - nextStart) : STANDARD_REQUEST_LENGTH;
    
    self.dataRequestRange = NSMakeRange(nextStart, nextSize);
    
    [appDelegate.networkEngine searchChannelsForTerm: self.searchTerm
                                            andRange: self.dataRequestRange
                                          onComplete: ^(int itemsCount) {
                                              self.dataItemsAvailable = itemsCount;
                                              self.loadingMoreContent = NO;
                                          }];
}

#pragma mark - Perform Search

- (void) performNewSearchWithTerm: (NSString*) term
{
    
    
    if (!appDelegate)
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    self.dataRequestRange = NSMakeRange(0, kAPIInitialBatchSize);
        
    
    
    
    [appDelegate.networkEngine searchChannelsForTerm: term
                                            andRange: self.dataRequestRange
                                          onComplete: ^(int itemsCount) {
                                              self.dataItemsAvailable = itemsCount;
                                              if (self.itemToUpdate)
                                                  [self.itemToUpdate setNumberOfItems: self.dataItemsAvailable
                                                                             animated: YES];

                                          }];
    
    self.searchTerm = term;
}   


- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: NSManagedObjectContextObjectsDidChangeNotification
                                                  object: appDelegate.searchManagedObjectContext];
    
}


- (void) animatedPushViewController: (UIViewController *) vc
{
    // we push to the parent
    [((SYNSearchRootViewController*)self.parentViewController) animatedPushViewController: vc];
}

#pragma mark - UICollectionView Delegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isAnimating) // prevent double clicking
        return;
    
    
    Channel *channel = (Channel*)(self->channels[indexPath.row]);
    
    SYNChannelDetailViewController *channelVC = [[SYNChannelDetailViewController alloc] initWithChannel: channel
                                                                                              usingMode: kChannelDetailsModeDisplay];
    
    [self animatedPushViewController: channelVC];
}

-(void)setRunningSearchOperation:(MKNetworkOperation *)runningSearchOperation
{
    if(_runningNetworkOperation)
        [_runningNetworkOperation cancel];
    
    _runningNetworkOperation = runningSearchOperation;
}

#pragma mark - Helper Methods


- (CGSize) itemSize
{
    return [SYNDeviceManager.sharedInstance isIPhone] ? CGSizeMake(152.0f, 152.0f) : CGSizeMake(251.0, 274.0);
}

@end
