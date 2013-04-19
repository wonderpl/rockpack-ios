//
//  SYNAbstractChannelsDetailViewController.h
//  rockpack
//
//  Created by Nick Banks on 17/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAbstractViewController.h"

#import "LXReorderableCollectionViewFlowLayout.h"

@interface SYNAbstractChannelDetailViewController : SYNAbstractViewController <LXReorderableCollectionViewDelegateFlowLayout,
                                                                                UICollectionViewDataSource,
                                                                                UICollectionViewDelegateFlowLayout>

- (id) initWithChannel: (Channel *) channel;

// There is no elegant way to make properties only available to subclasses, so delare them here has readonly and re-declare in
// the subclasses as readwrite in anonymous categories
@property (nonatomic, strong, readonly) Channel *channel;
@property (nonatomic, strong, readonly) UIButton *shareButton;
@property (nonatomic, strong, readonly) UIButton *buyButton;
@property (nonatomic, strong, readonly) UIImageView *avatarImageView;

@end
