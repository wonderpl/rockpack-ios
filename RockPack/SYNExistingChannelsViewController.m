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
#import "SYNDeviceManager.h"
#import "UIFont+SYNFont.h"

@interface SYNExistingChannelsViewController ()

@property (nonatomic, strong) IBOutlet UICollectionView* channelThumbnailCollectionView;
@property (nonatomic, strong) IBOutlet UIButton* closeButton;
@property (nonatomic, strong) IBOutlet UIButton* confirmButtom;
@property (nonatomic, weak) SYNChannelMidCell* selectedCell;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;


@property (nonatomic, weak) Channel* selectedChannel;

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
    
    self.titleLabel.font = [UIFont rockpackFontOfSize:28.0];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.closeButton.enabled = YES;
    self.confirmButtom.enabled = YES;
    
    [self willAnimateRotationToInterfaceOrientation:[[SYNDeviceManager sharedInstance] orientation] duration:0.0f];
    
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
    self.closeButton.enabled = NO;
    self.confirmButtom.enabled = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
    
    
    
}

-(IBAction)confirmButtonPressed:(id)sender
{
    if(!self.selectedChannel)
        return;
    
    self.confirmButtom.enabled = NO;
    self.closeButton.enabled = NO;
    [UIView animateWithDuration:0.2 animations:^{
        
        self.view.alpha = 0.0;
        
        
    } completion:^(BOOL finished) {
        
        
        [self.view removeFromSuperview];
        
        
        
        Channel* currentlyCreating = appDelegate.videoQueue.currentlyCreatingChannel;
        [self.selectedChannel addVideoInstancesFromChannel:currentlyCreating];
        [appDelegate saveContext:YES];
        
        [self removeFromParentViewController];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kNoteAddToChannel
                                                            object: self
                                                          userInfo: @{kChannel:self.selectedChannel}];
    }];
    
    
    
}


- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    
    if(indexPath.row == 0)
    {
        // create new channel clicked
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kNoteCreateNewChannel
                                                            object: self
                                                          userInfo: @{kChannel:appDelegate.videoQueue.currentlyCreatingChannel}];
        
        self.selectedChannel = nil;
        
        [self confirmButtonPressed:nil];
        
        return;
    }
    
    self.selectedCell = (SYNChannelMidCell*)[self.channelThumbnailCollectionView cellForItemAtIndexPath:indexPath];
    
    self.selectedChannel = (Channel*)[self.fetchedResultsController objectAtIndexPath: indexPath];
    
    
    
}


-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    
}

-(void)setSelectedCell:(SYNChannelMidCell *)selectedCell
{
    _selectedCell.specialSelected = NO;
    selectedCell.specialSelected = YES;
    
    _selectedCell = selectedCell;
}

@end
