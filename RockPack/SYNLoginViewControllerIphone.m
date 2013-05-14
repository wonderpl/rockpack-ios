//
//  SYNLoginViewControllerIphone.m
//  rockpack
//
//  Created by Mats Trovik on 02/05/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNLoginViewControllerIphone.h"
#import "SYNDeviceManager.h"
#import "UIFont+SYNFont.h"
#import "SYNOAuthNetworkEngine.h"
#import "RegexKitLite.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SYNFacebookManager.h"

#define kLoginAnimationTransitionDuration 0.3f

@interface SYNLoginViewControllerIphone () <UITextFieldDelegate, UIActionSheetDelegate>
{
    BOOL facebookLoginIsInProgress;
}
@property (weak, nonatomic) IBOutlet UIView *initialView;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UIView *firstSignupView;
@property (weak, nonatomic) IBOutlet UIView *secondSignupView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIView *termsAndConditionsView;

@property (assign, nonatomic) kLoginScreenState loginScreenState;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;

@property (weak, nonatomic) IBOutlet UILabel *loginErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordResetErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *signupErrorLabel;
@property (strong, nonatomic) NSDateFormatter * dateFormatter;
@end

@implementation SYNLoginViewControllerIphone 

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
    
    BOOL isPreIPhone5 = [[SYNDeviceManager sharedInstance] currentScreenHeight] < 500;
    
    //Move all subviews offscreen
    CGPoint newCenter = self.loginView.center;
    newCenter.x = 480.0f;
    if(isPreIPhone5)
    {
        newCenter.y -= 50.0f;
    }
    self.loginView.center = newCenter;
    
    newCenter = self.passwordView.center;
    newCenter.x = 480.0f;
    if(isPreIPhone5)
    {
        newCenter.y -= 40.0f;
    }
    self.passwordView.center = newCenter;

    newCenter = self.firstSignupView.center;
    newCenter.x = 480.0f;
    if(isPreIPhone5)
    {
        newCenter.y -= 45.0f;
    }
    self.firstSignupView.center = newCenter;
    
    newCenter = self.secondSignupView.center;
    newCenter.x = 480.0f;
    if(isPreIPhone5)
    {
        newCenter.y -= 40.0f;
    }
    self.secondSignupView.center = newCenter;
    
    
    newCenter = self.termsAndConditionsView.center;
    newCenter.x = 480.0f;
    if(isPreIPhone5)
    {
        newCenter.y -= 68.0f;
    }
    self.termsAndConditionsView.center = newCenter;
    
    //Setup fonts
    self.userNameInputField.font = [UIFont rockpackFontOfSize:self.userNameInputField.font.pointSize];
    self.userNameInputField.delegate = self;
    self.registeringUserEmailInputField.font = [UIFont rockpackFontOfSize:self.registeringUserEmailInputField.font.pointSize];
    self.registeringUserEmailInputField.delegate = self;
    self.registeringUserNameInputField.font = [UIFont rockpackFontOfSize:self.registeringUserNameInputField.font.pointSize];
    self.registeringUserNameInputField.delegate=self;
    self.registeringUserPasswordInputField.font = [UIFont rockpackFontOfSize:self.registeringUserPasswordInputField.font.pointSize];
    self.registeringUserPasswordInputField.delegate = self;
    self.passwordInputField.font = [UIFont rockpackFontOfSize:self.passwordInputField.font.pointSize];
    self.passwordInputField.delegate = self;
    self.ddInputField.font = [UIFont rockpackFontOfSize:self.ddInputField.font.pointSize];
    self.passwordInputField.delegate = self;
    self.mmInputField.font = [UIFont rockpackFontOfSize:self.mmInputField.font.pointSize];
    self.mmInputField.delegate = self;
    self.yyyyInputField.font = [UIFont rockpackFontOfSize:self.yyyyInputField.font.pointSize];
    self.yyyyInputField.delegate = self;
    
    self.loginErrorLabel.font = [UIFont rockpackFontOfSize:self.loginErrorLabel.font.pointSize];
    self.passwordResetErrorLabel.font = [UIFont rockpackFontOfSize:self.passwordResetErrorLabel.font.pointSize];
    self.signupErrorLabel.font = [UIFont rockpackFontOfSize:self.signupErrorLabel.font.pointSize];
    
    NSMutableAttributedString* termsString = [[NSMutableAttributedString alloc] initWithString:@"BY SIGNING INTO ROCKPACK, YOU AGREE TO OUR TERMS OF SERVICE AND PRIVACY POLICY"];
    [termsString addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:(32.0/255.0) green:(195.0/255.0) blue:(226.0/255.0) alpha:(1.0)] range: NSMakeRange(42, 17)];
    [termsString addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:(32.0/255.0) green:(195.0/255.0) blue:(226.0/255.0) alpha:(1.0)] range: NSMakeRange(64, 14)];
    self.termsAndConditionsLabel.attributedText = termsString;
    self.termsAndConditionsLabel.font = [UIFont rockpackFontOfSize:self.termsAndConditionsLabel.font.pointSize];
    
    self.passwordForgottenButton.titleLabel.font = [UIFont rockpackFontOfSize:self.passwordForgottenButton.titleLabel.font.pointSize];
    
    self.loginScreenState = kLoginScreenStateInitial;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - button IBActions

- (IBAction)facebookTapped:(id)sender {
    
    facebookLoginIsInProgress = NO;
    FBSession* facebookSession = [FBSession activeSession];
    
    if(facebookSession.state == FBSessionStateCreatedTokenLoaded) {
        facebookLoginIsInProgress = YES;
        [self doFacebookLoginAnimation];
    }
    
    
    
    SYNFacebookManager* facebookManager = [SYNFacebookManager sharedFBManager];
    
    [facebookManager loginOnSuccess:^(NSDictionary<FBGraphUser> *dictionary) {
        
        if(!facebookLoginIsInProgress) {
            
            [self doFacebookLoginAnimation];
        }
        
        
        FBAccessTokenData* accessTokenData = [[FBSession activeSession] accessTokenData];
        
        [self.appDelegate.oAuthNetworkEngine doFacebookLoginWithAccessToken:accessTokenData.accessToken
                                                     completionHandler: ^(SYNOAuth2Credential* credential) {
                                                         
                                                         [self.appDelegate.oAuthNetworkEngine userInformationFromCredentials: credential
                                                                                                      completionHandler: ^(NSDictionary* dictionary) {
                                                                                                          
                                                                                                          [self checkAndSaveRegisteredUser:credential];
                                                                                                          
                                                                                                          [self completeLoginProcess:credential];
                                                                                                          
                                                                                                      } errorHandler: ^(NSDictionary* errorDictionary) {
                                                                                                    
                                                                                                      }];
                                                         
                                                         
                                                     } errorHandler: ^(NSDictionary* errorDictionary) {
                                                         
                                                         
                                                         NSDictionary* formErrors = errorDictionary [@"form_errors"];
                                                         
                                                         if (formErrors)
                                                         {
                                                             [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Facebook Login", nil)
                                                                                         message: NSLocalizedString(@"Could not log in through facebook", nil)
                                                                                        delegate: nil
                                                                               cancelButtonTitle: NSLocalizedString(@"OK", nil)
                                                                               otherButtonTitles: nil] show];
                                                             [self doFacebookFailedAnimation];
                                                         }
                                                     }];
    }
                          onFailure: ^(NSString* errorString)
     {
         facebookLoginIsInProgress= NO;
         
         
         // TODO: Use custom alert box here
         [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Facebook Login", nil)
                                     message: errorString
                                    delegate: nil
                           cancelButtonTitle: NSLocalizedString(@"OK", nil)
                           otherButtonTitles: nil] show];
         [self doFacebookFailedAnimation];
         DebugLog(@"Log in failed!");
     }];
}

- (IBAction)signupTapped:(id)sender {
    self.loginScreenState = kLoginScreenStateRegister;
    
    [self turnOnButton:self.cancelButton];
    [self turnOnButton:self.nextButton];
    self.nextButton.enabled = [self validateRegistrationFirstScreen];
    
    [UIView animateWithDuration:kLoginAnimationTransitionDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGPoint newCenter = self.firstSignupView.center;
        newCenter.x = 160.0f;
        self.firstSignupView.center = newCenter;
        
        newCenter = self.termsAndConditionsView.center;
        newCenter.x = 160.0f;
        self.termsAndConditionsView.center = newCenter;
        
        newCenter = self.initialView.center;
        newCenter.x = -160.0f;
        self.initialView.center = newCenter;
        
    } completion:nil];
    
}
- (IBAction)loginTapped:(id)sender {
    self.loginScreenState = kLoginScreenStateLogin;
    
    [self turnOnButton:self.backButton];
    [self turnOnButton:self.confirmButton];
    self.confirmButton.enabled = [self validateLogin];
    
    [UIView animateWithDuration:kLoginAnimationTransitionDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGPoint newCenter = self.loginView.center;
        newCenter.x = 160.0f;
        self.loginView.center = newCenter;
        
        newCenter = self.initialView.center;
        newCenter.x = -160.0f;
        self.initialView.center = newCenter;
    } completion:^(BOOL finished) {
        [self.userNameInputField becomeFirstResponder];
        
    }];
}

- (IBAction)forgotPasswordTapped:(id)sender {
    
    self.loginScreenState = kLoginScreenStatePasswordRetrieve;
    self.confirmButton.enabled = YES;
    [UIView animateWithDuration:kLoginAnimationTransitionDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGPoint newCenter = self.passwordView.center;
        newCenter.x = 160.0f;
        self.passwordView.center = newCenter;
        
        newCenter = self.loginView.center;
        newCenter.x = -160.0f;
        self.loginView.center = newCenter;
    } completion:^(BOOL finished) {
        [self.emailInputField becomeFirstResponder];
        
    }];

}
- (IBAction)photoButtonTapped:(id)sender
{
    if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIActionSheet* sourceSelector = [[UIActionSheet alloc] initWithTitle: NSLocalizedString(@"Select source", nil)
                                                                    delegate: self
                                                           cancelButtonTitle: NSLocalizedString(@"Cancel", nil)
                                                      destructiveButtonTitle: nil
                                                           otherButtonTitles: NSLocalizedString(@"Camera", nil),
                                                                              NSLocalizedString(@"Choose existing", nil), nil];
        [sourceSelector showInView:self.view];
    }
    else
    {
        [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

- (IBAction)backbuttonTapped:(id)sender
{
    
    switch (self.loginScreenState) {
        case kLoginScreenStateRegisterStepTwo:
        {
            [self turnOnButton:self.backButton];
            [self turnOffButton:self.confirmButton];
            [self turnOnButton:self.nextButton];
            [self turnOnButton:self.cancelButton];
            self.loginScreenState = kLoginScreenStateRegister;
            [UIView animateWithDuration:kLoginAnimationTransitionDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                CGPoint newCenter = self.secondSignupView.center;
                newCenter.x = 480.0f;
                self.secondSignupView.center = newCenter;
                
                newCenter = self.firstSignupView.center;
                newCenter.x = 160.0f;
                self.firstSignupView.center = newCenter;
                
                newCenter = self.termsAndConditionsView.center;
                newCenter.x = 160.0f;
                self.termsAndConditionsView.center = newCenter;
                
                
            } completion:^(BOOL finished) {
                [self.registeringUserNameInputField becomeFirstResponder];
            }];
            
            break;
        }

        case kLoginScreenStatePasswordRetrieve:
        {
            self.loginScreenState = kLoginScreenStateLogin;
            [UIView animateWithDuration:kLoginAnimationTransitionDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                CGPoint newCenter = self.passwordView.center;
                newCenter.x = 480.0f;
                self.passwordView.center = newCenter;
                
                newCenter = self.loginView.center;
                newCenter.x = 160.0f;
                self.loginView.center = newCenter;
            } completion:^(BOOL finished) {
                [self.userNameInputField becomeFirstResponder];
            }];

            break;
        }
        case kLoginScreenStateLogin:
        default:
        {
            self.loginScreenState = kLoginScreenStateInitial;
            [UIView animateWithDuration:kLoginAnimationTransitionDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                CGPoint newCenter = self.loginView.center;
                newCenter.x = 480.0f;
                self.loginView.center = newCenter;
                newCenter = self.initialView.center;
                newCenter.x = 160.0f;
                self.initialView.center = newCenter;
            } completion:nil];
            [[self.loginView subviews] makeObjectsPerformSelector:@selector(resignFirstResponder)];
            [self turnOffButton:self.backButton];
            [self turnOffButton:self.confirmButton];
            break;
        }
    }
}
- (IBAction)cancelTapped:(id)sender {
    switch (self.loginScreenState) {
        case kLoginScreenStateRegister:
        {
            self.loginScreenState = kLoginScreenStateInitial;
            [UIView animateWithDuration:kLoginAnimationTransitionDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                CGPoint newCenter = self.firstSignupView.center;
                newCenter.x = 480.0f;
                self.firstSignupView.center = newCenter;
                
                newCenter = self.termsAndConditionsView.center;
                newCenter.x = 480.0f;
                self.termsAndConditionsView.center = newCenter;
                
                newCenter = self.initialView.center;
                newCenter.x = 160.0f;
                self.initialView.center = newCenter;
            } completion:nil];
            [self turnOffButton:self.cancelButton];
            [self turnOffButton:self.nextButton];
            [[self.firstSignupView subviews] makeObjectsPerformSelector:@selector(resignFirstResponder)];
            break;
        }
        default:
            break;
    }

}
- (IBAction)confirmTapped:(id)sender {
    
    [self.registeringUserEmailInputField resignFirstResponder];
    [self.registeringUserPasswordInputField resignFirstResponder];
    [self.ddInputField resignFirstResponder];
    [self.yyyyInputField resignFirstResponder];
    [self.mmInputField resignFirstResponder];
    [self.userNameInputField resignFirstResponder];
    [self.passwordInputField resignFirstResponder];
    [self.emailInputField resignFirstResponder];
    
    switch (self.loginScreenState) {
        case kLoginScreenStateLogin:
        {
            [self turnOffButton:self.backButton];
            [self turnOffButton:self.confirmButton];
            self.activityIndicator.hidden = NO;
            self.activityIndicator.center = self.confirmButton.center;
            [self.activityIndicator startAnimating];
            
            [self.appDelegate.oAuthNetworkEngine doSimpleLoginForUsername: self.userNameInputField.text
                                                         forPassword: self.passwordInputField.text
                                                   completionHandler: ^(SYNOAuth2Credential* credential) {
                                                       
                                                       // Case where the user is a member of Rockpack but has not signing in this device
                                                       
                                                       [self.appDelegate.oAuthNetworkEngine userInformationFromCredentials:credential
                                                                                                    completionHandler:^(NSDictionary* dictionary) {
                                                                                                        
                                                                                                        NSString* username = [dictionary objectForKey:@"username"];
                                                                                                        DebugLog(@"User Registerd: %@", username);
                                                                                                        
                                                                                                        [self checkAndSaveRegisteredUser:credential];
                                                                                                        
                                                                                                        //[self.activityIndicator stopAnimating];
                                                                                                        
                                                                                                        [self completeLoginProcess:credential];
                                                                                                        
                                                                                                    } errorHandler:^(NSDictionary* errorDictionary) {
                                                                                                        
                                                                                                        [self.activityIndicator stopAnimating];
                                                                                                        [self turnOnButton:self.backButton];
                                                                                                        [self turnOnButton:self.confirmButton];
                                                                                                        
                                                                                                        self.loginErrorLabel.text = NSLocalizedString(@"CHECK USERNAME AND PASSWORD", nil);
                                                                                                        
                                                                                                    }];
                                                       
                                                       
                                                       
                                                       
                                                   } errorHandler: ^(NSDictionary* errorDictionary) {
                                                       
                                                       NSDictionary* errors = errorDictionary [@"error"];
                                                       
                                                       if (errors)
                                                       {
                                                          self.loginErrorLabel.text = NSLocalizedString(@"CHECK USERNAME AND PASSWORD", nil);
                                                       }
                                                       [self.activityIndicator stopAnimating];
                                                       [self turnOnButton:self.backButton];
                                                       [self turnOnButton:self.confirmButton];
                                                       
                                                       
                                                   }];

            break;
        }
        case kLoginScreenStateRegisterStepTwo:
        {
            self.activityIndicator.center = self.confirmButton.center;
            self.activityIndicator.hidden = NO;
            [self.activityIndicator startAnimating];
            [self turnOffButton:self.backButton];
            [self turnOffButton:self.confirmButton];
            NSDictionary* userData = @{@"username": self.registeringUserNameInputField.text,
                                       @"password": self.registeringUserPasswordInputField.text,
                                       @"date_of_birth": [NSString stringWithFormat:@"%@-%@-%@", self.yyyyInputField.text, self.mmInputField.text, self.ddInputField.text],
                                       @"locale":@"en-US",
                                       @"email": self.registeringUserEmailInputField.text};
            
            [self.appDelegate.oAuthNetworkEngine registerUserWithData:userData
                                               completionHandler: ^(SYNOAuth2Credential* credential) {
                                                   
                                                   // Case where the user registers
                                                   
                                                   [self.appDelegate.oAuthNetworkEngine userInformationFromCredentials: credential
                                                                                                completionHandler: ^(NSDictionary* dictionary) {
                                                                                                    
                                                                                                    
                                                                                                    [self checkAndSaveRegisteredUser:credential];
                                                                                                    
                                                                                                    [self.activityIndicator stopAnimating];
                                                                                                    
                                                                                                    if(self.avatarImage)
                                                                                                    {
                                                                                                        [self uploadAvatar:self.avatarImage];
                                                                                                    }
                                                                                                    
                                                                                                    [self completeLoginProcess: credential];
                                                                                                    
                                                                                                } errorHandler:^(NSDictionary* errorDictionary) {
                                                                                                    [self.activityIndicator stopAnimating];
                                                                                                    [self turnOnButton:self.backButton];
                                                                                                    [self turnOnButton:self.confirmButton];
                                                                                                }];
                                                   
                                                   
                                                   
                                               } errorHandler: ^(NSDictionary* errorDictionary) {
                                                   
                                                   NSDictionary* formErrors = [errorDictionary objectForKey:@"form_errors"];
                                                   NSString* errorString;
                                                   BOOL append = NO;
                                                   if (formErrors)
                                                   {
                                                       NSArray* usernameError = [formErrors objectForKey:@"username"];
                                                       if(usernameError)
                                                       {
                                                           errorString = [NSString stringWithFormat:NSLocalizedString(@"Username: %@", nil), [usernameError objectAtIndex:0]];
                                                           append = YES;
                                                       }
                                                       
                                                       NSArray* emailError = [formErrors objectForKey:@"email"];
                                                       if (emailError)
                                                       {
                                                           NSString* emailErrorString = [NSString stringWithFormat:NSLocalizedString(@"Email: %@", nil), [emailError objectAtIndex:0]];
                                                           if(append)
                                                           {
                                                               errorString = [NSString stringWithFormat:@"%@\n%@",errorString, emailErrorString];
                                                           }
                                                           else
                                                           {
                                                               errorString = emailErrorString;
                                                           }
                                                       }
                                                       
                                                       NSArray* passwordError = [formErrors objectForKey:@"password"];
                                                       if (passwordError)
                                                       {
                                                           NSString* passwordErrorString = [NSString stringWithFormat:NSLocalizedString(@"Password: %@", nil), [passwordError objectAtIndex:0]];
                                                           if(append)
                                                           {
                                                               errorString = [NSString stringWithFormat:@"%@\n%@",errorString, passwordErrorString];
                                                           }
                                                           else
                                                           {
                                                               errorString = passwordErrorString;
                                                           }
                                                       }
                                                                                            
                                                       if(errorString)
                                                       {
                                                           self.signupErrorLabel.text = errorString;
                                                           CGFloat width = self.signupErrorLabel.frame.size.width;
                                                           [self.signupErrorLabel sizeToFit];
                                                           CGRect newFrame = self.signupErrorLabel.frame;
                                                           newFrame.size.width = width;
                                                           self.signupErrorLabel.frame = newFrame;
                                                       }
                                                   }
                                                   
                                                   [self.activityIndicator stopAnimating];
                                                   [self turnOnButton:self.backButton];
                                                   [self turnOnButton:self.confirmButton];
                                                   
                                               }];

            break;
        }
        case kLoginScreenStatePasswordRetrieve:
        {
            [self turnOffButton:self.backButton];
            [self turnOffButton:self.confirmButton];
            [self.appDelegate.oAuthNetworkEngine doRequestPasswordResetForUsername:self.emailInputField.text completionHandler:^(NSDictionary * completionInfo) {
                if ([completionInfo valueForKey:@"error"])
                {
                    self.passwordResetErrorLabel.text = NSLocalizedString(@"USER UNKNOWN", nil);
                    [self turnOnButton:self.backButton];
                    [self turnOnButton:self.confirmButton];

                }
                else
                {
                    self.passwordResetErrorLabel.text = NSLocalizedString(@"CHECK YOUR EMAIL FOR INSTRUCTIONS", nil);
                    [self turnOnButton:self.backButton];

                }
            } errorHandler:^(NSError *error) {
                self.passwordResetErrorLabel.text = NSLocalizedString(@"REQUEST FAILED", nil);
                [self turnOnButton:self.backButton];
                [self turnOnButton:self.confirmButton];

            }];
            break;
        }
        default:
            break;
    }
    
    
}

- (IBAction)nextTapped:(id)sender {
    self.loginScreenState = kLoginScreenStateRegisterStepTwo;
    [self turnOnButton:self.backButton];
    [self turnOnButton:self.confirmButton];
    [self turnOffButton:self.nextButton];
    [self turnOffButton:self.cancelButton];
    self.confirmButton.enabled = [self validateRegistrationSecondScreen];
    [UIView animateWithDuration:kLoginAnimationTransitionDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGPoint newCenter = self.secondSignupView.center;
        newCenter.x = 160.0f;
        self.secondSignupView.center = newCenter;
        
        newCenter = self.firstSignupView.center;
        newCenter.x = -160.0f;
        self.firstSignupView.center = newCenter;
        
    } completion:^(BOOL finished) {
        [self.registeringUserEmailInputField becomeFirstResponder];
    }];

    
}

- (IBAction)termsTapped:(id)sender {
}

- (IBAction)privacyPolicyTapped:(id)sender {
}

#pragma mark - facebook UI animation
-(void)doFacebookLoginAnimation
{
    self.activityIndicator.center = self.initialView.center;
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    [UIView animateWithDuration:kLoginAnimationTransitionDuration delay:0.0f options:UIViewAnimationCurveEaseInOut animations:^{
        self.signupButton.alpha = 0.0f;
        self.loginButton.alpha = 0.0f;
        self.facebookButton.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if(finished)
        {
            self.signupButton.enabled = NO;
            self.loginButton.enabled = NO;
            self.facebookButton.enabled = NO;
        }
    }];
}

-(void)doFacebookFailedAnimation
{
    [self.activityIndicator stopAnimating];
    [UIView animateWithDuration:kLoginAnimationTransitionDuration delay:0.0f options:UIViewAnimationCurveEaseInOut animations:^{
        self.signupButton.alpha = 1.0f;
        self.loginButton.alpha = 1.0f;
        self.facebookButton.alpha = 1.0f;
    } completion:^(BOOL finished) {
        if(finished)
        {
            self.signupButton.enabled = YES;
            self.loginButton.enabled = YES;
            self.facebookButton.enabled = YES;
        }
    }];
}

#pragma mark - login completion
-(void) completeLoginProcess: (SYNOAuth2Credential *) credential
{
    
    
    
    [self.activityIndicator stopAnimating];
    
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

#pragma mark - validation methods

-(BOOL)validateLogin
{
    return self.userNameInputField.text.length > 0 && self.passwordInputField.text.length > 0 ;
}

-(BOOL)validateRegistrationFirstScreen
{
    return [self.registeringUserNameInputField.text isMatchedByRegex:@"^[a-zA-Z0-9\\._]+$"];
}

-(BOOL)validateRegistrationSecondScreen
{
    return [self validateRegistrationFirstScreen] && [self.registeringUserEmailInputField.text isMatchedByRegex:@"^([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})$"] && self.registeringUserPasswordInputField.text.length>0 &&
    self.ddInputField.text.length == 2 && self.mmInputField.text.length == 2 && self.yyyyInputField.text.length == 4;
}

#pragma mark - UITextField delegate

-(IBAction)textfieldDidChange:(id)sender
{
    self.signupErrorLabel.text = @"";
    self.loginErrorLabel.text = @"";
    self.passwordResetErrorLabel.text = @"";
    switch (self.loginScreenState) {
        case kLoginScreenStateLogin:
            self.confirmButton.enabled = [self validateLogin];
            break;
        case kLoginScreenStateRegister:
            self.nextButton.enabled = [self validateRegistrationFirstScreen];
            break;
        case kLoginScreenStateRegisterStepTwo:
            self.confirmButton.enabled = [self validateRegistrationSecondScreen];
            break;
        default:
            break;
    }
}

- (BOOL) textFieldShouldReturn: (UITextField *) textField
{
    UIView* nextView = [self.view viewWithTag: textField.tag + 1];
    if (nextView)
    {
        [nextView becomeFirstResponder];
    }
    else
    {
        switch (textField.tag) {
            case 2:
            case 4:
            case 12:
                //Last field on a form. Confirm!
                [self confirmTapped:nil];
                break;
            case 6:
                //First page of Sign Up. Go next!
                [self nextTapped:nil];
                break;
            default:
                [textField resignFirstResponder];
                break;
        }
    }
    
    
    return YES;
}


#pragma mark - button enabling convenience methods

-(void)turnOnButton:(UIButton*)button
{
    button.hidden = NO;
    button.alpha = 0.0f;
    [UIView animateWithDuration:kLoginAnimationTransitionDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        button.alpha = 1.0f;
    } completion:nil];
}

-(void)turnOffButton:(UIButton*)button
{
    [UIView animateWithDuration:kLoginAnimationTransitionDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        button.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if(finished)
        {
            button.hidden = YES;
        }
    }];
}

#pragma mark - UIActionsheet delegate

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //Camera
        [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
    }
    else if (buttonIndex ==1)
    {
        //Choose existing
        [self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

@end
