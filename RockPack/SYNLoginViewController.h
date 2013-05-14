//
//  SYNLoginViewController.h
//  rockpack
//
//  Created by Michael Michailidis on 11/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//


#import "GKImagePicker.h"
#import <UIKit/UIKit.h>
#import "SYNOAuth2Credential.h"
#import "SYNAppDelegate.h"
#import "SYNLoginBaseViewController.h"


@interface SYNLoginViewController : SYNLoginBaseViewController <UIPopoverControllerDelegate, GKImagePickerDelegate>

@property (nonatomic) BOOL facebookLoginIsInProcess;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;

@property (nonatomic, strong) IBOutlet UITextField* userNameInputField;
@property (nonatomic, strong) IBOutlet UITextField* passwordInputField;
@property (nonatomic, strong) IBOutlet UITextField* registeringUserNameInputField;
@property (nonatomic, strong) IBOutlet UITextField* registeringUserEmailInputField;
@property (nonatomic, strong) IBOutlet UITextField* registeringUserPasswordInputField;
@property (nonatomic, strong) IBOutlet UITextField* emailInputField;
@property (nonatomic, strong) IBOutlet UIView* dobView;
@property (nonatomic, strong) IBOutlet UITextField* ddInputField;
@property (nonatomic, strong) IBOutlet UITextField* mmInputField;
@property (nonatomic, strong) IBOutlet UITextField* yyyyInputField;
@property (nonatomic, strong) IBOutlet UILabel* wellSendYouLabel;
@property (nonatomic, strong) IBOutlet UILabel* termsAndConditionsLabel;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* activityIndicator;

@property (nonatomic, strong) IBOutlet UIButton* passwordForgottenButton;

@property (nonatomic, strong) IBOutlet UIImage* avatarImage;

-(void)showAutologinWithCredentials:(SYNOAuth2Credential*)credentials;

-(void)setUpInitialState;



-(IBAction)registerPressed:(id)sender;
-(IBAction)signUp:(id)sender;
-(IBAction)faceButtonImagePressed:(UIButton*)sender;
-(IBAction)forgottenPasswordPressed:(id)sender;
-(IBAction)registerNewUser:(id)sender;
-(IBAction)goToLoginForm:(id)sender;
-(IBAction)signInWithFacebook:(id)sender;
-(IBAction)sendEmailButtonPressed:(id)sender;
- (IBAction) doLogin: (id) sender;

-(BOOL)checkAndSaveRegisteredUser:(SYNOAuth2Credential*)credential;

- (void) showImagePicker: (UIImagePickerControllerSourceType) sourceType;



@end
