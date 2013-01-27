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
#import <QuartzCore/QuartzCore.h>




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
    
#ifdef 1
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor blackColor];
	
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40, 320, 40)];
    
	textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, 240, 40)];
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 0);
    
	textView.minNumberOfLines = 1;
	textView.maxNumberOfLines = 6;
	textView.returnKeyType = UIReturnKeyGo; //just as an example
	textView.font = [UIFont systemFontOfSize:15.0f];
	textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor blackColor];
    textView.textColor = [UIColor whiteColor];
    
    // textView.text = @"test\n\ntest";
	// textView.animateHeightChange = NO; //turns off animation
    
    [self.view addSubview:containerView];
	
    UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(5, 0, 248, 40);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [containerView addSubview:imageView];
    [containerView addSubview:textView];
    [containerView addSubview:entryImageView];
    
    UIImage *sendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    
	UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	doneBtn.frame = CGRectMake(containerView.frame.size.width - 69, 8, 63, 27);
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	[doneBtn setTitle:@"Done" forState:UIControlStateNormal];
    
    [doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
    doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[doneBtn addTarget:self action:@selector(resignTextView) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
    [doneBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
	[containerView addSubview:doneBtn];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
#endif
    
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
    
//    [[self.channelDescriptionTextView layer] setBorderColor: [[UIColor whiteColor] CGColor]];
//    [[self.channelDescriptionTextView layer] setBorderWidth: 10];
//    [[self.channelDescriptionTextView layer] setCornerRadius: 15];
    
    [self.userNameLabel.layer setBackgroundColor: [[UIColor whiteColor] CGColor]];
    [self.userNameLabel.layer setBorderColor: [[UIColor grayColor] CGColor]];
    [self.userNameLabel.layer setBorderWidth: 1.0];
    [self.userNameLabel.layer setCornerRadius: 8.0f];
    [self.userNameLabel.layer setMasksToBounds: YES];
}
@end