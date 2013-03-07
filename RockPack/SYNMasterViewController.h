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

@interface SYNMasterViewController : UIViewController <UIPopoverControllerDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UITableViewDelegate> {
    SYNAppDelegate* appDelegate;
}

@property (nonatomic, strong) UIViewController* rootViewController;


-(id)initWithRootViewController:(UIViewController*)root;

-(void)addOverlay:(UIView*)view;
-(void)removeOverlay;

@property (nonatomic, strong) IBOutlet UIView* containerView;

@end
