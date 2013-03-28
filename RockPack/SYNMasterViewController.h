//
//  SYNTopBarViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNBottomTabViewController.h"

#import "SYNAppDelegate.h"

@interface SYNMasterViewController : UIViewController <UIPopoverControllerDelegate,
                                                       UITextFieldDelegate,
                                                       UIGestureRecognizerDelegate,
                                                       UITableViewDelegate>
{
    SYNAppDelegate* appDelegate;
}


@property (nonatomic, strong) IBOutlet UIView* containerView;
@property (nonatomic, strong) IBOutlet UIView* overEverythingView;
@property (nonatomic, strong) UIViewController* originViewController;
@property (nonatomic, strong) UIViewController* rootViewController;

- (id) initWithRootViewController: (UIViewController*) root;

- (void) addVideoOverlayToViewController: (UIViewController *) originViewController
            withFetchedResultsController: (NSFetchedResultsController*) fetchedResultsController
                            andIndexPath: (NSIndexPath *) indexPath;

- (void) addCategoryChooserOverlayToViewController: (UIViewController *) originViewController;

- (void) removeVideoOverlayController;

@end
