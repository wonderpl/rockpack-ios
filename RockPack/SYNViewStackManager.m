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

@implementation SYNViewStackManager

#pragma mark - NavigationController Methods

+(id)manager
{
    return [[self alloc] init];
}

- (UIViewController*) topControllerMatchingTypeString:(NSString*)classString
{
    UIViewController* lastControllerOfClass;
    for (UIViewController* viewControllerOnStack in self.navigationController.viewControllers)
    {
        if ([viewControllerOnStack isKindOfClass:NSClassFromString(classString)])
        {
            lastControllerOfClass = viewControllerOnStack;
        }
    }
    return lastControllerOfClass;
}

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
    
    self.sideNavigatorController.state = SideNavigationStateHidden;
    
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
    
    self.sideNavigatorController.state = SideNavigationStateHidden;
    
}


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
                     completion:^(BOOL finished) {
                         //controllerself.isAnimating = NO;
                         
                     }];
    
    
    [self.navigationController pushViewController:controller animated: NO];
    
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
                         
                     } completion: ^(BOOL finished) {
                         
                     }];
    
    [self.navigationController popViewControllerAnimated:NO];
    
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
                         
                     } completion: ^(BOOL finished) {
                         
                     }];
    
    [self.navigationController popToViewController:controller animated:NO];
}


-(void)popToRootController
{
    [self popToController:self.navigationController.viewControllers[0]];
}

@end
