//
//  SYNChannelsUserViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 26/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNChannelsUserViewController.h"
#import "SYNUserTabViewController.h"

@interface SYNChannelsUserViewController ()

@end

@implementation SYNChannelsUserViewController


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Google Analytics support
    self.trackedViewName = @"Channels - User";
    
    self.channelThumbnailCollectionView.center = CGPointMake(self.channelThumbnailCollectionView.center.x,
                                                             self.channelThumbnailCollectionView.center.y + 70.0);
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


- (void) fetchUserChannels: (ChannelOwner *) channelOwner
{
    owner = channelOwner;
    
    [appDelegate.searchRegistry clearImportContextFromEntityName: @"Channel"];
    
    [appDelegate.networkEngine userPublicChannelsByOwner: owner];
    
    SYNUserTabViewController* userTabViewController = (SYNUserTabViewController*)self.tabViewController;
    [userTabViewController setOwner: owner];
}



- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{
    [self reloadCollectionViews];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    // override the data loading
}

@end
