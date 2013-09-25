//
//  SYNSubscriptionsViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 17/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNChannelsRootViewController.h"
#import "Channel.h"
#import "SYNNoChannelsMessageView.h"
#import "SYNYouHeaderView.h"

@interface SYNSubscriptionsViewController : SYNChannelsRootViewController

@property (nonatomic, assign) CGRect viewFrame;
@property (nonatomic, readonly) UICollectionView* channelCollectionView;
@property (nonatomic, strong) SYNNoChannelsMessageView *noChannelsMessage;
@property (nonatomic, weak) ChannelOwner* user;
@property (nonatomic, weak) SYNYouHeaderView* headerView;

@end
