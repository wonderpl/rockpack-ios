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
#import "SYNMyRockpackChannelDetailViewController.h"
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

// The following 4 methods are called by the abstract class' getFetchedResults controller methods
- (NSPredicate *) videoFetchedResultsControllerPredicate
{
    return [NSPredicate predicateWithFormat: @"rockedByUser == TRUE"];
}


- (NSArray *) videoFetchedResultsControllerSortDescriptors
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"title"
                                                                   ascending: YES];
    return @[sortDescriptor];
}


- (NSPredicate *) channelFetchedResultsControllerPredicate
{
    return [NSPredicate predicateWithFormat: @"(rockedByUser == TRUE) AND (userGenerated == TRUE)"];
}


- (NSArray *) channelFetchedResultsControllerSortDescriptors
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"title"
                                                                   ascending: YES];
    return @[sortDescriptor];
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
        
        cell.imageView.image = video.keyframeImage;
        
        cell.maintitle.text = video.title;
        
        cell.subtitle.text = video.subtitle;
        
        cell.rockItNumber.text = [NSString stringWithFormat: @"%@", video.totalRocks];
        
        cell.rockItButton.selected = video.rockedByUserValue;
        
        // Wire the Done button up to the correct method in the sign up controller      
        [cell.rockItButton removeTarget: nil
                                 action: @selector(toggleVideoRockItButton:)
                       forControlEvents: UIControlEventTouchUpInside];
		
		[cell.rockItButton addTarget: self
                              action: @selector(toggleVideoRockItButton:)
                    forControlEvents: UIControlEventTouchUpInside];
        
        [cell.addItButton removeTarget: nil
                                action: @selector(touchVideoShareButton:)
                      forControlEvents: UIControlEventTouchUpInside];
		
		[cell.addItButton addTarget: self
                             action: @selector(touchVideoShareButton:)
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
        
        cell.rockItNumber.text = [NSString stringWithFormat: @"%@", channel.totalRocks];
        
        cell.rockItButton.selected = channel.rockedByUserValue;
        
        // Wire the Done button up to the correct method in the sign up controller       
        [cell.rockItButton removeTarget: nil
                                 action: @selector(toggleChannelRockItButton:)
                       forControlEvents: UIControlEventTouchUpInside];
        
        [cell.rockItButton addTarget: self
                              action: @selector(toggleChannelRockItButton:)
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
        
        SYNMyRockpackMovieViewController *movieVC = [[SYNMyRockpackMovieViewController alloc] initWithVideo: video];
        
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


// Buttons activated from scrolling list of thumbnails
- (IBAction) toggleVideoRockItButton: (UIButton *) rockItButton
{
    // Get to cell it self (from button subview)
    UIView *v = rockItButton.superview.superview;
    NSIndexPath *indexPath = [self.packedVideoThumbnailCollection indexPathForItemAtPoint: v.center];
    
    // Bail if we don't have an index path
    if (!indexPath)
    {
        return;
    }
    
    [self toggleVideoRockItAtIndex: indexPath];
    
    Video *video = [self.videoFetchedResultsController objectAtIndexPath: indexPath];
    SYNVideoThumbnailCell *cell = (SYNVideoThumbnailCell *)[self.packedVideoThumbnailCollection cellForItemAtIndexPath: indexPath];
    
    cell.rockItButton.selected = video.rockedByUserValue;
    cell.rockItNumber.text = [NSString stringWithFormat: @"%@", video.totalRocks];
}


// Buttons activated from scrolling list of thumbnails
- (IBAction) toggleChannelRockItButton: (UIButton *) rockItButton
{
    // Get to cell it self (from button subview)
    UIView *v = rockItButton.superview.superview;
    NSIndexPath *indexPath = [self.channelThumbnailCollection indexPathForItemAtPoint: v.center];
    
    // Bail if we don't have an index path
    if (!indexPath)
    {
        return;
    }
    
    [self toggleChannelRockItAtIndex: indexPath];
    
    Channel *channel = [self.channelFetchedResultsController objectAtIndexPath: indexPath];
    SYNChannelThumbnailCell *cell = (SYNChannelThumbnailCell *)[self.channelThumbnailCollection cellForItemAtIndexPath: indexPath];
    
    cell.rockItButton.selected = channel.rockedByUserValue;
    cell.rockItNumber.text = [NSString stringWithFormat: @"%@", channel.totalRocks];
}


- (IBAction) touchVideoShareButton: (UIButton *) addItButton
{
    // TODO: Add share
}

@end
