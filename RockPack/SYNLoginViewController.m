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

@interface SYNLoginViewController ()  <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIButton* facebookSignInButton;
@property (nonatomic, strong) IBOutlet UIButton* signUpButton;

@property (nonatomic, strong) IBOutlet UIButton* loginButton;

@property (nonatomic, strong) IBOutlet UIButton* finalLoginButton;

@property (nonatomic, strong) IBOutlet UIButton* passwordForgottenButton;

@property (nonatomic, strong) IBOutlet UIButton* registerButton;


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

@property (nonatomic, strong) IBOutlet UILabel* termsAndConditionsLabel;


@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* activityIndicator;

@property (nonatomic) BOOL isAnimating;

@property (nonatomic, weak) SYNAppDelegate* appDelegate;


#define kOffsetForLoginForm 100.0

@end

@implementation SYNLoginViewController

@synthesize state;
@synthesize appDelegate;
@synthesize signUpButton, facebookSignInButton;
@synthesize loginButton, finalLoginButton, passwordInputField, registerButton, userNameInputField;

@synthesize passwordForgottenButton, passwordForgottenLabel, areYouNewLabel, memberLabel, termsAndConditionsLabel;
@synthesize activityIndicator;
@synthesize isAnimating;
@synthesize emailInputField, dobView, registerNewUserButton;
@synthesize titleImageView;
@synthesize ddInputField, mmInputField, yyyyInputField;
@synthesize labelsToErrorArrows;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set up controls
    
    appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
    activityIndicator.hidesWhenStopped = YES;
    
    
    
    
    // == Setup Fonts for labels (except Input Fields)
    
    memberLabel.font = [UIFont boldRockpackFontOfSize:22];
    
    areYouNewLabel.font = [UIFont boldRockpackFontOfSize:22];
    passwordForgottenLabel.font = [UIFont rockpackFontOfSize:14];
    termsAndConditionsLabel.font = [UIFont rockpackFontOfSize:16];
    
    
    
    labelsToErrorArrows = [[NSMutableDictionary alloc] init];
    
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
    
    
    // == Setup Mock Credentials
    
    userNameInputField.text = @"test";
    passwordInputField.text = @"test";
    
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
                                passwordForgottenButton, termsAndConditionsLabel, dobView, emailInputField,
                                registerNewUserButton];
    for (UIView* control in controlsToHide) {
       
        control.alpha = 0.0;
    }
    
    
    
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
                    
                    
                    emailInputField.center = CGPointMake(emailInputField.center.x, emailInputField.center.y - kOffsetForLoginForm);
                    dobView.center = CGPointMake(dobView.center.x, dobView.center.y - kOffsetForLoginForm);
                }];
            }];
        }];
        
    }
    else if (previousState == kLoginScreenStateRegister)
    {
        
        
        [UIView animateWithDuration:0.5 animations:^{
            
            facebookSignInButton.alpha = 1.0;
            facebookSignInButton.center = CGPointMake(facebookSignInButton.center.x - 100.0,
                                                      facebookSignInButton.center.y);
            
            emailInputField.alpha = 0.0;
            emailInputField.center = CGPointMake(userNameInputField.center.x - 50.0,
                                                 emailInputField.center.y);
            
            dobView.alpha = 0.0;
            dobView.center = CGPointMake(userNameInputField.center.x - 50.0,
                                         dobView.center.y);
            
            
            registerNewUserButton.alpha = 0.0;
            
            finalLoginButton.alpha = 1.0;
            finalLoginButton.center = CGPointMake(finalLoginButton.center.x,
                                                  finalLoginButton.center.y - 50.0);
            
            passwordForgottenButton.alpha = 1.0;
            passwordForgottenLabel.alpha = 1.0;
            
            registerButton.alpha = 1.0;
            areYouNewLabel.alpha = 1.0;
            
            loginButton.alpha = 0.0;
            memberLabel.alpha = 0.0;
            
        } completion:^(BOOL finished) {
            isAnimating = NO;
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
        
        NSArray* loginForControls = @[emailInputField, userNameInputField, passwordInputField, dobView, termsAndConditionsLabel];
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
            facebookSignInButton.center = CGPointMake(facebookSignInButton.center.x,
                                                      facebookSignInButton.center.y - 150.0);
            signUpButton.alpha = 0.0;
        } completion:^(BOOL finished) {
            finalLoginButton.center = CGPointMake(finalLoginButton.center.x, finalLoginButton.center.y - kOffsetForLoginForm);
            passwordForgottenLabel.center = CGPointMake(passwordForgottenLabel.center.x, passwordForgottenLabel.center.y - kOffsetForLoginForm);
            passwordForgottenButton.center = CGPointMake(passwordForgottenButton.center.x, passwordForgottenButton.center.y - kOffsetForLoginForm);
            facebookSignInButton.center = CGPointMake(facebookSignInButton.center.x + 100.0,
                                                      facebookSignInButton.center.y + 50.0);
        }];
        
        
    }
    else if(previousState == kLoginScreenStateLogin)
    {
        // prepare in the correct place
        
        
        [UIView animateWithDuration:0.5 animations:^{
            
            
            emailInputField.alpha = 1.0;
            emailInputField.center = CGPointMake(userNameInputField.center.x,
                                                 emailInputField.center.y);
            
            dobView.alpha = 1.0;
            dobView.center = CGPointMake(userNameInputField.center.x,
                                         dobView.center.y);
            
            
            // move facebook button to the right
            facebookSignInButton.center = CGPointMake(facebookSignInButton.center.x + 100.0,
                                                      facebookSignInButton.center.y);
            
            
            
        }];
    }

    [UIView animateWithDuration:0.3 animations:^{
        
        facebookSignInButton.alpha = 0.0;
    
        titleImageView.alpha = 0.0;
        registerNewUserButton.alpha = 1.0;
    
        
        
        registerNewUserButton.alpha = 1.0;
    
        
        loginButton.alpha = 1.0;
        memberLabel.alpha = 1.0;
        
        passwordForgottenButton.alpha = 0.0;
        passwordForgottenLabel.alpha = 0.0;
    
        
        finalLoginButton.alpha = 0.0;
        finalLoginButton.center = CGPointMake(finalLoginButton.center.x,
                                          finalLoginButton.center.y + 50.0);
    
        registerButton.alpha = 0.0;
        areYouNewLabel.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
    }];
    
    

}



#pragma mark - Button Actions

-(IBAction)doLogin:(id)sender
{
    [UIView animateWithDuration:0.1 animations:^{
        finalLoginButton.alpha = 0.0;
    }];
    [activityIndicator startAnimating];
    
    [appDelegate.networkEngine doSimpleLoginForUsername:@"test"
                                            forPassword:@"test"
                                           withComplete:^(AccessInfo* accessInfo) {
                                               
                                               
                                               [self completeLoginProcess:accessInfo];
                                           
                                           } andError:^(NSError * error) {
        
                                           }];
    
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

-(IBAction)registerNewUser:(id)sender
{
    // Check Text Fields
    
    [UIView animateWithDuration:0.2 animations:^{
        registerNewUserButton.alpha = 0.0;
    }];
    
    NSDictionary* mockUserData = @{@"username": @"MikeM",
                                   @"password": @"MikeMM",
                                   @"date_of_birth": @"1979-03-01",
                                   @"locale":@"en-US",
                                   @"email": @"michael1@rockpack.com"};
    
    [activityIndicator startAnimating];
    
    [appDelegate.networkEngine registerUserWithData:mockUserData
                                       withComplete:^(AccessInfo* accessinfo) {
                                           
//                                           [appDelegate.networkEngine retrieveUserFromAccessInfo:accessinfo
//                                                                                    withComplete:^(User* user) {
//                                               
//                                                                                    } andError:^(NSDictionary* dict) {
//                                               
//                                                                                    }];
                                           
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
    
    if(emailInputField.text.length < 2 ||
       userNameInputField.text.length < 2 ||
       passwordInputField.text.length < 2) {
        return;
        
        
    }
    
//    NSString* dateFormatted = [NSString stringWithFormat:@"%@-%@-%@", yyyyInputField.text, mmInputField.text, ddInputField.text];
//    
//    NSDictionary* userData = @{@"username": userNameInputField.text,
//                               @"password": passwordInputField.text,
//                               @"date_of_birth":dateFormatted,
//                               @"locale":@"en-US",
//                               @"email": emailInputField.text};
    
    // Do registration
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

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [textField setText: @""];
    SYNLoginErrorArrow* possibleErrorArrow =
    (SYNLoginErrorArrow*)[labelsToErrorArrows objectForKey:[NSValue valueWithPointer:(__bridge const void *)(textField)]];
    if(possibleErrorArrow)
    {
        [UIView animateWithDuration:0.2 animations:^{
            possibleErrorArrow.alpha = 0.0;
        } completion:^(BOOL finished) {
            [possibleErrorArrow removeFromSuperview];
        }];
    }
    return YES;
}

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


#pragma mark CoreData Access





@end
