//
//  SYNChannelHeaderView.h
//  rockpack
//
//  Created by Nick Banks on 04/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"

@interface SYNChannelHeaderView : UICollectionReusableView

@property (nonatomic, strong) IBOutlet UILabel *videoCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *videosLabel;
@property (nonatomic, strong) IBOutlet UILabel *followersCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *followersLabel;
@property (nonatomic, strong) IBOutlet HPGrowingTextView *channelDescriptionTextView;

@property (nonatomic, weak) UIViewController *viewControllerDelegate;
@property (nonatomic, strong) UIImageView *channelDescriptionHightlightView;
@property (nonatomic, strong) IBOutlet UIView *channelDescriptionTextContainerView;
@end
