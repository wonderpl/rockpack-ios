//
//  SYNAbstractChannelsDetailViewController.m
//  rockpack
//
//  Created by Nick Banks on 17/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "Channel.h"
#import "SYNChannelDetailViewController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNVideoThumbnailRegularCell.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+ImageProcessing.h"
#import "Video.h"
#import "VideoInstance.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNChannelDetailViewController ()

@property (nonatomic, strong) IBOutlet UIImageView *channelCoverImageView;
@property (nonatomic, strong) Channel *channel;
@property (nonatomic, strong) IBOutlet UIButton *shareButton;
@property (nonatomic, strong) IBOutlet UIButton *buyButton;
@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet UITextView *channelTitleTextView;
@property (nonatomic, strong) IBOutlet UIView *displayControlsView;
@property (nonatomic, strong) IBOutlet UIView *editControlsView;
@property (nonatomic, strong) IBOutlet UILabel *channelOwnerLabel;
@property (nonatomic, strong) IBOutlet UILabel *channelDetailsLabel;

@end


@implementation SYNChannelDetailViewController

- (id) initWithChannel: (Channel *) channel
{
//	if ((self = [super initWithNibName: @"SYNAbstractChannelDetailViewController"
//                                bundle: nil]))
    if ((self = [super init]))
    {
		self.channel = channel;
	}
    {
		self.channel = channel;
	}
    
	return self;
}


#pragma mark - View lifecyle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Google Analytics support
    self.trackedViewName = @"Channels - Detail";
    
    // Add a custom flow layout to our thumbail collection view (with the right size and spacing)
    LXReorderableCollectionViewFlowLayout *layout = [[LXReorderableCollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(256.0f , 179.0f);
    layout.minimumInteritemSpacing = 0.0f;
    layout.minimumLineSpacing = 0.0f;
    
    self.videoThumbnailCollectionView.collectionViewLayout = layout;
    
    // Regster video thumbnail cell
    UINib *videoThumbnailCellNib = [UINib nibWithNibName: @"SYNVideoThumbnailRegularCell"
                                                  bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: videoThumbnailCellNib
                        forCellWithReuseIdentifier: @"SYNVideoThumbnailRegularCell"];
    
    // Set wallpaper
    [self.channelCoverImageView setAsynchronousImageFromURL: [NSURL URLWithString: self.channel.wallpaperURL]
                                           placeHolderImage: nil];
    
    // Add Rockpack font and shadow to UITextView
    // Originally the opacity was required to be 0.25f, but this appears less visible on the actual screen
    CALayer *textLayer = self.channelTitleTextView.layer;
    textLayer.shadowColor = [UIColor blackColor].CGColor;
    textLayer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    textLayer.shadowOpacity = 0.5f;
    textLayer.shadowRadius = 2.0f;
    
    // Needed for shadows to work
    self.channelTitleTextView.backgroundColor = [UIColor clearColor];
    
    // Set wallpaper
    [self.avatarImageView setAsynchronousImageFromURL: [NSURL URLWithString: self.channel.channelOwner.thumbnailURL]
                                     placeHolderImage: nil];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(reloadCollectionViews)
                                                 name: kDataUpdated
                                               object: nil];
    
    // FIXME: Move out to subclass is there is a distinct display view, overridden by edit subclass
    [self setDisplayControlsVisibility: TRUE];
    
    // Refresh our view
    [self.videoThumbnailCollectionView reloadData];
    
    if ([self.channel.resourceURL hasPrefix: @"https"])
    {
        [appDelegate.oAuthNetworkEngine updateChannel: self.channel.resourceURL];
    }
    else
    {
        [appDelegate.networkEngine updateChannel: self.channel.resourceURL];
    }
}


- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kDataUpdated
                                                  object: nil];
}


- (void) reloadCollectionViews
{
    [self.videoThumbnailCollectionView reloadData];
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *) fetchedResultsController
{
    
    
    if (fetchedResultsController)
        return fetchedResultsController;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    
    fetchRequest.entity = [NSEntityDescription entityForName: @"VideoInstance"
                                      inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat: @"channel.uniqueId == \"%@\"", self.channel.uniqueId]];
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"position" ascending: YES]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                        managedObjectContext: appDelegate.mainManagedObjectContext
                                                                          sectionNameKeyPath: nil
                                                                                   cacheName: nil];
    fetchedResultsController.delegate = self;
    
    
    NSError *error = nil;
    ZAssert([fetchedResultsController performFetch: &error], @"Channels Details Failed: %@\n%@", [error localizedDescription], [error userInfo]);
    
    return fetchedResultsController;
}


#pragma mark - Collection view support

- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger) section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    DebugLog (@"Objects %d", sectionInfo.numberOfObjects);
    return sectionInfo.numberOfObjects;
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    UICollectionViewCell *cell = nil;
    
    SYNVideoThumbnailRegularCell *videoThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNVideoThumbnailRegularCell"
                                                                                                 forIndexPath: indexPath];
    
    VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
    videoThumbnailCell.videoImageViewImage = videoInstance.video.thumbnailURL;
    videoThumbnailCell.titleLabel.text = videoInstance.title;
    
    cell = videoThumbnailCell;
    
    return cell;
}


- (void) collectionView: (UICollectionView *) collectionView
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
        // Display the video viewer
        [self displayVideoViewerWithSelectedIndexPath: indexPath];
}


- (void) collectionView: (UICollectionView *) collectionView
        itemAtIndexPath: (NSIndexPath *) fromIndexPath
    willMoveToIndexPath: (NSIndexPath *)toIndexPath
{
    [self saveDB];
}

- (void) setDisplayControlsVisibility: (BOOL) visible
{
    // Support for different appearances / functionality of textview
    self.channelTitleTextView.textColor = (visible) ? [UIColor whiteColor] : [UIColor blackColor];
    self.channelTitleTextView.userInteractionEnabled = (visible) ? NO : YES;

    self.displayControlsView.alpha = (visible) ? 1.0f : 0.0f;
    self.editControlsView.alpha = (visible) ? 0.0f : 1.0f;
}


// For edit controls just do the inverse of details control
- (void) setEditControlsVisibility: (BOOL) visible
{
    [self setDisplayControlsVisibility: !visible];
}


- (void) enterEditMode
{
    [UIView animateWithDuration: kChannelEditModeAnimationDuration
                     animations: ^{
                         [self setEditControlsVisibility: TRUE];
                     }
                     completion: nil];
}


- (void) leaveEditMode
{
    [UIView animateWithDuration: kChannelEditModeAnimationDuration
                     animations: ^{
                         [self setDisplayControlsVisibility: TRUE];
                     }
                     completion: nil];
}

#pragma mark - Share

- (void) shareChannelButtonTapped: (id) sender
{
    NSString *messageString = kChannelShareMessage;
    
    //  TODO: Put in cover art image?
    //  UIImage *messageImage = [UIImage imageNamed: @"xyz.png"];
    
    // TODO: Put in real link
    NSURL *messageURL = [NSURL URLWithString: @"http://www.rockpack.com"];
    
    [self shareURL: messageURL
       withMessage: messageString
          fromRect: self.shareButton.frame
   arrowDirections: UIPopoverArrowDirectionUp];
}


@end
