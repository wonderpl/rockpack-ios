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

@property (nonatomic, strong) NSString* currentSearchTerm;

@end

@implementation SYNSearchVideosViewController


- (NSFetchedResultsController *)fetchedResultsController
{
    
    if (fetchedResultsController != nil)
        return fetchedResultsController;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    
    fetchRequest.entity = [NSEntityDescription entityForName: @"VideoInstance"
                                      inManagedObjectContext: appDelegate.searchManagedObjectContext];
    
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"viewId == \"%@\"", viewId]];
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"position" ascending: YES]];
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                        managedObjectContext: appDelegate.searchManagedObjectContext
                                                                          sectionNameKeyPath: nil
                                                                                   cacheName: nil];
    fetchedResultsController.delegate = self;
    
    NSError *error = nil;
    
    ZAssert([fetchedResultsController performFetch: &error],
            @"Search Videos Fetch Request Failed: %@\n%@", [error localizedDescription], [error userInfo]);
    
    return fetchedResultsController;
}


-(void)performSearchWithTerm:(NSString*)term
{
    if(self.currentSearchTerm && [self.currentSearchTerm isEqualToString:term]) // same search
        return;
    
    self.currentSearchTerm = term;
    
    [appDelegate.networkEngine searchVideosForTerm:term];
    
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow: 0 inSection: 0];
    
    self.currentIndexPath = firstIndexPath;
    
    
}

- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{
    
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

-(void)viewDidAppear:(BOOL)animated
{
    //override with empty function
}

-(void)viewWillAppear:(BOOL)animated
{
    // override with empty function
}




@end
