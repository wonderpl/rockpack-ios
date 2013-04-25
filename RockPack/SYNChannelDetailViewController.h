//
//  SYNAbstractChannelsDetailViewController.h
//  rockpack
//
//  Created by Nick Banks on 17/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "LXReorderableCollectionViewFlowLayout.h"
#import "SYNAbstractViewController.h"

typedef enum {
    kChannelDetailsModeDisplay = 0,
    kChannelDetailsModeEdit = 1
} kChannelDetailsMode;

@interface SYNChannelDetailViewController : SYNAbstractViewController <LXReorderableCollectionViewDelegateFlowLayout,
                                                                     UICollectionViewDataSource,
                                                                     UICollectionViewDelegateFlowLayout>

- (id) initWithChannel: (Channel *) channel
             usingMode: (kChannelDetailsMode) mode;

@end
