//
//  SYNLoginViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 11/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "GAI.h"
#import "NSString+Utils.h"
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
#import "SYNTextFieldLogin.h"

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
@property (nonatomic, strong) IBOutlet UIImageView* avatarImageView;
@property (nonatomic, strong) IBOutlet UIImageView* dividerImageView;
@property (nonatomic, strong) IBOutlet UIImageView* titleImageView;
@property (nonatomic, strong) IBOutlet UILabel* areYouNewLabel;
@property (nonatomic, strong) IBOutlet UILabel* memberLabel;
@property (nonatomic, strong) IBOutlet UILabel* passwordForgottenLabel;
@property (nonatomic, strong) IBOutlet UILabel* secondaryFacebookMessage;
@property (nonatomic, strong) IBOutlet UILabel* termsAndConditionsLabel;
@property (nonatomic, strong) IBOutlet UILabel* termsAndConditionsLabelSide;
@property (nonatomic, strong) IBOutlet UILabel* wellSendYouLabel;
@property (nonatomic, strong) IBOutlet UILabel* whatsOnYourChannelLabel;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin* ddInputField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin* emailInputField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin* mmInputField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin* passwordInputField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin* userNameInputField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLogin* yyyyInputField;
@property (nonatomic, strong) UIButton* termsAndConditionsButton;
@property (nonatomic, strong) IBOutlet UIView* dobView;
@property (nonatomic, strong) NSArray* mainFormElements;
@property (nonatomic, strong) NSMutableDictionary* labelsToErrorArrows;
@property (nonatomic, strong) UIPopoverController* cameraMenuPopoverController;
@property (nonatomic, strong) UIPopoverController* cameraPopoverController;
@property (nonatomic, strong) IBOutlet UIImageView* loginBackgroundImage;

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
@synthesize termsAndConditionsButton;

- (void) viewDidLoad
{
    [super viewDidLoad];

    activityIndicator.hidesWhenStopped = YES;
    
        // == Setup Fonts for labels (except Input Fields)
    UIFont* rockpackBigLabelFont = [UIFont rockpackFontOfSize: 20];
        
    memberLabel.font = rockpackBigLabelFont;
    areYouNewLabel.font = rockpackBigLabelFont;
        
    passwordForgottenLabel.font = [UIFont rockpackFontOfSize: 14.0];
    secondaryFacebookMessage.font = [UIFont rockpackFontOfSize: 20.0];
    termsAndConditionsLabel.font = [UIFont rockpackFontOfSize: 14.0];
    termsAndConditionsLabelSide.font = termsAndConditionsLabel.font;
    wellSendYouLabel.font = [UIFont rockpackFontOfSize: 16.0];
    
    self.whatsOnYourChannelLabel.font = [UIFont rockpackFontOfSize:self.whatsOnYourChannelLabel.font.pointSize];
    self.whatsOnYourChannelLabel.text = NSLocalizedString(@"rockpack_strapline", nil);
    
    NSMutableAttributedString* termsString = [[NSMutableAttributedString alloc] initWithString: NSLocalizedString(@"register_screen_legal", nil)];

        // TERMS & SERVICESs
    
    [termsString addAttribute: NSForegroundColorAttributeName
                        value: [UIColor colorWithRed:(11.0/255.0) green:(166.0/255.0) blue:(171.0/255.0) alpha:(1.0)]
                        range: NSMakeRange(36, 16)];
    
        
    
    
        // PRIVACY POLICY
    
    [termsString addAttribute: NSForegroundColorAttributeName
                        value: [UIColor colorWithRed:(11.0/255.0) green:(166.0/255.0) blue:(171.0/255.0) alpha:(1.0)]
                        range: NSMakeRange(57, 15)];
    
        
    
        // add terms buttons
    termsAndConditionsLabel.attributedText = termsString;
    termsAndConditionsLabelSide.attributedText = termsAndConditionsLabel.attributedText;
    
    self.termsAndConditionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.termsAndConditionsButton.frame = self.termsAndConditionsLabel.frame;
    [self.termsAndConditionsButton addTarget:self action:@selector(termsAndConditionsPressed:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:termsAndConditionsButton];
    
    
    labelsToErrorArrows = [[NSMutableDictionary alloc] init];
        
    ddInputField.keyboardType = UIKeyboardTypeNumberPad;
    mmInputField.keyboardType = UIKeyboardTypeNumberPad;
    yyyyInputField.keyboardType = UIKeyboardTypeNumberPad;
    
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
//        // -- this is to create the left padding for the text fields (hack) -- //
//        tf.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 57)];
//        tf.leftViewMode = UITextFieldViewModeAlways;
    }
    
    if([[SYNDeviceManager sharedInstance] isPortrait])
    {
        
        signUpButton.center = CGPointMake(facebookSignInButton.center.x + 304.0, signUpButton.center.y);
    }
    
    self.state = kLoginScreenStateInitial;
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(outerViewTapped:)];
    [self.view addGestureRecognizer:tapGesture];

}

-(void)termsAndConditionsPressed:(UIButton*)button withEvent:(UIEvent*)event
{
    
    CGPoint center = [[[event allTouches] anyObject] locationInView:button];
    BOOL isLeft = center.x > (self.termsAndConditionsButton.frame.size.width * 0.5);
    NSURL* urlToGo;
    if(isLeft)
    {
        urlToGo = [NSURL URLWithString: kLoginPrivacyUrl];
        
    }
    else
    {
        urlToGo = [NSURL URLWithString: kLoginTermsUrl];
    }
    
    [[UIApplication sharedApplication] openURL:urlToGo];
}

- (void) viewWillAppear:(BOOL)animated
{
    self.loginBackgroundImage.frame = self.loginBackgroundImage.bounds;
    
    [UIView animateWithDuration:40.0f
                          delay:0.0f
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.loginBackgroundImage.frame = CGRectMake(self.loginBackgroundImage.frame.origin.x - 593.0f, self.loginBackgroundImage.frame.origin.y, self.loginBackgroundImage.frame.size.width, self.loginBackgroundImage.frame.size.height);
                         
                     } completion:^(BOOL finished) {
                         //self.darkOverlayView.hidden = NO;
                     }];
}

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear:animated];

    // Google analytics support
    [GAI.sharedInstance.defaultTracker sendView: @"Login - iPad"];
    
    memberLabel.center = CGPointMake(memberLabel.center.x, loginButton.center.y - 54.0);
    memberLabel.frame = CGRectIntegral(memberLabel.frame);
    
}


#pragma mark - States and Transitions

- (void) setState: (kLoginScreenState) newState
{
    if (newState == state)
        return;
    
    if (newState == kLoginScreenStateInitial)
        [self setUpInitialState];
    else if (newState == kLoginScreenStateLogin)
        [self setUpLoginStateFromPreviousState:state];
    else if (newState == kLoginScreenStateRegister)
        [self setUpRegisterStateFromState:state];
    else if (newState == kLoginScreenStatePasswordRetrieve)
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
    
    termsAndConditionsButton.enabled = NO;
    
    dobView.center = CGPointMake(dobView.center.x - 50.0, dobView.center.y);
    emailInputField.center = CGPointMake(emailInputField.center.x - 50.0, emailInputField.center.y);
    faceImageButton.center = CGPointMake(faceImageButton.center.x - 50.0, faceImageButton.center.y);
    self.avatarImageView.center = CGPointMake(self.avatarImageView.center.x - 50.0, self.avatarImageView.center.y);
    
    facebookSignInButton.enabled = YES;
    facebookSignInButton.alpha = 1.0;
    
    _facebookLoginIsInProcess = NO;
    
    if ([SYNDeviceManager.sharedInstance isPortrait])
    {
        faceImageButton.center = CGPointMake(78.0, faceImageButton.center.y);
        self.avatarImageView.center = CGPointMake(78.0, self.avatarImageView.center.y);
        passwordForgottenLabel.center = CGPointMake(650.0, passwordForgottenLabel.center.y);
        
    }

    signUpButton.enabled = YES;
    signUpButton.alpha = 1.0;
    signUpButton.hidden = NO;
    
    loginButton.enabled = YES;
    loginButton.hidden = NO;
    
    finalLoginButton.enabled = YES;
    
    userNameInputField.enabled = YES;
    passwordInputField.enabled = YES;
    
    [activityIndicator stopAnimating];  
}


- (void) setUpPasswordState
{    
    self.initialUsernameFrame = userNameInputField.frame;
    loginButton.frame = registerButton.frame;
    sendEmailButton.enabled = YES;
    memberLabel.center = CGPointMake(loginButton.center.x,
                                     registerButton.center.y - 57.0);
    
    userNameInputField.placeholder = NSLocalizedString(@"forgot_password_screen_form_field_username_placeholder", nil);
    
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


- (void) setUpLoginStateFromPreviousState: (kLoginScreenState) previousState
{
    //Fade out login background
    self.loginBackgroundImage.alpha = 1.0f;
    
    [UIView animateWithDuration:0.6f
                          delay:0.0f
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.loginBackgroundImage.alpha = 0.0f;
                         
                     } completion:^(BOOL finished) {
                         self.loginBackgroundImage.hidden = YES;
                     }];
    
    secondaryFacebookMessage.alpha = 0.0;
    
    [self clearAllErrorArrows];
    
    isAnimating = YES;
    userNameInputField.placeholder = NSLocalizedString(@"login_screen_form_field_username_placeholder", nil);
    
    self.userNameInputField.returnKeyType = UIReturnKeyNext;
    self.passwordInputField.returnKeyType = UIReturnKeyGo;
    
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
                             self.whatsOnYourChannelLabel.alpha = 0.0f;
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
                                                                       
                                                                       termsAndConditionsButton.enabled = YES;
                                                                       termsAndConditionsButton.frame = termsAndConditionsLabel.frame;
                                                                       
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
                             
                             termsAndConditionsButton.enabled = YES;
                             termsAndConditionsButton.frame = termsAndConditionsLabel.frame;
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
                             termsAndConditionsButton.enabled = YES;
                             [userNameInputField becomeFirstResponder];
                         }];
    }
}

-(void)reEnableLoginControls
{
    userNameInputField.enabled = YES;
    passwordInputField.enabled = YES;
    
    [activityIndicator stopAnimating];
    finalLoginButton.enabled = YES;
    
    facebookSignInButton.enabled = YES;
    
    [userNameInputField becomeFirstResponder];
    
}

- (void) setUpRegisterStateFromState: (kLoginScreenState) previousState
{
    //Fade out login background
    self.loginBackgroundImage.alpha = 1.0f;
    
    [UIView animateWithDuration:0.6f
                          delay:0.0f
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.loginBackgroundImage.alpha = 0.0f;
                         
                     } completion:^(BOOL finished) {
                         self.loginBackgroundImage.hidden = YES;
                     }];
    
    //Make member label grey
    self.memberLabel.textColor = self.memberLabel.textColor;
    self.memberLabel.shadowColor = self.memberLabel.shadowColor;
    
    [UIView animateWithDuration:0.6f
                          delay:1.0f
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.memberLabel.textColor = [UIColor colorWithRed:(130.0f/255.0f) green:(141.0f/255.0f) blue:(145.0f/255.0f) alpha:(1.0f)];
                         self.memberLabel.shadowColor = [UIColor whiteColor];
                         
                     } completion:^(BOOL finished) {
                     }];
    
    secondaryFacebookMessage.alpha = 0.0;
    
    [self clearAllErrorArrows];
    isAnimating = YES;
    userNameInputField.placeholder = NSLocalizedString(@"login_screen_form_field_username_placeholder", nil);
    
    
    self.userNameInputField.returnKeyType = UIReturnKeyNext;
    self.passwordInputField.returnKeyType = UIReturnKeyNext;
    
    if (previousState == kLoginScreenStateInitial)
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
                                                  self.termsAndConditionsButton.frame = termsAndConditionsLabelSide.frame;
                                                  self.termsAndConditionsButton.enabled = YES;
                                              }];
                         }];
    }
    else if (previousState == kLoginScreenStateLogin)
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
                             self.termsAndConditionsButton.frame = termsAndConditionsLabelSide.frame;
                             self.termsAndConditionsButton.enabled = YES;
                             [emailInputField becomeFirstResponder];
                         }];
    }
    
    [UIView animateWithDuration: 0.4
                     animations: ^{
                         
                         facebookSignInButton.alpha = 0.0;
                         
                         titleImageView.alpha = 0.0;
                         self.whatsOnYourChannelLabel.alpha = 0.0;
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
                         termsAndConditionsButton.enabled = YES;
                     }];
}


#pragma mark - Button Actions

- (BOOL) loginFormIsValid
{
    // email
    if (userNameInputField.text.length < 1)
    {
        [self placeErrorLabel: NSLocalizedString(@"login_screen_form_field_username_error_empty", nil)
                   nextToView: userNameInputField];
        
        [userNameInputField becomeFirstResponder];
        
        return NO;
    }

    if (passwordInputField.text.length < 1)
    {
        [self placeErrorLabel: NSLocalizedString(@"login_screen_form_field_password_error_empty", nil)
                   nextToView: passwordInputField];
        
        [passwordInputField becomeFirstResponder];
        
        return NO;
    }

    return YES;
}


- (BOOL) resetPasswordFormIsValid
{
    
    if (userNameInputField.text.length < 1)
    {
        [self placeErrorLabel: NSLocalizedString(@"forgot_password_screen_form_field_username_error_empty", nil)
                   nextToView: userNameInputField];
        
        [userNameInputField becomeFirstResponder];
        
        return NO;
    }
    
    return YES;
    
}

- (IBAction) doLogin: (id) sender
{
    [self clearAllErrorArrows];
    
    [self resignAllFirstResponders];
    
    if (![self isNetworkAccessibleOtherwiseShowErrorAlert])
    {
        return;
    }
    
    if (![self loginFormIsValid])
        return;
    
    finalLoginButton.enabled = NO;
    
    [UIView animateWithDuration: 0.1 animations:^
     {
         finalLoginButton.alpha = 0.0;
     }];
    
    activityIndicator.center = CGPointMake(finalLoginButton.center.x, finalLoginButton.center.y);
    [activityIndicator startAnimating];
    
    [self loginForUsername: userNameInputField.text
               forPassword: passwordInputField.text
         completionHandler: ^(NSDictionary* dictionary) {
            
             DebugLog(@"User Registerd: %@", [dictionary objectForKey: @"username"]);
             
             // by this time the currentUser is set in the DB //
             
             [activityIndicator stopAnimating];
             
             [self completeLoginProcess];
             
         }
              errorHandler:^(NSDictionary* errorDictionary) {
                  
                  NSDictionary* errors = errorDictionary [@"error"];
                  if (errors)
                  {
                      //[self placeErrorLabel: @"Username could be incorrect"
                      //           nextToView: userNameInputField];
                      
                      [self placeErrorLabel: NSLocalizedString(@"login_screen_form_field_username_password_error_incorrect", nil)
                                 nextToView: passwordInputField];
                  }
                  
                  NSDictionary* savingError = errorDictionary [@"saving_error"];
                  if(savingError)
                  {
                      [self placeErrorLabel: NSLocalizedString(@"login_screen_saving_error", nil)
                                 nextToView: passwordInputField];
                  }
                  
                  finalLoginButton.enabled = YES;
                  
                  [activityIndicator stopAnimating];
                  
                  [UIView animateWithDuration: 0.3
                                   animations: ^{
                                       finalLoginButton.alpha = 1.0;
                                   }
                                   completion: ^(BOOL finished) {
                                       [userNameInputField becomeFirstResponder];
                                   }];
              }];
}


- (IBAction) goToLoginForm: (id) sender
{
    if (isAnimating)
        return;
    
    self.state = kLoginScreenStateLogin;
}


- (IBAction) sendEmailButtonPressed: (id) sender
{
    if (![self isNetworkAccessibleOtherwiseShowErrorAlert])
        return;
    
    if (![self resetPasswordFormIsValid])
        return;
    
    [self doRequestPasswordResetForUsername:self.userNameInputField.text completionHandler: ^(NSDictionary * completionInfo) {
        
        if ([completionInfo valueForKey: @"error"])
        {
            [self placeErrorLabel: NSLocalizedString(@"forgot_password_screen_form_field_username_user_unknown", nil)
                       nextToView: self.userNameInputField];
            
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"forgot_password_screen_complete_title", nil)
                                        message: NSLocalizedString(@"forgot_password_screen_complete_message", nil)
                                       delegate: nil
                              cancelButtonTitle: NSLocalizedString(@"OK", nil)
                              otherButtonTitles: nil] show];
            
        }

    } errorHandler: ^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"forgot_password_screen_complete_title", nil)
                                    message: NSLocalizedString(@"forgot_password_screen_form_field_request_failed_error", nil)
                                   delegate: nil
                          cancelButtonTitle: NSLocalizedString(@"OK", nil)
                          otherButtonTitles: nil] show];
        
    }];
}


- (void) doFacebookLoginAnimation
{
    [UIView animateWithDuration: 0.3
                     animations: ^{
                         if (!signUpButton.hidden)
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
    [passwordForgottenLabel resignFirstResponder];
    finalLoginButton.enabled = NO;
    loginButton.enabled = NO;
    passwordForgottenButton.enabled = NO;
    
    activityIndicator.color = [UIColor whiteColor];
    
    activityIndicator.center = CGPointMake(facebookSignInButton.frame.origin.x + facebookSignInButton.frame.size.width + 35.0,
                                           facebookSignInButton.center.y);
}

- (void) doFacebookFailAnimation
{
    [UIView animateWithDuration: 0.3
                     animations: ^{
                         if (!signUpButton.hidden)
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
    
    if (![self isNetworkAccessibleOtherwiseShowErrorAlert])
    {
        return;
    }
    
    facebookSignInButton.enabled = NO;
    [self doFacebookLoginAnimation];
    
    [self loginThroughFacebookWithCompletionHandler: ^(NSDictionary * dictionary) {
        
                                        [activityIndicator stopAnimating];
                                        [self completeLoginProcess];
        
                                    }  errorHandler:^(id error) {
                                           
                                           [self doFacebookFailAnimation];
                                            facebookSignInButton.enabled = YES;
                                           
                                           if ([error isKindOfClass: [NSDictionary class]])
                                           {
                                               NSDictionary* formErrors = error[@"form_errors"];
                                               
                                               if (formErrors)
                                               {
                                                   secondaryFacebookMessage.text = NSLocalizedString(@"facebook_login_error_description", nil);
                                                   secondaryFacebookMessage.alpha = 1.0;
                                               }
                                               
                                           }
                                           else if ([error isKindOfClass: [NSString class]])
                                           {_facebookLoginIsInProcess = NO;
                                               
                                               // TODO: Use custom alert box here
                                               [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"facebook_login_error_title", nil)
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
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_field_email_error_empty", nil)
                   nextToView: emailInputField];
        
        [emailInputField becomeFirstResponder];
        
        return NO;
    }
    
    // == Regular expression through RegexKitLite.h (not arc compatible) == //
    
    if (![emailInputField.text isMatchedByRegex: @"^([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})$"])
    {
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_field_email_error_empty", nil)
                   nextToView: emailInputField];
        
        [emailInputField becomeFirstResponder];
        
        return NO;
    }
    
    // == Determine if we are in login or registration mode by asking if the Register button is visible and show different error messages == //
    
    if (userNameInputField.text.length < 1 && registerButton.hidden == YES)
    {
        [self placeErrorLabel: NSLocalizedString(@"login_screen_form_field_username_error_empty", nil)
                   nextToView: userNameInputField];
        
        [userNameInputField becomeFirstResponder];
        
        return NO;
    }
    
    if (userNameInputField.text.length < 1 && registerButton.hidden == NO)
    {
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_field_username_error_empty", nil)
                   nextToView: userNameInputField];
        
        [userNameInputField becomeFirstResponder];
        
        return NO;
    }
    //register_screen_form_field_username_error_too_long
    // == Username must be
    
    if (![userNameInputField.text isMatchedByRegex:@"^[a-zA-Z0-9\\._]+$"])
    {
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_field_username_error_invalid", nil)
                   nextToView: userNameInputField];
        
        [userNameInputField becomeFirstResponder];
        
        return NO;
    }
    
    if(userNameInputField.text.length > 20)
    {
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_field_username_error_too_long", nil)
                   nextToView: userNameInputField];
        
        [userNameInputField becomeFirstResponder];
        
        return NO;
    }
    
    // == Determine if we are in login or registration mode by asking if the Register button is visible and show different error messages == //
    
    if (passwordInputField.text.length < 1 && registerButton.hidden == YES)
    {
        [self placeErrorLabel: NSLocalizedString(@"login_screen_form_field_password_error_empty", nil)
                   nextToView: passwordInputField];
        
        [passwordInputField becomeFirstResponder];
        
        return NO;
    }
    
    if (passwordInputField.text.length < 1 && registerButton.hidden == NO)
    {
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_field_password_error_empty", nil)
                   nextToView: passwordInputField];
        
        [passwordInputField becomeFirstResponder];
        
        return NO;
    }
    
    // == Check for date == //
    
    NSArray* dobTextFields = @[mmInputField, ddInputField, yyyyInputField];
    
    
    
    
    
    // == Check wether the DOB fields contain numbers == //
    
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    
    for (UITextField* dobField in dobTextFields)
    {
        if(dobField.text.length == 0)
        {
            [self placeErrorLabel: NSLocalizedString(@"register_screen_form_error_invalid_date", nil)
                       nextToView: dobField];
            
            [ddInputField becomeFirstResponder];
            
            return NO;
        }
        
        if(dobField.text.length == 1)
        {
            dobField.text = [NSString stringWithFormat:@"0%@", dobField.text]; // add a trailing 0
        }
        
        if (![numberFormatter numberFromString: dobField.text])
        {
            [self placeErrorLabel: NSLocalizedString(@"register_screen_form_error_invalid_date", nil)
                       nextToView: dobView];
            
            [dobField becomeFirstResponder];
            
            return NO;
        }
    }
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    NSDate* potentialDate = [dateFormatter dateFromString: [self dateStringFromCurrentInput]];
    
    // == Not a real date == //
    
    if (!potentialDate)
    {
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_error_invalid_date", nil)
                   nextToView: dobView];
        
        return NO;
    }
    
    NSDate* nowDate = [NSDate date];
    
    // == In the future == //
    
    if ([nowDate compare:potentialDate] == NSOrderedAscending) {
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_error_future", nil)
                   nextToView: dobView];
        
        return NO;
    }
    
    // == Yonger than 13 == //
    
    NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* nowDateComponents = [gregorian components:(NSYearCalendarUnit) fromDate:nowDate];
    nowDateComponents.year -= 13;
    
    NSDate* tooYoungDate = [gregorian dateFromComponents:nowDateComponents];
    
    if ([tooYoungDate compare:potentialDate] == NSOrderedAscending) {
        
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_error_under_13", nil)
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
    
    if (![self registrationFormIsValid])
        return;
    
    [self resignAllFirstResponders];
    
    if (![self isNetworkAccessibleOtherwiseShowErrorAlert])
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
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    NSDate* birthdayDate = [dateFormatter dateFromString: [self dateStringFromCurrentInput]];
    
    // Calculate age, taking account of leap-years etc. (probably too accurate!)
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar] components: NSYearCalendarUnit
                                                                      fromDate: birthdayDate
                                                                        toDate: NSDate.date
                                                                       options: 0];
    
    NSInteger age = [ageComponents year];
    
    NSString *ageString = [NSString ageCategoryStringFromInt: age];
    
    // Now set the age
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker setCustom: kGADimensionAge
             dimension: ageString];
    
    activityIndicator.center = CGPointMake(registerNewUserButton.center.x, registerNewUserButton.center.y);
    [activityIndicator startAnimating];
    
    [self registerUserWithData: userData
             completionHandler: ^(NSDictionary* dictionary){
                 
                 [activityIndicator stopAnimating];
                 
                 [self completeLoginProcess];
                 
                 if (self.avatarImage)
                 {
                     [self uploadAvatar: self.avatarImage];
                 }
             }
                  errorHandler: ^(NSDictionary* errorDictionary){
                      NSDictionary* formErrors = [errorDictionary objectForKey: @"form_errors"];
                      
                      if (formErrors)
                      {
                          [self showRegistrationError: formErrors];
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
    }
               errorHandler:^(NSDictionary* errorDictionary) {
                   DebugLog(@"Avatar upload failed");
                   [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"register_screen_form_avatar_upload_title", nil)
                                               message: NSLocalizedString(@"register_screen_form_avatar_upload_description.", nil)
                                              delegate: nil
                                     cancelButtonTitle: NSLocalizedString(@"OK", nil)
                                     otherButtonTitles: nil] show];
               }];
}


- (void) showRegistrationError: (NSDictionary*) errorDictionary
{
    // form errors
    NSArray* usernameError = [errorDictionary objectForKey: @"username"];
    //NSArray* localeError = [errorDictionary objectForKey:@"locale"];
    NSArray* passwordError = [errorDictionary objectForKey :@"password"];
    NSArray* emailError = [errorDictionary objectForKey: @"email"];
    
    if (usernameError)
        [self placeErrorLabel: (NSString*)[usernameError objectAtIndex: 0]
                   nextToView: userNameInputField];
    
    // TODO: deal with locale
    
    if (passwordError)
        [self placeErrorLabel: (NSString*)[passwordError objectAtIndex: 0]
                   nextToView: passwordInputField];
    
    if (emailError)
        [self placeErrorLabel: (NSString*)[emailError objectAtIndex: 0]
                   nextToView: emailInputField];
    
}


#pragma mark - Error Arrows

- (void) placeErrorLabel: (NSString*) errorText
              nextToView: (UIView*) view
{
    SYNLoginErrorArrow* errorArrow = [labelsToErrorArrows objectForKey:[NSValue valueWithPointer:(__bridge const void *)(view)]];
    if (errorArrow)
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
    if (self.isAnimating)
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
    
    if (self.loginBackgroundImage.alpha == 1.0f)
    {
        //Fade out login background
        self.loginBackgroundImage.alpha = 1.0f;
        
        [UIView animateWithDuration:0.6f
                              delay:0.0f
                            options: UIViewAnimationCurveEaseInOut
                         animations:^{
                             self.loginBackgroundImage.alpha = 0.0f;
                             
                         } completion:^(BOOL finished) {
                         }];
    }
    
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
    
    
    if ((textField == ddInputField || textField == mmInputField) && newLength > 2)
        return NO;
    if (textField == yyyyInputField && newLength > 4)
        return NO;
    if(textField == self.userNameInputField && newLength > 26)
        return NO;
    if(textField == self.passwordInputField && newLength > 20)
        return NO;
        
    
    
    
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    if (textField == ddInputField || textField == mmInputField || textField == yyyyInputField)
        if (![numberFormatter numberFromString:newCharacter] && newCharacter.length != 0) // is backspace, length is 0
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

- (IBAction) textfieldDidChange: (id) sender
{

    if(sender == self.ddInputField && [self.ddInputField.text length]==2)
    {
        [self.mmInputField becomeFirstResponder];

    }
    else if(sender == self.mmInputField && [self.mmInputField.text length]==2)
    {
        [self.yyyyInputField becomeFirstResponder];

    }
    else if(sender == self.yyyyInputField && [self.yyyyInputField.text length] == 4)
    {
        //[sender resignFirstResponder];
        
    }
}

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    if (self.state == kLoginScreenStateLogin)
    {
        
        if (self.userNameInputField.text.length < 1) {
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
    else if (self.state == kLoginScreenStateRegister)
    {
        if (self.emailInputField.text.length < 1) {
            self.emailInputField.returnKeyType = UIReturnKeyNext;
            [self.emailInputField becomeFirstResponder];
            return YES;
        }
        
        if (self.userNameInputField.text.length < 1) {
            self.userNameInputField.returnKeyType = UIReturnKeyNext;
            [self.userNameInputField becomeFirstResponder];
            return YES;
        }
        
        if (self.passwordInputField.text.length < 1) {
            self.passwordInputField.returnKeyType = UIReturnKeyNext;
            [self.passwordInputField becomeFirstResponder];
            return YES;
        }
        if (self.ddInputField.text.length < 1) {
            self.ddInputField.returnKeyType = UIReturnKeyNext;
            [self.ddInputField becomeFirstResponder];
            return YES;
        }
        if (self.mmInputField.text.length < 1) {
            self.mmInputField.returnKeyType = UIReturnKeyNext;
            [self.mmInputField becomeFirstResponder];
            return YES;
        }
        if (self.yyyyInputField.text.length < 1) {
            self.yyyyInputField.returnKeyType = UIReturnKeyDone;
            [self.yyyyInputField becomeFirstResponder];
            return YES;
        }
        
        [self registerNewUser:self.registerNewUserButton];
        return YES;
    
    }
    else if (self.state == kLoginScreenStatePasswordRetrieve)
    {
        if (self.userNameInputField.text.length < 1) {
            self.passwordInputField.returnKeyType = UIReturnKeySend;
            [self.userNameInputField becomeFirstResponder];
            return YES;
        }
        
        [self sendEmailButtonPressed:self.sendEmailButton];
        return YES;
    
    }

    // default case just go to the next text field (from 6 text fields)
    [((UITextField*)[self.view viewWithTag: (textField.tag+1)%6]) becomeFirstResponder];
    
    return YES;
}


#pragma mark - Avatar image selection

- (IBAction) faceButtonImagePressed: (UIButton*) button
{
    self.imagePicker = [[SYNImagePickerController alloc] initWithHostViewController:self];
    self.imagePicker.delegate = self;
    [self.imagePicker presentImagePickerAsPopupFromView:button arrowDirection:UIPopoverArrowDirectionLeft];
}


- (void) picker: (SYNImagePickerController *) picker
         finishedWithImage: (UIImage *) image
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
        passwordForgottenLabel.center = CGPointMake(115.0, passwordForgottenLabel.center.y);
        faceImageButton.center = CGPointMake(124.0, faceImageButton.center.y);
        self.avatarImageView.center = CGPointMake(124.0, self.avatarImageView.center.y);
        termsAndConditionsLabel.center = CGPointMake(termsAndConditionsLabel.center.x, 714.0);
        termsAndConditionsLabelSide.center = CGPointMake(termsAndConditionsLabelSide.center.x, 714.0);        
        registerButton.center = CGPointMake(registerButton.center.x, 704.0);
        
    }
    else
    {
        signUpButton.center = CGPointMake(730.0, signUpButton.center.y);
        passwordForgottenLabel.center = CGPointMake(248.0, passwordForgottenLabel.center.y);
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
    termsAndConditionsLabelSide.frame = CGRectIntegral(termsAndConditionsLabelSide.frame);
    faceImageButton.frame = CGRectIntegral(faceImageButton.frame);
    self.avatarImageView.frame = CGRectIntegral(self.avatarImageView.frame);
    areYouNewLabel.frame = CGRectIntegral(areYouNewLabel.frame);
    
    if(termsAndConditionsLabel.alpha > 0.0)
        termsAndConditionsButton.frame = termsAndConditionsLabel.frame;
    else
        termsAndConditionsButton.frame = termsAndConditionsLabelSide.frame;
    
}



- (CGFloat) elementsOffsetY
{
        if ([SYNDeviceManager.sharedInstance isLandscape])
            return 284.0;
        else
            return 284.0;    
}


- (void) placeSecondaryElements
{
    CGFloat registerOffsetY = [SYNDeviceManager.sharedInstance isPortrait] ? 704.0 : 358.0;
    registerButton.center = CGPointMake(registerButton.center.x, registerOffsetY);
    areYouNewLabel.center = CGPointMake(areYouNewLabel.center.x, registerButton.center.y - 44.0);
    memberLabel.center = CGPointMake(loginButton.center.x, areYouNewLabel.center.y);
    loginButton.center = registerButton.center;
    dividerImageView.center = CGPointMake(dividerImageView.center.x, dividerImageView.center.y - self.elementsOffsetY);
    passwordForgottenLabel.center = CGPointMake(passwordForgottenLabel.center.x, passwordForgottenLabel.center.y - self.elementsOffsetY);
    passwordForgottenButton.center = CGPointMake(passwordForgottenButton.center.x, passwordForgottenButton.center.y - self.elementsOffsetY);
    CGFloat termsOffsetY = [SYNDeviceManager.sharedInstance isPortrait] ? 714.0 : 370.0;
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
    
    if(termsAndConditionsLabel.alpha > 0.0)
        termsAndConditionsButton.frame = termsAndConditionsLabel.frame;
    else
        termsAndConditionsButton.frame = termsAndConditionsLabelSide.frame;
}

@end
