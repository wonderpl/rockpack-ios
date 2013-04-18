//
//  SYNLoginViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 11/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "RegexKitLite.h"
#import "SYNActivityManager.h"
#import "SYNAppDelegate.h"
#import "SYNFacebookManager.h"
#import "SYNLoginErrorArrow.h"
#import "SYNLoginViewController.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuth2Credential.h"
#import "SYNOAuthNetworkEngine.h"
#import "UIFont+SYNFont.h"
#import "User.h"
#import "SYNCameraPopoverViewController.h"
#import "SYNAutocompletePopoverBackgroundView.h"
#import <FacebookSDK/FacebookSDK.h>

@interface SYNLoginViewController ()  <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIButton* facebookSignInButton;
@property (nonatomic, strong) IBOutlet UIButton* signUpButton;

@property (nonatomic, strong) IBOutlet UIButton* loginButton;

@property (nonatomic, strong) IBOutlet UIButton* finalLoginButton;

@property (nonatomic, strong) IBOutlet UIButton* passwordForgottenButton;

@property (nonatomic, strong) IBOutlet UIButton* sendEmailButton;


@property (nonatomic, strong) IBOutlet UIButton* registerButton;

@property (nonatomic, strong) IBOutlet UIImageView* dividerImageView;

@property (nonatomic, strong) IBOutlet UIButton* faceImageButton;

@property (nonatomic, strong) IBOutlet UILabel* secondaryFacebookMessage;
@property (nonatomic, strong) IBOutlet UILabel* facebookLogingInLabel;


@property (nonatomic, strong) NSMutableDictionary* labelsToErrorArrows;

@property (nonatomic, strong) IBOutlet UITextField* userNameInputField;
@property (nonatomic, strong) IBOutlet UITextField* passwordInputField;
@property (nonatomic, strong) IBOutlet UITextField* emailInputField;
@property (nonatomic, strong) IBOutlet UIView* dobView;
@property (nonatomic, strong) IBOutlet UITextField* ddInputField;
@property (nonatomic, strong) IBOutlet UITextField* mmInputField;
@property (nonatomic, strong) IBOutlet UITextField* yyyyInputField;
@property (nonatomic, strong) IBOutlet UILabel* wellSendYouLabel;

@property (nonatomic, strong) IBOutlet UIImageView* titleImageView;

@property (nonatomic, strong) IBOutlet UILabel* passwordForgottenLabel;
@property (nonatomic, strong) IBOutlet UIButton* registerNewUserButton;

@property (nonatomic, strong) UIPopoverController* cameraMenuPopoverController;
@property (nonatomic, strong) UIPopoverController* cameraPopoverController;
@property (nonatomic, strong) GKImagePicker* imagePicker;

@property (nonatomic, strong) IBOutlet UILabel* areYouNewLabel;
@property (nonatomic, strong) IBOutlet UILabel* memberLabel;

@property (nonatomic, strong) IBOutlet UILabel* termsAndConditionsLabel;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* activityIndicator;

@property (nonatomic) CGRect facebookButtonInitialFrame;
@property (nonatomic) CGRect signUpButtonInitialFrame;
@property (nonatomic) CGRect initialUsernameFrame;

@property (nonatomic) BOOL isAnimating;

@property (nonatomic, weak) SYNAppDelegate* appDelegate;



@end


#define kOffsetForLoginForm 285.0
#define kOffsetForRegisterForm 100.0

@implementation SYNLoginViewController

@synthesize state;
@synthesize appDelegate;
@synthesize signUpButton, facebookSignInButton;
@synthesize loginButton, finalLoginButton, passwordInputField, registerButton, userNameInputField;
@synthesize facebookLogingInLabel;
@synthesize passwordForgottenButton, passwordForgottenLabel, areYouNewLabel, memberLabel, termsAndConditionsLabel;
@synthesize activityIndicator, dividerImageView, secondaryFacebookMessage;
@synthesize isAnimating;
@synthesize emailInputField, dobView, registerNewUserButton;
@synthesize titleImageView;
@synthesize ddInputField, mmInputField, yyyyInputField;
@synthesize labelsToErrorArrows;
@synthesize faceImageButton, facebookButtonInitialFrame, signUpButtonInitialFrame;
@synthesize sendEmailButton;
@synthesize wellSendYouLabel;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Google Analytics support
    self.trackedViewName = @"Login";
    
    // set up controls
    
    appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
    activityIndicator.hidesWhenStopped = YES;
    
    
    
    // == Setup Fonts for labels (except Input Fields)
    
    UIFont* rockpackBigLabelFont = [UIFont rockpackFontOfSize:20];
    
    memberLabel.font = rockpackBigLabelFont;
    areYouNewLabel.font = rockpackBigLabelFont;
    
    passwordForgottenLabel.font = [UIFont rockpackFontOfSize:14];
    secondaryFacebookMessage.font = [UIFont rockpackFontOfSize:20];
    facebookLogingInLabel.font = [UIFont boldRockpackFontOfSize:22];
    termsAndConditionsLabel.font = [UIFont rockpackFontOfSize:14.0];
    
    NSMutableAttributedString* termsString = [[NSMutableAttributedString alloc] initWithString:@"BY USING ROCKPACK, YOU AGREE TO OUR TERMS & SERVICES AND PRIVACY POLICY"];
    
    
    [termsString addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:(32.0/255.0) green:(195.0/255.0) blue:(226.0/255.0) alpha:(1.0)] range: NSMakeRange(32, 20)];
    [termsString addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:(32.0/255.0) green:(195.0/255.0) blue:(226.0/255.0) alpha:(1.0)] range: NSMakeRange(57, 14)];
    
    // add terms buttons
    
    termsAndConditionsLabel.attributedText = termsString;
    
    labelsToErrorArrows = [[NSMutableDictionary alloc] init];
    
    ddInputField.keyboardType = UIKeyboardTypeNumberPad;
    mmInputField.keyboardType = UIKeyboardTypeNumberPad;
    yyyyInputField.keyboardType = UIKeyboardTypeNumberPad;
    
    passwordInputField.secureTextEntry = YES;
    
    facebookButtonInitialFrame = facebookSignInButton.frame;
    signUpButtonInitialFrame = signUpButton.frame;
    
    emailInputField.keyboardType = UIKeyboardTypeEmailAddress;
    
    // == Setup Input Fields
    
    UIFont* rockpackInputFont = [UIFont rockpackFontOfSize:20];
    NSArray* textFieldsToSetup = @[emailInputField, userNameInputField, passwordInputField,
                                   ddInputField, mmInputField, yyyyInputField];
    for (UITextField* tf in textFieldsToSetup)
    {
        tf.font = rockpackInputFont;
        // -- this is to create the left padding for the text fields (hack) -- //
        tf.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 57)];
        tf.leftViewMode = UITextFieldViewModeAlways;
    }
    
    
    
    self.state = kLoginScreenStateInitial;
    
    
}

#pragma mark - States and Transitions

-(void)setState:(kLoginScreenState)newState
{
    if(newState == state)
        return;
    
    if(newState == kLoginScreenStateInitial)
        [self setUpInitialState];
    else if(newState == kLoginScreenStateLogin)
        [self setUpLoginStateFromPreviousState:state];
    else if(newState == kLoginScreenStateRegister)
        [self setUpRegisterStateFromState:state];
    else if(newState == kLoginScreenStatePasswordRetrieve)
        [self setUpPasswordState];
    
    state = newState;
}

-(kLoginScreenState)state
{
    return state;
}



-(void)setUpInitialState
{
    
    // controls to hide initially
    
    NSArray* controlsToHide = @[userNameInputField, passwordInputField, finalLoginButton, secondaryFacebookMessage,
                                areYouNewLabel, registerButton, passwordForgottenLabel, facebookLogingInLabel,
                                passwordForgottenButton, termsAndConditionsLabel, dobView, emailInputField,
                                registerNewUserButton, dividerImageView, faceImageButton, sendEmailButton,
                                wellSendYouLabel];
    
    for (UIView* control in controlsToHide) {
       
        control.alpha = 0.0;
    }
    
    dobView.center = CGPointMake(dobView.center.x - 50.0, dobView.center.y);
    emailInputField.center = CGPointMake(emailInputField.center.x - 50.0, emailInputField.center.y);
    faceImageButton.center = CGPointMake(faceImageButton.center.x - 50.0, faceImageButton.center.y);
    
    facebookSignInButton.enabled = YES;
    facebookSignInButton.frame = facebookButtonInitialFrame;
    facebookSignInButton.alpha = 1.0;
    
    _facebookLoginIsInProcess = NO;
    
    signUpButton.enabled = YES;
    signUpButton.alpha = 1.0;
    signUpButton.frame = signUpButtonInitialFrame;
    
    [activityIndicator stopAnimating];
    
    
    
}

-(void)setUpPasswordState
{
    self.initialUsernameFrame = userNameInputField.frame;
    loginButton.frame = registerButton.frame;
    sendEmailButton.enabled = YES;
    memberLabel.center = CGPointMake(loginButton.center.x,
                                     registerButton.center.y - 57.0);
    
    
    memberLabel.frame = CGRectIntegral(memberLabel.frame);
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
        facebookSignInButton.alpha = 0.0;
        CGFloat diff = passwordInputField.frame.origin.y - userNameInputField.frame.origin.y;
        userNameInputField.frame = passwordInputField.frame;
        passwordInputField.alpha = 0.0;
        emailInputField.alpha = 0.0;
        finalLoginButton.alpha = 0.0;
        passwordForgottenLabel.alpha = 0.0;
        loginButton.alpha = 1.0;
        registerButton.alpha = 0.0;
        
        memberLabel.alpha = 1.0;
        areYouNewLabel.alpha = 0.0;
        sendEmailButton.alpha = 1.0;
        dividerImageView.center = CGPointMake(dividerImageView.center.x, dividerImageView.center.y + diff);
        
    } completion:^(BOOL finished) {
        dividerImageView.frame = CGRectIntegral(dividerImageView.frame);
        [UIView animateWithDuration:0.3 animations:^{
        
            wellSendYouLabel.alpha = 1.0;
        
        }];
    
    }];
    
    
}


-(void)setUpLoginStateFromPreviousState:(kLoginScreenState)previousState
{
    secondaryFacebookMessage.alpha = 0.0;
    [self clearAllErrorArrows];
    isAnimating = YES;
    
    if(previousState == kLoginScreenStateInitial)
    {
        
        
        NSArray* loginForControls = @[facebookSignInButton, userNameInputField, passwordInputField, finalLoginButton];
        float delay = 0.0;
        for (UIView* control in loginForControls) {
            control.hidden = NO;
            
            [UIView animateWithDuration:0.4
                                  delay:delay
                                options:UIViewAnimationCurveEaseInOut
                             animations:^{
                                 
                                 control.alpha = 1.0;
                                 control.center = CGPointMake(control.center.x, control.center.y - kOffsetForLoginForm);
                                 
                             } completion:^(BOOL finished) {
                                 
                             }];
            delay += 0.05;
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            titleImageView.alpha = 0.0;
        }];
        
        // place secondary elements to the correct place for fade in animation
        
        
        passwordForgottenLabel.center = CGPointMake(passwordForgottenLabel.center.x, passwordForgottenLabel.center.y - kOffsetForLoginForm);
        passwordForgottenButton.center = CGPointMake(passwordForgottenButton.center.x, passwordForgottenButton.center.y - kOffsetForLoginForm);
        termsAndConditionsLabel.center = CGPointMake(termsAndConditionsLabel.center.x, termsAndConditionsLabel.center.y - kOffsetForLoginForm);
        
        // consequitive fade in animations
        
        [UIView animateWithDuration:0.4 animations:^{
            signUpButton.alpha = 0.0;
            memberLabel.alpha = 0.0;
            loginButton.alpha = 0.0;
        } completion:^(BOOL finished) {
            dividerImageView.center = CGPointMake(dividerImageView.center.x, dividerImageView.center.y - kOffsetForLoginForm);
            [UIView animateWithDuration:0.2 animations:^{
                passwordForgottenButton.alpha = 1.0;
                passwordForgottenLabel.alpha = 1.0;
                termsAndConditionsLabel.alpha = 1.0;
                dividerImageView.alpha = 1.0;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.2 animations:^{
                    areYouNewLabel.alpha = 1.0;
                    registerButton.alpha = 1.0;
                    
                } completion:^(BOOL finished) {
                    
                    isAnimating = NO;
                    
                    
                    emailInputField.center = CGPointMake(emailInputField.center.x,
                                                         emailInputField.center.y - kOffsetForLoginForm);
                    dobView.center = CGPointMake(dobView.center.x,
                                                 dobView.center.y - kOffsetForLoginForm);
                    
                    memberLabel.center = CGPointMake(memberLabel.center.x,
                                                     registerButton.center.y - 57.0);
                    
                    
                    memberLabel.frame = CGRectIntegral(memberLabel.frame);
                    
                    sendEmailButton.center = CGPointMake(sendEmailButton.center.x,
                                                         sendEmailButton.center.y - kOffsetForLoginForm);
                    
                    
                    
                    sendEmailButton.frame = CGRectIntegral(sendEmailButton.frame);
                    
                    registerNewUserButton.center = CGPointMake(registerNewUserButton.center.x,
                                                               registerNewUserButton.center.y - kOffsetForLoginForm);
                    
                    
                    faceImageButton.center = CGPointMake(faceImageButton.center.x,
                                                         faceImageButton.center.y - kOffsetForLoginForm);
                    
                    [userNameInputField becomeFirstResponder];
                    
                }];
            }];
        }];
        
    }
    else if (previousState == kLoginScreenStateRegister)
    {
        
        
        [UIView animateWithDuration:0.5 animations:^{
            
            facebookSignInButton.alpha = 1.0;
            facebookSignInButton.center = CGPointMake(facebookSignInButton.center.x - kOffsetForRegisterForm,
                                                      facebookSignInButton.center.y);
            
            emailInputField.alpha = 0.0;
            emailInputField.center = CGPointMake(userNameInputField.center.x - 50.0,
                                                 emailInputField.center.y);
            
            dobView.alpha = 0.0;
            dobView.center = CGPointMake(userNameInputField.center.x - 50.0,
                                         dobView.center.y);
            
            dividerImageView.alpha = 1.0;
            
            registerNewUserButton.alpha = 0.0;
            
            finalLoginButton.alpha = 1.0;
            finalLoginButton.center = CGPointMake(finalLoginButton.center.x - 50.0,
                                                  finalLoginButton.center.y);
            
            faceImageButton.alpha = 0.0;
            faceImageButton.center = CGPointMake(faceImageButton.center.x - 50.0,
                                                 faceImageButton.center.y);
            
            passwordForgottenButton.alpha = 1.0;
            passwordForgottenLabel.alpha = 1.0;
            
            registerButton.alpha = 1.0;
            areYouNewLabel.alpha = 1.0;
            
            loginButton.alpha = 0.0;
            memberLabel.alpha = 0.0;
            
            
            termsAndConditionsLabel.alpha = 1.0;
            
            
            
        } completion:^(BOOL finished) {
            isAnimating = NO;
            [userNameInputField becomeFirstResponder];
        }];
    }
    else if(previousState == kLoginScreenStatePasswordRetrieve)
    {
        
        
        [UIView animateWithDuration:0.5 animations:^{
            
            facebookSignInButton.alpha = 1.0;
            
            CGFloat diff = userNameInputField.frame.origin.y - self.initialUsernameFrame.origin.y;
            dividerImageView.center = CGPointMake(dividerImageView.center.x, dividerImageView.center.y - diff);
            
            userNameInputField.frame = self.initialUsernameFrame;
            
            finalLoginButton.alpha = 1.0;
            
            
            passwordForgottenButton.alpha = 1.0;
            passwordForgottenLabel.alpha = 1.0;
            
            registerButton.alpha = 1.0;
            areYouNewLabel.alpha = 1.0;
            
            loginButton.alpha = 0.0;
            memberLabel.alpha = 0.0;
            
            sendEmailButton.alpha = 0.0;
            
            
            passwordInputField.alpha = 1.0;
            wellSendYouLabel.alpha = 0.0;
            
            termsAndConditionsLabel.alpha = 1.0;
            
            
            
        } completion:^(BOOL finished) {
            isAnimating = NO;
            [userNameInputField becomeFirstResponder];
        }];
        
        
        
    }
    
    
    
}

-(void)setUpRegisterStateFromState:(kLoginScreenState)previousState
{
    secondaryFacebookMessage.alpha = 0.0;
    [self clearAllErrorArrows];
    isAnimating = YES;
    if(previousState == kLoginScreenStateInitial)
    {
        
        emailInputField.alpha = 1.0;
        emailInputField.center = CGPointMake(userNameInputField.center.x,
                                             emailInputField.center.y);
        
        dobView.alpha = 1.0;
        dobView.center = CGPointMake(userNameInputField.center.x,
                                     dobView.center.y);
        
        NSArray* loginForControls = @[emailInputField, userNameInputField, passwordInputField, dobView, registerNewUserButton];
        float delay = 0.05;
        for (UIView* control in loginForControls) {
            control.hidden = NO;
            
            [UIView animateWithDuration:0.4
                                  delay:delay
                                options:UIViewAnimationCurveEaseInOut
                             animations:^{
                                 
                                 control.alpha = 1.0;
                                 control.center = CGPointMake(control.center.x, control.center.y - kOffsetForLoginForm);
                                 
                             } completion:^(BOOL finished) {
                                 
                             }];
            delay += 0.05;
        }
        
        [UIView animateWithDuration:0.4 animations:^{
            
            memberLabel.alpha = 0.0;
            loginButton.alpha = 0.0;
            facebookSignInButton.center = CGPointMake(facebookSignInButton.center.x,
                                                      facebookSignInButton.center.y - kOffsetForLoginForm);
            signUpButton.alpha = 0.0;
            
            
            
            
            
        } completion:^(BOOL finished) {
            
            finalLoginButton.center = CGPointMake(finalLoginButton.center.x, finalLoginButton.center.y - kOffsetForLoginForm);
            passwordForgottenLabel.center = CGPointMake(passwordForgottenLabel.center.x, passwordForgottenLabel.center.y - kOffsetForLoginForm);
            passwordForgottenButton.center = CGPointMake(passwordForgottenButton.center.x, passwordForgottenButton.center.y - kOffsetForLoginForm);
            facebookSignInButton.center = CGPointMake(facebookSignInButton.center.x + kOffsetForRegisterForm,
                                                      facebookSignInButton.center.y);
            
            dividerImageView.center = CGPointMake(dividerImageView.center.x, dividerImageView.center.y - kOffsetForLoginForm);
            termsAndConditionsLabel.center = CGPointMake(termsAndConditionsLabel.center.x, termsAndConditionsLabel.center.y - kOffsetForLoginForm);
            
            [emailInputField becomeFirstResponder];
            
            loginButton.center = CGPointMake(registerButton.center.x,
                                             registerButton.center.y);
            
            memberLabel.center = CGPointMake(loginButton.center.x,
                                             registerButton.center.y - 57.0);
            memberLabel.frame = CGRectIntegral(memberLabel.frame);
            
            
            
            
            faceImageButton.center = CGPointMake(faceImageButton.center.x + 50.0,
                                                 faceImageButton.center.y - kOffsetForLoginForm);
            
            isAnimating = NO;
            
            [UIView animateWithDuration:0.3 animations:^{
                memberLabel.alpha = 1.0;
                loginButton.alpha = 1.0;
                faceImageButton.alpha = 1.0;
                
            }];
        }];
    }
    
    
    else if(previousState == kLoginScreenStateLogin)
    {
        // prepare in the correct place
        
        loginButton.center = CGPointMake(registerButton.center.x, registerButton.center.y);
        memberLabel.center = CGPointMake(loginButton.center.x,
                                         registerButton.center.y - 57.0);
        memberLabel.frame = CGRectIntegral(memberLabel.frame);
        
        [UIView animateWithDuration:0.5 animations:^{
            
            
            emailInputField.alpha = 1.0;
            emailInputField.center = CGPointMake(userNameInputField.center.x,
                                                 emailInputField.center.y);
            
            dobView.alpha = 1.0;
            dobView.center = CGPointMake(userNameInputField.center.x,
                                         dobView.center.y);
            
            faceImageButton.alpha = 1.0;
            faceImageButton.center = CGPointMake(faceImageButton.center.x + 50.0,
                                                 faceImageButton.center.y);
            
            loginButton.alpha = 1.0;
            memberLabel.alpha = 1.0;
            
            // move facebook button to the right
            facebookSignInButton.center = CGPointMake(facebookSignInButton.center.x + kOffsetForRegisterForm,
                                                      facebookSignInButton.center.y);
            
            
        
        }];
    }

    [UIView animateWithDuration:0.3 animations:^{
        
        facebookSignInButton.alpha = 0.0;
    
        titleImageView.alpha = 0.0;
        registerNewUserButton.alpha = 1.0;
        
        dividerImageView.alpha = 0.0;
        
        registerNewUserButton.alpha = 1.0;
        
        
        termsAndConditionsLabel.alpha = 0.0;
    
        
        passwordForgottenButton.alpha = 0.0;
        passwordForgottenLabel.alpha = 0.0;
    
        
        finalLoginButton.alpha = 0.0;
        finalLoginButton.center = CGPointMake(finalLoginButton.center.x + 50.0,
                                          finalLoginButton.center.y);
    
        registerButton.alpha = 0.0;
        areYouNewLabel.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        [emailInputField becomeFirstResponder];
        isAnimating = NO;
    }];
    
    

}



#pragma mark - Button Actions
-(BOOL)loginFormIsValid
{
    // email
    
    
    if(userNameInputField.text.length < 1) {
        [self placeErrorLabel:@"Please enter a user name" NextToView:userNameInputField];
        [userNameInputField becomeFirstResponder];
        return NO;
    }
    
    
    if(passwordInputField.text.length < 1) {
        [self placeErrorLabel:@"Please enter a password" NextToView:passwordInputField];
        [passwordInputField becomeFirstResponder];
        return NO;
    }
    
    
    return YES;
}

-(BOOL)checkAndSaveRegisteredUser:(SYNOAuth2Credential*)credential
{
    
    User* newUser = appDelegate.currentUser;
    
    if(!newUser) {
        // problem
        DebugLog(@"The user was not registered correctly...");
        return NO;
    }
    
    [credential saveToKeychainForService: kOAuth2Service
                                 account: newUser.uniqueId];
    
    [SYNActivityManager.sharedInstance updateActivityForCurrentUser];
    
    DebugLog(@"Registered:\n%@", newUser);
    
    return YES;
}

- (IBAction) doLogin: (id) sender
{
    [self clearAllErrorArrows];
    
    [self resignAllFirstResponders];
    
    if(![self loginFormIsValid])
        return;
    
    finalLoginButton.enabled = NO;
    
    [UIView animateWithDuration: 0.1 animations:^
    {
        finalLoginButton.alpha = 0.0;
    }];
    
    activityIndicator.center = CGPointMake(finalLoginButton.center.x, finalLoginButton.center.y);
    [activityIndicator startAnimating];
    
    [appDelegate.oAuthNetworkEngine doSimpleLoginForUsername: userNameInputField.text
                                                 forPassword: passwordInputField.text
                                           completionHandler: ^(SYNOAuth2Credential* credential) {
                                               
                                               // Case where the user is a member of Rockpack but has not signing in this device
                                               
                                               [appDelegate.oAuthNetworkEngine userInformationFromCredentials:credential
                                                                                      completionHandler:^(NSDictionary* dictionary) {
                                                                                          
                                                                                          NSString* username = [dictionary objectForKey:@"username"];
                                                                                          DebugLog(@"User Registerd: %@", username);
                                                  
                                                                                          [self checkAndSaveRegisteredUser:credential];
                                                                                          
                                                                                          [activityIndicator stopAnimating];
                                                                                          
                                                                                          [self completeLoginProcess:credential];
                                                   
                                                                                      } errorHandler:^(NSDictionary* errorDictionary) {
                                                   
                                                   
                                                   
                                                                                      }];
                                               
                                               
                                               
                                               
                                           } errorHandler: ^(NSDictionary* errorDictionary) {
                                               
                                               NSDictionary* errors = errorDictionary [@"error"];
         
                                               if (errors)
                                               {
                                                   [self placeErrorLabel: @"Username could be incorrect"
                                                              NextToView: userNameInputField];
             
                                                   [self placeErrorLabel: @"Password could be incorrect"
                                                              NextToView: passwordInputField];
                                               }
         
                                               finalLoginButton.enabled = YES;
                                               
                                               [activityIndicator stopAnimating];
         
                                               [UIView animateWithDuration:0.3 animations:^{
                                                   
                                                   finalLoginButton.alpha = 1.0;
                                                   
                                               } completion:^(BOOL finished) {
                                                   
                                                   [userNameInputField becomeFirstResponder];
                                                   
                                               }];
                                           }];
    
}




-(IBAction)goToLoginForm:(id)sender
{
    if(isAnimating)
        return;
    
    self.state = kLoginScreenStateLogin;
}

-(IBAction)sendEmailButtonPressed:(id)sender
{
    
    
    
}

-(void)doFacebookLoginAnimation
{
    [UIView animateWithDuration:0.3 animations:^{
        facebookLogingInLabel.alpha = 1.0;
        signUpButton.alpha = 0.0;
        signUpButton.center = CGPointMake(signUpButton.center.x + 10.0, signUpButton.center.y);
    } completion:^(BOOL finished) {
        [activityIndicator startAnimating];
    }];
    
    userNameInputField.enabled = NO;
    [userNameInputField resignFirstResponder];
    passwordForgottenButton.enabled = NO;
    [passwordForgottenButton resignFirstResponder];
    finalLoginButton.enabled = NO;
    loginButton.enabled = NO;
    passwordForgottenButton.enabled = NO;
    
    activityIndicator.center = CGPointMake(facebookSignInButton.frame.origin.x + facebookSignInButton.frame.size.width + 35.0,
                                           facebookSignInButton.center.y);
    
    CGRect labelFrame = facebookLogingInLabel.frame;
    labelFrame.origin.x = facebookSignInButton.frame.origin.x + facebookSignInButton.frame.size.width + 40.0;
    labelFrame.origin.y = facebookSignInButton.frame.origin.y + 8.0;
    facebookLogingInLabel.frame = labelFrame;
}

-(IBAction)signInWithFacebook:(id)sender
{
    
    _facebookLoginIsInProcess = NO;
    
    [self clearAllErrorArrows];
    facebookSignInButton.enabled = NO;
    
    FBSession* facebookSession = [FBSession activeSession];
    
    if(facebookSession.state == FBSessionStateCreatedTokenLoaded) {
        _facebookLoginIsInProcess = YES;
        [self doFacebookLoginAnimation];
    }
    
    
    
    SYNFacebookManager* facebookManager = [SYNFacebookManager sharedFBManager];
    
    [facebookManager loginOnSuccess:^(NSDictionary<FBGraphUser> *dictionary) {
        
        if(!_facebookLoginIsInProcess) {
            
            [self doFacebookLoginAnimation];
        }
        
        
        FBAccessTokenData* accessTokenData = [[FBSession activeSession] accessTokenData];
        
        [appDelegate.oAuthNetworkEngine doFacebookLoginWithAccessToken:accessTokenData.accessToken
                                                     completionHandler: ^(SYNOAuth2Credential* credential) {
                                                         
                                                         [appDelegate.oAuthNetworkEngine userInformationFromCredentials: credential
                                                                                                      completionHandler: ^(NSDictionary* dictionary) {
                                                                                                          
                                                                                                          [self checkAndSaveRegisteredUser:credential];
                                                                                                          [activityIndicator stopAnimating];
                                                                                                          [self completeLoginProcess:credential];
                  
                                                                                                      } errorHandler: ^(NSDictionary* errorDictionary) {
                  
                                                                                                      }];
                                                         
                                                         
                                                        } errorHandler: ^(NSDictionary* errorDictionary) {
                                                            facebookLogingInLabel.alpha = 0.0;

                                                            signUpButton.alpha = 1.0;

                                                            signUpButton.center = CGPointMake(signUpButton.center.x + 20.0, signUpButton.center.y);
                                                            [activityIndicator stopAnimating];

                                                            NSDictionary* formErrors = errorDictionary [@"form_errors"];

                                                            userNameInputField.enabled = YES;
                                                            passwordForgottenButton.enabled = YES;
                                                            finalLoginButton.enabled = YES;
                                                            loginButton.enabled = YES;

                                                            passwordForgottenButton.enabled = YES;

                                                            if (formErrors)
                                                            {
                                                                facebookSignInButton.enabled = YES;
                                                                secondaryFacebookMessage.text = @"Could not log in through facebook";
                                                                secondaryFacebookMessage.alpha = 1.0;
                                                            }
                                                        }];
    }
    onFailure: ^(NSString* errorString)
    {
        _facebookLoginIsInProcess = NO;
        facebookSignInButton.enabled = YES;
        
        // TODO: Use custom alert box here
        [[[UIAlertView alloc] initWithTitle: @"Facebook Login"
                                    message: errorString
                                   delegate: nil
                          cancelButtonTitle: @"OK"
                          otherButtonTitles: nil] show];
        
        DebugLog(@"Log in failed!"); 
    }];
    
}

-(IBAction)forgottenPasswordPressed:(id)sender
{
    self.state = kLoginScreenStatePasswordRetrieve;
}


-(void)showAutologinWithCredentials:(SYNOAuth2Credential*)credentials
{
    
//    activityIndicator.center = CGPointMake(facebookSignInButton.frame.origin.x + facebookSignInButton.frame.size.width + 35.0,
//                                           facebookSignInButton.center.y);
//    
//    [UIView animateWithDuration:0.3 animations:^{
//        signUpButton.alpha = 0.0;
//    } completion:^(BOOL finished) {
//        [activityIndicator startAnimating];
//        [self completeLoginProcess:credentials];
//    }];
    
    
}



-(BOOL)registrationFormIsValid
{
    
    
    if(emailInputField.text.length < 1) {
        [self placeErrorLabel:@"Please enter an email address" NextToView:emailInputField];
        [emailInputField becomeFirstResponder];
        return NO;
    }
    
    // == Regular expression through RegexKitLite.h (not arc compatible) == //
    
    if(![emailInputField.text isMatchedByRegex:@"^([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})$"]) {
        [self placeErrorLabel:@"Email Address Not Valid" NextToView:emailInputField];
        [emailInputField becomeFirstResponder];
        return NO;
    }
    
    if(userNameInputField.text.length < 1) {
        [self placeErrorLabel:@"Please enter a user name" NextToView:userNameInputField];
        [userNameInputField becomeFirstResponder];
        return NO;
    }
    
    // == Username must be 
    if(![userNameInputField.text isMatchedByRegex:@"^[a-zA-Z0-9\\._]+$"]) {
        [self placeErrorLabel:@"Username has invalid characters" NextToView:userNameInputField];
        [userNameInputField becomeFirstResponder];
        return NO;
    }
    
    
    if(passwordInputField.text.length < 1) {
        [self placeErrorLabel:@"Please enter a password" NextToView:passwordInputField];
        [passwordInputField becomeFirstResponder];
        return NO;
    }
    
    if(ddInputField.text.length != 2 || mmInputField.text.length != 2 || yyyyInputField.text.length != 4) {
        [self placeErrorLabel:@"Date Invalid" NextToView:dobView];
        [ddInputField becomeFirstResponder];
        return NO;
    }
    
    // == Check wether the fields contain numbers == //
    
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    NSArray* dobTextFields = @[mmInputField, ddInputField, yyyyInputField];
    for (UITextField* dobField in dobTextFields) {
        if(![numberFormatter numberFromString:dobField.text]) {
            [self placeErrorLabel:@"Only enter numbers" NextToView:dobView];
            [dobField becomeFirstResponder];
            return NO;
        }
    }
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate* potentialDate = [dateFormatter dateFromString:[self dateStringFromCurrentInput]];
    // not a real date
    if(!potentialDate) {
        [self placeErrorLabel:@"The Date is not Valid" NextToView:dobView];
        return NO;
    }
        
    
    
    
    return YES;
}

-(void)clearAllErrorArrows
{
    [labelsToErrorArrows enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop){
        
        SYNLoginErrorArrow* arrow = (SYNLoginErrorArrow*)value;
        [arrow removeFromSuperview];
    }];
    
    [labelsToErrorArrows removeAllObjects];
}

-(void)resignAllFirstResponders
{
    NSArray* allTextFields = @[emailInputField, userNameInputField, passwordForgottenButton, ddInputField, mmInputField, yyyyInputField];
    for (UITextField* textField in allTextFields) {
        [textField resignFirstResponder];
    }
}
-(NSString*)dateStringFromCurrentInput
{
    return [NSString stringWithFormat:@"%@-%@-%@", yyyyInputField.text, mmInputField.text, ddInputField.text];
}
-(IBAction)registerNewUser:(id)sender
{
    // Check Text Fields
    
    
    [self clearAllErrorArrows];
    
    if(![self registrationFormIsValid])
        return;
    
    [self resignAllFirstResponders];
    
    
    
    [UIView animateWithDuration:0.2 animations:^{
        registerNewUserButton.alpha = 0.0;
    }];
    
    NSDictionary* userData = @{@"username": userNameInputField.text,
                               @"password": passwordInputField.text,
                               @"date_of_birth": [self dateStringFromCurrentInput],
                               @"locale":@"en-US",
                               @"email": emailInputField.text};
    
    activityIndicator.center = CGPointMake(registerNewUserButton.center.x, registerNewUserButton.center.y);
    [activityIndicator startAnimating];
    
    [appDelegate.oAuthNetworkEngine registerUserWithData:userData
                                       completionHandler: ^(SYNOAuth2Credential* credential) {
                                           
                                           // Case where the user registers
                                           
                                           [appDelegate.oAuthNetworkEngine userInformationFromCredentials: credential
                                                                                        completionHandler: ^(NSDictionary* dictionary) {
                                                                                      
                                                                                      
                                                                                            [self checkAndSaveRegisteredUser:credential];
             
                                                                                            [activityIndicator stopAnimating];
             
                                                                                            [self completeLoginProcess: credential];
             
                                                                                        } errorHandler:^(NSDictionary* errorDictionary) {
             
                                                                                        }];
         
                                           registerNewUserButton.enabled = YES;
                                           
                                       } errorHandler: ^(NSDictionary* errorDictionary) {
                                           
                                           NSDictionary* formErrors = [errorDictionary objectForKey:@"form_errors"];
         
                                           if (formErrors)
                                           {
                                               [self showRegistrationError:formErrors];
                                           }
         
                                           registerNewUserButton.enabled = YES;
         
                                           [activityIndicator stopAnimating];
                                           registerNewUserButton.alpha = 1.0;
         
                                       }];

    return;
}

-(void)showRegistrationError:(NSDictionary*)errorDictionary
{
    // form errors
    
    NSArray* usernameError = [errorDictionary objectForKey:@"username"];
    //NSArray* localeError = [errorDictionary objectForKey:@"locale"];
    NSArray* passwordError = [errorDictionary objectForKey:@"password"];
    NSArray* emailError = [errorDictionary objectForKey:@"email"];
    
    if(usernameError)
        [self placeErrorLabel:(NSString*)[usernameError objectAtIndex:0] NextToView:userNameInputField];
    
    // TODO: deal with locale
    
    if(passwordError)
        [self placeErrorLabel:(NSString*)[passwordError objectAtIndex:0] NextToView:passwordInputField];
    
    if(emailError)
        [self placeErrorLabel:(NSString*)[emailError objectAtIndex:0] NextToView:emailInputField];
    
}

-(void)placeErrorLabel:(NSString*)errorText NextToView:(UIView*)view
{
    SYNLoginErrorArrow* errorArrow = [SYNLoginErrorArrow withMessage:errorText];
    
    CGFloat xPos = view.frame.origin.x + view.frame.size.width - 20.0;
    CGRect errorArrowFrame = errorArrow.frame;
    errorArrowFrame.origin.x = xPos;
    
    errorArrow.frame = errorArrowFrame;
    errorArrow.center = CGPointMake(errorArrow.center.x, view.center.y);
    
    errorArrow.alpha = 0.0;
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(errorArrowTapped:)];
    [errorArrow addGestureRecognizer:tapGesture];
    
    [UIView animateWithDuration:0.2 animations:^{
        errorArrow.alpha = 1.0;
    }];
    
    [labelsToErrorArrows setObject:errorArrow forKey:[NSValue valueWithPointer:(__bridge const void *)(view)]];
    [self.view addSubview:errorArrow];
}

-(void)errorArrowTapped:(UITapGestureRecognizer*)recogniser
{
    
    SYNLoginErrorArrow* arrowTapped = (SYNLoginErrorArrow*)recogniser.view;
    
    [labelsToErrorArrows enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop){
        
        SYNLoginErrorArrow* arrow = (SYNLoginErrorArrow*)value;
        if(arrow == arrowTapped) {
            
            [UIView animateWithDuration:0.2 animations:^{
                arrow.alpha = 0.0;
            } completion:^(BOOL finished) {
                [labelsToErrorArrows removeObjectForKey:key];
                [arrow removeFromSuperview];
            }];
            
            
            return;
        }
        
    }];
}

-(IBAction)registerPressed:(id)sender
{
    if(self.isAnimating)
        return;
    
    self.state = kLoginScreenStateRegister;
}


-(IBAction)signUp:(id)sender
{
    self.state = kLoginScreenStateRegister;
}


- (void) completeLoginProcess: (SYNOAuth2Credential *) credential
{
    
    
    
    [activityIndicator stopAnimating];
    
    UIImageView *splashView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 1024, 748)];
    splashView.image = [UIImage imageNamed:  @"Default-Landscape.png"];
    splashView.alpha = 0.0;
	[self.view addSubview: splashView];
    
    [UIView animateWithDuration: 0.3
                     animations: ^{
                         splashView.alpha = 1.0;
    }
    completion: ^(BOOL finished)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: kLoginCompleted
                                                            object: self];
        
        
    }];
}


#pragma mark - TextField Delegate Methods



- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)newCharacter
{
    
    NSUInteger oldLength = textField.text.length;
    NSUInteger replacementLength = newCharacter.length;
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = (oldLength + replacementLength) - rangeLength;
    
    
    if((textField == ddInputField || textField == mmInputField) && newLength > 2)
        return NO;
    if(textField == yyyyInputField && newLength > 4)
        return NO;
    
    
    
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    if(textField == ddInputField || textField == mmInputField || textField == yyyyInputField)
        if(![numberFormatter numberFromString:newCharacter] && newCharacter.length != 0) // is backspace, length is 0
            return NO;
        
    
    NSValue* key = [NSValue valueWithPointer:(__bridge const void *)(textField)];
    SYNLoginErrorArrow* possibleErrorArrow =
    (SYNLoginErrorArrow*)[labelsToErrorArrows objectForKey:key];
    if(possibleErrorArrow)
    {
        [UIView animateWithDuration:0.2 animations:^{
            possibleErrorArrow.alpha = 0.0;
        } completion:^(BOOL finished) {
            [possibleErrorArrow removeFromSuperview];
            [labelsToErrorArrows removeObjectForKey:key];
        }];
    }
    return YES;
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    
    [textField resignFirstResponder];
    
    // if both text fields have stuff then consider the return as a Login command
    
    if(self.userNameInputField.text.length > 1 && self.passwordInputField.text.length > 1)
    {
        // perform login
        return YES;
    }
    
    // if not and the user is at the top field take them to the second
    
    if(textField == self.userNameInputField)
    {
        [self.passwordInputField becomeFirstResponder];
    }
    
    
    return YES;
}


#pragma mark - CoreData Access

#pragma mark - Face Image and Camera

-(IBAction)faceButtonImagePressed:(UIButton*)sender
{
    
    SYNCameraPopoverViewController *actionPopoverController = [[SYNCameraPopoverViewController alloc] init];
    actionPopoverController.delegate = self;
    
    // Need show the popover controller
    self.cameraMenuPopoverController = [[UIPopoverController alloc] initWithContentViewController: actionPopoverController];
    self.cameraMenuPopoverController.popoverContentSize = CGSizeMake(206, 70);
    self.cameraMenuPopoverController.delegate = self;
    self.cameraMenuPopoverController.popoverBackgroundViewClass = [SYNAutocompletePopoverBackgroundView class];
    
    [self.cameraMenuPopoverController presentPopoverFromRect: sender.frame
                                                      inView: self.view
                                    permittedArrowDirections: UIPopoverArrowDirectionUp
                                                    animated: YES];
}

- (void) showImagePicker: (UIImagePickerControllerSourceType) sourceType
{
    self.imagePicker = [[GKImagePicker alloc] init];
    self.imagePicker.cropSize = CGSizeMake(256, 176);
    self.imagePicker.delegate = self;
    self.imagePicker.imagePickerController.sourceType = sourceType;
    
    if ((sourceType == UIImagePickerControllerSourceTypeCamera) && [UIImagePickerController respondsToSelector: @selector(isCameraDeviceAvailable:)])
    {
        if ([UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront])
        {
            self.imagePicker.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        }
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.cameraPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.imagePicker.imagePickerController];
        
        [self.cameraPopoverController presentPopoverFromRect: self.faceImageButton.frame
                                                      inView: self.view
                                    permittedArrowDirections: UIPopoverArrowDirectionLeft
                                                    animated: YES];
    }
    else
    {
        [self presentViewController: self.imagePicker.imagePickerController
                           animated: YES
                         completion: nil];
    }
}

- (void) userTouchedTakePhotoButton
{
    [self.cameraMenuPopoverController dismissPopoverAnimated: NO];
    [self showImagePicker: UIImagePickerControllerSourceTypeCamera];
}

- (void) imagePicker: (GKImagePicker *) imagePicker
         pickedImage: (UIImage *) image
{
    //    self.imgView.image = image;
    
    [self.faceImageButton setImage:image forState:UIControlStateNormal];
    
    DebugLog(@"width %f, height %f", image.size.width, image.size.height);
    [self hideImagePicker];
}

- (void) hideImagePicker
{
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        
        [self.cameraPopoverController dismissPopoverAnimated: YES];
        
    } else {
        
        [self.imagePicker.imagePickerController dismissViewControllerAnimated: YES
                                                                   completion: nil];
    }
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if(UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        signUpButton.center = CGPointMake(604.0, signUpButton.center.y);
        passwordForgottenLabel.center = CGPointMake(650.0, passwordForgottenLabel.center.y);
        faceImageButton.center = CGPointMake(120.0, faceImageButton.center.y);
    }
    else
    {
        signUpButton.center = CGPointMake(730.0, signUpButton.center.y);
        passwordForgottenLabel.center = CGPointMake(780.0, passwordForgottenLabel.center.y);
        faceImageButton.center = CGPointMake(250.0, faceImageButton.center.y);
    }
    
    
}
@end
