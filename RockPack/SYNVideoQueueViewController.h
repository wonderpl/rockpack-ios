//
//  SYNVideoQueueViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 25/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SYNVideoQueueDelegate.h"

#import "SYNVideoQueueView.h"

@interface SYNVideoQueueViewController : UIViewController


@property (nonatomic, weak) id <SYNVideoQueueDelegate, UICollectionViewDataSource, UICollectionViewDelegate> delegate;

-(void)setHighlighted:(BOOL)value;

-(SYNVideoQueueView*)videoQueueView;

@end
