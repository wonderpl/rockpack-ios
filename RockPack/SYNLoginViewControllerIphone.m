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

#define kLoginAnimationTransitionDuration 0.3f

@interface SYNLoginViewControllerIphone () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *defaultView;
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
        
        newCenter = self.defaultView.center;
        newCenter.x = -160.0f;
        self.defaultView.center = newCenter;
        
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
        
        newCenter = self.defaultView.center;
        newCenter.x = -160.0f;
        self.defaultView.center = newCenter;
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
- (IBAction)photoButtonTapped:(id)sender {
}

- (IBAction)backbuttonTapped:(id)sender {
    
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
                newCenter = self.defaultView.center;
                newCenter.x = 160.0f;
                self.defaultView.center = newCenter;
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
                
                newCenter = self.defaultView.center;
                newCenter.x = 160.0f;
                self.defaultView.center = newCenter;
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
    
    switch (self.loginScreenState) {
        case kLoginScreenStateLogin:
        {
            [self turnOffButton:self.backButton];
            [self turnOffButton:self.confirmButton];
            
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
                                                                                                        
                                                                                                        [self turnOnButton:self.backButton];
                                                                                                        [self turnOnButton:self.confirmButton];
                                                                                                        
                                                                                                    }];
                                                       
                                                       
                                                       
                                                       
                                                   } errorHandler: ^(NSDictionary* errorDictionary) {
                                                       
                                                       NSDictionary* errors = errorDictionary [@"error"];
                                                       
//                                                       if (errors)
//                                                       {
//                                                           [self placeErrorLabel: @"Username could be incorrect"
//                                                                      NextToView: userNameInputField];
//                                                           
//                                                           [self placeErrorLabel: @"Password could be incorrect"
//                                                                      NextToView: passwordInputField];
//                                                       }
                                                       [self turnOnButton:self.backButton];
                                                       [self turnOnButton:self.confirmButton];
                                                   }];

            break;
        }
            
        case kLoginScreenStatePasswordRetrieve:
        {
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

-(void) completeLoginProcess: (SYNOAuth2Credential *) credential
{
    
    
    
//    [activityIndicator stopAnimating];
    
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

@end
