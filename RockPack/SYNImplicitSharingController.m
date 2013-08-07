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
#import "SYNOAuthNetworkEngine.h"

@interface SYNImplicitSharingController ()

@end

@implementation SYNImplicitSharingController



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
    
    //    ExternalAccount* facebookAccount = appDelegate.currentUser.facebookAccount;
    //    if(facebookAccount)
    //    {
    //
    //    }
    //    else
    //    {
    //
    //    }
    __weak SYNImplicitSharingController* wself = self;
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    __weak SYNAppDelegate* wAppDelegate = appDelegate;
    BOOL isYesButton = (sender == self.yesButton);
    [appDelegate.oAuthNetworkEngine setFlag:@"facebook_autopost_star" withValue:isYesButton
                                   forUseId:appDelegate.currentUser.uniqueId completionHandler:^(id no_response) {
                                       
                                       [wself switchAutopostViewToYes:isYesButton];
                                       
                                       if(isYesButton)
                                           [wAppDelegate.currentUser setFlag:ExternalAccountFlagAutopostStar toExternalAccount:@"facebook"];
                                       else
                                           [wAppDelegate.currentUser unsetFlag:ExternalAccountFlagAutopostStar toExternalAccount:@"facebook"];
                                       
                                       [wAppDelegate saveContext:YES];
                                       
                                   } errorHandler:^(id error) {
                                       
                                       [wself switchAutopostViewToYes:!isYesButton];
                                       
                                   }];
}

-(void)switchAutopostViewToYes:(BOOL)value
{
    self.yesButton.selected = value;
    self.notNowButton.selected = !value;
}

@end
