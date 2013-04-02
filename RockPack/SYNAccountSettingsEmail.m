//
//  SYNAccountSettingsEmail.m
//  rockpack
//
//  Created by Michael Michailidis on 02/04/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAccountSettingsEmail.h"
#import "SYNOAuthNetworkEngine.h"

@interface SYNAccountSettingsEmail ()

@end

@implementation SYNAccountSettingsEmail

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)saveButtonPressed:(UIButton*)button
{
    
    self.saveButton.enabled = NO;
    [self.spinner startAnimating];
    [self updateEmail];
}


-(void)updateEmail
{
    
    
    [self.appDelegate.oAuthNetworkEngine changeUserField:@"email"
                                                 forUser:self.appDelegate.currentUser
                                       completionHandler:^ {
                                           
                                           self.appDelegate.currentUser.emailAddress = self.inputField.text;
                                           
                                           
                                           [self.appDelegate saveContext:YES];
                                           
                                           [self.navigationController popViewControllerAnimated:YES];
                                           
                                       } errorHandler:^(id object) {
                                           
                                       }];
    
    
}


@end
