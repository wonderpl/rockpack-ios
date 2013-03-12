//
//  SYNLoginViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 11/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNLoginViewController.h"
#import "SYNAppDelegate.h"
#import "UIFont+SYNFont.h"

@interface SYNLoginViewController ()  <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIButton* facebookSignInButton;
@property (nonatomic, strong) IBOutlet UIButton* signUpButton;

@property (nonatomic, strong) IBOutlet UIButton* loginButton;

@property (nonatomic, strong) IBOutlet UIButton* finalLoginButton;

@property (nonatomic, strong) IBOutlet UIButton* passwordForgottenButton;

@property (nonatomic, strong) IBOutlet UIButton* registerButton;

@property (nonatomic, strong) IBOutlet UITextField* userNameInputField;
@property (nonatomic, strong) IBOutlet UITextField* passwordInputField;
@property (nonatomic, strong) IBOutlet UITextField* emailInputField;
@property (nonatomic, strong) IBOutlet UIView* dobView;
@property (nonatomic, strong) IBOutlet UITextField* ddInputField;
@property (nonatomic, strong) IBOutlet UITextField* mmInputField;
@property (nonatomic, strong) IBOutlet UITextField* yyyyInputField;

@property (nonatomic, strong) IBOutlet UIImageView* titleImageView;

@property (nonatomic, strong) IBOutlet UILabel* passwordForgottenLabel;
@property (nonatomic, strong) IBOutlet UIButton* registerNewUserButton;

@property (nonatomic, strong) IBOutlet UILabel* areYouNewLabel;
@property (nonatomic, strong) IBOutlet UILabel* memberLabel;

@property (nonatomic, strong) IBOutlet UILabel* termsAndConditionsLabel;


@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* activityIndicator;

@property (nonatomic) BOOL isAnimating;

@property (nonatomic, weak) SYNAppDelegate* appDelegate;


#define kOffsetForLoginForm 100.0

@end

@implementation SYNLoginViewController

@synthesize state;
@synthesize appDelegate;
@synthesize facebookSignInButton, signUpButton, loginButton, finalLoginButton, passwordInputField, registerButton, userNameInputField;
@synthesize passwordForgottenButton, passwordForgottenLabel, areYouNewLabel, memberLabel, termsAndConditionsLabel, activityIndicator;
@synthesize isAnimating;
@synthesize emailInputField, dobView, registerNewUserButton;
@synthesize titleImageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set up controls
    
    appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
    activityIndicator.hidesWhenStopped = YES;
    
    // == Setup Fonts for labels (not input fields)
    
    memberLabel.font = [UIFont boldRockpackFontOfSize:22];
    
    areYouNewLabel.font = [UIFont boldRockpackFontOfSize:22];
    passwordForgottenLabel.font = [UIFont rockpackFontOfSize:14];
    termsAndConditionsLabel.font = [UIFont rockpackFontOfSize:16];
    
    
    
    // == Setup Input Fields
    
    UIFont* rockpackInputFont = [UIFont rockpackFontOfSize:20];
    NSArray* textFieldsToSetup = @[emailInputField, userNameInputField, passwordInputField];
    for (UITextField* tf in textFieldsToSetup)
    {
        tf.font = rockpackInputFont;
        // this is to create the left padding for the text fields (hack)
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
        [self setUpLoginState];
    else if(newState == kLoginScreenStateRegister)
        [self setupRegisterStateFromState:state];
    
    state = newState;
}

-(kLoginScreenState)state
{
    return state;
}

-(void)setUpInitialState
{
    
    // controls to hide initially
    
    NSArray* controlsToHide = @[userNameInputField, passwordInputField, finalLoginButton,
                                areYouNewLabel, registerButton, passwordForgottenLabel,
                                passwordForgottenButton, termsAndConditionsLabel, dobView, emailInputField,
                                registerNewUserButton];
    for (UIView* control in controlsToHide) {
        control.hidden = YES;
        control.alpha = 0.0;
    }
    
    
    
}



-(void)setUpLoginState
{
    
    isAnimating = YES;
    
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
    
    passwordForgottenButton.hidden = NO;
    passwordForgottenLabel.hidden = NO;
    termsAndConditionsLabel.hidden = NO;
    areYouNewLabel.hidden = NO;
    registerButton.hidden = NO;
    passwordForgottenLabel.center = CGPointMake(passwordForgottenLabel.center.x, passwordForgottenLabel.center.y - kOffsetForLoginForm);
    passwordForgottenButton.center = CGPointMake(passwordForgottenButton.center.x, passwordForgottenButton.center.y - kOffsetForLoginForm);
    termsAndConditionsLabel.center = CGPointMake(termsAndConditionsLabel.center.x, termsAndConditionsLabel.center.y - kOffsetForLoginForm);
    activityIndicator.center = CGPointMake(activityIndicator.center.x, activityIndicator.center.y - kOffsetForLoginForm);
    
    // consequitive fade in animations
    
    [UIView animateWithDuration:0.4 animations:^{
        signUpButton.alpha = 0.0;
        memberLabel.alpha = 0.0;
        loginButton.alpha = 0.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            passwordForgottenButton.alpha = 1.0;
            passwordForgottenLabel.alpha = 1.0;
            termsAndConditionsLabel.alpha = 1.0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                areYouNewLabel.alpha = 1.0;
                registerButton.alpha = 1.0;
            } completion:^(BOOL finished) {
                isAnimating = NO;
            }];
        }];
    }];
    
    
}

-(void)setupRegisterStateFromState:(kLoginScreenState)previousState
{
    if(previousState == kLoginScreenStateInitial)
    {
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationCurveEaseInOut
                         animations:^{
            
            facebookSignInButton.alpha = 0.0;
            
            
            facebookSignInButton.center = CGPointMake(facebookSignInButton.center.x + 150.0,
                                                      facebookSignInButton.center.y);
            emailInputField.hidden = NO;
            emailInputField.alpha = 1.0;
            emailInputField.center = CGPointMake(emailInputField.center.x + 100.0,
                                                 emailInputField.center.y);
            dobView.hidden = NO;
            dobView.alpha = 1.0;
            dobView.center = CGPointMake(dobView.center.x + 100.0,
                                         dobView.center.y);
            
        } completion:^(BOOL finished) {
            
        }];
        
    }
    else if(previousState == kLoginScreenStateLogin)
    {
        [UIView animateWithDuration:0.5 animations:^{
            
            facebookSignInButton.alpha = 0.0;
            
            
            facebookSignInButton.center = CGPointMake(facebookSignInButton.center.x + 100.0,
                                                      facebookSignInButton.center.y);
            emailInputField.hidden = NO;
            emailInputField.alpha = 1.0;
            emailInputField.center = CGPointMake(userNameInputField.center.x,
                                                 emailInputField.center.y);
            dobView.hidden = NO;
            dobView.alpha = 1.0;
            dobView.center = CGPointMake(userNameInputField.center.x,
                                         dobView.center.y);
            
            registerNewUserButton.hidden = NO;
            registerNewUserButton.alpha = 1.0;
            
            loginButton.alpha = 0.0;
            finalLoginButton.alpha = 0.0;
            finalLoginButton.center = CGPointMake(finalLoginButton.center.x,
                                                  finalLoginButton.center.y + 50.0);
            
        }];
    }
    
}



#pragma mark - Button Actions

-(IBAction)doLogin:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        finalLoginButton.alpha = 0.0;
    }];
    [activityIndicator startAnimating];
    
    // TODO : Do actual login
}

-(IBAction)goToLoginForm:(id)sender
{
    if(isAnimating)
        return;
    
    self.state = kLoginScreenStateLogin;
}

-(IBAction)signInWithFacebook:(id)sender
{
    
    
}

-(IBAction)forgottenPasswordPressed:(id)sender
{
    
}

-(IBAction)registerNewUser:(id)sender
{
    // Check Text Fields
    
    if(emailInputField.text.length < 2 ||
       userNameInputField.text.length < 2 ||
       passwordInputField.text.length < 2) {
        return;
    }
    
    // Do registration
}

-(IBAction)registerPressed:(id)sender
{
    self.state = kLoginScreenStateRegister;
}


-(IBAction)signUp:(id)sender
{
    
    
    
    

}


#pragma mark - TextField Delegate Methods

- (void) textViewDidBeginEditing: (UITextView *) textView
{
    [textView setText: @""];
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



@end
