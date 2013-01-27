//
//  SYNADetailViewController.m
//  rockpack
//
//  Created by Nick Banks on 04/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "Channel.h"
#import "LXReorderableCollectionViewFlowLayout.h"
#import "SYNChannelsDetailViewController.h"
#import "SYNChannelCollectionBackgroundView.h"
#import "SYNChannelHeaderView.h"
#import "SYNChannelsDetailViewController.h"
#import "SYNMyRockpackMovieViewController.h"
#import "SYNVideoThumbnailRegularCell.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "UIFont+SYNFont.h"
#import "Video.h"
#import "VideoInstance.h"

@interface SYNChannelsDetailViewController ()

@property (nonatomic, assign) BOOL keyboardShown;
@property (nonatomic, strong) Channel *channel;
@property (nonatomic, strong) IBOutlet UICollectionView *videoThumbnailCollectionView;
@property (nonatomic, strong) IBOutlet UIImageView *channelWallpaperImageView;
@property (nonatomic, strong) IBOutlet UITextView *channelDescriptionTextView;
@property (nonatomic, strong) IBOutlet UILabel *userNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *channelTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *videosLabel;
@property (nonatomic, strong) IBOutlet UILabel *followersLabel;
@property (nonatomic, strong) IBOutlet UILabel *videoCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *followersCountLabel;
@property (nonatomic, strong) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *videoInstancesArray;

@end


@implementation SYNChannelsDetailViewController

- (id) initWithChannel: (Channel *) channel
{
	
	if ((self = [super initWithNibName: @"SYNChannelsDetailViewController" bundle: nil]))
    {
		self.channel = channel;
        self.videoInstancesArray = [NSMutableArray arrayWithArray: self.channel.videoInstancesSet.array];
	}
    
	return self;
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Set all the labels to use the custom font
    self.channelTitleLabel.font = [UIFont boldRockpackFontOfSize: 29.0f];
    self.userNameLabel.font = [UIFont rockpackFontOfSize: 17.0f];
    self.videosLabel.font = [UIFont rockpackFontOfSize: 12.0f];
    self.followersLabel.font = [UIFont rockpackFontOfSize: 12.0f];
    self.videoCountLabel.font = [UIFont boldRockpackFontOfSize: 18.0f];
    self.followersCountLabel.font = [UIFont boldRockpackFontOfSize: 18.0f];
    self.channelDescriptionTextView.font = [UIFont rockpackFontOfSize: 15.0f];
    
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
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

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
//    self.biogBodyLabel.text = [NSString stringWithFormat: @"%@\n\n\n", self.channel.channelDescription];
    
    // Refresh our view
    [self.videoThumbnailCollectionView reloadData];
}


#pragma mark - Collection view support

- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    return self.videoInstancesArray.count;
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
    
    VideoInstance *videoInstance = self.videoInstancesArray[indexPath.item];
    cell.imageView.image = videoInstance.video.thumbnailImage;
    cell.titleLabel.text = videoInstance.title;
    cell.subtitleLabel.text = videoInstance.channel.title;
    
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
//    reusableView.titleLabel.text = self.channel.biogTitle;
    reusableView.subtitleLabel.text = [NSString stringWithFormat: @"%@\n\n\n", self.channel.channelDescription];
    
    return reusableView;
}


- (void) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    VideoInstance *videoInstance = self.videoInstancesArray[indexPath.row];
    
    SYNMyRockpackMovieViewController *movieVC = [[SYNMyRockpackMovieViewController alloc] initWithVideo: videoInstance.video];
    
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
    // Actually swap the video thumbnails around in the visible list
    id fromItem = self.videoInstancesArray[fromIndexPath.item];
    id fromObject = self.channel.videoInstances[fromIndexPath.item];
    
    [self.videoInstancesArray removeObjectAtIndex: fromIndexPath.item];
    [self.channel.videoInstancesSet removeObjectAtIndex: fromIndexPath.item];
    
    [self.videoInstancesArray insertObject: fromItem atIndex: toIndexPath.item];
    [self.channel.videoInstancesSet insertObject: fromObject atIndex: toIndexPath.item];
    
    [self saveDB];
}


#pragma mark - Keyboard management

- (void) textViewDidBeginEditing: (UITextView *) textView
{
    [self.scrollView adjustOffsetToIdealIfNeeded];
}
@end