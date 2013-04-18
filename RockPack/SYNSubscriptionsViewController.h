//
//  SYNSubscriptionsViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 17/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNChannelsRootViewController.h"
#import "Channel.h"

@interface SYNSubscriptionsViewController : SYNChannelsRootViewController

@property (nonatomic, readonly) UICollectionView* collectionView;

-(void)setViewFrame:(CGRect)frame;
-(Channel*)channelAtIndexPath:(NSIndexPath*)indexPath;

@end
