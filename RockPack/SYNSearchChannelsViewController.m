//
//  SYNSearchChannelsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 27/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchChannelsViewController.h"
#import "SYNSearchTabView.h"
#import "SYNSearchRootViewController.h"

@interface SYNSearchChannelsViewController ()


@end



@implementation SYNSearchChannelsViewController

@synthesize itemToUpdate;

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.trackedViewName = @"Search - Channels";
    
    
    CGRect collectionFrame = self.channelThumbnailCollectionView.frame;
    collectionFrame.origin.y += 60.0;
    collectionFrame.size.height -= 60.0;
    self.channelThumbnailCollectionView.frame = collectionFrame;
}


- (void) viewWillAppear: (BOOL) animated
{
    // override the data loading
    
}

- (NSFetchedResultsController *) fetchedResultsController
{
    
    if (fetchedResultsController != nil)
        return fetchedResultsController;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.entity = [NSEntityDescription entityForName: @"Channel"
                                      inManagedObjectContext: appDelegate.searchManagedObjectContext];
    
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"viewId == \"%@\"", viewId]];
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"position" ascending: YES]];
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                        managedObjectContext: appDelegate.searchManagedObjectContext
                                                                          sectionNameKeyPath: nil
                                                                                   cacheName: nil];
    fetchedResultsController.delegate = self;
    
    NSError* error = nil;
    
    ZAssert([fetchedResultsController performFetch: &error],
            @"Search Channels Fetch Request Failed: %@\n%@", [error localizedDescription], [error userInfo]);
    
    return fetchedResultsController;
}


- (void) performSearchWithTerm: (NSString*) term
{
//    if(self.itemToUpdate)
//        [self.itemToUpdate hideItem];
    
    [appDelegate.networkEngine searchChannelsForTerm:term];
}


- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{
    if(self.itemToUpdate)
        [self.itemToUpdate setNumberOfItems: [controller.fetchedObjects count] animated:YES];
    
    [self reloadCollectionViews];
    
}


#pragma mark - Override

- (void) handleMainTap: (UITapGestureRecognizer *) recogniser
{
    // override with empty functiokn
}

- (void) handleNewTabSelectionWithId: (NSString *) selectionId
{
    // override with emtpy function
}




@end
