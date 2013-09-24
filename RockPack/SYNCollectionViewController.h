//
//  SYNCollectionViewController.h
//  rockpack
//
//  Created by Nick Banks on 24/09/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNTouchGestureRecognizer.h"

@interface SYNCollectionViewController : UICollectionViewController

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) SYNTouchGestureRecognizer *touchGestureRecognizer;

@end
