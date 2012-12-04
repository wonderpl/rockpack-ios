//
//  SYNChannelsChannelViewController.m
//  rockpack
//
//  Created by Nick Banks on 01/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "Channel.h"
#import "SYNChannelsDetailViewController.h"
#import "SYNChannelHeaderView.h"
#import "UIFont+SYNFont.h"
#import "Video.h"
#import "SYNMyRockpackMovieViewController.h"
#import "SYNVideoThumbnailRegularCell.h"

@interface SYNChannelsDetailViewController ()

@property (nonatomic, strong) Channel *channel;
@property (nonatomic, strong) IBOutlet UICollectionView *videoThumbnailCollectionView;
@property (nonatomic, strong) IBOutlet UIImageView *wallpackImageView;
@property (nonatomic, strong) IBOutlet UILabel *biogBodyLabel;
@property (nonatomic, strong) IBOutlet UILabel *biogTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *userNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *wallpackTitleLabel;
@property (nonatomic, strong) IBOutlet UIView *infoView;
@property (nonatomic, strong) NSArray *biogs;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *videos;

@end

@implementation SYNChannelsDetailViewController

- (id) initWithChannel: (Channel *) channel
{
	
	if ((self = [super init]))
    {
		self.channel = channel;
        self.videos = self.channel.videos.array;
	}
    
	return self;
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.wallpackTitleLabel.font = [UIFont boldRockpackFontOfSize: 28.0f];
    self.biogTitleLabel.font = [UIFont boldRockpackFontOfSize: 24.0f];
    self.biogBodyLabel.font = [UIFont rockpackFontOfSize: 17.0f];
    self.userNameLabel.font = [UIFont boldRockpackFontOfSize: 25.0f];
    
    // Register video thumbnail cell
    UINib *videoThumbnailCellNib = [UINib nibWithNibName: @"SYNVideoThumbnailRegularCell"
                                                  bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: videoThumbnailCellNib
                        forCellWithReuseIdentifier: @"SYNVideoThumbnailRegularCell"];
    
    // Register collection view header view
    UINib *headerViewNib = [UINib nibWithNibName: @"SYNChannelHeaderView"
                                                  bundle: nil];
    
    [self.videoThumbnailCollectionView registerNib: headerViewNib
                        forCellWithReuseIdentifier: @"SYNChannelHeaderView"];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    self.wallpackTitleLabel.text = self.channel.title;
    self.wallpackImageView.image = self.channel.wallpaperImage;
    self.biogTitleLabel.text = self.channel.biogTitle;
    self.biogBodyLabel.text = [NSString stringWithFormat: @"%@\n\n\n", self.channel.biog];
    
    [self.videoThumbnailCollectionView reloadData];
}


#pragma mark - Collection view support

- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    return self.videos.count;
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
    
    Video *video = [self.videos objectAtIndex: indexPath.row];
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
    SYNChannelHeaderView *reusableView = [cv dequeueReusableCellWithReuseIdentifier: @"SYNChannelHeaderView"
                                                                       forIndexPath: indexPath];
    
    return reusableView;
}


- (void) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    Video *video = [self.videos objectAtIndex: indexPath.row];
    
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

@end

