//
//  SYNExistingChannelsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 22/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNExistingChannelsViewController.h"
#import "SYNChannelMidCell.h"
#import "SYNChannelDetailViewController.h"
#import "SYNChannelCreateNewCell.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "AppConstants.h"

@interface SYNExistingChannelsViewController ()

@property (nonatomic, strong) IBOutlet UICollectionView* channelThumbnailCollectionView;
@property (nonatomic, strong) IBOutlet UIButton* closeButton;
@property (nonatomic, strong) IBOutlet UIButton* confirmButtom;

@end

@implementation SYNExistingChannelsViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    UINib *createCellNib = [UINib nibWithNibName: @"SYNChannelCreateNewCell"
                                          bundle: nil];
    
    [self.channelThumbnailCollectionView registerNib: createCellNib
                          forCellWithReuseIdentifier: @"SYNChannelCreateNewCell"];
    
    
    UINib *thumbnailCellNib = [UINib nibWithNibName: @"SYNChannelMidCell"
                                             bundle: nil];
    
    [self.channelThumbnailCollectionView registerNib: thumbnailCellNib
                          forCellWithReuseIdentifier: @"SYNChannelMidCell"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.channelThumbnailCollectionView reloadData];
}

#pragma mark - Data Source

- (NSFetchedResultsController *) fetchedResultsController
{
    NSError *error = nil;
    
    // Return cached version if we have already created one
    if (fetchedResultsController != nil)
        return fetchedResultsController;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    ChannelOwner* meAsOwner = (ChannelOwner*)appDelegate.currentUser;
    
    // Edit the entity name as appropriate.
    fetchRequest.entity = [NSEntityDescription entityForName: @"Channel"
                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    NSPredicate* ownedByUserPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"channelOwner.uniqueId == '%@'", meAsOwner.uniqueId]];
    
    
    fetchRequest.predicate = ownedByUserPredicate;
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"title"
                                                                 ascending: YES]];
    
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                        managedObjectContext: appDelegate.mainManagedObjectContext
                                                                          sectionNameKeyPath: nil
                                                                                   cacheName: nil];
    fetchedResultsController.delegate = self;
    
    ZAssert([fetchedResultsController performFetch: &error],
            @"YouRootViewController failed: %@\n%@", [error localizedDescription], [error userInfo]);
    
    
    return fetchedResultsController;
    
    
}

#pragma mark - UICollectionView DataSource

- (NSInteger) collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return sectionInfo.numberOfObjects;
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return self.fetchedResultsController.sections.count;
}



- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    Channel *channel = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    SYNChannelMidCell *channelThumbnailCell;
    SYNChannelCreateNewCell* createCell;
    if(indexPath.row == 0) // first row (create)
    {
        createCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelCreateNewCell"
                                                               forIndexPath: indexPath];
        
        return createCell;
        
        
    }
    
    channelThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelMidCell"
                                                                                        forIndexPath: indexPath];
    
    channelThumbnailCell.channelImageViewImage = channel.coverThumbnailLargeURL;
    [channelThumbnailCell setChannelTitle:channel.title];
    
    
    return channelThumbnailCell;
    
}

-(IBAction)closeButtonPressed:(id)sender
{
    
    
    
    
    
}

-(IBAction)confirmButtonPressed:(id)sender
{
    
    
    
    
    
}


- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    Channel *channel;
    
    if(indexPath.row == 0)
    {
        // create new channel clicked
        
        
        
        
        
        
        return;
    }
    
    channel = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    SYNChannelDetailViewController *channelVC = [[SYNChannelDetailViewController alloc] initWithChannel: channel];
    
    [self animatedPushViewController: channelVC];
    
}


@end
