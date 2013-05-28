//
//  SYNSearchChannelsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 27/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "GAI.h"
#import "SYNSearchChannelsViewController.h"
#import "SYNSearchRootViewController.h"
#import "SYNSearchTabView.h"
#import "SYNDeviceManager.h"
#import "SYNDeviceManager.h"


@interface SYNSearchChannelsViewController ()

@property (nonatomic, weak) NSString* searchTerm;

@end


@implementation SYNSearchChannelsViewController

@synthesize itemToUpdate;

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
        
        UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)self.channelThumbnailCollectionView.collectionViewLayout;
        UIEdgeInsets insets= layout.sectionInset;
        insets.top = 0.0f;
        insets.bottom = -50.0f;
        layout.sectionInset = insets;
        
    }
}


- (void) viewWillAppear: (BOOL) animated
{
    // override the data loading
    [self reloadCollectionViews];
    
    // Google analytics support
    [GAI.sharedInstance.defaultTracker sendView: @"Search - Channels"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNoteSearchBarRequestShow
                                                        object:self];
    
}


- (void) handleDataModelChange: (NSNotification*) dataNotification
{
    // channels are inserted so they are caught in the NSInsertedObjectsKey array
    // NSArray* updatedObjects = (NSArray*)[[dataNotification userInfo] objectForKey: NSInsertedObjectsKey];
    
    // this is mainly for the number refresh at the tabs
    [self reloadCollectionViews];
    
}

- (void) reloadCollectionViews
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName: @"Channel"
                                   inManagedObjectContext: appDelegate.searchManagedObjectContext]];
    
    NSPredicate* notOwnedByUserPredicate = [NSPredicate predicateWithFormat: @"channelOwner.uniqueId != %@", appDelegate.currentUser.uniqueId];
    
    [request setPredicate: notOwnedByUserPredicate];
    
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
    
    if (self.itemToUpdate)
        [self.itemToUpdate setNumberOfItems: resultsArray.count
                                   animated: YES];
}


- (void) loadChannelsForGenre: (Genre*) genre
{
    // override 
}

- (void) loadMoreChannels: (UIButton*) sender
{
    
    self.footerView.showsLoading = YES;
    
    NSInteger nextStart = self.dataRequestRange.location + self.dataRequestRange.length; // one is subtracted when the call happens for 0 indexing
    
    if(nextStart >= self.dataItemsAvailable)
        return;
    
    NSInteger nextSize = (nextStart + STANDARD_REQUEST_LENGTH) >= self.dataItemsAvailable ? (self.dataItemsAvailable - nextStart) : STANDARD_REQUEST_LENGTH;
    
    self.dataRequestRange = NSMakeRange(nextStart, nextSize);
    
    [appDelegate.networkEngine searchChannelsForTerm: self.searchTerm
                                            andRange: self.dataRequestRange
                                          onComplete: ^(int itemsCount) {
                                              self.dataItemsAvailable = itemsCount;
                                          }];
}


- (void) performNewSearchWithTerm: (NSString*) term
{
    
    
    if (!appDelegate)
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    self.dataRequestRange = NSMakeRange(0, 48);
        
    
    
    
    [appDelegate.networkEngine searchChannelsForTerm: term
                                            andRange: self.dataRequestRange
                                          onComplete: ^(int itemsCount) {
                                              self.dataItemsAvailable = itemsCount;
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
    [super collectionView:collectionView didSelectItemAtIndexPath:indexPath];
}

@end
