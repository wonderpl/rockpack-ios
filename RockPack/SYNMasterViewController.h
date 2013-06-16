//
//  SYNTopBarViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "GAITrackedViewController.h"
#import "SYNAppDelegate.h"
#import "SYNContainerViewController.h"

#import "SYNAccountSettingsMainTableViewController.h"
#import "SYNAccountSettingsPopoverBackgroundView.h"
#import <UIKit/UIKit.h>

typedef void (^VideoOverlayDismissBlock)(void);

@interface SYNMasterViewController : GAITrackedViewController <UIPopoverControllerDelegate,
                                                                UIGestureRecognizerDelegate>

{
    SYNAppDelegate* appDelegate;
    CGFloat originalAddButtonX;
}


@property (nonatomic, strong) IBOutlet UIView* containerView;
@property (nonatomic, strong) SYNContainerViewController* containerViewController;
@property (nonatomic, strong) SYNAbstractViewController* originViewController;
@property (strong, nonatomic) Reachability *reachability;
@property (nonatomic, readonly) BOOL isInSearchMode;


@property (nonatomic, weak, readonly) SYNAbstractViewController* showingBaseViewController;
@property (nonatomic, weak, readonly) SYNAbstractViewController* showingViewController;

- (id) initWithContainerViewController: (UIViewController*) root;

- (void) addVideoOverlayToViewController: (SYNAbstractViewController *) originViewController
                  withVideoInstanceArray: (NSArray*) videoInstanceArray
                        andSelectedIndex: (int) selectedIndex fromCenter:(CGPoint)centerPoint;

- (void) removeVideoOverlayController;



@end
