//
//  SYNExistingChannelsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 22/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "SYNChannelCreateNewCell.h"
#import "SYNChannelDetailViewController.h"
#import "SYNChannelMidCell.h"
#import "SYNDeletionWobbleLayout.h"
#import "SYNDeviceManager.h"
#import "SYNExistingChannelsViewController.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "UIFont+SYNFont.h"

@interface SYNExistingChannelsViewController ()

@property (nonatomic, strong) IBOutlet UIButton* closeButton;
@property (nonatomic, strong) IBOutlet UIButton* confirmButtom;
@property (nonatomic, strong) IBOutlet UICollectionView* channelThumbnailCollectionView;
@property (nonatomic, weak) Channel* selectedChannel;
@property (nonatomic, weak) SYNChannelMidCell* selectedCell;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation SYNExistingChannelsViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // We need to use a custom layout (as due to the deletion/wobble logic used elsewhere)
    if ([[SYNDeviceManager sharedInstance] isIPad])
    {
        // iPad layout & size
        self.channelThumbnailCollectionView.collectionViewLayout =
        [SYNDeletionWobbleLayout layoutWithItemSize: CGSizeMake(184.0f, 184.0f)
                            minimumInterItemSpacing: 10.0f
                                 minimumLineSpacing: 10.0f
                                    scrollDirection: UICollectionViewScrollDirectionVertical
                                       sectionInset: UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    }
    else
    {
        // iPhone layout & size
        self.channelThumbnailCollectionView.collectionViewLayout =
        [SYNDeletionWobbleLayout layoutWithItemSize: CGSizeMake(152.0f, 152.0f)
                            minimumInterItemSpacing: 6.0f
                                 minimumLineSpacing: 5.0f
                                    scrollDirection: UICollectionViewScrollDirectionVertical
                                       sectionInset: UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
    }

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


- (void) viewWillAppear: (BOOL) animated
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
    
    NSPredicate* ownedByUserPredicate = [NSPredicate predicateWithFormat:   [NSString stringWithFormat: @"channelOwner.uniqueId == '%@'", meAsOwner.uniqueId]];
    
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

- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    return self.fetchedResultsController.fetchedObjects.count + 1; // add one for the 'create new channel' cell
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    UICollectionViewCell* cell;
    
    if (indexPath.row == 0) // first row (create)
    {
        SYNChannelCreateNewCell* createCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelCreateNewCell"
                                                                                        forIndexPath: indexPath];
        
        cell = createCell;
    }
    else
    {
        Channel *channel = (Channel*)self.fetchedResultsController.fetchedObjects[indexPath.row-1];
        
        SYNChannelMidCell *channelThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNChannelMidCell"
                                                                                            forIndexPath: indexPath];
        
        channelThumbnailCell.channelImageViewImage = channel.coverThumbnailLargeURL;
        [channelThumbnailCell setChannelTitle: channel.title];
        
        cell = channelThumbnailCell;
    }

    return cell;
}


- (IBAction) closeButtonPressed: (id) sender
{
    self.closeButton.enabled = NO;
    self.confirmButtom.enabled = NO;
    [UIView animateWithDuration: 0.2
                     animations: ^{
        self.view.alpha = 0.0;
    }
                     completion: ^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
    
    if ([[SYNDeviceManager sharedInstance] isIPhone])
    {
        //Ensure only one video is ever queud on iPhone
        [[NSNotificationCenter defaultCenter] postNotificationName: kVideoQueueClear
                                                            object: self];
    }
}


- (IBAction) confirmButtonPressed: (id) sender
{
    if (!self.selectedChannel)
        return;
    
    self.confirmButtom.enabled = NO;
    self.closeButton.enabled = NO;
    
    [UIView animateWithDuration: 0.2
                     animations: ^{
        self.view.alpha = 0.0;
    }
                     completion: ^(BOOL finished) {
        [self.view removeFromSuperview];
        
        Channel* currentlyCreating = appDelegate.videoQueue.currentlyCreatingChannel;
        [self.selectedChannel addVideoInstancesFromChannel: currentlyCreating];
        [appDelegate saveContext:YES];
        
        [self removeFromParentViewController];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kNoteAddedToChannel
                                                            object: self
                                                          userInfo: @{kChannel:self.selectedChannel}];
    }];
}


- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (indexPath.row == 0)
    {
        if (!appDelegate.videoQueue.currentlyCreatingChannel)
            return;
        
        self.selectedChannel = nil;
        self.selectedCell = nil;
        
        [UIView animateWithDuration: 0.3
                              delay: 0.0
                            options: UIViewAnimationCurveLinear
                         animations: ^{
                             
                             self.view.alpha = 0.0;
                            
            
                         }
                         completion: ^(BOOL finished) {
                             [self.view removeFromSuperview];
                           
                             [[NSNotificationCenter defaultCenter] postNotificationName: kNoteCreateNewChannel
                                                                                 object: self
                                                                               userInfo: @{kChannel:appDelegate.videoQueue.currentlyCreatingChannel}];
                         }];
        
    }
    else
    {
        self.selectedCell = (SYNChannelMidCell*)[self.channelThumbnailCollectionView cellForItemAtIndexPath:indexPath];
        
        self.selectedChannel = (Channel*)[self.fetchedResultsController objectAtIndexPath: indexPath];
    }
}


- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    [super willAnimateRotationToInterfaceOrientation: toInterfaceOrientation
                                            duration: duration];
    
    CGRect collectionFrame = self.channelThumbnailCollectionView.frame;
    
    if ([[SYNDeviceManager sharedInstance] isIPad])
    {
        if(UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
        {
            collectionFrame.size.width = 572.0;
        }
        else
        {
            collectionFrame.size.width = 766.0;
        }
    }
    else
    {
        collectionFrame.size.width = 320.0f;
    }
    
    collectionFrame.origin.x = (self.view.frame.size.width * 0.5) - (collectionFrame.size.width * 0.5);
    self.channelThumbnailCollectionView.frame = CGRectIntegral(collectionFrame);
}


- (void) setSelectedCell: (SYNChannelMidCell *) selectedCell
{
    _selectedCell.specialSelected = NO;
    
    if(selectedCell) // we can still pass nill
        selectedCell.specialSelected = YES;
    
    _selectedCell = selectedCell;
}

@end
