//
//  SYNAccountSettingsPassword.m
//  rockpack
//
//  Created by Michael Michailidis on 21/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAccountSettingsPassword.h"
#import "SYNAppDelegate.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNOAuth2Credential.h"

@interface SYNAccountSettingsPassword ()

@property (nonatomic, strong) UITextField* passwordField;
@property (nonatomic, strong) UITextField* passwordConfirmField;

@end

@implementation SYNAccountSettingsPassword

@synthesize passwordConfirmField, passwordField;

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
    self.inputField.text = @"";
    self.inputField.placeholder = @"Old Password";
    self.inputField.secureTextEntry = YES;
    
    passwordField = [self createInputField];
    passwordField.placeholder = @"New Password";
    passwordField.secureTextEntry = YES;
    [self.view addSubview:passwordField];
    
    passwordConfirmField = [self createInputField];
    passwordConfirmField.secureTextEntry = YES;
    passwordConfirmField.placeholder = @"Confirm Password";
    [self.view addSubview:passwordConfirmField];
	
}


-(void)saveButtonPressed:(UIButton*)button
{
    
    
    if(![self formIsValid]) {
        self.errorLabel.text = @"You Have Entered Invalid Characters";
        return;
    }
    
    if(![passwordField.text isEqualToString:passwordConfirmField.text]) {
        self.errorLabel.text = @"Passwords do not match";
        return;
    }
    
    if([self.inputField.text isEqualToString:passwordField.text]) {
        self.errorLabel.text = @"The new password typed is the same with old";
        return;
    }
    
    SYNAppDelegate* appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.oAuthNetworkEngine changeUserPasswordWithOldValue:self.inputField.text
                                                       andNewValue:passwordField.text
                                                         forUserId:appDelegate.currentUser.uniqueId
                                                 completionHandler:^(id credentialInfo) {
                                                     
                                                     
                        SYNOAuth2Credential* newOAuth2Credentials = [SYNOAuth2Credential credentialWithAccessToken: credentialInfo[@"access_token"]
                                                                                                         expiresIn: credentialInfo[@"expires_in"]
                                                                                                      refreshToken: credentialInfo[@"refresh_token"]
                                                                                                       resourceURL: credentialInfo[@"resource_url"]
                                                                                                         tokenType: credentialInfo[@"token_type"]
                                                                                                            userId: credentialInfo[@"user_id"]];
                                                     
                                                     
                        appDelegate.currentOAuth2Credentials = newOAuth2Credentials;
                                                     
                                                     
                                                     
            [self.navigationController popViewControllerAnimated:YES];
                                                     
                                                     
        
                        } errorHandler:^(id error) {
                            
                            if(![error isKindOfClass:[NSDictionary class]])
                                return;
                            
                            
                            NSString* errorType = [error objectForKey:@"error"];
                            
                            if([errorType isEqualToString:@"invalid_request"])
                            {
                                NSArray* errorMessage = [error objectForKey:@"message"];
                                
                                if(errorMessage.count > 0)
                                {
                                    self.errorLabel.text = (NSString*)[errorMessage objectAtIndex:0];
                                }
                                else
                                {
                                    self.errorLabel.text = @"Could not change password";
                                }
                            }
                            else
                            {
                                self.errorLabel.text = @"Could not change password";
                            }
                            
                            self.saveButton.hidden = NO;
     
    
                        }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
