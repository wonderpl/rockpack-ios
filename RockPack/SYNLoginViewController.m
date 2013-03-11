//
//  SYNLoginViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 11/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNLoginViewController.h"
#import "SYNAppDelegate.h"

@interface SYNLoginViewController ()  <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIButton* facebookSignInButton;
@property (nonatomic, strong) IBOutlet UIButton* signUpButton;

@property (nonatomic, strong) IBOutlet UIButton* loginButton;

@property (nonatomic, strong) IBOutlet UIButton* finalLoginButton;

@property (nonatomic, strong) IBOutlet UIButton* passwordForgottenButton;

@property (nonatomic, strong) IBOutlet UIButton* registerButton;

@property (nonatomic, strong) IBOutlet UITextField* userNameInputTextField;
@property (nonatomic, strong) IBOutlet UITextField* passwordInputTextField;


@property (nonatomic, strong) IBOutlet UILabel* passwordForgottenLabel;

@property (nonatomic, strong) IBOutlet UILabel* areYouNewLabel;
@property (nonatomic, strong) IBOutlet UILabel* memberLabel;

@property (nonatomic, strong) IBOutlet UILabel* termsAndConditionsLabel;

@property (nonatomic) BOOL isAnimating;

@property (nonatomic, weak) SYNAppDelegate* appDelegate;


#define kOffsetForLoginForm 100.0

@end

@implementation SYNLoginViewController

@synthesize state;
@synthesize appDelegate;
@synthesize facebookSignInButton, signUpButton, loginButton, finalLoginButton, passwordInputTextField, registerButton, userNameInputTextField;
@synthesize passwordForgottenButton, passwordForgottenLabel, areYouNewLabel, memberLabel, termsAndConditionsLabel;
@synthesize isAnimating;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set up controls
    
    appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    self.state = kLoginScreenStateInitial;
    
    
}

#pragma mark - States and Transitions

-(void)setState:(kLoginScreenState)newState
{
    if(newState == kLoginScreenStateInitial)
        [self setUpInitialState];
    else if(newState == kLoginScreenStateLogin)
        [self setUpLoginState];
}

-(void)setUpInitialState
{
    
    // controls to hide initially
    
    NSArray* controlsToHide = @[userNameInputTextField, passwordInputTextField, finalLoginButton, areYouNewLabel, registerButton, passwordForgottenLabel, passwordForgottenButton, termsAndConditionsLabel];
    for (UIView* control in controlsToHide) {
        control.hidden = YES;
        control.alpha = 0.0;
    }
    
    
}

-(void)setUpLoginState
{
    
    isAnimating = YES;
    
    NSArray* loginForControls = @[facebookSignInButton, userNameInputTextField, passwordInputTextField, finalLoginButton];
    float delay = 0.0;
    for (UIView* control in loginForControls) {
        control.hidden = NO;
        
        [UIView animateWithDuration:0.3
                              delay:delay
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             
                             control.alpha = 1.0;
                             control.center = CGPointMake(control.center.x, control.center.y - kOffsetForLoginForm);
                         
        } completion:^(BOOL finished) {
            
        }];
        delay += 0.03;
    }
    
    // place secondary elements to the correct place for fade in animation
    
    passwordForgottenButton.hidden = NO;
    passwordForgottenLabel.hidden = NO;
    termsAndConditionsLabel.hidden = NO;
    areYouNewLabel.hidden = NO;
    registerButton.hidden = NO;
    passwordForgottenLabel.center = CGPointMake(passwordForgottenLabel.center.x, passwordForgottenLabel.center.y - kOffsetForLoginForm);
    passwordForgottenButton.center = CGPointMake(passwordForgottenButton.center.x, passwordForgottenButton.center.y - kOffsetForLoginForm);
    termsAndConditionsLabel.center = CGPointMake(termsAndConditionsLabel.center.x, termsAndConditionsLabel.center.y - kOffsetForLoginForm);
    
    
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

#pragma mark - Button Actions

-(IBAction)doLogin:(id)sender
{
    
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

-(IBAction)registerPressed:(id)sender
{
    
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
    
    if(self.userNameInputTextField.text.length > 1 && self.passwordInputTextField.text.length > 1)
    {
        // perform login
        return YES;
    }
    
    // if not and the user is at the top field take them to the second
    
    if(textField == self.userNameInputTextField)
    {
        [self.passwordInputTextField becomeFirstResponder];
    }
    
    
    return YES;
}



@end
