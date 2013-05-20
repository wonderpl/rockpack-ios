//
//  SYNLoginViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 11/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "RegexKitLite.h"
#import "SYNAccountSettingsPopoverBackgroundView.h"
#import "SYNActivityManager.h"
#import "SYNCameraPopoverViewController.h"
#import "SYNDeviceManager.h"
#import "SYNLoginErrorArrow.h"
#import "SYNLoginViewController.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuth2Credential.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNPopoverBackgroundView.h"
#import "UIFont+SYNFont.h"
#import "User.h"

@interface SYNLoginViewController ()  <UITextFieldDelegate, SYNImagePickerControllerDelegate>

@property (nonatomic) BOOL isAnimating;
@property (nonatomic) CGRect facebookButtonInitialFrame;
@property (nonatomic) CGRect initialUsernameFrame;
@property (nonatomic) CGRect signUpButtonInitialFrame;
@property (nonatomic, readonly) CGFloat elementsOffsetY;
@property (nonatomic, strong) IBOutlet UIButton* faceImageButton;
@property (nonatomic, strong) IBOutlet UIButton* facebookSignInButton;
@property (nonatomic, strong) IBOutlet UIButton* finalLoginButton;
@property (nonatomic, strong) IBOutlet UIButton* loginButton;
@property (nonatomic, strong) IBOutlet UIButton* registerButton;
@property (nonatomic, strong) IBOutlet UIButton* registerNewUserButton;
@property (nonatomic, strong) IBOutlet UIButton* sendEmailButton;
@property (nonatomic, strong) IBOutlet UIButton* signUpButton;
@property (nonatomic, strong) IBOutlet UIImageView* dividerImageView;
@property (nonatomic, strong) IBOutlet UIImageView* titleImageView;
@property (nonatomic, strong) IBOutlet UIImageView* avatarImageView;
@property (nonatomic, strong) IBOutlet UILabel* areYouNewLabel;
@property (nonatomic, strong) IBOutlet UILabel* memberLabel;
@property (nonatomic, strong) IBOutlet UILabel* passwordForgottenLabel;
@property (nonatomic, strong) IBOutlet UILabel* secondaryFacebookMessage;
@property (nonatomic, strong) IBOutlet UILabel* termsAndConditionsLabelSide;
@property (nonatomic, strong) NSArray* mainFormElements;
@property (nonatomic, strong) NSMutableDictionary* labelsToErrorArrows;
@property (nonatomic, strong) UIPopoverController* cameraMenuPopoverController;
@property (nonatomic, strong) UIPopoverController* cameraPopoverController;
@property (nonatomic, strong) IBOutlet UITextField* userNameInputField;
@property (nonatomic, strong) IBOutlet UITextField* passwordInputField;
@property (nonatomic, strong) IBOutlet UITextField* emailInputField;
@property (nonatomic, strong) IBOutlet UIView* dobView;
@property (nonatomic, strong) IBOutlet UITextField* ddInputField;
@property (nonatomic, strong) IBOutlet UITextField* mmInputField;
@property (nonatomic, strong) IBOutlet UITextField* yyyyInputField;
@property (nonatomic, strong) IBOutlet UILabel* wellSendYouLabel;
@property (nonatomic, strong) IBOutlet UILabel* termsAndConditionsLabel;

@end


#define kOffsetForRegisterForm 100.0

@implementation SYNLoginViewController

@synthesize state;
@synthesize signUpButton, facebookSignInButton;
@synthesize loginButton, finalLoginButton, passwordInputField, registerButton, userNameInputField;
@synthesize passwordForgottenButton, passwordForgottenLabel, areYouNewLabel, memberLabel, termsAndConditionsLabel;
@synthesize activityIndicator, dividerImageView, secondaryFacebookMessage;
@synthesize isAnimating, termsAndConditionsLabelSide;
@synthesize emailInputField, dobView, registerNewUserButton;
@synthesize titleImageView;
@synthesize ddInputField, mmInputField, yyyyInputField;
@synthesize labelsToErrorArrows;
@synthesize faceImageButton, facebookButtonInitialFrame, signUpButtonInitialFrame;
@synthesize sendEmailButton;
@synthesize wellSendYouLabel;
@synthesize elementsOffsetY;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Google Analytics support
    self.trackedViewName = @"Login";

    
    activityIndicator.hidesWhenStopped = YES;
    
        // == Setup Fonts for labels (except Input Fields)
        UIFont* rockpackBigLabelFont = [UIFont rockpackFontOfSize: 20];
        
        memberLabel.font = rockpackBigLabelFont;
        areYouNewLabel.font = rockpackBigLabelFont;
        
        passwordForgottenLabel.font = [UIFont rockpackFontOfSize: 14];
        secondaryFacebookMessage.font = [UIFont rockpackFontOfSize: 20];
        termsAndConditionsLabel.font = [UIFont rockpackFontOfSize: 14.0];
        termsAndConditionsLabelSide.font = termsAndConditionsLabel.font;
        wellSendYouLabel.font = [UIFont rockpackFontOfSize: 16.0];
    
        NSMutableAttributedString* termsString = [[NSMutableAttributedString alloc] initWithString: NSLocalizedString(@"BY USING ROCKPACK, YOU AGREE TO OUR\nTERMS & SERVICES AND PRIVACY POLICY", nil)];
        
        [termsString addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed: (70.0/255.0)
                                                                                         green: (206.0/255.0)
                                                                                          blue: (210.0/255.0)
                                                                                         alpha:(1.0)] range: NSMakeRange(36, 16)];
        
        [termsString addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed: (70.0/255.0)
                                                                                         green: (206.0/255.0)
                                                                                          blue: (210.0/255.0)
                                                                                         alpha: (1.0)] range: NSMakeRange(57, 14)];
        // add terms buttons
        termsAndConditionsLabel.attributedText = termsString;
        termsAndConditionsLabelSide.attributedText = termsAndConditionsLabel.attributedText;
        
        labelsToErrorArrows = [[NSMutableDictionary alloc] init];
        
        ddInputField.keyboardType = UIKeyboardTypeNumberPad;
        mmInputField.keyboardType = UIKeyboardTypeNumberPad;
        yyyyInputField.keyboardType = UIKeyboardTypeNumberPad;
        
        passwordInputField.secureTextEntry = YES;
        
        facebookButtonInitialFrame = facebookSignInButton.frame;
        signUpButtonInitialFrame = signUpButton.frame;
        
        emailInputField.keyboardType = UIKeyboardTypeEmailAddress;
        
        self.mainFormElements = @[];
        
        // == Setup Input Fields
        
        UIFont* rockpackInputFont = [UIFont rockpackFontOfSize: 20];
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
    
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(outerViewTapped:)];
        [self.view addGestureRecognizer:tapGesture];

}


#pragma mark - States and Transitions

- (void) setState: (kLoginScreenState) newState
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


- (kLoginScreenState) state
{
    return state;
}


- (void) setUpInitialState
{
    // controls to hide initially
    NSArray* controlsToHide = @[userNameInputField, passwordInputField, finalLoginButton, secondaryFacebookMessage,
                                areYouNewLabel, registerButton, passwordForgottenLabel,
                                passwordForgottenButton, termsAndConditionsLabel, dobView, emailInputField,
                                registerNewUserButton, dividerImageView, faceImageButton, self.avatarImageView, sendEmailButton,
                                wellSendYouLabel, termsAndConditionsLabelSide];
    
    for (UIView* control in controlsToHide)
    {
        control.alpha = 0.0;
    }
    
    dobView.center = CGPointMake(dobView.center.x - 50.0, dobView.center.y);
    emailInputField.center = CGPointMake(emailInputField.center.x - 50.0, emailInputField.center.y);
    faceImageButton.center = CGPointMake(faceImageButton.center.x - 50.0, faceImageButton.center.y);
    self.avatarImageView.center = CGPointMake(self.avatarImageView.center.x - 50.0, self.avatarImageView.center.y);
    
    facebookSignInButton.enabled = YES;
    facebookSignInButton.frame = facebookButtonInitialFrame;
    facebookSignInButton.alpha = 1.0;
    
    _facebookLoginIsInProcess = NO;
    
    if ([[SYNDeviceManager sharedInstance] isPortrait])
    {
        signUpButton.center = CGPointMake(facebookSignInButton.center.x + 304.0, signUpButton.center.y);
        faceImageButton.center = CGPointMake(78.0, faceImageButton.center.y);
        self.avatarImageView.center = CGPointMake(78.0, self.avatarImageView.center.y);
        passwordForgottenLabel.center = CGPointMake(650.0, passwordForgottenLabel.center.y);
    }

    signUpButton.enabled = YES;
    signUpButton.alpha = 1.0;
    [activityIndicator stopAnimating];  
}

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear:animated];
    
    memberLabel.center = CGPointMake(memberLabel.center.x, loginButton.center.y - 54.0);
    memberLabel.frame = CGRectIntegral(memberLabel.frame);
}

- (void) setUpPasswordState
{
    self.initialUsernameFrame = userNameInputField.frame;
    loginButton.frame = registerButton.frame;
    sendEmailButton.enabled = YES;
    memberLabel.center = CGPointMake(loginButton.center.x,
                                     registerButton.center.y - 57.0);
    
    userNameInputField.placeholder = NSLocalizedString(@"USERNAME OR PASSWORD", nil);
    
    memberLabel.frame = CGRectIntegral(memberLabel.frame);
    
    [UIView animateWithDuration: 0.5
                          delay: 0.0
                        options: UIViewAnimationCurveEaseInOut
                     animations: ^{
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
                     }
                     completion: ^(BOOL finished) {
                         dividerImageView.frame = CGRectIntegral(dividerImageView.frame);
                         [UIView animateWithDuration: 0.3
                                          animations: ^{
                                              wellSendYouLabel.alpha = 1.0;
                                          }];
                     }];
}


-(void)setUpLoginStateFromPreviousState:(kLoginScreenState)previousState
{
    secondaryFacebookMessage.alpha = 0.0;
    
    [self clearAllErrorArrows];
    
    isAnimating = YES;
    userNameInputField.placeholder = NSLocalizedString(@"USERNAME", nil);
    
    if (previousState == kLoginScreenStateInitial)
    {
        NSArray* loginForControls = @[facebookSignInButton, userNameInputField, passwordInputField, finalLoginButton];
        float delay = 0.0;
        
        for (UIView* control in loginForControls)
        {
            control.hidden = NO;
            
            [UIView animateWithDuration: 0.4
                                  delay: delay
                                options: UIViewAnimationCurveEaseInOut
                             animations: ^{
                                 control.alpha = 1.0;
                                 control.center = CGPointMake(control.center.x, control.center.y - self.elementsOffsetY);
                             }
                             completion: ^(BOOL finished) {
                             }];
            
            delay += 0.05;
        }
        
        [UIView animateWithDuration: 0.3
                         animations: ^{
                             signUpButton.alpha = 0.0; // right of facebook button
                             signUpButton.hidden = YES;
                             
                             memberLabel.alpha = 0.0;
                             loginButton.alpha = 0.0;
                             
                             titleImageView.alpha = 0.0;
                         }
                         completion: ^(BOOL finished) {
                             [self placeSecondaryElements];
                             
                             dividerImageView.center = CGPointMake(dividerImageView.center.x, dividerImageView.center.y - self.elementsOffsetY);
                             
                             [UIView animateWithDuration: 0.2
                                              animations: ^{
                                                  passwordForgottenButton.alpha = 1.0;
                                                  passwordForgottenLabel.alpha = 1.0;
                                                  
                                                  dividerImageView.alpha = 1.0;
                                              }
                                              completion: ^(BOOL finished) {
                                                  [UIView animateWithDuration: 0.2
                                                                   animations: ^{
                                                                       areYouNewLabel.alpha = 1.0;
                                                                       registerButton.alpha = 1.0;
                                                                       
                                                                       termsAndConditionsLabel.alpha = 1.0;
                                                                       
                                                                   }
                                                                   completion: ^(BOOL finished) {
                                                                       isAnimating = NO;
                                                                       
                                                                       
                                                                       emailInputField.center = CGPointMake(emailInputField.center.x,
                                                                                                            emailInputField.center.y - self.elementsOffsetY);
                                                                       dobView.center = CGPointMake(dobView.center.x,
                                                                                                    dobView.center.y - self.elementsOffsetY);
                                                                       
                                                                       memberLabel.center = CGPointMake(memberLabel.center.x,
                                                                                                        registerButton.center.y - 57.0);
                                                                       
                                                                       
                                                                       memberLabel.frame = CGRectIntegral(memberLabel.frame);
                                                                       
                                                                       
                                                                       
                                                                       
                                                                       sendEmailButton.frame = CGRectIntegral(sendEmailButton.frame);
                                                                       
                                                                       registerNewUserButton.center = CGPointMake(registerNewUserButton.center.x,
                                                                                                                  registerNewUserButton.center.y - self.elementsOffsetY);
                                                                       
                                                                       
                                                                       faceImageButton.center = CGPointMake(faceImageButton.center.x,
                                                                                                            faceImageButton.center.y - self.elementsOffsetY);
                                                                       
                                                                       self.avatarImageView.center = CGPointMake(self.avatarImageView.center.x,
                                                                                                            self.avatarImageView.center.y - self.elementsOffsetY);
                                                                       
                                                                       [userNameInputField becomeFirstResponder];
                                                                       
                                                                   }];
                                              }];
                         }];
        
    }
    else if (previousState == kLoginScreenStateRegister)
    {
        [UIView animateWithDuration: 0.5
                         animations: ^{
                             facebookSignInButton.alpha = 1.0;
                             facebookSignInButton.center = CGPointMake(self.userNameInputField.center.x, facebookSignInButton.center.y);
                             
                             emailInputField.alpha = 0.0;
                             emailInputField.center = CGPointMake(userNameInputField.center.x - 50.0,
                                                                  emailInputField.center.y);
                             
                             dobView.alpha = 0.0;
                             dobView.center = CGPointMake(userNameInputField.center.x - 50.0,
                                                          dobView.center.y);

                             dividerImageView.alpha = 1.0;
                             
                             registerNewUserButton.alpha = 0.0;
                             
                             finalLoginButton.alpha = 1.0;
                             
                             finalLoginButton.center = CGPointMake(userNameInputField.center.x,
                                                                   finalLoginButton.center.y);
                             
                             faceImageButton.alpha = 0.0;
                             faceImageButton.center = CGPointMake(faceImageButton.center.x - 50.0,
                                                                  faceImageButton.center.y);
                             
                             self.avatarImageView.alpha = 0.0;
                             self.avatarImageView.center = CGPointMake(self.avatarImageView.center.x - 50.0,
                                                                  self.avatarImageView.center.y);
                             
                             passwordForgottenButton.alpha = 1.0;
                             passwordForgottenLabel.alpha = 1.0;
                             
                             registerButton.alpha = 1.0;
                             areYouNewLabel.alpha = 1.0;
                             
                             loginButton.alpha = 0.0;
                             memberLabel.alpha = 0.0;

                             termsAndConditionsLabelSide.alpha = 0.0;

                             termsAndConditionsLabel.alpha = 1.0;
                         }
                         completion: ^(BOOL finished) {
                             isAnimating = NO;
                             [userNameInputField becomeFirstResponder];
                         }];
    }
    else if (previousState == kLoginScreenStatePasswordRetrieve)
    {
        [UIView animateWithDuration: 0.5
                         animations: ^{
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
                         }
                         completion: ^(BOOL finished) {
                             isAnimating = NO;
                             [userNameInputField becomeFirstResponder];
                         }];
    }
}

- (void) setUpRegisterStateFromState: (kLoginScreenState) previousState
{
    secondaryFacebookMessage.alpha = 0.0;
    
    [self clearAllErrorArrows];
    isAnimating = YES;
    userNameInputField.placeholder = NSLocalizedString(@"USERNAME", nil);
    if(previousState == kLoginScreenStateInitial)
    {
        emailInputField.center = CGPointMake(userNameInputField.center.x,
                                             emailInputField.center.y);
        emailInputField.frame = CGRectIntegral(emailInputField.frame);
        
        
        dobView.center = CGPointMake(userNameInputField.center.x,
                                     dobView.center.y);
        dobView.frame = CGRectIntegral(dobView.frame);
        
        
        NSArray* loginForControls = @[emailInputField, userNameInputField, passwordInputField, dobView, registerNewUserButton];
        float delay = 0.05;
        for (UIView* control in loginForControls)
        {
            control.hidden = NO;
            
            [UIView animateWithDuration: 0.5
                                  delay: delay
                                options: UIViewAnimationCurveEaseInOut
                             animations: ^{
                                 control.alpha = 1.0;
                                 control.center = CGPointMake(control.center.x, control.center.y - self.elementsOffsetY);
                             }
                             completion: ^(BOOL finished) {
                             }];
            delay += 0.05;
        }
        
        [UIView animateWithDuration:0.4
                         animations: ^{
                             memberLabel.alpha = 0.0;
                             loginButton.alpha = 0.0;
                             
                             signUpButton.alpha = 0.0;
                             signUpButton.hidden = YES;
                         }
                         completion: ^(BOOL finished) {
                             finalLoginButton.center = CGPointMake(finalLoginButton.center.x, finalLoginButton.center.y - self.elementsOffsetY);
                             
                             facebookSignInButton.center = CGPointMake(facebookSignInButton.center.x + kOffsetForRegisterForm, facebookSignInButton.center.y - self.elementsOffsetY);
                             
                             [self placeSecondaryElements];
                             
                             memberLabel.center = CGPointMake(loginButton.center.x, areYouNewLabel.center.y - 8.0);
                             
                             CGRect faceRect = faceImageButton.frame;
                             faceRect.origin.x = userNameInputField.frame.origin.x - 10.0 - faceRect.size.width;
                             faceRect.origin.y -= self.elementsOffsetY;
                             faceImageButton.frame = faceRect;
                             self.avatarImageView.frame = faceRect;
                             
                             isAnimating = NO;
                             
                             [UIView animateWithDuration: 0.3
                                              animations: ^{
                                                  memberLabel.alpha = 1.0;
                                                  loginButton.alpha = 1.0;
                                                  faceImageButton.alpha = 1.0;
                                                  self.avatarImageView.alpha = 1.0;
                                                  
                                                  termsAndConditionsLabelSide.alpha = 1.0;
                                              }
                                              completion: ^(BOOL finished) {
                                                  [emailInputField becomeFirstResponder];
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
        
        [UIView animateWithDuration: 0.5
                         animations: ^{
                             emailInputField.alpha = 1.0;
                             emailInputField.center = CGPointMake(userNameInputField.center.x,
                                                                  emailInputField.center.y);
                             
                             dobView.alpha = 1.0;
                             CGRect dobRect = dobView.frame;
                             dobRect.origin.x = self.userNameInputField.frame.origin.x;
                             dobView.frame = dobRect;
                             
                             faceImageButton.alpha = 1.0;
                             self.avatarImageView.alpha = 1.0;
                             CGRect faceRect = faceImageButton.frame;
                             faceRect.origin.x = userNameInputField.frame.origin.x - 10.0 - faceRect.size.width;
                             faceImageButton.frame = faceRect;
                             self.avatarImageView.frame = faceRect;
                             
                             loginButton.alpha = 1.0;
                             memberLabel.alpha = 1.0;
                             
                             termsAndConditionsLabelSide.alpha = 1.0;
                             
                             // move facebook button to the right
                             facebookSignInButton.center = CGPointMake(facebookSignInButton.center.x + kOffsetForRegisterForm,
                                                                       facebookSignInButton.center.y);
                         } completion: ^(BOOL finished) {
                             [emailInputField becomeFirstResponder];
                         }];
    }
    
    [UIView animateWithDuration: 0.4
                     animations: ^{
                         
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
                     }
                     completion: ^(BOOL finished) {
                         isAnimating = NO;
                     }];
}


#pragma mark - Button Actions

- (BOOL) loginFormIsValid
{
    // email
    if (userNameInputField.text.length < 1)
    {
        [self placeErrorLabel: NSLocalizedString(@"Please enter a user name", nil)
                   nextToView: userNameInputField];
        
        [userNameInputField becomeFirstResponder];
        
        return NO;
    }

    if (passwordInputField.text.length < 1)
    {
        [self placeErrorLabel: NSLocalizedString(@"Please enter a password", nil)
                   nextToView: passwordInputField];
        
        [passwordInputField becomeFirstResponder];
        
        return NO;
    }

    return YES;
}




- (IBAction) doLogin: (id) sender
{
    
    [self clearAllErrorArrows];
    
    [self resignAllFirstResponders];
    
    if(![self isNetworkAccessibleOtherwiseShowErrorAlert])
    {
        return;
    }
    
    if(![self loginFormIsValid])
        return;
    
    finalLoginButton.enabled = NO;
    
    [UIView animateWithDuration: 0.1 animations:^
     {
         finalLoginButton.alpha = 0.0;
     }];
    
    activityIndicator.center = CGPointMake(finalLoginButton.center.x, finalLoginButton.center.y);
    [activityIndicator startAnimating];
    
    [self loginForUsername:userNameInputField.text forPassword:passwordInputField.text completionHandler:^(NSDictionary* dictionary) {
        NSString* username = [dictionary objectForKey: @"username"];
        DebugLog(@"User Registerd: %@", username);
        
        // by this time the currentUser is set in the DB //
        
        [activityIndicator stopAnimating];
        
        [self completeLoginProcess];
        
    } errorHandler:^(NSDictionary* errorDictionary) {
        NSDictionary* errors = errorDictionary [@"error"];
        
        if (errors)
        {
            [self placeErrorLabel: @"Username could be incorrect"
                       nextToView: userNameInputField];
            
            [self placeErrorLabel: @"Password could be incorrect"
                       nextToView: passwordInputField];
        }
        
        finalLoginButton.enabled = YES;
        
        [activityIndicator stopAnimating];
        
        [UIView animateWithDuration: 0.3
                         animations: ^{
                             finalLoginButton.alpha = 1.0;
                         } completion: ^(BOOL finished) {
                             [userNameInputField becomeFirstResponder];
                         }];
    }];
}


- (IBAction) goToLoginForm: (id) sender
{
    if(isAnimating)
        return;
    
    self.state = kLoginScreenStateLogin;
}


- (IBAction) sendEmailButtonPressed: (id) sender
{
    if(![self isNetworkAccessibleOtherwiseShowErrorAlert])
    {
        return;
    }
    
    [self doRequestPasswordResetForUsername:self.userNameInputField.text completionHandler:^(NSDictionary * completionInfo) {
        if ([completionInfo valueForKey: @"error"])
        {
            [self placeErrorLabel: @"User unknown"
                       nextToView: self.userNameInputField];
            
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle: @"Password Reset"
                                        message: @"Check your email for instructions"
                                       delegate: nil
                              cancelButtonTitle: @"OK"
                              otherButtonTitles: nil] show];
            
        }

    } errorHandler:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle: @"Password Reset"
                                    message: @"Error, request failed..."
                                   delegate: nil
                          cancelButtonTitle: @"OK"
                          otherButtonTitles: nil] show];
        
    }];
}

- (void) doFacebookLoginAnimation
{
    [UIView animateWithDuration: 0.3
                     animations: ^{
                         if(!signUpButton.hidden)
                         {
                             signUpButton.alpha = 0.0;
                             signUpButton.center = CGPointMake(signUpButton.center.x + 10.0, signUpButton.center.y);
                         }
                     }
                     completion: ^(BOOL finished) {
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
}

- (void) doFacebookFailAnimation
{
    [UIView animateWithDuration: 0.3
                     animations: ^{
                         if(!signUpButton.hidden)
                         {
                             signUpButton.alpha = 1.0;
                             signUpButton.center = CGPointMake(signUpButton.center.x - 10.0, signUpButton.center.y);
                         }
                     }
                     completion: ^(BOOL finished) {
                     }];
    
    userNameInputField.enabled = YES;
    passwordForgottenButton.enabled = YES;
    finalLoginButton.enabled = YES;
    loginButton.enabled = YES;
    passwordForgottenButton.enabled = YES;
    
    [activityIndicator stopAnimating];
}


- (IBAction) signInWithFacebook: (id) sender
{
    _facebookLoginIsInProcess = NO;
    
    [self clearAllErrorArrows];
    
    if(![self isNetworkAccessibleOtherwiseShowErrorAlert])
    {
        return;
    }
    
    facebookSignInButton.enabled = NO;
    [self doFacebookLoginAnimation];
    
    [self loginThroughFacebookWithCompletionHandler:^(NSDictionary * dictionary) {
        [activityIndicator stopAnimating];
        [self completeLoginProcess];
        
    } errorHandler:^(id error) {
        
        [self doFacebookFailAnimation];
        
        if([error isKindOfClass:[NSDictionary class]])
        {
            NSDictionary* formErrors = error[@"form_errors"];
            
            if (formErrors)
            {
                facebookSignInButton.enabled = YES;
                secondaryFacebookMessage.text = NSLocalizedString(@"Could not log in through facebook", nil);
                secondaryFacebookMessage.alpha = 1.0;
            }

        }
        else if([error isKindOfClass:[NSString class]])
        {_facebookLoginIsInProcess = NO;
            
            // TODO: Use custom alert box here
            [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Facebook Login", nil)
                                        message: error
                                       delegate: nil
                              cancelButtonTitle: NSLocalizedString(@"OK", nil)
                              otherButtonTitles: nil] show];
            
            DebugLog(@"Log in failed!");
        }
        else
        {
            //Should not happen!
        }
        
    }];
}

- (IBAction) forgottenPasswordPressed: (id) sender
{
    self.state = kLoginScreenStatePasswordRetrieve;
}


- (void) showAutologinWithCredentials: (SYNOAuth2Credential*) credentials
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


- (BOOL) registrationFormIsValid
{
    if (emailInputField.text.length < 1)
    {
        [self placeErrorLabel: @"Please enter an email address"
                   nextToView: emailInputField];
        
        [emailInputField becomeFirstResponder];
        
        return NO;
    }
    
    // == Regular expression through RegexKitLite.h (not arc compatible) == //
    
    if (![emailInputField.text isMatchedByRegex: @"^([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})$"])
    {
        [self placeErrorLabel: NSLocalizedString(@"Email Address Not Valid", nil)
                   nextToView: emailInputField];
        
        [emailInputField becomeFirstResponder];
        
        return NO;
    }
    
    if (userNameInputField.text.length < 1)
    {
        [self placeErrorLabel: NSLocalizedString(@"Please enter a user name", nil)
                   nextToView: userNameInputField];
        
        [userNameInputField becomeFirstResponder];
        
        return NO;
    }
    
    // == Username must be
    if (![userNameInputField.text isMatchedByRegex:@"^[a-zA-Z0-9\\._]+$"])
    {
        [self placeErrorLabel: NSLocalizedString(@"Username has invalid characters", nil)
                   nextToView: userNameInputField];
        
        [userNameInputField becomeFirstResponder];
        
        return NO;
    }
    
    
    if (passwordInputField.text.length < 1)
    {
        [self placeErrorLabel: NSLocalizedString(@"Please enter a password", nil)
                   nextToView: passwordInputField];
        
        [passwordInputField becomeFirstResponder];
        
        return NO;
    }
    
    // == Check for date == // 
    
    if (ddInputField.text.length != 2 || mmInputField.text.length != 2 || yyyyInputField.text.length != 4)
    {
        [self placeErrorLabel: NSLocalizedString(@"Date Invalid", nil)
                   nextToView:dobView];
        
        [ddInputField becomeFirstResponder];
        
        return NO;
    }
    
    // == Check wether the DOB fields contain numbers == //
    
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    NSArray* dobTextFields = @[mmInputField, ddInputField, yyyyInputField];
    for (UITextField* dobField in dobTextFields)
    {
        if(![numberFormatter numberFromString: dobField.text])
        {
            [self placeErrorLabel: NSLocalizedString(@"Only enter numbers", nil)
                       nextToView: dobView];
            
            [dobField becomeFirstResponder];
            
            return NO;
        }
    }
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    NSDate* potentialDate = [dateFormatter dateFromString: [self dateStringFromCurrentInput]];
    
    // == Not a real date == //
    
    if(!potentialDate)
    {
        [self placeErrorLabel: NSLocalizedString(@"The Date is not Valid", nil)
                   nextToView: dobView];
        
        return NO;
    }
    
    NSDate* nowDate = [NSDate date];
    
    // == In the future == //
    
    if ([nowDate compare:potentialDate] == NSOrderedAscending) {
        [self placeErrorLabel: NSLocalizedString(@"The Date is in the future", nil)
                   nextToView: dobView];
        
        return NO;
    }
    
    // == Yonger than 13 == //
    
    
    NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* nowDateComponents = [gregorian components:(NSYearCalendarUnit) fromDate:nowDate];
    nowDateComponents.year -= 13;
    
    NSDate* tooYoungDate = [gregorian dateFromComponents:nowDateComponents];
    
    if([tooYoungDate compare:potentialDate] == NSOrderedAscending) {
        
        [self placeErrorLabel: NSLocalizedString(@"Cannot create an account for under 13", nil)
                   nextToView: dobView];
        
        return NO;
    }
    

    return YES;
}





- (void) resignAllFirstResponders
{
    NSArray* allTextFields = @[emailInputField, userNameInputField, passwordForgottenButton, ddInputField, mmInputField, yyyyInputField];
    
    for (UITextField* textField in allTextFields)
    {
        [textField resignFirstResponder];
    }
}


- (NSString*) dateStringFromCurrentInput
{
    return [NSString stringWithFormat: @"%@-%@-%@", yyyyInputField.text, mmInputField.text, ddInputField.text];
}


- (IBAction) registerNewUser: (id) sender
{
    // Check Text Fields
    [self clearAllErrorArrows];
    
    if(![self registrationFormIsValid])
        return;
    
    [self resignAllFirstResponders];
    
    if(![self isNetworkAccessibleOtherwiseShowErrorAlert])
    {
        return;
    }

    
    [UIView animateWithDuration: 0.2
                     animations: ^{
                         registerNewUserButton.alpha = 0.0;
                     }];
    
    NSDictionary* userData = @{@"username": userNameInputField.text,
                               @"password": passwordInputField.text,
                               @"date_of_birth": [self dateStringFromCurrentInput],
                               @"locale":@"en-US",
                               @"email": emailInputField.text};
    
    activityIndicator.center = CGPointMake(registerNewUserButton.center.x, registerNewUserButton.center.y);
    [activityIndicator startAnimating];
    
    [self registerUserWithData:userData completionHandler:^(NSDictionary* dictionary)
    {
        
        [activityIndicator stopAnimating];
        
        [self completeLoginProcess];
        
        if (self.avatarImage)
        {
            [self uploadAvatar: self.avatarImage];
        }

        
    }
    errorHandler:^(NSDictionary* errorDictionary)
    {
        NSDictionary* formErrors = [errorDictionary objectForKey:@"form_errors"];
        
        if (formErrors)
        {
            [self showRegistrationError:formErrors];
        }
        
        registerNewUserButton.enabled = YES;
        
        [activityIndicator stopAnimating];
        registerNewUserButton.alpha = 1.0;
    }];
}

- (void) uploadAvatar: (UIImage *) avatarImage;
{
    [self uploadAvatarImage:avatarImage completionHandler:^(NSDictionary* dictionary) {
        DebugLog(@"Avatar uploaded successfully");
    } errorHandler:^(NSDictionary* errorDictionary) {
         DebugLog(@"Avatar upload failed");
    }];
}

- (void) showRegistrationError: (NSDictionary*) errorDictionary
{
    // form errors
    NSArray* usernameError = [errorDictionary objectForKey: @"username"];
    //NSArray* localeError = [errorDictionary objectForKey:@"locale"];
    NSArray* passwordError = [errorDictionary objectForKey :@"password"];
    NSArray* emailError = [errorDictionary objectForKey: @"email"];
    
    if(usernameError)
        [self placeErrorLabel: (NSString*)[usernameError objectAtIndex: 0]
                   nextToView: userNameInputField];
    
    // TODO: deal with locale
    
    if(passwordError)
        [self placeErrorLabel: (NSString*)[passwordError objectAtIndex: 0]
                   nextToView: passwordInputField];
    
    if(emailError)
        [self placeErrorLabel: (NSString*)[emailError objectAtIndex: 0]
                   nextToView: emailInputField];
    
}

#pragma mark - Error Arrows

- (void) placeErrorLabel: (NSString*) errorText
              nextToView: (UIView*) view
{
    
    
    SYNLoginErrorArrow* errorArrow = [labelsToErrorArrows objectForKey:[NSValue valueWithPointer:(__bridge const void *)(view)]];
    if(errorArrow)
    {
        [errorArrow setMessage:errorText];
        return;
    }
    
    errorArrow = [SYNLoginErrorArrow withMessage:errorText];
    
    CGFloat xPos = view.frame.origin.x + view.frame.size.width - 20.0;
    CGRect errorArrowFrame = errorArrow.frame;
    errorArrowFrame.origin.x = xPos;
    
    errorArrow.frame = errorArrowFrame;
    errorArrow.center = CGPointMake(errorArrow.center.x, view.center.y);
    
    errorArrow.alpha = 0.0;
    
    
    [UIView animateWithDuration: 0.2
                     animations: ^{
                         errorArrow.alpha = 1.0;
                     }];
    
    [labelsToErrorArrows setObject:errorArrow forKey:[NSValue valueWithPointer:(__bridge const void *)(view)]];
    [self.view addSubview:errorArrow];
}

- (void) clearAllErrorArrows
{
    [labelsToErrorArrows enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop)
     {
         SYNLoginErrorArrow* arrow = (SYNLoginErrorArrow*)value;
         [arrow removeFromSuperview];
     }];
    
    [labelsToErrorArrows removeAllObjects];
}

- (void) outerViewTapped: (UITapGestureRecognizer*) recogniser
{
    
    
    [labelsToErrorArrows enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop){
        
        SYNLoginErrorArrow* arrow = (SYNLoginErrorArrow*)value;
        [UIView animateWithDuration:0.2
                         animations: ^{
                             arrow.alpha = 0.0;
                         }
                         completion: ^(BOOL finished) {
                             [labelsToErrorArrows removeObjectForKey:key];
                             [arrow removeFromSuperview];
                         }];
    }];
}


- (IBAction) registerPressed: (id) sender
{
    if(self.isAnimating)
        return;
    
    self.state = kLoginScreenStateRegister;
}


- (IBAction) signUp: (id) sender
{
    self.state = kLoginScreenStateRegister;
}


- (void) completeLoginProcess
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
                     completion: ^(BOOL finished) {
                         [[NSNotificationCenter defaultCenter] postNotificationName: kLoginCompleted
                                                                             object: self];
                         
                     }];
}


#pragma mark - TextField Delegate Methods

- (BOOL) textField: (UITextField *) textField
         shouldChangeCharactersInRange: (NSRange) range
         replacementString: (NSString *) newCharacter
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
    (SYNLoginErrorArrow*)[labelsToErrorArrows objectForKey: key];
    
    if (possibleErrorArrow)
    {
        [UIView animateWithDuration: 0.2
                         animations: ^{
                             possibleErrorArrow.alpha = 0.0;
                         }
                         completion: ^(BOOL finished) {
                             [possibleErrorArrow removeFromSuperview];
                             [labelsToErrorArrows removeObjectForKey:key];
                         }];
    }
    return YES;
}


- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    
    
    if(self.state == kLoginScreenStateLogin)
    {
        
        if(self.userNameInputField.text.length < 1) {
            self.userNameInputField.returnKeyType = UIReturnKeyNext;
            [self.userNameInputField becomeFirstResponder];
            return YES;
        }
        if (self.passwordInputField.text.length < 1) {
            self.passwordInputField.returnKeyType = UIReturnKeyGo;
            [self.passwordInputField becomeFirstResponder];
            return YES;
        }
        
        [self doLogin:self.finalLoginButton];
            
    
    }
    else if(self.state == kLoginScreenStateRegister)
    {
        
        if(self.emailInputField.text.length < 1) {
            self.emailInputField.returnKeyType = UIReturnKeyNext;
            [self.emailInputField becomeFirstResponder];
            return YES;
        }
        
        if(self.userNameInputField.text.length < 1) {
            self.userNameInputField.returnKeyType = UIReturnKeyNext;
            [self.userNameInputField becomeFirstResponder];
            return YES;
        }
        
        if(self.passwordInputField.text.length < 1) {
            self.passwordInputField.returnKeyType = UIReturnKeyNext;
            [self.passwordInputField becomeFirstResponder];
            return YES;
        }
        if(self.ddInputField.text.length < 1) {
            self.ddInputField.returnKeyType = UIReturnKeyNext;
            [self.ddInputField becomeFirstResponder];
            return YES;
        }
        if(self.mmInputField.text.length < 1) {
            self.mmInputField.returnKeyType = UIReturnKeyNext;
            [self.mmInputField becomeFirstResponder];
            return YES;
        }
        if(self.yyyyInputField.text.length < 1) {
            self.yyyyInputField.returnKeyType = UIReturnKeyDone;
            [self.yyyyInputField becomeFirstResponder];
            return YES;
        }
        
        [self registerNewUser:self.registerNewUserButton];
        return YES;
    
    }
    else if(self.state == kLoginScreenStatePasswordRetrieve)
    {
        if(self.userNameInputField.text.length < 1) {
            self.passwordInputField.returnKeyType = UIReturnKeySend;
            [self.userNameInputField becomeFirstResponder];
            return YES;
        }
        
        [self sendEmailButtonPressed:self.sendEmailButton];
        return YES;
    
    }

    // default case just go to the next text field (from 6 text fields)
    
    [((UITextField*)[self.view viewWithTag:(textField.tag+1)%6]) becomeFirstResponder];
    
    return YES;
}




#pragma mark - Avatar image selection


- (IBAction) faceButtonImagePressed: (UIButton*) button
{
    self.imagePicker = [[SYNImagePickerController alloc] initWithHostViewController:self];
    self.imagePicker.delegate = self;
    [self.imagePicker presentImagePickerAsPopupFromView:button arrowDirection:UIPopoverArrowDirectionLeft];
}

-(void)picker:(SYNImagePickerController *)picker finishedWithImage:(UIImage *)image
{
    self.imagePicker = nil;
    // Save our avatar
    self.avatarImage = image;
    
    // And update on-screen avatar
    self.avatarImageView.image = image;
}

#pragma mark - Rotation support

- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    [super willAnimateRotationToInterfaceOrientation: toInterfaceOrientation
                                            duration: duration];
    
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        signUpButton.center = CGPointMake(604.0, signUpButton.center.y);
        passwordForgottenLabel.center = CGPointMake(650.0, passwordForgottenLabel.center.y);
        faceImageButton.center = CGPointMake(124.0, faceImageButton.center.y);
        self.avatarImageView.center = CGPointMake(124.0, self.avatarImageView.center.y);
        termsAndConditionsLabel.center = CGPointMake(termsAndConditionsLabel.center.x, 714.0);
        termsAndConditionsLabelSide.center = CGPointMake(termsAndConditionsLabelSide.center.x, 714.0);
        
        registerButton.center = CGPointMake(registerButton.center.x, 704.0); 
    }
    else
    {
        signUpButton.center = CGPointMake(730.0, signUpButton.center.y);
        passwordForgottenLabel.center = CGPointMake(780.0, passwordForgottenLabel.center.y);
        faceImageButton.center = CGPointMake(254.0, faceImageButton.center.y);
        self.avatarImageView.center = CGPointMake(254.0, self.avatarImageView.center.y);
        termsAndConditionsLabel.center = CGPointMake(termsAndConditionsLabel.center.x, 370.0);
        termsAndConditionsLabelSide.center = CGPointMake(termsAndConditionsLabelSide.center.x, 370.0);
        registerButton.center = CGPointMake(registerButton.center.x, 358.0);
    }
    
    areYouNewLabel.center = CGPointMake(areYouNewLabel.center.x, registerButton.center.y - 44.0);
    
    if (self.state != kLoginScreenStateInitial)
    {
        loginButton.center = registerButton.center;
        memberLabel.center = CGPointMake(loginButton.center.x, areYouNewLabel.center.y - 8.0);
    }
    else
    {
        memberLabel.center = CGPointMake(loginButton.center.x, loginButton.center.y - 54.0);
    }
    
    loginButton.frame = CGRectIntegral(loginButton.frame);
    registerButton.frame = CGRectIntegral(registerButton.frame);
    signUpButton.frame = CGRectIntegral(signUpButton.frame);
    passwordForgottenLabel.frame = CGRectIntegral(passwordForgottenLabel.frame);
    faceImageButton.frame = CGRectIntegral(faceImageButton.frame);
    self.avatarImageView.frame = CGRectIntegral(self.avatarImageView.frame);
    areYouNewLabel.frame = CGRectIntegral(areYouNewLabel.frame);
}

- (CGFloat) elementsOffsetY
{
        if ([[SYNDeviceManager sharedInstance] isLandscape])
            return 284.0;
        else
            return 284.0;    
}


- (void) placeSecondaryElements
{
    CGFloat registerOffsetY = [[SYNDeviceManager sharedInstance] isPortrait] ? 704.0 : 358.0;
    registerButton.center = CGPointMake(registerButton.center.x, registerOffsetY);
    areYouNewLabel.center = CGPointMake(areYouNewLabel.center.x, registerButton.center.y - 44.0);
    memberLabel.center = CGPointMake(loginButton.center.x, areYouNewLabel.center.y);
    loginButton.center = registerButton.center;
    dividerImageView.center = CGPointMake(dividerImageView.center.x, dividerImageView.center.y - self.elementsOffsetY);
    passwordForgottenLabel.center = CGPointMake(passwordForgottenLabel.center.x, passwordForgottenLabel.center.y - self.elementsOffsetY);
    passwordForgottenButton.center = CGPointMake(passwordForgottenButton.center.x, passwordForgottenButton.center.y - self.elementsOffsetY);
    CGFloat termsOffsetY = [[SYNDeviceManager sharedInstance] isPortrait] ? 714.0 : 370.0;
    termsAndConditionsLabel.center = CGPointMake(termsAndConditionsLabel.center.x, termsOffsetY);
    termsAndConditionsLabelSide.center = CGPointMake(termsAndConditionsLabelSide.center.x, termsOffsetY);
    
    loginButton.frame = CGRectIntegral(loginButton.frame);
    registerButton.frame = CGRectIntegral(registerButton.frame);
    signUpButton.frame = CGRectIntegral(signUpButton.frame);
    passwordForgottenLabel.frame = CGRectIntegral(passwordForgottenLabel.frame);
    faceImageButton.frame = CGRectIntegral(faceImageButton.frame);
    self.avatarImageView.frame = CGRectIntegral(self.avatarImageView.frame);
    areYouNewLabel.frame = CGRectIntegral(areYouNewLabel.frame);
    termsAndConditionsLabel.frame = CGRectIntegral(termsAndConditionsLabel.frame);
    termsAndConditionsLabelSide.frame = CGRectIntegral(termsAndConditionsLabelSide.frame);
    memberLabel.frame = CGRectIntegral(memberLabel.frame);
}

@end
