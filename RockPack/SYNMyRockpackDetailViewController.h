//
//  SYNMyRockPackViewController.h
//  RockPack
//
//  Created by Nick Banks on 13/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNAbstractViewController.h"

@class Channel;

@interface SYNMyRockpackDetailViewController : SYNAbstractViewController <UICollectionViewDataSource,
                                                                          UICollectionViewDelegateFlowLayout,
                                                                          UIScrollViewDelegate>

- (id) initWithChannel: (Channel *) channel;

@end
