//
//  SYNTopBarViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "GAITrackedViewController.h"
#import "SYNAppDelegate.h"
#import "SYNContainerViewController.h"
#import <UIKit/UIKit.h>


@interface SYNMasterViewController : GAITrackedViewController <UIPopoverControllerDelegate,
                                                                UIGestureRecognizerDelegate>

{
    SYNAppDelegate* appDelegate;
    CGFloat originalAddButtonX;
}


@property (nonatomic, strong) IBOutlet UIView* containerView;
@property (nonatomic, strong) IBOutlet UIView* overEverythingView;
@property (nonatomic, strong) UIViewController* originViewController;
@property (nonatomic, strong) SYNContainerViewController* containerViewController;

- (id) initWithContainerViewController: (UIViewController*) root;

- (void) addVideoOverlayToViewController: (UIViewController *) originViewController
            withFetchedResultsController: (NSFetchedResultsController*) fetchedResultsController
                            andIndexPath: (NSIndexPath *) indexPath;

- (void) addCategoryChooserOverlayToViewController: (UIViewController *) originViewController;

- (void) removeVideoOverlayController;
- (void) removeCategoryChooserOverlayController;

@end
