//
//  SYNVideoQueueViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 25/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNVideoQueueDelegate.h"
#import "VideoInstance.h"

@interface SYNVideoQueueViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) id <SYNVideoQueueDelegate> delegate;

- (void) reloadData;

- (void) showVideoQueue: (BOOL) animated;
- (void) hideVideoQueue: (BOOL) animated;

- (void) addVideoToQueue: (VideoInstance *) videoInstance;

-(void) setHighlighted:(BOOL)highlighted;


@end
