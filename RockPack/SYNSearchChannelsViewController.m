//
//  SYNSearchChannelsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 27/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchChannelsViewController.h"

@interface SYNSearchChannelsViewController ()


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
    [appDelegate.networkEngine searchChannelsForTerm:term];
}

- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{
    
    [self reloadCollectionViews];
    
}



- (void) viewWillAppear: (BOOL) animated
{
    // override the data loading
    
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.channelThumbnailCollectionView.center = CGPointMake(self.channelThumbnailCollectionView.center.x,
                                                             self.channelThumbnailCollectionView.center.y + 30.0);
}




#pragma mark - Override

-(void)handleMainTap:(UITapGestureRecognizer *)recogniser
{
    // override with empty functiokn
}

-(void)handleNewTabSelectionWithId:(NSString *)selectionId
{
    // override with emtpy function
}

@end
