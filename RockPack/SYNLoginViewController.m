//
//  SYNLoginViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 11/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNLoginViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNNetworkEngine.h"
#import "User.h"
#import "SYNFacebookManager.h"
#import "SYNLoginErrorArrow.h"
#import "RegexKitLite.h"

@interface SYNLoginViewController ()  <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIButton* facebookSignInButton;
@property (nonatomic, strong) IBOutlet UIButton* signUpButton;

@property (nonatomic, strong) IBOutlet UIButton* loginButton;

@property (nonatomic, strong) IBOutlet UIButton* finalLoginButton;

@property (nonatomic, strong) IBOutlet UIButton* passwordForgottenButton;

@property (nonatomic, strong) IBOutlet UILabel* joingRockpackLabel;

@property (nonatomic, strong) IBOutlet UIButton* registerButton;

@property (nonatomic, strong) IBOutlet UIImageView* dividerImageView;

@property (nonatomic, strong) IBOutlet UIButton* faceImageButton;


@property (nonatomic, strong) NSMutableDictionary* labelsToErrorArrows;

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

@property (nonatomic, strong) IBOutlet UIView* termsAndConditionsView;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* activityIndicator;

@property (nonatomic) BOOL isAnimating;

@property (nonatomic, weak) SYNAppDelegate* appDelegate;


#define kOffsetForLoginForm 240.0
#define kOffsetForRegisterForm 100.0

@end

@implementation SYNLoginViewController

@synthesize state;
@synthesize appDelegate;
@synthesize signUpButton, facebookSignInButton;
@synthesize loginButton, finalLoginButton, passwordInputField, registerButton, userNameInputField;
@synthesize joingRockpackLabel;
@synthesize passwordForgottenButton, passwordForgottenLabel, areYouNewLabel, memberLabel, termsAndConditionsView;
@synthesize activityIndicator, dividerImageView;
@synthesize isAnimating;
@synthesize emailInputField, dobView, registerNewUserButton;
@synthesize titleImageView;
@synthesize ddInputField, mmInputField, yyyyInputField;
@synthesize labelsToErrorArrows;
@synthesize faceImageButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set up controls
    
    appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
    activityIndicator.hidesWhenStopped = YES;
    
    
    
    
    // == Setup Fonts for labels (except Input Fields)
    
    UIFont* rockpackBigLabelFont = [UIFont boldRockpackFontOfSize:24];
    
    memberLabel.font = rockpackBigLabelFont;
    areYouNewLabel.font = rockpackBigLabelFont;
    
    passwordForgottenLabel.font = [UIFont rockpackFontOfSize:14];
    
    joingRockpackLabel.font = [UIFont boldRockpackFontOfSize:23];
    
    labelsToErrorArrows = [[NSMutableDictionary alloc] init];
    
    ddInputField.keyboardType = UIKeyboardTypeNumberPad;
    mmInputField.keyboardType = UIKeyboardTypeNumberPad;
    yyyyInputField.keyboardType = UIKeyboardTypeNumberPad;
    
    passwordInputField.secureTextEntry = YES;
    
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
                                passwordForgottenButton, termsAndConditionsView, dobView, emailInputField,
                                registerNewUserButton, dividerImageView, faceImageButton, joingRockpackLabel];
    for (UIView* control in controlsToHide) {
       
        control.alpha = 0.0;
    }
    
    
    faceImageButton.center = CGPointMake(faceImageButton.center.x,
                                         faceImageButton.center.y - kOffsetForLoginForm);
    
}



-(void)setUpLoginStateFromPreviousState:(kLoginScreenState)previousState
{
    
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
        termsAndConditionsView.center = CGPointMake(termsAndConditionsView.center.x, termsAndConditionsView.center.y - kOffsetForLoginForm);
        activityIndicator.center = CGPointMake(activityIndicator.center.x, activityIndicator.center.y - kOffsetForLoginForm);
        
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
                termsAndConditionsView.alpha = 1.0;
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
                    
                    memberLabel.center = CGPointMake(loginButton.center.x + 5.0,
                                                     loginButton.frame.origin.y - 17.0);
                    
                    
                    memberLabel.frame = CGRectIntegral(memberLabel.frame);
                    
                    registerNewUserButton.center = CGPointMake(registerNewUserButton.center.x,
                                                               registerNewUserButton.center.y - kOffsetForLoginForm);
                    
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
            
            joingRockpackLabel.alpha = 0.0;
            
            termsAndConditionsView.alpha = 1.0;
            
            
            
        } completion:^(BOOL finished) {
            isAnimating = NO;
            [userNameInputField becomeFirstResponder];
        }];
    }
    
    
    
}

-(void)setupRegisterStateFromState:(kLoginScreenState)previousState
{
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
            termsAndConditionsView.center = CGPointMake(termsAndConditionsView.center.x, termsAndConditionsView.center.y - kOffsetForLoginForm);
            
            [emailInputField becomeFirstResponder];
            
            loginButton.center = CGPointMake(registerButton.center.x, registerButton.center.y);
            
            memberLabel.center = CGPointMake(loginButton.center.x + 5.0, loginButton.frame.origin.y - 17.0);
            memberLabel.frame = CGRectIntegral(memberLabel.frame);
            
            faceImageButton.center = CGPointMake(faceImageButton.center.x + 50.0,
                                                 faceImageButton.center.y);
            
            [UIView animateWithDuration:0.3 animations:^{
                memberLabel.alpha = 1.0;
                loginButton.alpha = 1.0;
                faceImageButton.alpha = 1.0;
                
                joingRockpackLabel.alpha = 1.0;
            }];
        }];
    }
    
    
    else if(previousState == kLoginScreenStateLogin)
    {
        // prepare in the correct place
        
        loginButton.center = CGPointMake(registerButton.center.x, registerButton.center.y);
        memberLabel.center = CGPointMake(loginButton.center.x + 5.0, loginButton.frame.origin.y - 17.0);
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
            
            
            
            joingRockpackLabel.alpha = 1.0;
        }];
    }

    [UIView animateWithDuration:0.3 animations:^{
        
        facebookSignInButton.alpha = 0.0;
    
        titleImageView.alpha = 0.0;
        registerNewUserButton.alpha = 1.0;
        
        dividerImageView.alpha = 0.0;
        
        registerNewUserButton.alpha = 1.0;
        
        
        termsAndConditionsView.alpha = 0.0;
    
        
        passwordForgottenButton.alpha = 0.0;
        passwordForgottenLabel.alpha = 0.0;
    
        
        finalLoginButton.alpha = 0.0;
        finalLoginButton.center = CGPointMake(finalLoginButton.center.x + 50.0,
                                          finalLoginButton.center.y);
    
        registerButton.alpha = 0.0;
        areYouNewLabel.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        [emailInputField becomeFirstResponder];
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
        [self placeErrorLabel:@"Please enter a password"NextToView:passwordInputField];
        [passwordInputField becomeFirstResponder];
        return NO;
    }
    
    
    return YES;
}

-(IBAction)doLogin:(id)sender
{
    
    
    [self clearAllErrorArrows];
    
    if(![self loginFormIsValid])
        return;
    
    
    [userNameInputField resignFirstResponder];
    [passwordInputField resignFirstResponder];
    
    
    [UIView animateWithDuration:0.1 animations:^{
        finalLoginButton.alpha = 0.0;
    }];
    [activityIndicator startAnimating];
    
    [appDelegate.networkEngine doSimpleLoginForUsername:userNameInputField.text
                                            forPassword:passwordInputField.text
                                           withComplete:^(AccessInfo* accessInfo) {
                                               
                                               
                                               [self completeLoginProcess:accessInfo];
                                           
                                           } andError:^(NSError * error) {
        
                                           }];
    
}

-(IBAction)faceButtonImagePressed:(id)sender
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
    SYNFacebookManager* facebookManager = [SYNFacebookManager sharedFBManager];
    
    [facebookManager loginOnSuccess:^(NSDictionary<FBGraphUser> *dictionary) {
        
        DebugLog(@"Loged in!");
            
        
    } onFailure:^(NSString* errorString) {
        
        DebugLog(@"Log in failed!");
        
    }];
    
}

-(IBAction)forgottenPasswordPressed:(id)sender
{
    
}
-(BOOL)registrationFormIsValid
{
    // email
    
    if(emailInputField.text.length < 1) {
        [self placeErrorLabel:@"Please enter an email address" NextToView:emailInputField];
        [emailInputField becomeFirstResponder];
        return NO;
    }
    
    // regular expression through RegexKitLite.h (not arc compatible)
    if(![emailInputField.text isMatchedByRegex:@"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b"]) {
        [self placeErrorLabel:@"Email Address Not Valid" NextToView:emailInputField];
        [emailInputField becomeFirstResponder];
        return NO;
    }
    
    if(userNameInputField.text.length < 1) {
        [self placeErrorLabel:@"Please enter a user name" NextToView:userNameInputField];
        [userNameInputField becomeFirstResponder];
        return NO;
    }
    
    
    if(passwordInputField.text.length < 1) {
        [self placeErrorLabel:@"Please enter a password"NextToView:passwordInputField];
        [passwordInputField becomeFirstResponder];
        return NO;
    }
    
    if(ddInputField.text.length != 2 || mmInputField.text.length != 2 || yyyyInputField.text.length != 4) {
        [self placeErrorLabel:@"Date Invalid" NextToView:dobView];
        [ddInputField becomeFirstResponder];
        return NO;
    }
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    NSArray* dobTextFields = @[mmInputField, ddInputField, yyyyInputField];
    for (UITextField* dobField in dobTextFields) {
        if(![numberFormatter numberFromString:dobField.text]) {
            [self placeErrorLabel:@"Only enter numbers" NextToView:dobView];
            [dobField becomeFirstResponder];
            return NO;
        }
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
-(IBAction)registerNewUser:(id)sender
{
    // Check Text Fields
    
    
    [self clearAllErrorArrows];
    
    if(![self registrationFormIsValid])
        return;
    
    
    [UIView animateWithDuration:0.2 animations:^{
        registerNewUserButton.alpha = 0.0;
    }];
    
    NSDictionary* userData = @{@"username": userNameInputField.text,
                               @"password": passwordInputField.text,
                               @"date_of_birth": [NSString stringWithFormat:@"%@-%@-%@", yyyyInputField.text, mmInputField.text, ddInputField.text],
                               @"locale":@"en-US",
                               @"email": emailInputField.text};
    
    [activityIndicator startAnimating];
    
    [appDelegate.networkEngine registerUserWithData:userData
     
                                       withComplete:^(AccessInfo* accessinfo) {
                                           
                                           [self completeLoginProcess:accessinfo];
        
                                       } andError:^(NSDictionary* errorDictionary) {
                                           
                                           NSDictionary* formErrors = [errorDictionary objectForKey:@"form_errors"];
                                           
                                           if(formErrors) {
                                               
                                               [self showRegistrationError:formErrors];
                                           }
                                           
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
    
    [UIView animateWithDuration:0.3 animations:^{
        errorArrow.alpha = 1.0;
    }];
    
    [labelsToErrorArrows setObject:errorArrow forKey:[NSValue valueWithPointer:(__bridge const void *)(view)]];
    [self.view addSubview:errorArrow];
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


-(void)completeLoginProcess:(AccessInfo*) accessInfo
{
    [activityIndicator stopAnimating];
    
    [UIView animateWithDuration:0.4 animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoginCompleted object:self];
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


#pragma mark CoreData Access





@end
