//
//  SYNSubscriptionsViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 17/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNChannelsRootViewController.h"
#import "Channel.h"
#import "SYNYouHeaderView.h"


@interface SYNSubscriptionsViewController : SYNChannelsRootViewController

@property (nonatomic, readonly) UICollectionView* collectionView;
@property (nonatomic, weak) SYNYouHeaderView* headerView;

@property (nonatomic, weak) ChannelOwner* user;

- (void) setViewFrame: (CGRect) frame;

@end
