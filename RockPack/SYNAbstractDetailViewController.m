//
//  SYNADetailViewController.m
//  rockpack
//
//  Created by Nick Banks on 04/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "Channel.h"
#import "LXReorderableCollectionViewFlowLayout.h"
#import "SYNAbstractDetailViewController.h"
#import "SYNChannelCollectionBackgroundView.h"
#import "SYNChannelHeaderView.h"
#import "SYNChannelsDetailViewController.h"
#import "SYNMyRockpackMovieViewController.h"
#import "SYNVideoThumbnailRegularCell.h"
#import "UIFont+SYNFont.h"
#import "Video.h"

@interface SYNAbstractDetailViewController ()

@property (nonatomic, strong) Channel *channel;
@property (nonatomic, strong) IBOutlet UICollectionView *videoThumbnailCollectionView;
@property (nonatomic, strong) IBOutlet UIImageView *channelWallpaperImageView;
@property (nonatomic, strong) IBOutlet UILabel *biogBodyLabel;
@property (nonatomic, strong) IBOutlet UILabel *biogTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *userNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *channelTitleLabel;
@property (nonatomic, strong) NSMutableArray *videosArray;

@end


@implementation SYNAbstractDetailViewController

- (id) initWithChannel: (Channel *) channel
{
	
	if ((self = [super initWithNibName: @"SYNAbstractDetailViewController" bundle: nil]))
    {
		self.channel = channel;
        self.videosArray = [NSMutableArray arrayWithArray: self.channel.videos.array];
	}
    
	return self;
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Set all the labels to use the custom font
    self.channelTitleLabel.font = [UIFont boldRockpackFontOfSize: 29.0f];
    self.userNameLabel.font = [UIFont rockpackFontOfSize: 17.0f];
    self.biogTitleLabel.font = [UIFont boldRockpackFontOfSize: 24.0f];
    self.biogBodyLabel.font = [UIFont rockpackFontOfSize: 17.0f];
    
    
    // Register video thumbnail cell
    UINib *videoThumbnailCellNib = [UINib nibWithNibName: @"SYNVideoThumbnailRegularCell"
                                                  bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: videoThumbnailCellNib
                        forCellWithReuseIdentifier: @"SYNVideoThumbnailRegularCell"];
    
    // Register collection view header view
    UINib *headerViewNib = [UINib nibWithNibName: @"SYNChannelHeaderView"
                                          bundle: nil];
    
     [self.videoThumbnailCollectionView registerNib: headerViewNib
                         forSupplementaryViewOfKind: UICollectionElementKindSectionHeader
                                withReuseIdentifier: @"SYNChannelHeaderView"];
    
    // Add a custom flow layout to our thumbail collection view (with the right size and spacing)
    LXReorderableCollectionViewFlowLayout *layout = [[LXReorderableCollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(256.0f , 193.0f);
    layout.minimumInteritemSpacing = 0.0f;
    layout.minimumLineSpacing = 0.0f;
#ifdef USE_DECORATION_VIEWS
    [layout registerClass: [SYNChannelCollectionBackgroundView class]  forDecorationViewOfKind: @"SemiOpaqueBackground"];
#endif
    self.videoThumbnailCollectionView.collectionViewLayout = layout;
    
    // Now add the long-press gesture recognizers to the custom flow layout
    [layout setUpGestureRecognizersOnCollectionView];

}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    // Set all labels and images to correspond to the selected channel
    self.channelTitleLabel.text = self.channel.title;
    self.channelWallpaperImageView.image = self.channel.wallpaperImage;
    self.biogTitleLabel.text = self.channel.biogTitle;
    self.biogBodyLabel.text = [NSString stringWithFormat: @"%@\n\n\n", self.channel.biog];
    
    // Refresh our view
    [self.videoThumbnailCollectionView reloadData];
}


#pragma mark - Collection view support

- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    return self.videosArray.count;
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) cv
{
    return 1;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNVideoThumbnailRegularCell *cell = [cv dequeueReusableCellWithReuseIdentifier: @"SYNVideoThumbnailRegularCell"
                                                                       forIndexPath: indexPath];
    
    Video *video = [self.videosArray objectAtIndex: indexPath.item];
    cell.imageView.image = video.keyframeImage;
    cell.titleLabel.text = video.title;
    cell.subtitleLabel.text = video.subtitle;
    
    return cell;
}


// Used for the collection view header
- (UICollectionReusableView *) collectionView: (UICollectionView *) cv
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
    SYNChannelHeaderView *reusableView = [cv dequeueReusableSupplementaryViewOfKind: kind
                                                                withReuseIdentifier: @"SYNChannelHeaderView"
                                                                       forIndexPath: indexPath];
    reusableView.titleLabel.text = self.channel.biogTitle;
    reusableView.subtitleLabel.text = [NSString stringWithFormat: @"%@\n\n\n", self.channel.biog];
    
    return reusableView;
}


- (void) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    Video *video = [self.videosArray objectAtIndex: indexPath.row];
    
    SYNMyRockpackMovieViewController *movieVC = [[SYNMyRockpackMovieViewController alloc] initWithVideo: video];
    
    [self animatedPushViewController: movieVC];
    
}

- (CGSize) collectionView: (UICollectionView *) cv
                   layout: (UICollectionViewLayout*) cvLayout
                   referenceSizeForHeaderInSection: (NSInteger) section
{
    if (section == 0)
    {
        return CGSizeMake(0, 372);
    }
    
    return CGSizeZero;
}

- (void) collectionView: (UICollectionView *) cv
                 layout: (UICollectionViewLayout *) layout
        itemAtIndexPath: (NSIndexPath *) fromIndexPath
    willMoveToIndexPath: (NSIndexPath *) toIndexPath
{
    NSLog (@"Moving");

    // Actually swap the video thumbnails around in the visible list
    id fromItem = [self.videosArray objectAtIndex: fromIndexPath.item];
    id fromObject = [self.channel.videosSet objectAtIndex: fromIndexPath.item];
    
    [self.videosArray removeObjectAtIndex: fromIndexPath.item];
    [self.channel.videosSet removeObjectAtIndex: fromIndexPath.item];
    
    [self.videosArray insertObject: fromItem atIndex: toIndexPath.item];
    [self.channel.videosSet insertObject: fromObject atIndex: toIndexPath.item];
    
    [self saveDB];
}

@end