//
//  SYNAbstractChannelsDetailViewController.m
//  rockpack
//
//  Created by Nick Banks on 17/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAbstractChannelsDetailViewController.h"
#import "Channel.h"
#import "Channel.h"
#import "Video.h"
#import "VideoInstance.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+ImageProcessing.h"
#import "SYNVideoThumbnailRegularCell.h"

@interface SYNAbstractChannelsDetailViewController ()

@property (nonatomic, strong) Channel *channel;
@property (nonatomic, strong) UIImageView *channelCoverImageView;

@end


@implementation SYNAbstractChannelsDetailViewController

- (id) initWithChannel: (Channel *) channel
{
	if ((self = [super initWithNibName: @"SYNAbstractChannelsDetailViewController"
                                bundle: nil]))
    {
		self.channel = channel;
	}
    
	return self;
}


#pragma mark - View lifecyle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
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
    
    // Now add the long-press gesture recognizers to the custom flow layout
    [layout setUpGestureRecognizersOnCollectionView];
    
    // Set wallpaper
    [self.channelCoverImageView setAsynchronousImageFromURL: [NSURL URLWithString: self.channel.wallpaperURL]
                                           placeHolderImage: nil];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    // Refresh our view
    [self.videoThumbnailCollectionView reloadData];
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
    
    NSLog (@"Objects = %@", fetchedResultsController.fetchedObjects);
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
                 layout: (UICollectionViewLayout *) layout
        itemAtIndexPath: (NSIndexPath *) fromIndexPath
    willMoveToIndexPath: (NSIndexPath *) toIndexPath
{
    
    [self saveDB];
}


- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout*) collectionViewLayout
           referenceSizeForHeaderInSection: (NSInteger) section
{
    if (collectionView == self.videoThumbnailCollectionView)
    {
        return CGSizeMake(1024.0f, 463.0f);
    }
    else
    {
        return CGSizeMake(0, 0);
    }
}


@end
