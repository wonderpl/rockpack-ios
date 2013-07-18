//
//  SYNViewStackManager.m
//  rockpack
//
//  Created by Michael Michailidis on 04/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNViewStackManager.h"
#import "SYNAbstractViewController.h"
#import "SYNProfileRootViewController.h"
#import "SYNChannelDetailViewController.h"
#import "SYNSideNavigatorViewController.h"
#import "ChannelOwner.h"
#import "SYNDeviceManager.h"
#import "SYNMasterViewController.h"

@implementation SYNViewStackManager



+(id)manager
{
    return [[self alloc] init];
}

#pragma mark - Specific Views Methods

- (void) viewProfileDetails: (ChannelOwner *) channelOwner
{
    if(!channelOwner)
        return;
    
    SYNProfileRootViewController *profileVC =
    (SYNProfileRootViewController*)[self topControllerMatchingTypeString:NSStringFromClass([SYNProfileRootViewController class])];
    
    if(profileVC)
    {
        
        [self popToController:profileVC];
        
    }
    else
    {
        profileVC = [[SYNProfileRootViewController alloc] initWithViewId:kProfileViewId];
        
        [self pushController:profileVC];
        
    }
    
    
    profileVC.user = channelOwner;
    
    [self hideSideNavigator];
    
}

- (void) viewChannelDetails: (Channel*) channel
{
    
    [self viewChannelDetails:channel withAutoplayId:nil];
    
}

-(void)viewChannelDetails: (Channel*) channel withAutoplayId:(NSString*)autoplayId
{
    
    if(!channel)
        return;
    
    SYNChannelDetailViewController *channelVC =
    (SYNChannelDetailViewController*)[self topControllerMatchingTypeString:NSStringFromClass([SYNChannelDetailViewController class])];
    
    if(channelVC)
    {
        channelVC.channel = channel;
        channelVC.autoplayVideoId = autoplayId;
        [self popToController:channelVC];
        
    }
    else
    {
        channelVC = [[SYNChannelDetailViewController alloc] initWithChannel: channel
                                                                  usingMode: kChannelDetailsModeDisplay];
        
        channelVC.autoplayVideoId = autoplayId;
        [self pushController:channelVC];
        
    }
    
    [self hideSideNavigator];
    
}

#pragma mark - Navigation Controller Methods

-(void)pushController:(SYNAbstractViewController*)controller
{
    
    
    controller.view.alpha = 0.0f;
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations: ^ {
                         // Contract thumbnail view
                         self.navigationController.topViewController.view.alpha = 0.0;
                         controller.view.alpha = 1.0f;
                     }
                     completion:nil];
    
    
    [self.navigationController pushViewController:controller animated: NO];
    
    [self hideSideNavigator];
    
}
-(void)popController
{
    NSInteger viewControllersCount = self.navigationController.viewControllers.count;
    
    if (viewControllersCount < 2) // we must have at least two to pop one
        return;
    
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         
                         self.navigationController.topViewController.view.alpha = 0.0f;
                         // pick the previous view controller
                         ((UIViewController*)self.navigationController.viewControllers[viewControllersCount - 2]).view.alpha = 1.0f;
                         
                     } completion:nil];
    
    [self.navigationController popViewControllerAnimated:NO];
    
    [self hideSideNavigator];
    
}

-(void)popToRootController
{
    [self popToController:self.navigationController.viewControllers[0]];
}

-(void)popToController:(UIViewController*)controller
{
    NSInteger viewControllersCount = self.navigationController.viewControllers.count;
    
    // we must have at least two to pop one and the controller must be contained in the navigation view stack
    if (viewControllersCount < 2 || ![self.navigationController.viewControllers containsObject:controller])
        return;
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         
                         self.navigationController.topViewController.view.alpha = 0.0f;
                         
                         controller.view.alpha = 1.0f;
                         
                     } completion:nil];
    
    [self.navigationController popToViewController:controller animated:NO];
    
    [self hideSideNavigator];
}

-(void)hideSideNavigator
{
    self.sideNavigatorController.state = SideNavigationStateHidden;
}

-(void)presentModallyController:(UIViewController*)controller
{
    modalViewController = controller;
    
    [self.masterController addChildViewController:controller];
    [self.masterController.view addSubview:controller.view];
    
    CGRect controllerFrame = controller.view.frame;
    
    controllerFrame.origin.y = [[SYNDeviceManager sharedInstance] currentScreenHeight];
    
    
    controller.view.frame = controllerFrame;
    
    controllerFrame.origin.y = 0.0f;
    
    [UIView animateWithDuration:0.3 delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.masterController.view.userInteractionEnabled = NO;
                         controller.view.frame = controllerFrame;
                         
                     } completion:^(BOOL finished) {
                         self.masterController.view.userInteractionEnabled = YES;
                     }];
}

-(void)hideModallyController
{
    
    CGRect controllerFrame = modalViewController.view.frame;
    controllerFrame.origin.y = [[SYNDeviceManager sharedInstance] currentScreenHeight];
    
    [UIView animateWithDuration:0.3 delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         modalViewController.view.frame = controllerFrame;
                         
                         self.masterController.view.userInteractionEnabled = NO;

                         
                     } completion:^(BOOL finished) {
                         
                         self.masterController.view.userInteractionEnabled = YES;
                         [modalViewController.view removeFromSuperview];
                         [modalViewController removeFromParentViewController];
                         
                     }];
}

#pragma mark - Helper

- (UIViewController*) topControllerMatchingTypeString:(NSString*)classString
{
    UIViewController* lastControllerOfClass;
    for (UIViewController* viewControllerOnStack in self.navigationController.viewControllers)
        if ([viewControllerOnStack isKindOfClass:NSClassFromString(classString)])
            lastControllerOfClass = viewControllerOnStack;
    
    return lastControllerOfClass;
}

@end
