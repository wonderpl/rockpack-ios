//
//  SYNCollectionViewController.h
//  rockpack
//
//  Created by Nick Banks on 24/09/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNTouchGestureRecognizer.h"

typedef void (^TapRecognizedBlock) (UICollectionViewCell *cell);
typedef void (^LongPressRecognizedBlock) (UIGestureRecognizer *recognizer);

@interface SYNCollectionViewController : UICollectionViewController

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) SYNTouchGestureRecognizer *touchGestureRecognizer;
@property (nonatomic, copy) TapRecognizedBlock tapRecognizedBlock;
@property (nonatomic, copy) LongPressRecognizedBlock longPressRecognizedBlock;

@end
