//
//  SYNVideoViewerViewController.h
//  rockpack
//
//  Created by Nick Banks on 23/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAbstractViewController.h"

@class SYNMasterViewController;

@interface SYNVideoViewerViewController : SYNAbstractViewController

- (id) initWithFetchedResultsController: (NSFetchedResultsController *) fetchedResultsController
                      selectedIndexPath: (NSIndexPath *) selectedIndexPath;

@property (nonatomic, strong) IBOutlet UIButton *closeButton;
@property (nonatomic, strong) SYNMasterViewController *overlayParent;

@end
