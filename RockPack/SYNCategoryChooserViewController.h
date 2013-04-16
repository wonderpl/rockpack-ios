//
//  SYNCategoryChooserViewController.h
//  rockpack
//
//  Created by Nick Banks on 28/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "GAITrackedViewController.h"
#import <UIKit/UIKit.h>

@class SYNMasterViewController;

@interface SYNCategoryChooserViewController : GAITrackedViewController

@property (nonatomic, strong) SYNMasterViewController *overlayParent;

@end
