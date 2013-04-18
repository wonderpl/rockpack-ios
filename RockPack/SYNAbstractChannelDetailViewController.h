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

@end
