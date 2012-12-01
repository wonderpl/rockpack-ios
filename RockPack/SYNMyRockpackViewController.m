//
//  SYNMyRockpackViewController.m
//  rockpack
//
//  Created by Nick Banks on 26/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "SYNChannelThumbnailCell.h"
#import "SYNVideoThumbnailCell.h"
#import "SYNMyRockpackMovieViewController.h"
#import "SYNMyRockpackDetailViewController.h"
#import "SYNMyRockpackViewController.h"
#import "SYNSwitch.h"
#import "UIFont+SYNFont.h"
#import "Video.h"
#import "Channel.h"

@interface SYNMyRockpackViewController ()

@property (nonatomic, assign) CGPoint originalOrigin;
@property (nonatomic, assign) int currentIndex;
@property (nonatomic, assign) int currentOffset;
@property (nonatomic, strong) IBOutlet SYNSwitch *toggleSwitch;
@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UICollectionView *channelThumbnailCollection;
@property (nonatomic, strong) IBOutlet UICollectionView *packedVideoThumbnailCollection;
@property (nonatomic, strong) IBOutlet UIImageView *userAvatar;
@property (nonatomic, strong) IBOutlet UILabel *channelLabel;
@property (nonatomic, strong) IBOutlet UILabel *packedVideosLabel;
@property (nonatomic, strong) IBOutlet UILabel *userName;
@property (nonatomic, strong) IBOutlet UIView *avatarView;
@property (nonatomic, strong) IBOutlet UIView *cardsView;
@property (nonatomic, strong) NSFetchedResultsController *channelFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *videoFetchedResultsController;
@property (nonatomic, strong) UIColor *darkSwitchColor;
@property (nonatomic, strong) UIColor *lightSwitchColor;

@end

@implementation SYNMyRockpackViewController

@synthesize videoFetchedResultsController = _videoFetchedResultsController;
@synthesize channelFetchedResultsController = _channelFetchedResultsController;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Add custom slider
    self.toggleSwitch = [[SYNSwitch alloc] initWithFrame: CGRectMake(780, 24, 95, 42)];
    self.toggleSwitch.on = NO;
    [self.toggleSwitch addTarget: self
                          action: @selector(switchChanged:forEvent:)
                forControlEvents: (UIControlEventValueChanged)];
    
    // Set switch label colours
    self.lightSwitchColor = [UIColor colorWithRed: 213.0f/255.0f green: 233.0f/255.0f blue: 238.0f/255.0f alpha: 1.0f];
    self.darkSwitchColor = [UIColor colorWithRed: 129.0f/255.0f green: 154.0f/255.0f blue: 162.0f/255.0f alpha: 1.0f];
    self.packedVideosLabel.textColor = self.lightSwitchColor;
    self.channelLabel.textColor = self.darkSwitchColor;
    
    [self.view addSubview: self.toggleSwitch];
    
    self.userName.font = [UIFont boldRockpackFontOfSize: 25.0f];
    self.packedVideosLabel.font = [UIFont boldRockpackFontOfSize: 15.0f];
    self.channelLabel.font = [UIFont boldRockpackFontOfSize: 15.0f];
    self.userAvatar.image = [UIImage imageNamed: @"EddieTaylor.png"];
    
    // Init collection views
    // Video thumbnails
    UINib *videoThumbnailCellNib = [UINib nibWithNibName: @"SYNVideoThumbnailCell"
                                             bundle: nil];
    
    [self.packedVideoThumbnailCollection registerNib: videoThumbnailCellNib
                          forCellWithReuseIdentifier: @"ThumbnailCell"];
    
    // Channel thumbnails
    UINib *channelThumbnailCellNib = [UINib nibWithNibName: @"SYNChannelThumbnailCell"
                                             bundle: nil];
    
    [self.channelThumbnailCollection registerNib: channelThumbnailCellNib
                          forCellWithReuseIdentifier: @"ChannelThumbnailCell"];
    
    self.channelThumbnailCollection.alpha = 0.0f;
    self.channelThumbnailCollection.hidden = TRUE;
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];

}


#pragma mark - CoreData support

- (NSFetchedResultsController *) videoFetchedResultsController
{
    // Return cached version if we have already created one
    if (_videoFetchedResultsController != nil)
    {
        return _videoFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName: @"Video"
                                              inManagedObjectContext: self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"title"
                                                                   ascending: YES];
    
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors: sortDescriptors];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"packedByUser == TRUE"];
    [fetchRequest setPredicate: predicate];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *newFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                                                  managedObjectContext: self.managedObjectContext
                                                                                                    sectionNameKeyPath: nil
                                                                                                             cacheName: nil];
    newFetchedResultsController.delegate = self;
    self.videoFetchedResultsController = newFetchedResultsController;
    
    NSError *error = nil;
    if (![_videoFetchedResultsController performFetch: &error])
    {
        // TODO: Put some more error handling in here
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _videoFetchedResultsController;
}


- (NSFetchedResultsController *) channelFetchedResultsController
{
    // Return cached version if we have already created one
    if (_channelFetchedResultsController != nil)
    {
        return _channelFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName: @"Channel"
                                              inManagedObjectContext: self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"title"
                                                                   ascending: YES];
    
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors: sortDescriptors];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"packedByUser == TRUE"];
    [fetchRequest setPredicate: predicate];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *newFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                                                  managedObjectContext: self.managedObjectContext
                                                                                                    sectionNameKeyPath: nil
                                                                                                             cacheName: nil];
    newFetchedResultsController.delegate = self;
    self.channelFetchedResultsController = newFetchedResultsController;
    
    NSError *error = nil;
    if (![_channelFetchedResultsController performFetch: &error])
    {
        // TODO: Put some more error handling in here
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _channelFetchedResultsController;
}


- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{
    if (controller == self.videoFetchedResultsController)
    {
        [self.packedVideoThumbnailCollection reloadData];
    }
    else
    {
        [self.channelThumbnailCollection reloadData];
    }
}


#pragma mark - Collection view support

- (NSInteger) collectionView: (UICollectionView *) cv
      numberOfItemsInSection: (NSInteger) section
{
    if (cv == self.packedVideoThumbnailCollection)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.videoFetchedResultsController sections][section];
        return [sectionInfo numberOfObjects];
    }
    else
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.channelFetchedResultsController sections][section];
        return [sectionInfo numberOfObjects];
    }
}

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) cv
{
    if (cv == self.packedVideoThumbnailCollection)
    {
        return self.videoFetchedResultsController.sections.count;
    }
    else
    {
        return self.channelFetchedResultsController.sections.count;
    }
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (cv == self.packedVideoThumbnailCollection)
    {
        Video *video = [self.videoFetchedResultsController objectAtIndexPath: indexPath];
        
        SYNVideoThumbnailCell *cell = [cv dequeueReusableCellWithReuseIdentifier: @"ThumbnailCell"
                                                                    forIndexPath: indexPath];
        
        [cell setThirdButtonType: kShowShareButton];
        
        cell.imageView.image = video.keyframeImage;
        
        cell.maintitle.text = video.title;
        
        cell.subtitle.text = video.subtitle;
        
        cell.packItNumber.text = [NSString stringWithFormat: @"%@", video.totalPacks];
        
        cell.rockItNumber.text = [NSString stringWithFormat: @"%@", video.totalRocks];
        
        cell.packItButton.selected = video.packedByUserValue;
        
        cell.rockItButton.selected = video.rockedByUserValue;
        
        // Wire the Done button up to the correct method in the sign up controller
		[cell.packItButton removeTarget: nil
                                 action: @selector(toggleThumbnailPackItButton:)
                       forControlEvents: UIControlEventTouchUpInside];
		
		[cell.packItButton addTarget: self
                              action: @selector(toggleThumbnailPackItButton:)
                    forControlEvents: UIControlEventTouchUpInside];
        
        [cell.rockItButton removeTarget: nil
                                 action: @selector(toggleThumbnailRockItButton:)
                       forControlEvents: UIControlEventTouchUpInside];
		
		[cell.rockItButton addTarget: self
                              action: @selector(toggleThumbnailRockItButton:)
                    forControlEvents: UIControlEventTouchUpInside];
        
        [cell.addItButton removeTarget: nil
                                action: @selector(touchThumbnailAddItButton:)
                      forControlEvents: UIControlEventTouchUpInside];
		
		[cell.addItButton addTarget: self
                             action: @selector(touchThumbnailAddItButton:)
                   forControlEvents: UIControlEventTouchUpInside];
        
        return cell;
    }
    else
    {
        Channel *channel = [self.channelFetchedResultsController objectAtIndexPath: indexPath];
        
        SYNChannelThumbnailCell *cell = [cv dequeueReusableCellWithReuseIdentifier: @"ChannelThumbnailCell"
                                                                      forIndexPath: indexPath];
        
        cell.imageView.image = channel.keyframeImage;
        
        cell.maintitle.text = channel.title;
        
        cell.subtitle.text = channel.subtitle;
        
        cell.packItNumber.text = [NSString stringWithFormat: @"%@", channel.totalPacks];
        
        cell.rockItNumber.text = [NSString stringWithFormat: @"%@", channel.totalRocks];
        
        cell.packItButton.selected = channel.packedByUserValue;
        
        cell.rockItButton.selected = channel.rockedByUserValue;
        
        // Wire the Done button up to the correct method in the sign up controller
        [cell.packItButton removeTarget: nil
                                 action: @selector(toggleThumbnailPackItButton:)
                       forControlEvents: UIControlEventTouchUpInside];
        
        [cell.packItButton addTarget: self
                              action: @selector(toggleThumbnailPackItButton:)
                    forControlEvents: UIControlEventTouchUpInside];
        
        [cell.rockItButton removeTarget: nil
                                 action: @selector(toggleThumbnailRockItButton:)
                       forControlEvents: UIControlEventTouchUpInside];
        
        [cell.rockItButton addTarget: self
                              action: @selector(toggleThumbnailRockItButton:)
                    forControlEvents: UIControlEventTouchUpInside];
        
        return cell;
    }
}


- (void) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (cv == self.packedVideoThumbnailCollection)
    {
        Video *video = [self.videoFetchedResultsController objectAtIndexPath: indexPath];
        
        SYNMyRockpackMovieViewController *movieController = [[SYNMyRockpackMovieViewController alloc] initWithVideo: video];
        
        movieController.view.alpha = 0.0f;
        
        [self.navigationController pushViewController: movieController
                                             animated: NO];
        
        [UIView animateWithDuration: 0.5f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^
         {
             // Contract thumbnail view
             self.view.alpha = 0.0f;
             movieController.view.alpha = 1.0f;
             
         }
                         completion: ^(BOOL finished)
         {
         }];
    }
    else
    {
        Channel *channel = [self.channelFetchedResultsController objectAtIndexPath: indexPath];
        
        SYNMyRockpackDetailViewController *channelDetailViewController = [[SYNMyRockpackDetailViewController alloc] initWithChannel: channel];
        
        channelDetailViewController.view.alpha = 0.0f;
        
        [self.navigationController pushViewController: channelDetailViewController
                                             animated: NO];
        
        [UIView animateWithDuration: 0.5f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^
         {
             // Contract thumbnail view
             self.view.alpha = 0.0f;
             channelDetailViewController.view.alpha = 1.0f;
             
         }
                         completion: ^(BOOL finished)
         {
         }];
    }
}


#pragma mark - UI Stuff

- (void) switchChanged: (id)sender
              forEvent: (UIEvent *) event
{
    if (self.toggleSwitch.on == YES)
    {
        // Set packed videos label to light and channel label to dark
        self.packedVideosLabel.textColor = self.darkSwitchColor;
        self.channelLabel.textColor = self.lightSwitchColor;
        self.channelThumbnailCollection.alpha = 0.0f;
        self.channelThumbnailCollection.hidden = FALSE;

        
        [UIView animateWithDuration: kSwitchLabelAnimation
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^
         {
             // Swap collection views
             self.channelThumbnailCollection.alpha = 1.0f;
             self.packedVideoThumbnailCollection.alpha = 0.0f;
         }
                         completion: ^(BOOL finished)
         {
             self.packedVideoThumbnailCollection.hidden = TRUE;
         }];
    }
    else
    {
        // Set packed videos label to dark and channel label to light
        self.packedVideosLabel.textColor = self.lightSwitchColor;
        self.channelLabel.textColor = self.darkSwitchColor;
        self.packedVideoThumbnailCollection.alpha = 0.0f;
        self.packedVideoThumbnailCollection.hidden = FALSE;
        
        
        [UIView animateWithDuration: kSwitchLabelAnimation
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^
         {
             // Swap collection views
             self.channelThumbnailCollection.alpha = 0.0f;
             self.packedVideoThumbnailCollection.alpha = 1.0f;
         }
                         completion: ^(BOOL finished)
         {
             self.channelThumbnailCollection.hidden = TRUE;
         }];
    }
}


- (IBAction) transition: (id) sender
{
    SYNMyRockpackDetailViewController *vc = [[SYNMyRockpackDetailViewController alloc] init];
    
    vc.view.alpha = 0.0f;
    
    [self.navigationController pushViewController: vc
                                         animated: NO];
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         // Contract thumbnail view
         self.view.alpha = 0.0f;
         vc.view.alpha = 1.0f;
         
     }
                     completion: ^(BOOL finished)
     {
     }];
}

- (void) toggleRockItAtIndex: (NSIndexPath *) indexPath
{
    Video *video = [self.videoFetchedResultsController objectAtIndexPath: indexPath];
    
    if (video.rockedByUserValue == TRUE)
    {
        // Currently highlighted, so decrement
        video.rockedByUserValue = FALSE;
        video.totalRocksValue -= 1;
    }
    else
    {
        // Currently highlighted, so increment
        video.rockedByUserValue = TRUE;
        video.totalRocksValue += 1;
    }
    
    [self saveDB];
}


- (void) togglePackItAtIndex: (NSIndexPath *) indexPath
{
    Video *video = [self.videoFetchedResultsController objectAtIndexPath: indexPath];
    
    if (video.packedByUserValue == TRUE)
    {
        // Currently highlighted, so decrement
        video.packedByUserValue = FALSE;
        video.totalPacksValue -= 1;
    }
    else
    {
        // Currently highlighted, so increment
        video.packedByUserValue = TRUE;
        video.totalPacksValue += 1;
    }
    
    [self saveDB];
}


// Buttons activated from scrolling list of thumbnails
- (IBAction) toggleThumbnailRockItButton: (UIButton *) rockItButton
{
    // Get to cell it self (from button subview)
    UIView *v = rockItButton.superview.superview;
    NSIndexPath *indexPath = [self.packedVideoThumbnailCollection indexPathForItemAtPoint: v.center];
    
    // Bail if we don't have an index path
    if (!indexPath)
    {
        return;
    }
    
    [self toggleRockItAtIndex: indexPath];
    
    Video *video = [self.videoFetchedResultsController objectAtIndexPath: indexPath];
    SYNChannelThumbnailCell *cell = (SYNChannelThumbnailCell *)[self.packedVideoThumbnailCollection cellForItemAtIndexPath: indexPath];
    
    cell.rockItButton.selected = video.rockedByUserValue;
    cell.rockItNumber.text = [NSString stringWithFormat: @"%@", video.totalRocks];
}

- (IBAction) toggleThumbnailPackItButton: (UIButton *) packItButton
{
    UIView *v = packItButton.superview.superview;
    NSIndexPath *indexPath = [self.packedVideoThumbnailCollection indexPathForItemAtPoint: v.center];
    
    // Bail if we don't have an index path
    if (!indexPath)
    {
        return;
    }
    
    [self togglePackItAtIndex: indexPath];
    
    // We don't need to update the UI as this cell can only be deselected
    // (Otherwise a race-condition will occur if deleting the last cell)
//    
//    Video *video = [self.videoFetchedResultsController objectAtIndexPath: indexPath];
//    SYNVideoThumbnailCell *cell = (SYNVideoThumbnailCell *)[self.rockedVideoThumbnailCollection cellForItemAtIndexPath: indexPath];
//    
//    cell.packItButton.selected = video.packedByUserValue;
//    cell.packItNumber.text = [NSString stringWithFormat: @"%@", video.totalPacks];
    
//    [self.rockedVideoThumbnailCollection reloadData];
}

@end
