//
//  SYNSubscriptionsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 17/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSubscriptionsViewController.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "AppConstants.h"
#import "SYNChannelMidCell.h"
#import "Channel.h"

@interface SYNSubscriptionsViewController ()

@end

@implementation SYNSubscriptionsViewController

@synthesize collectionView;

- (void) loadView
{
    [super loadView];
    
    
    self.channelThumbnailCollectionView.backgroundColor = [UIColor greenColor];
    self.channelThumbnailCollectionView.showsVerticalScrollIndicator = NO;
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    // Register Cells
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNChannelMidCell"
                                             bundle: nil];
    
    [self.channelThumbnailCollectionView registerNib: thumbnailCellNib
                          forCellWithReuseIdentifier: @"SYNChannelMidCell"];
    
    
    
    
}


- (NSFetchedResultsController *) fetchedResultsController
{
    
    
    if (fetchedResultsController)
        return fetchedResultsController;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    fetchRequest.entity = [NSEntityDescription entityForName: @"Channel"
                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"subscribedByUser == YES"]];
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"title" ascending: YES]];
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                        managedObjectContext: appDelegate.mainManagedObjectContext
                                                                          sectionNameKeyPath: nil
                                                                                   cacheName: nil];
    fetchedResultsController.delegate = self;
    
    NSError *error;
    ZAssert([fetchedResultsController performFetch: &error],
            @"Channels FetchedResultsController Failed: %@\n%@",
            [error localizedDescription], [error userInfo]);
    
    return fetchedResultsController;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) cv cellForItemAtIndexPath: (NSIndexPath *) indexPath {
    
    Channel *channel = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    SYNChannelMidCell *channelThumbnailCell = [cv dequeueReusableCellWithReuseIdentifier: @"SYNChannelMidCell"
                                                                                        forIndexPath: indexPath];
    
    channelThumbnailCell.channelImageViewImage = channel.coverThumbnailLargeURL;
    [channelThumbnailCell setChannelTitle:channel.title];
    
    
    return channelThumbnailCell;
    
}

-(void)setViewFrame:(CGRect)frame
{
    self.view.frame = frame;
    self.channelThumbnailCollectionView.frame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);


}

-(UICollectionView*)collectionView
{
    return self.channelThumbnailCollectionView;
}

-(Channel*)channelAtIndexPath:(NSIndexPath*)indexPath
{
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

@end
