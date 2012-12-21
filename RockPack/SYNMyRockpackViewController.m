//
//  SYNMyRockpackViewController.m
//  rockpack
//
//  Created by Nick Banks on 26/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "Channel.h"
#import "SYNChannelThumbnailCell.h"
#import "SYNMyRockpackChannelDetailViewController.h"
#import "SYNMyRockpackMovieViewController.h"
#import "SYNMyRockpackViewController.h"
#import "SYNSwitch.h"
#import "SYNVideoThumbnailWideCell.h"
#import "UIFont+SYNFont.h"
#import "Video.h"
#import "VideoInstance.h"

@interface SYNMyRockpackViewController () <UICollectionViewDataSource,
                                           UICollectionViewDelegateFlowLayout,
                                           UIScrollViewDelegate>

@property (nonatomic, assign) CGPoint originalOrigin;
@property (nonatomic, strong) IBOutlet SYNSwitch *toggleSwitch;
@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UICollectionView *channelThumbnailCollectionView;
@property (nonatomic, strong) IBOutlet UIImageView *userAvatarImageView;
@property (nonatomic, strong) IBOutlet UILabel *channelLabel;
@property (nonatomic, strong) IBOutlet UILabel *packedVideosLabel;
@property (nonatomic, strong) IBOutlet UILabel *userNameLabel;
@property (nonatomic, strong) IBOutlet UIView *avatarView;
@property (nonatomic, strong) IBOutlet UIView *cardsView;
@property (nonatomic, strong) UIColor *darkSwitchColor;
@property (nonatomic, strong) UIColor *lightSwitchColor;

@end

@implementation SYNMyRockpackViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Add custom slider
    self.toggleSwitch = [[SYNSwitch alloc] initWithFrame: CGRectMake(780, 24 + 44, 95, 42)];
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
    
    self.userNameLabel.font = [UIFont boldRockpackFontOfSize: 25.0f];
    self.packedVideosLabel.font = [UIFont boldRockpackFontOfSize: 15.0f];
    self.channelLabel.font = [UIFont boldRockpackFontOfSize: 15.0f];
    self.userAvatarImageView.image = [UIImage imageNamed: @"EddieTaylor.png"];
    
    // Init collection views
    // Video thumbnails
    UINib *videoThumbnailCellNib = [UINib nibWithNibName: @"SYNVideoThumbnailWideCell"
                                             bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: videoThumbnailCellNib
                          forCellWithReuseIdentifier: @"SYNVideoThumbnailWideCell"];
    
    // Channel thumbnails
    UINib *channelThumbnailCellNib = [UINib nibWithNibName: @"SYNChannelThumbnailCell"
                                             bundle: nil];
    
    [self.channelThumbnailCollectionView registerNib: channelThumbnailCellNib
                          forCellWithReuseIdentifier: @"ChannelThumbnailCell"];
    
    self.channelThumbnailCollectionView.alpha = 0.0f;
    self.channelThumbnailCollectionView.hidden = TRUE;
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];

}


#pragma mark - CoreData support

// The following 4 methods are called by the abstract class' getFetchedResults controller methods
- (NSPredicate *) videoInstanceFetchedResultsControllerPredicate
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(uniqueId == %@) AND (video.starredByUser == TRUE)", @"1"];
    
    return predicate;
//    return [NSPredicate predicateWithFormat: @"video.starredByUser == TRUE"];
}


- (NSArray *) videoInstanceFetchedResultsControllerSortDescriptors
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"title"
                                                                   ascending: YES];
    return @[sortDescriptor];
}


- (NSPredicate *) channelFetchedResultsControllerPredicate
{
    return [NSPredicate predicateWithFormat: @"channelOwner.uniqueId == 666"];
}


- (NSArray *) channelFetchedResultsControllerSortDescriptors
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"title"
                                                                   ascending: YES];
    return @[sortDescriptor];
}


- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{
    if (controller == self.videoInstanceFetchedResultsController)
    {
        [self.videoThumbnailCollectionView reloadData];
    }
    else
    {
        [self.channelThumbnailCollectionView reloadData];
    }
}


#pragma mark - Collection view support

- (NSInteger) collectionView: (UICollectionView *) cv
      numberOfItemsInSection: (NSInteger) section
{
    if (cv == self.videoThumbnailCollectionView)
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.videoInstanceFetchedResultsController sections][section];
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
    if (cv == self.videoThumbnailCollectionView)
    {
        return self.videoInstanceFetchedResultsController.sections.count;
    }
    else
    {
        return self.channelFetchedResultsController.sections.count;
    }
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    // See if this can be handled in our abstract base class
    UICollectionViewCell *cell = [super collectionView: cv
                                cellForItemAtIndexPath: indexPath];
    
    // Do we have a valid cell?
    if (!cell)
    {
        if (cv == self.channelThumbnailCollectionView)
        {
            Channel *channel = [self.channelFetchedResultsController objectAtIndexPath: indexPath];
            
            SYNChannelThumbnailCell *channelCell = [cv dequeueReusableCellWithReuseIdentifier: @"ChannelThumbnailCell"
                                                                          forIndexPath: indexPath];
            
            channelCell.imageView.image = channel.thumbnailImage;
            channelCell.titleLabel.text = channel.title;
            channelCell.rockItNumberLabel.text = [NSString stringWithFormat: @"%@", channel.rockCount];
            channelCell.rockItButton.selected = channel.rockedByUserValue;
            
            // Wire the Done button up to the correct method in the sign up controller
            [channelCell.rockItButton removeTarget: nil
                                     action: @selector(toggleChannelRockItButton:)
                           forControlEvents: UIControlEventTouchUpInside];
            
            [channelCell.rockItButton addTarget: self
                                  action: @selector(toggleChannelRockItButton:)
                        forControlEvents: UIControlEventTouchUpInside];
            
            cell = channelCell;
        }
        else
        {
            AssertOrLog(@"No valid collection view found");
        }
    }
    
    return cell;
}


- (void) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (cv == self.videoThumbnailCollectionView)
    {
        VideoInstance *videoInstance = [self.videoInstanceFetchedResultsController objectAtIndexPath: indexPath];
        
        SYNMyRockpackMovieViewController *movieVC = [[SYNMyRockpackMovieViewController alloc] initWithVideo: videoInstance.video];
        
        [self animatedPushViewController: movieVC];
    }
    else
    {
        Channel *channel = [self.channelFetchedResultsController objectAtIndexPath: indexPath];
        
        SYNMyRockpackChannelDetailViewController *channelDetailVC = [[SYNMyRockpackChannelDetailViewController alloc] initWithChannel: channel];
        

        [self animatedPushViewController: channelDetailVC];
    }
}


#pragma mark - UI Stuff

- (IBAction) userTouchedRockedVideoButton: (id) sender
{
    self.toggleSwitch.on = FALSE;
}

- (IBAction) userTouchedMyChannelsButton: (id) sender
{
    self.toggleSwitch.on = TRUE;
}

- (void) switchChanged: (id)sender
              forEvent: (UIEvent *) event
{
    if (self.toggleSwitch.on == YES)
    {
        // Set packed videos label to light and channel label to dark
        self.packedVideosLabel.textColor = self.darkSwitchColor;
        self.channelLabel.textColor = self.lightSwitchColor;
        self.channelThumbnailCollectionView.alpha = 0.0f;
        self.channelThumbnailCollectionView.hidden = FALSE;

        [UIView animateWithDuration: kSwitchLabelAnimation
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^
         {
             // Swap collection views
             self.channelThumbnailCollectionView.alpha = 1.0f;
             self.videoThumbnailCollectionView.alpha = 0.0f;
         }
                         completion: ^(BOOL finished)
         {
             self.videoThumbnailCollectionView.hidden = TRUE;
         }];
    }
    else
    {
        // Set packed videos label to dark and channel label to light
        self.packedVideosLabel.textColor = self.lightSwitchColor;
        self.channelLabel.textColor = self.darkSwitchColor;
        self.videoThumbnailCollectionView.alpha = 0.0f;
        self.videoThumbnailCollectionView.hidden = FALSE;
        
        
        [UIView animateWithDuration: kSwitchLabelAnimation
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^
         {
             // Swap collection views
             self.channelThumbnailCollectionView.alpha = 0.0f;
             self.videoThumbnailCollectionView.alpha = 1.0f;
         }
                         completion: ^(BOOL finished)
         {
             self.channelThumbnailCollectionView.hidden = TRUE;
         }];
    }
}


- (BOOL) shouldUpdateRockItStatus
{
    return FALSE;
}


// Buttons activated from scrolling list of thumbnails
- (IBAction) toggleChannelRockItButton: (UIButton *) rockItButton
{
    // Get to cell it self (from button subview)
    UIView *v = rockItButton.superview.superview;
    NSIndexPath *indexPath = [self.channelThumbnailCollectionView indexPathForItemAtPoint: v.center];
    
    // Bail if we don't have an index path
    if (!indexPath)
    {
        return;
    }
    
    [self toggleChannelRockItAtIndex: indexPath];
    
    Channel *channel = [self.channelFetchedResultsController objectAtIndexPath: indexPath];
    SYNChannelThumbnailCell *cell = (SYNChannelThumbnailCell *)[self.channelThumbnailCollectionView cellForItemAtIndexPath: indexPath];
    
    cell.rockItButton.selected = channel.rockedByUserValue;
    cell.rockItNumberLabel.text = [NSString stringWithFormat: @"%@", channel.rockCount];
}


- (IBAction) touchVideoShareButton: (UIButton *) addItButton
{
    // TODO: Add share
}

@end
