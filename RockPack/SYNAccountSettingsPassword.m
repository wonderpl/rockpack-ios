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

@property (nonatomic, strong) SYNPaddedUITextField* passwordField;
@property (nonatomic, strong) SYNPaddedUITextField* passwordConfirmField;

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
    
    self.view.backgroundColor = [UIColor whiteColor];

    self.inputField.text = @"";
    self.inputField.placeholder = NSLocalizedString (@"Old Password", nil);
    self.inputField.secureTextEntry = YES;
    
    passwordField = [self createInputField];
    passwordField.placeholder = NSLocalizedString (@"New Password", nil);
    passwordField.secureTextEntry = YES;
    [self.view addSubview:passwordField];
    
    passwordConfirmField = [self createInputField];
    passwordConfirmField.secureTextEntry = YES;
    passwordConfirmField.placeholder = NSLocalizedString (@"Confirm Password", nil);
    [self.view addSubview:passwordConfirmField];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* backButtonImage = [UIImage imageNamed: @"ButtonAccountBackDefault.png"];
    UIImage* backButtonHighlightedImage = [UIImage imageNamed: @"ButtonAccountBackHighlighted.png"];
    
    
    [backButton setImage: backButtonImage
                forState: UIControlStateNormal];
    
    [backButton setImage: backButtonHighlightedImage
                forState: UIControlStateHighlighted];
    
    [backButton addTarget:self action:@selector(didTapBackButton:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0.0, 0.0, backButtonImage.size.width, backButtonImage.size.height);
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.navigationItem.leftBarButtonItem = backButtonItem;
	
}


-(void)saveButtonPressed:(UIButton*)button
{
    
    if([self.inputField.text isEqualToString:@""] || [self.passwordField isEqual:@""] || [self.passwordConfirmField isEqual:@""]) {
        self.errorLabel.text = NSLocalizedString (@"Please Fill All Fields", nil);
        return;
        
    }
    
    if(![self formIsValid]) {
        self.errorLabel.text = NSLocalizedString (@"You Have Entered Invalid Characters", nil);
        return;
    }
    
    if(![passwordField.text isEqualToString:passwordConfirmField.text]) {
        self.errorLabel.text = NSLocalizedString (@"Passwords do not match", nil);
        return;
    }
    
    if([self.inputField.text isEqualToString:passwordField.text]) {
        self.errorLabel.text = NSLocalizedString (@"The new password typed is the same with old", nil);
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
                                    self.errorLabel.text = (NSString*)errorMessage[0];
                                }
                                else
                                {
                                    self.errorLabel.text = NSLocalizedString (@"Could not change password", nil);
                                }
                            }
                            else
                            {
                                self.errorLabel.text = NSLocalizedString (@"Could not change password", nil);
                            }
                            
                            self.saveButton.hidden = NO;
     
    
                        }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
