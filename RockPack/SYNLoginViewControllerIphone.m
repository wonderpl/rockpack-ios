//
//  SYNLoginViewControllerIphone.m
//  rockpack
//
//  Created by Mats Trovik on 02/05/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "GAI.h"
#import "RegexKitLite.h"
#import "SYNDeviceManager.h"
#import "SYNFacebookManager.h"
#import "SYNLoginViewController.h"
#import "SYNLoginViewControllerIphone.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNOnboard1ViewController.h"
#import "SYNOnboard2ViewController.h"
#import "SYNOnboard3ViewController.h"
#import "SYNOnboard4ViewController.h"
#import "SYNTextFieldLoginiPhone.h"
#import "UIFont+SYNFont.h"
#import <FacebookSDK/FacebookSDK.h>

#define kLoginAnimationTransitionDuration 0.3f

@interface SYNLoginViewControllerIphone () <UITextFieldDelegate,
                                            SYNImagePickerControllerDelegate,
                                            UIPageViewControllerDataSource,
                                            UIPageViewControllerDelegate>

@property (nonatomic, strong) IBOutlet SYNTextFieldLoginiPhone* ddInputField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLoginiPhone* emailInputField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLoginiPhone* mmInputField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLoginiPhone* passwordInputField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLoginiPhone* registeringUserEmailInputField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLoginiPhone* registeringUserNameInputField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLoginiPhone* registeringUserPasswordInputField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLoginiPhone* userNameInputField;
@property (nonatomic, strong) IBOutlet SYNTextFieldLoginiPhone* yyyyInputField;
@property (nonatomic, strong) IBOutlet UIImageView* loginBackgroundImage;
@property (nonatomic, strong) IBOutlet UIImageView* rockpackLogoImage;
@property (nonatomic, strong) IBOutlet UILabel* termsAndConditionsLabel;
@property (nonatomic, strong) IBOutlet UILabel* wellSendYouLabel;
@property (nonatomic, strong) IBOutlet UILabel* whatsOnYourChannelLabel;
@property (nonatomic, strong) IBOutlet UIView* dobView;
@property (strong, nonatomic) NSArray *onboardingViewControllers;
@property (strong, nonatomic) NSDateFormatter * dateFormatter;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UILabel *loginErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordResetErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *registeringUserErrorLabel;
@property (weak, nonatomic) IBOutlet UILabel *signupErrorLabel;
@property (weak, nonatomic) IBOutlet UIView *firstSignupView;
@property (weak, nonatomic) IBOutlet UIView *initialView;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UIView *secondSignupView;
@property (weak, nonatomic) IBOutlet UIView *termsAndConditionsView;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* activityIndicator;

@property (nonatomic, strong) IBOutlet UIButton* passwordForgottenButton;

@property (nonatomic, strong) IBOutlet UIImage* avatarImage;

@property (nonatomic, strong) IBOutlet UIImageView* avatarImageView;

@property (nonatomic, strong) NSDateFormatter* formatter;

@property (nonatomic, strong) NSMutableArray* validUsernames;

@end

@implementation SYNLoginViewControllerIphone 


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    BOOL isPreIPhone5 = [SYNDeviceManager.sharedInstance currentScreenHeight] < 500;
    
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
    self.ddInputField.delegate = self;
    self.mmInputField.font = [UIFont rockpackFontOfSize:self.mmInputField.font.pointSize];
    self.mmInputField.delegate = self;
    self.yyyyInputField.font = [UIFont rockpackFontOfSize:self.yyyyInputField.font.pointSize];
    self.yyyyInputField.delegate = self;
    self.emailInputField.font = [UIFont rockpackFontOfSize:self.emailInputField.font.pointSize];
    self.emailInputField.delegate = self;
    
    self.loginErrorLabel.font = [UIFont rockpackFontOfSize:self.loginErrorLabel.font.pointSize];
    self.passwordResetErrorLabel.font = [UIFont rockpackFontOfSize:self.passwordResetErrorLabel.font.pointSize];
    self.signupErrorLabel.font = [UIFont rockpackFontOfSize:self.signupErrorLabel.font.pointSize];
    self.whatsOnYourChannelLabel.font = [UIFont rockpackFontOfSize:self.whatsOnYourChannelLabel.font.pointSize];
    self.whatsOnYourChannelLabel.text = NSLocalizedString(@"rockpack_strapline", nil);

    
    NSMutableAttributedString* termsString = [[NSMutableAttributedString alloc] initWithString: NSLocalizedString(@"register_screen_legal" , nil)];
    
    [termsString addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:(11.0/255.0) green:(166.0/255.0) blue:(171.0/255.0) alpha:(1.0)] range: NSMakeRange(36, 17)];
    [termsString addAttribute: NSForegroundColorAttributeName value: [UIColor colorWithRed:(11.0/255.0) green:(166.0/255.0) blue:(171.0/255.0) alpha:(1.0)] range: NSMakeRange(58, 14)];
    self.termsAndConditionsLabel.attributedText = termsString;
    self.termsAndConditionsLabel.font = [UIFont rockpackFontOfSize:self.termsAndConditionsLabel.font.pointSize];
    
    self.passwordForgottenButton.titleLabel.font = [UIFont rockpackFontOfSize:self.passwordForgottenButton.titleLabel.font.pointSize];
    
    //Setup Keyboard Return Button
    self.userNameInputField.returnKeyType = UIReturnKeyNext;
    self.passwordInputField.returnKeyType = UIReturnKeyGo;
    self.registeringUserEmailInputField.returnKeyType = UIReturnKeyNext;
    self.registeringUserNameInputField.returnKeyType = UIReturnKeyNext;
    self.registeringUserPasswordInputField.returnKeyType = UIReturnKeyNext;
    self.emailInputField.returnKeyType = UIReturnKeySend;
    
    self.state = kLoginScreenStateInitial;
    
    self.formatter = [[NSDateFormatter alloc] init];
    self.formatter.dateFormat = @"dd/MM/yyyy";
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle: UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation: UIPageViewControllerNavigationOrientationHorizontal
                                                                            options: nil];
    
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    // Setup the on-boarding controller
    self.onboardingViewControllers = @[[SYNOnboard1ViewController new],
                                       [SYNOnboard2ViewController new],
                                       [SYNOnboard3ViewController new],
                                       [SYNOnboard4ViewController new]];
    
    [self.pageViewController setViewControllers: @[self.onboardingViewControllers[0]]
                                      direction: UIPageViewControllerNavigationDirectionForward
                                       animated: NO
                                     completion: nil];
    
    [self addChildViewController: self.pageViewController];
    [self.view addSubview: self.pageViewController.view];
    
    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    // This is the amount by which to offset the bottom of the page view from the bottom of the screen
    CGRect pageViewRect = self.view.bounds;
    pageViewRect.size.height -= 130;
    self.pageViewController.view.frame = pageViewRect;
    
    [self.pageViewController didMoveToParentViewController: self];

}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    self.loginBackgroundImage.frame = self.loginBackgroundImage.bounds;
    
    [UIView animateWithDuration:50.0f
                          delay:0.0f
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.loginBackgroundImage.frame = CGRectMake(self.loginBackgroundImage.frame.origin.x - 360.0f, self.loginBackgroundImage.frame.origin.y, self.loginBackgroundImage.frame.size.width, self.loginBackgroundImage.frame.size.height);
                         
                     } completion:^(BOOL finished) {
                         //self.darkOverlayView.hidden = NO;
                     }];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.rockpackLogoImage.frame = self.rockpackLogoImage.frame;
    
    [UIView animateWithDuration:0.3f
                          delay:0.1f
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.rockpackLogoImage.frame = CGRectMake(self.rockpackLogoImage.frame.origin.x, 35.0f, self.rockpackLogoImage.frame.size.width, self.rockpackLogoImage.frame.size.height);
                         
                     } completion:^(BOOL finished) {
                     }];
    
    self.whatsOnYourChannelLabel.frame = self.whatsOnYourChannelLabel.frame;
    self.whatsOnYourChannelLabel.alpha = 0.0f;
    
    [UIView animateWithDuration:0.3f
                          delay:0.1f
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.whatsOnYourChannelLabel.frame = CGRectMake(self.whatsOnYourChannelLabel.frame.origin.x, 100.0f, self.whatsOnYourChannelLabel.frame.size.width, self.whatsOnYourChannelLabel.frame.size.height);
                         self.whatsOnYourChannelLabel.alpha = 1.0f;
                     } completion:^(BOOL finished) {
                     }];
    
    
    
    self.facebookButton.alpha = 0.0f;
    self.facebookButton.frame = self.facebookButton.frame;
    
    [UIView animateWithDuration:0.3f
                          delay:0.1f
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.facebookButton.alpha = 1.0f;
                         self.facebookButton.frame = CGRectMake(self.facebookButton.frame.origin.x, self.facebookButton.frame.origin.y - 20.0f, self.facebookButton.frame.size.width, self.facebookButton.frame.size.height);
                         
                     } completion:^(BOOL finished) {
                     }];
    
    self.signupButton.alpha = 0.0f;
    self.signupButton.frame = self.signupButton.frame;
    
    [UIView animateWithDuration:0.3f
                          delay:0.1f
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.signupButton.alpha = 1.0f;
                         self.signupButton.frame = CGRectMake(self.signupButton.frame.origin.x, self.signupButton.frame.origin.y - 20.0f, self.signupButton.frame.size.width, self.signupButton.frame.size.height);
                         
                     } completion:^(BOOL finished) {
                     }];
    
    self.loginButton.alpha = 0.0f;
    self.loginButton.frame = self.loginButton.frame;
    
    [UIView animateWithDuration:0.3f
                          delay:0.1f
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.loginButton.alpha = 1.0f;
                         self.loginButton.frame = CGRectMake(self.loginButton.frame.origin.x, self.loginButton.frame.origin.y - 20.0f, self.loginButton.frame.size.width, self.loginButton.frame.size.height);
                         
                     } completion:^(BOOL finished) {
                     }];
}

-(void)reEnableLoginControls
{
}


#pragma mark - Onboarding support

- (void) hideOnboarding
{
    [UIView animateWithDuration: 0.3f
                          delay: 0.1f
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         self.pageViewController.view.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                         self.pageViewController.view.hidden = TRUE;
                     }];
}

- (void) showOnboarding
{
    self.pageViewController.view.hidden = FALSE;
    
    [UIView animateWithDuration: 0.3f
                          delay: 0.1f
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         self.pageViewController.view.alpha = 1.0f;
                     } completion: nil];
}

#pragma mark - Page View Controller Data Source

- (UIViewController *) pageViewController: (UIPageViewController *) pageViewController
       viewControllerBeforeViewController: (UIViewController *) viewController
{
    NSUInteger numberOfOnboardViewControllers = self.onboardingViewControllers.count;
    int index = 0;
    for (UIViewController *vc in self.onboardingViewControllers)
    {
        if (vc == viewController)
        {
#ifdef WRAP_AROUND
            if (index == 0)
            {
                return nil;
            }
            else
            {
                return self.onboardingViewControllers[index - 1];
            }
#else
            if (index == 0)
            {
                return self.onboardingViewControllers [numberOfOnboardViewControllers - 1];
            }
            else
            {
                return self.onboardingViewControllers [index - 1];
            }
#endif
        }
        
        index++;
    }
    
    // If we got here then we didn't find the viewcontroller
    return nil;
}

- (UIViewController *) pageViewController: (UIPageViewController *) pageViewController
        viewControllerAfterViewController: (UIViewController *) viewController
{
    NSUInteger numberOfOnboardViewControllers = self.onboardingViewControllers.count;
    int index = 0;
    for (UIViewController *vc in self.onboardingViewControllers)
    {
        if (vc == viewController)
        {
#ifdef WRAP_AROUND
            if (index == (self.onboardingViewControllers.count - 1))
            {
                return nil;
            }
            else
            {
                return self.onboardingViewControllers[(index + 1) % numberOfOnboardViewControllers];
            }
#else
            return self.onboardingViewControllers [(index + 1) % numberOfOnboardViewControllers];
#endif
        }
        
        index++;
    }
    
    // If we got here then we didn't find the viewcontroller
    return nil;
}



- (NSInteger) presentationCountForPageViewController: (UIPageViewController *) pageViewController
{
    return self.onboardingViewControllers.count;
}


- (NSInteger) presentationIndexForPageViewController: (UIPageViewController *) pageViewController
{
    // Start off showing the first view controller
    return 0;
}


#pragma mark - button IBActions

- (IBAction) facebookTapped: (id) sender
{
    [self hideOnboarding];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker sendEventWithCategory: @"uiAction"
                        withAction: @"facebookLogin"
                         withLabel: nil
                         withValue: nil];
    
    [tracker sendEventWithCategory: @"goal"
                        withAction: @"userLogin"
                         withLabel: @"Facebook"
                         withValue: nil];
    
    if(![self isNetworkAccessibleOtherwiseShowErrorAlert])
    {
        return;
    }
    
    [self doFacebookLoginAnimation];
    
    [self loginThroughFacebookWithCompletionHandler:^(NSDictionary * dictionary) {
        
        [tracker sendEventWithCategory: @"goal"
                            withAction: @"userLogin"
                             withLabel: @"Facebook"
                             withValue: nil];
        
        [self completeLoginProcess];
    } errorHandler:^(id error) {
        [self doFacebookFailedAnimation];
        if([error isKindOfClass:[NSDictionary class]])
        {
            NSDictionary* formErrors = error[@"form_errors"];

            
            if (formErrors)
            {
                [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"facebook_login_error_title", nil)
                                            message: NSLocalizedString(@"facebook_login_error_description", nil)
                                           delegate: nil
                                  cancelButtonTitle: NSLocalizedString(@"OK", nil)
                                  otherButtonTitles: nil] show];
            }
            
        }
        else if([error isKindOfClass:[NSString class]])
        {
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


- (IBAction) signupTapped: (id) sender
{
    [self hideOnboarding];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker sendEventWithCategory: @"goal"
                        withAction: @"userRegistration"
                         withLabel: @"Rockpack"
                         withValue: nil];
    
    [GAI.sharedInstance.defaultTracker sendView: @"Register"];
    
    //Fade out login background
    self.loginBackgroundImage.alpha = 1.0f;
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.loginBackgroundImage.alpha = 0.0f;
                         
                     } completion:^(BOOL finished) {
                     }];
    
    self.state = kLoginScreenStateRegister;
    
    [self turnOnButton:self.cancelButton];
    [self turnOnButton:self.nextButton];
    
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


- (IBAction) loginTapped: (id) sender
{
    [self hideOnboarding];
    
    [GAI.sharedInstance.defaultTracker sendView: @"Login"];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker sendEventWithCategory: @"goal"
                        withAction: @"userLogin"
                         withLabel: @"Rockpack"
                         withValue: nil];
    
    //Fade out login background
    self.loginBackgroundImage.alpha = 1.0f;
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.loginBackgroundImage.alpha = 0.0f;
                         
                     } completion:^(BOOL finished) {
                     }];
    
    self.state = kLoginScreenStateLogin;
    
    [self turnOnButton:self.backButton];
    [self turnOnButton:self.confirmButton];
    
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


- (IBAction) forgotPasswordTapped: (id) sender
{
    // Google analytics support
    [GAI.sharedInstance.defaultTracker sendView: @"Forgot password"];
    self.state = kLoginScreenStatePasswordRetrieve;
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


- (IBAction) photoButtonTapped: (id) sender
{
            self.imagePicker = [[SYNImagePickerController alloc] initWithHostViewController:self];
            self.imagePicker.delegate = self;
            [self.imagePicker presentImagePickerAsPopupFromView:nil arrowDirection:UIPopoverArrowDirectionLeft];
}


- (IBAction) backbuttonTapped: (id) sender
{
    switch (self.state)
    {
        case kLoginScreenStateRegisterStepTwo:
        {
            [self turnOffButton:self.backButton];
            [self turnOffButton:self.confirmButton];
            [self turnOnButton:self.nextButton];
            [self turnOnButton:self.cancelButton];
            self.state = kLoginScreenStateRegister;
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
                [self turnOffButton:self.backButton];
            }];
            
            break;
        }
        case kLoginScreenStatePasswordRetrieve:
        {
            self.state = kLoginScreenStateLogin;
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
            //Fade in login background
            self.loginBackgroundImage.alpha = 0.0f;
            
            [self showOnboarding];
            
            [UIView animateWithDuration:0.3f
                                  delay:0.0f
                                options: UIViewAnimationCurveEaseInOut
                             animations:^{
                                 self.loginBackgroundImage.alpha = 1.0f;
                                 
                             } completion:^(BOOL finished) {
                             }];
            
            self.state = kLoginScreenStateInitial;
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


- (IBAction) cancelTapped: (id) sender
{
    switch (self.state)
    {
        case kLoginScreenStateRegister:
        {
            //Fade in login background
            self.loginBackgroundImage.alpha = 0.0f;
            
            [self showOnboarding];
            
            [UIView animateWithDuration:0.3f
                                  delay:0.0f
                                options: UIViewAnimationCurveEaseInOut
                             animations:^{
                                 self.loginBackgroundImage.alpha = 1.0f;
                                 
                             } completion:^(BOOL finished) {
                             }];
            
            self.state = kLoginScreenStateInitial;
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


- (IBAction) confirmTapped: (id) sender
{
    BOOL valid = YES;
    switch (self.state) {
            case kLoginScreenStateLogin:
                valid = [self loginFormIsValidForUsername:self.userNameInputField password:self.passwordInputField];
                break;
            case kLoginScreenStateRegisterStepTwo:
                valid = [self registrationFormIsValidForEmail:self.registeringUserEmailInputField userName:self.registeringUserNameInputField password:self.registeringUserPasswordInputField dd:self.ddInputField mm:self.mmInputField yyyy:self.yyyyInputField];
                break;
            case kLoginScreenStatePasswordRetrieve:
                valid = [self resetPasswordFormIsValidForUsername:self.emailInputField];
                break;
            default:
                valid = NO;
                break;
    }
    
    //Registration screen has no space for the keyboard together with the error message. ensure keyboard is always not showing on this screen.
    [self.registeringUserEmailInputField resignFirstResponder];
    [self.registeringUserPasswordInputField resignFirstResponder];
    [self.ddInputField resignFirstResponder];
    [self.yyyyInputField resignFirstResponder];
    [self.mmInputField resignFirstResponder];
    
    if(!valid)
    {
        return;
    }
    
    // Hide the keyboard.
    [self.userNameInputField resignFirstResponder];
    [self.passwordInputField resignFirstResponder];
    [self.emailInputField resignFirstResponder];
    
    if(![self isNetworkAccessibleOtherwiseShowErrorAlert])
    {
        return;
    }
    
    switch (self.state) {
        case kLoginScreenStateLogin:
        {
            [self turnOffButton:self.backButton];
            [self turnOffButton:self.confirmButton];
            self.activityIndicator.hidden = NO;
            self.activityIndicator.center = self.confirmButton.center;
            [self.activityIndicator startAnimating];
            [self loginForUsername:self.userNameInputField.text forPassword:self.passwordInputField.text completionHandler:^(NSDictionary* dictionary) {
         
//                DebugLog(@"User Registerd: %@", [dictionary objectForKey:@"username"]);
                
                [self.activityIndicator stopAnimating];
                
                [self completeLoginProcess];
                
            } errorHandler:^(NSDictionary* errorDictionary) {
                
                [self.activityIndicator stopAnimating];
                [self turnOnButton:self.backButton];
                [self turnOnButton:self.confirmButton];
                
                NSError* networkError = [errorDictionary valueForKey:@"nserror"];
                if (networkError.code >= 500 && networkError.code <600) {
                    return;
                }
                
                NSString* savingError = errorDictionary[@"saving_error"];
                if(savingError) {
                    self.loginErrorLabel.text = NSLocalizedString(@"login_screen_saving_error", nil);
                } else {
                    self.loginErrorLabel.text = NSLocalizedString(@"login_screen_form_field_username_password_error_incorrect", nil);
                }
                
                
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
            self.ddInputField.text = [self zeroPadIfOneCharacter:self.ddInputField.text];
            self.mmInputField.text = [self zeroPadIfOneCharacter:self.mmInputField.text];
            NSDictionary* userData = @{@"username": self.registeringUserNameInputField.text,
                                       @"password": self.registeringUserPasswordInputField.text,
                                       @"date_of_birth": [NSString stringWithFormat:@"%@-%@-%@", self.yyyyInputField.text, self.mmInputField.text, self.ddInputField.text],
                                       @"locale":@"en-US",
                                       @"email": self.registeringUserEmailInputField.text};
            [self registerUserWithData:userData completionHandler:^(NSDictionary*dictionary) {
                [self.activityIndicator stopAnimating];
                
                if(self.avatarImage)
                {
                    [self uploadAvatarImage:self.avatarImage completionHandler:nil errorHandler:^(id dictionary) {
                        [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"register_screen_form_avatar_upload_title", nil)
                                                    message: NSLocalizedString(@"register_screen_form_avatar_upload_description.", nil)
                                                   delegate: nil
                                          cancelButtonTitle: NSLocalizedString(@"OK", nil)
                                          otherButtonTitles: nil] show];
                    }];
                }
                [self completeLoginProcess];
                
            } errorHandler:^(NSDictionary* errorDictionary) {
                
                [self.activityIndicator stopAnimating];
                [self turnOnButton:self.backButton];
                [self turnOnButton:self.confirmButton];
                
                NSError* networkError = [errorDictionary valueForKey:@"nserror"];
                if (networkError.code >= 500 && networkError.code <600) {
                    return;
                }
                
                NSDictionary* formErrors = [errorDictionary objectForKey:@"form_errors"];
                NSString* errorString;
                BOOL append = NO;
                if (formErrors)
                {
                    NSArray* usernameError = [formErrors objectForKey:@"username"];
                    if(usernameError)
                    {
                        errorString = [NSString stringWithFormat:NSLocalizedString(@"%@: %@", nil), NSLocalizedString(@"Username", nil), [usernameError objectAtIndex:0]];
                        append = YES;
                    }
                    
                    NSArray* emailError = [formErrors objectForKey:@"email"];
                    if (emailError)
                    {
                        NSString* emailErrorString = [NSString stringWithFormat:NSLocalizedString(@"%@: %@", nil), NSLocalizedString(@"Email", nil),[emailError objectAtIndex:0]];
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
                        NSString* passwordErrorString = [NSString stringWithFormat:NSLocalizedString(@"%@: %@", nil), NSLocalizedString(@"Password", nil),[passwordError objectAtIndex:0]];
                        if(append)
                        {
                            errorString = [NSString stringWithFormat:@"%@\n%@",errorString, passwordErrorString];
                        }
                        else
                        {
                            errorString = passwordErrorString;
                        }
                    }
                    
                    NSArray* dateError = [formErrors objectForKey:@"date_of_birth"];
                    if (dateError)
                    {
                        NSString* dateErrorString = [NSString stringWithFormat:NSLocalizedString(@"%@: %@", nil), NSLocalizedString(@"DOB", nil),[dateError objectAtIndex:0]];
                        if(append)
                        {
                            errorString = [NSString stringWithFormat:@"%@\n%@",errorString, dateErrorString];
                        }
                        else
                        {
                            errorString = dateErrorString;
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

            }];
            break;
        }
        case kLoginScreenStatePasswordRetrieve:
        {
            [self turnOffButton:self.backButton];
            [self turnOffButton:self.confirmButton];
            [self doRequestPasswordResetForUsername:self.emailInputField.text completionHandler:^(NSDictionary *completionInfo) {
                if ([completionInfo valueForKey:@"error"])
                {
                    self.passwordResetErrorLabel.text = NSLocalizedString(@"forgot_password_screen_form_field_username_user_unknown", nil);
                    [self turnOnButton:self.backButton];
                    [self turnOnButton:self.confirmButton];
                    
                }
                else
                {
                    [[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"forgot_password_screen_complete_title", nil)
                                                message: NSLocalizedString(@"forgot_password_screen_complete_message", nil)
                                               delegate: nil
                                      cancelButtonTitle: NSLocalizedString(@"OK", nil)
                                      otherButtonTitles: nil] show];
                    [self turnOnButton:self.backButton];
                    
                }

            } errorHandler:^(NSError *error) {
                self.passwordResetErrorLabel.text = NSLocalizedString(@"forgot_password_screen_form_field_request_failed_error", nil);
                [self turnOnButton:self.backButton];
                [self turnOnButton:self.confirmButton];
            }];
            break;
        }
        default:
            break;
    } 
}


- (IBAction) nextTapped: (id) sender
{
    BOOL valid = YES;
    switch (self.state) {
            case kLoginScreenStateRegister:
               [self.registeringUserNameInputField resignFirstResponder];
               valid = [self registrationFormPartOneIsValidForUserName:self.registeringUserNameInputField];
               break;
            default:
            valid = NO;
                break;
        }
    
    if(!valid)
    {
        return;
    }
    
    if(!self.validUsernames)
    {
        self.validUsernames = [NSMutableArray array];
    }
    else
    {
        if([self.validUsernames indexOfObject:self.registeringUserNameInputField.text] !=NSNotFound)
        {
            [self showRegistrationStep2];
            return;
        }
    }
    
    [self.activityIndicator startAnimating];
    [self turnOffButton:self.cancelButton];
    [self turnOffButton:self.nextButton];
    
    [self doRequestUsernameAvailabilityForUsername:self.registeringUserNameInputField.text completionHandler:^(NSDictionary *result) {
        
        [self.activityIndicator stopAnimating];
        [self turnOnButton:self.cancelButton];
        
        NSNumber* availabilitynumber = [result objectForKey:@"available"];
        if(availabilitynumber)
        {
        BOOL usernameAvailable = [availabilitynumber boolValue];
            if(usernameAvailable)
            {
                [self showRegistrationStep2];
            }
            else
            {
                [self turnOnButton:self.nextButton];
                self.registeringUserErrorLabel.text = NSLocalizedString(@"register_screen_form_field_username_already_taken", nil);
            }
        }
        else
        {
            NSArray* formErrors = [result objectForKey:@"message"];
            NSString* errorString = self.registeringUserErrorLabel.text = NSLocalizedString(@"unknown_error_message", nil);
            if (formErrors && [formErrors count]>0)
            {
                errorString = [NSString stringWithFormat:NSLocalizedString(@"%@: %@", nil), NSLocalizedString(@"Username", nil), [formErrors objectAtIndex:0]];
            }
            
            self.registeringUserErrorLabel.text = errorString;
            
            [self turnOnButton:self.nextButton];
        }
    } errorHandler:^(NSError *error) {
        
        [self.activityIndicator stopAnimating];
        [self turnOnButton:self.cancelButton];
        [self turnOnButton:self.nextButton];
        self.registeringUserErrorLabel.text = NSLocalizedString(@"unknown_error_message", nil);

        
    }];

    
}

- (IBAction) termsTapped: (id) sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: kLoginTermsUrl]];

}


- (IBAction) privacyPolicyTapped: (id) sender
{

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: kLoginPrivacyUrl]];
    
}


#pragma mark - show registration step 2 animation

-(void)showRegistrationStep2
{
    [GAI.sharedInstance.defaultTracker sendView: @"Register 2"];
    
    self.state = kLoginScreenStateRegisterStepTwo;
    [self turnOnButton:self.backButton];
    [self turnOnButton:self.confirmButton];
    [self turnOffButton:self.nextButton];
    [self turnOffButton:self.cancelButton];
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


#pragma mark - facebook UI animation

- (void) doFacebookLoginAnimation
{
    self.activityIndicator.center = self.initialView.center;
    self.activityIndicator.hidden = NO;
    self.activityIndicator.color = [UIColor whiteColor];
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


- (void) doFacebookFailedAnimation
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

- (void) completeLoginProcess
{

    [self.activityIndicator stopAnimating];
    
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
    
    UIImageView *splashView = nil;
    if([SYNDeviceManager.sharedInstance currentScreenHeight]>480.0f)
    {
        splashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"Default-568h"]];
    }
    else
    {
        splashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"Default"]];
    }
    splashView.center = CGPointMake(160.0f, splashView.center.y - 20.0f);
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

#pragma mark - UITextField delegate

- (BOOL) textField: (UITextField *) textField
shouldChangeCharactersInRange: (NSRange) range
 replacementString: (NSString *) newCharacter
{
    
    NSUInteger oldLength = textField.text.length;
    NSUInteger replacementLength = newCharacter.length;
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = (oldLength + replacementLength) - rangeLength;
    
    
    if ((textField == self.ddInputField || textField == self.mmInputField) && newLength > 2)
        return NO;
    if (textField == self.yyyyInputField && newLength > 4)
        return NO;
    if(textField == self.registeringUserNameInputField && newLength > 20)
        return NO;
    
    
    
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    if (textField == self.ddInputField || textField == self.mmInputField || textField == self.yyyyInputField)
        if (![numberFormatter numberFromString:newCharacter] && newCharacter.length != 0) // is backspace, length is 0
            return NO;

    return YES;
}

- (IBAction) textfieldDidChange: (id) sender
{
    self.signupErrorLabel.text = @"";
    self.loginErrorLabel.text = @"";
    self.passwordResetErrorLabel.text = @"";
    self.registeringUserErrorLabel.text = @"";
        
    if(sender == self.ddInputField && [self.ddInputField.text length]==2)
    {
        [self.mmInputField becomeFirstResponder];
        if([self.mmInputField.text length]>0 && [self.yyyyInputField.text length]>0 )
        {
            [self dateValidForDd:self.ddInputField mm:self.mmInputField yyyy:self.yyyyInputField];
        }
    }
    else if(sender == self.mmInputField && [self.mmInputField.text length]==2)
    {
        [self.yyyyInputField becomeFirstResponder];
        if([self.ddInputField.text length]>0 && [self.yyyyInputField.text length]>0 )
        {
            [self dateValidForDd:self.ddInputField mm:self.mmInputField yyyy:self.yyyyInputField];
        }
    }
    else if(sender == self.yyyyInputField && [self.yyyyInputField.text length] >= 4)
    {
    
        [sender resignFirstResponder];
        [self dateValidForDd:self.ddInputField mm:self.mmInputField yyyy:self.yyyyInputField];
    }
    
    if(![self.signupErrorLabel.text isEqualToString: @""])
    {
        [sender resignFirstResponder];
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
                if(self.confirmButton.enabled)
                {
                    [self confirmTapped:nil];
                }
                break;
            case 6:
                //First page of Sign Up. Go next!
                if(self.nextButton.enabled)
                {
                    [self nextTapped:nil];
                }
                break;
            default:
                [textField resignFirstResponder];
                break;
        }
    }
    
    
    return YES;
}


#pragma mark - button enabling convenience methods

- (void) turnOnButton: (UIButton*) button
{
    if(button.hidden == YES)
    {
        button.hidden = NO;
        button.alpha = 0.0f;
        [UIView animateWithDuration:kLoginAnimationTransitionDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            button.alpha = 1.0f;
        } completion:nil];
    }
}


- (void) turnOffButton: (UIButton*) button
{
    if(button.hidden==NO)
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



#pragma mark - validation
- (void) placeErrorLabel: (NSString*) errorText
              nextToView: (UIView*) view
{
    
    UILabel* errorLabel = nil;
    switch (self.state) {
        case kLoginScreenStateLogin:
            errorLabel = self.loginErrorLabel;
            break;
        case kLoginScreenStateRegister:
            errorLabel = self.registeringUserErrorLabel;
            break;
        case kLoginScreenStateRegisterStepTwo:
            errorLabel = self.signupErrorLabel;
            break;
        case kLoginScreenStatePasswordRetrieve:
            errorLabel = self.passwordResetErrorLabel;
            break;
        default:
            break;
    }
    
    errorLabel.text = errorText;
}


@end
