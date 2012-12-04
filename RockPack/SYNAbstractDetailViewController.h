//
//  SYNADetailViewController.h
//  rockpack
//
//  Created by Nick Banks on 04/12/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

@class Channel;

#import "SYNAbstractViewController.h"

@interface SYNAbstractDetailViewController : SYNAbstractViewController <UICollectionViewDataSource,
                                                                 UICollectionViewDelegateFlowLayout,
                                                                 UIScrollViewDelegate>
- (id) initWithChannel: (Channel *) channel;

@end