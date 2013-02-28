//
//  SYNSearchRootViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 27/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchVideosViewController.h"
#import "SYNAppDelegate.h"

@interface SYNSearchVideosViewController ()



@end

@implementation SYNSearchVideosViewController


- (NSFetchedResultsController *)fetchedResultsController
{
    
    if (fetchedResultsController != nil)
        return fetchedResultsController;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    
    fetchRequest.entity = [NSEntityDescription entityForName: @"VideoInstance"
                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"viewId == \"%@\"", viewId]];
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"position" ascending: YES]];
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                        managedObjectContext: appDelegate.mainManagedObjectContext
                                                                          sectionNameKeyPath: nil
                                                                                   cacheName: nil];
    fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    
    ZAssert([fetchedResultsController performFetch: &error], @"Videos Root FetchRequest failed: %@\n%@", [error localizedDescription], [error userInfo]);
    
    return fetchedResultsController;
}


-(void)performSearchWithTerm:(NSString*)term
{
    
    [appDelegate.networkEngine searchVideosForTerm:term];
    
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow: 0 inSection: 0];
    
    self.currentIndexPath = firstIndexPath;
    
    [self reloadCollectionViews];
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    // override the data loading
    
    self.videoThumbnailCollectionView.center = CGPointMake(self.videoThumbnailCollectionView.center.x,
                                                           self.videoThumbnailCollectionView.center.y + 30.0);
    
    self.largeVideoPanelView.center = CGPointMake(self.largeVideoPanelView.center.x,
                                                  self.largeVideoPanelView.center.y + 30.0);
}



-(void)viewWillAppear:(BOOL)animated
{
    // override with empty function
}




@end
