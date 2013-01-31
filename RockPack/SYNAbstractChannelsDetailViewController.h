//
//  SYNADetailViewController.h
//  rockpack
//
//  Created by Nick Banks on 04/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

@class Channel;

#import "LXReorderableCollectionViewFlowLayout.h"
#import "SYNAbstractViewController.h"

@interface SYNAbstractChannelsDetailViewController : SYNAbstractViewController <LXReorderableCollectionViewDelegateFlowLayout,
                                                                        UICollectionViewDataSource,
                                                                        UICollectionViewDelegateFlowLayout,
                                                                        UIScrollViewDelegate>


@property (nonatomic, strong) IBOutlet UIButton *editButton;
@property (nonatomic, strong) IBOutlet UIButton *shareButton;
@property (nonatomic, strong) IBOutlet UICollectionView *channelCoverCarouselCollectionView;

@property (nonatomic, strong, readonly) Channel *channel;

- (id) initWithChannel: (Channel *) channel;

@end