//
//  SYNSearchChannelsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 27/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchChannelsViewController.h"

@interface SYNSearchChannelsViewController ()

@property (nonatomic, strong) NSString* currentSearchTerm;

@end

@implementation SYNSearchChannelsViewController

- (NSFetchedResultsController *)fetchedResultsController
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


-(void)performSearchWithTerm:(NSString*)term
{
    if(self.currentSearchTerm && [self.currentSearchTerm isEqualToString:term]) // same search
        return;
    
    self.currentSearchTerm = term;
    
    [appDelegate.networkEngine searchChannelsForTerm:term];

}

- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{
    
    [self reloadCollectionViews];
}


- (void) viewWillAppear: (BOOL) animated
{
    // override the data loading
    
    self.videoThumbnailCollectionView.center = CGPointMake(self.videoThumbnailCollectionView.center.x,
                                                           self.videoThumbnailCollectionView.center.y + 30.0);
    
    
}

@end
