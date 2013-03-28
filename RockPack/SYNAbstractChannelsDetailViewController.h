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
@property (nonatomic, strong) IBOutlet UIButton *changeCoverButton;
@property (nonatomic, strong) IBOutlet UIButton *doneButton;
@property (nonatomic, strong) IBOutlet UIButton *editButton;
@property (nonatomic, strong) IBOutlet UIButton *saveButton;
@property (nonatomic, strong) IBOutlet UIButton *shareButton;
@property (nonatomic, strong) IBOutlet UIButton* buyButton;
@property (nonatomic, strong) IBOutlet UIButton* categoryButton;
@property (nonatomic, strong) IBOutlet UIButton* privateButton;
@property (nonatomic, strong) IBOutlet UIButton* publicButton;
@property (nonatomic, strong) IBOutlet UICollectionView *channelCoverCarouselCollectionView;
@property (nonatomic, strong) IBOutlet UIImageView *channelDescriptionHightlightView;
@property (nonatomic, strong) IBOutlet UIImageView *channelTitleHighlightImageView;
@property (nonatomic, strong) IBOutlet UIImageView *channelWallpaperImageView;
@property (nonatomic, strong) IBOutlet UIImageView *userAvatarImageView;
@property (nonatomic, strong) IBOutlet UIImageView* privateImageView;
@property (nonatomic, strong) IBOutlet UILabel *changeCoverLabel;
@property (nonatomic, strong) IBOutlet UILabel *displayNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *saveOrDoneButtonLabel;
@property (nonatomic, strong) IBOutlet UILabel *selectACoverLabel;
@property (nonatomic, strong) IBOutlet UILabel* buyEditLabel;
@property (nonatomic, strong) IBOutlet UILabel* categoryLabel;
@property (nonatomic, strong) IBOutlet UILabel* categoryStaticLabel;
@property (nonatomic, strong) IBOutlet UIView *coverSelectionView;
@property (nonatomic, strong) IBOutlet UIView *headerBarView;
@property (nonatomic, strong) IBOutlet UIView *panelCoverSelectionView;
@property (nonatomic, strong) IBOutlet UIView *slideView;
@property (nonatomic, strong) SYNChannelHeaderView *collectionHeaderView;
@property (nonatomic, strong, readonly) Channel *channel;

- (id) initWithChannel: (Channel *) channel;

- (IBAction) userTouchedChangeCoverButton: (id) sender;
- (void) userTouchedTakePhotoButton;
- (void) userTouchedChooseExistingPhotoButton;
- (void) updateCategoryLabel;

@end