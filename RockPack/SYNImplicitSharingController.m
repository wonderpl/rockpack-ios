//
//  SYNImplicitSharingController.m
//  rockpack
//
//  Created by Michael Michailidis on 06/08/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNImplicitSharingController.h"
#import "UIFont+SYNFont.h"
#import "SYNAppDelegate.h"
#import "SYNFacebookManager.h"
#import "SYNOAuthNetworkEngine.h"

@interface SYNImplicitSharingController ()

@end

@implementation SYNImplicitSharingController

+(id)controllerWithBlock:(ImplicitSharingCompletionBlock)block
{
    SYNImplicitSharingController* instance = [[self alloc] init];
    instance.completionBlock = block;
    return instance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.font = [UIFont rockpackFontOfSize:self.titleLabel.font.pointSize];
    
    self.textLabel.font = [UIFont rockpackFontOfSize:self.textLabel.font.pointSize];
    
    
}

-(IBAction)autopostButtonPressed:(UIButton*)sender
{
    if(sender.selected) // button is pressed twice
        return;
    
    sender.selected = YES;
    
    
    __weak SYNImplicitSharingController* wself = self;
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    __weak SYNAppDelegate* wAppDelegate = appDelegate;
    
    
   
    
    BOOL isYesButton = (sender == self.yesButton);
    if(!isYesButton) // if no button is pressed, dismiss
    {
        // dismiss
        wAppDelegate.currentUser.facebookAccount.noautopostValue = YES; // consider the dismissal as a NO and log it
        [wAppDelegate saveContext: YES];
        return;
    }
    else
    {
        [[SYNFacebookManager sharedFBManager] openSessionWithPermissionType:kFacebookPermissionTypePublish onSuccess:^{
            
            [appDelegate.oAuthNetworkEngine setFlag:@"facebook_autopost_star" withValue:isYesButton
                                           forUseId:appDelegate.currentUser.uniqueId completionHandler:^(id no_response) {
                                               
                                               [wself switchAutopostViewToYes:isYesButton];
                                               
                                               if(isYesButton)
                                                   [wAppDelegate.currentUser setFlag:ExternalAccountFlagAutopostStar toExternalAccount:@"facebook"];
                                               else
                                                   [wAppDelegate.currentUser unsetFlag:ExternalAccountFlagAutopostStar toExternalAccount:@"facebook"];
                                               
                                               [wAppDelegate saveContext:YES];
                                               
                                               if(self.completionBlock)
                                                   self.completionBlock();
                                               
                                               [self dismiss];
                                               
                                           } errorHandler:^(id error) {
                                               
                                               [wself switchAutopostViewToYes:!isYesButton];
                                               
                                           }];
            
        } onFailure:^(NSString *errorMessage) {
            
            [wself switchAutopostViewToYes:!isYesButton];
            
        }];
    }
    
    
    
    
    
    
    
    
    
}

-(void)dismiss
{
    [UIView animateWithDuration:0.3f animations:^{
        self.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        
    }];
}

-(void)switchAutopostViewToYes:(BOOL)value
{
    self.yesButton.selected = value;
    self.notNowButton.selected = !value;
}

@end
