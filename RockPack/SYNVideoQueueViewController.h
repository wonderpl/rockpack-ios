//
//  SYNVideoQueueViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 25/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "Channel.h"
#import "GAITrackedViewController.h"
#import "SYNVideoQueueDelegate.h"
#import "Video.h"
#import "VideoInstance.h"
#import <UIKit/UIKit.h>

@interface SYNVideoQueueViewController : GAITrackedViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) id <SYNVideoQueueDelegate> delegate;
@property (nonatomic) BOOL locked;

- (void) reloadData;

- (void) showVideoQueue: (BOOL) animated;
- (void) hideVideoQueue: (BOOL) animated;

- (void) addVideoToQueue: (VideoInstance *) videoInstance;

-(void) setHighlighted:(BOOL)highlighted;
-(Channel*)getChannelFromCurrentQueue;

@end
