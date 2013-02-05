//
//  SYNADetailViewController.h
//  rockpack
//
//  Created by Nick Banks on 04/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

@class Channel, HPGrowingTextView, SYNChannelHeaderView, SYNTextField;

#import "LXReorderableCollectionViewFlowLayout.h"
#import "SYNAbstractViewController.h"

@interface SYNAbstractChannelsDetailViewController : SYNAbstractViewController <LXReorderableCollectionViewDelegateFlowLayout,
                                                                        UICollectionViewDataSource,
                                                                        UICollectionViewDelegateFlowLayout,
                                                                        UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet SYNTextField *channelTitleTextField;
@property (nonatomic, strong) IBOutlet UIButton *editButton;
@property (nonatomic, strong) IBOutlet UIButton *shareButton;
@property (nonatomic, strong) IBOutlet UIButton *saveButton;
@property (nonatomic, strong) IBOutlet UIButton *doneButton;
@property (nonatomic, strong) IBOutlet UICollectionView *channelCoverCarouselCollectionView;
@property (nonatomic, strong) IBOutlet UIImageView *channelWallpaperImageView;
@property (nonatomic, strong) IBOutlet UIImageView *userAvatarImageView;
@property (nonatomic, strong) IBOutlet UIImageView *channelTitleHighlightImageView;
@property (nonatomic, strong) IBOutlet UILabel *userNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *saveOrDoneButtonLabel;
@property (nonatomic, strong) NSMutableArray *videoInstancesArray;
@property (nonatomic, strong) SYNChannelHeaderView *collectionHeaderView;
@property (nonatomic, strong, readonly) Channel *channel;

- (id) initWithChannel: (Channel *) channel;

@end