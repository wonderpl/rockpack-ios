//
//  SYNLoginBaseViewController.m
//  rockpack
//
//  Created by Mats Trovik on 14/05/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "GAI.h"
#import "NSString+Utils.h"
#import "SYNActivityManager.h"
#import "SYNAppDelegate.h"
#import "SYNDeviceManager.h"
#import "SYNFacebookManager.h"
#import "SYNLoginBaseViewController.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import "User.h"
#import <FacebookSDK/FacebookSDK.h>
#import "RegexKitLite.h"


@interface SYNLoginBaseViewController ()

@end

@implementation SYNLoginBaseViewController

- (id) init
{
    if ((self = [super init]))
    {
        [self commonInit];
    }
        
    return self;
}

        
- (id) initWithCoder: (NSCoder *) aDecoder
{
    self = [super initWithCoder: aDecoder];
    
    if (self)
    {
        [self commonInit];
    }
    
    return self;
}

        
- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *) nibBundleOrNil
{
    self = [super initWithNibName: nibNameOrNil
                           bundle: nibBundleOrNil];
    if (self)
    {
        [self commonInit];
    }
    
    return self;
}

-(void)reEnableLoginControls
{
    // implement in subclass
}


- (void) commonInit
{
    _appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    self.reachability = [Reachability reachabilityWithHostname: _appDelegate.networkEngine.hostName];
    
    
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear:animated];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];

}

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    [self performSelector: @selector(reachabilityChanged:)
               withObject: nil];
}

- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kReachabilityChangedNotification
                                                  object: nil];
}

- (void) setUpInitialState
{
    //Override in subclass
}

- (BOOL) checkAndSaveRegisteredUser: (SYNOAuth2Credential*) credential
{
    User* newUser = self.appDelegate.currentUser;
    
    if (!newUser)
    {
        // problem
        DebugLog(@"The user was not registered correctly...");
        return NO;
    }
    
    self.appDelegate.currentOAuth2Credentials = credential;
    
    [SYNActivityManager.sharedInstance updateActivityForCurrentUser];
    
    return YES;
}


#pragma mark - login

- (void) loginForUsername: (NSString*) username
              forPassword: (NSString*) password
        completionHandler: (MKNKUserSuccessBlock) completionBlock
             errorHandler: (MKNKUserErrorBlock) errorBlock
{
    [self.appDelegate.oAuthNetworkEngine doSimpleLoginForUsername: username forPassword: password completionHandler: ^(SYNOAuth2Credential* credential) {

        // Case where the user is a member of Rockpack but has not signing in this device
        
        [self.appDelegate.oAuthNetworkEngine retrieveAndRegisterUserFromCredentials: credential completionHandler: ^(NSDictionary* dictionary) {

            // the dictionary contains a User dictionary (without subscriptions) //
            
          
            
            // by this time the currentUser is set in the DB //
            
            if([self checkAndSaveRegisteredUser: credential])
            {
                
                DebugLog(@"User Registerd: %@", [dictionary objectForKey: @"username"]);
                _appDelegate.currentUser.loginOriginValue = LoginOriginRockpack;
                completionBlock(dictionary);
            }
            else
            {
                DebugLog(@"ERROR: User not registered (User: %@)", _appDelegate.currentUser);
                // TODO: handle user not being registered propery
            }
            
            
            
        } errorHandler:errorBlock];
        
    } errorHandler:errorBlock];
    
}


#pragma mark - reset password

- (void) doRequestPasswordResetForUsername: (NSString*) username
                         completionHandler: (MKNKJSONCompleteBlock) completionBlock
                              errorHandler: (MKNKErrorBlock) errorBlock
{
    [self.appDelegate.oAuthNetworkEngine doRequestPasswordResetForUsername: username
                                                         completionHandler: completionBlock
                                                              errorHandler:errorBlock];
}

- (void) doRequestUsernameAvailabilityForUsername: (NSString*) username
                                completionHandler: (MKNKJSONCompleteBlock) completionBlock
                                     errorHandler: (MKNKErrorBlock) errorBlock
{
    [self.appDelegate.oAuthNetworkEngine doRequestUsernameAvailabilityForUsername:username
                                                         completionHandler: completionBlock
                                                              errorHandler:errorBlock];
}


#pragma mark - register user

- (void) registerUserWithData: (NSDictionary*) userData
            completionHandler: (MKNKUserSuccessBlock) completionBlock
                 errorHandler: (MKNKUserErrorBlock) errorBlock
{
    [self.appDelegate.oAuthNetworkEngine registerUserWithData:userData completionHandler: ^(SYNOAuth2Credential* credential) {
        
        // Case where the user registers
        [self.appDelegate.oAuthNetworkEngine retrieveAndRegisterUserFromCredentials: credential
                                                          completionHandler: ^(NSDictionary* dictionary) {
                                                              [self checkAndSaveRegisteredUser: credential];
                                                              completionBlock(dictionary);
                                                          }
                                                               errorHandler: errorBlock];
    } errorHandler: errorBlock];
}


#pragma mark - upload Avatar

- (void) uploadAvatarImage: (UIImage *) image
         completionHandler: (MKNKUserSuccessBlock) completionBlock
              errorHandler: (MKNKUserErrorBlock) errorBlock
{
    [self.appDelegate.oAuthNetworkEngine updateAvatarForUserId: self.appDelegate.currentOAuth2Credentials.userId
                                                         image: image
                                             completionHandler: completionBlock
                                                  errorHandler: errorBlock];
}


#pragma mark - login facebook

-(void) loginThroughFacebookWithCompletionHandler:(MKNKJSONCompleteBlock) completionBlock
                                     errorHandler: (MKNKUserErrorBlock) errorBlock
{
    SYNFacebookManager* facebookManager = [SYNFacebookManager sharedFBManager];
    
    [facebookManager loginOnSuccess: ^(NSDictionary<FBGraphUser> *dictionary) {
        
        FBAccessTokenData* accessTokenData = [[FBSession activeSession] accessTokenData];
        
        // Log our user's age in Google Analytics
        NSString *birthday = dictionary[@"birthday"];
        
        if (birthday)
        {
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat: @"MM/dd/yyyy"];
            NSDate* birthdayDate = [dateFormatter dateFromString: birthday];
            
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
        }
        
        [self doFacebookLoginAnimation];
        
        [_appDelegate.oAuthNetworkEngine doFacebookLoginWithAccessToken: accessTokenData.accessToken
                                                          completionHandler: ^(SYNOAuth2Credential* credential) {
            [_appDelegate.oAuthNetworkEngine retrieveAndRegisterUserFromCredentials: credential
                                                              completionHandler: ^(NSDictionary* dictionary) {
                                                                  
                if([self checkAndSaveRegisteredUser: credential])
                {
                    _appDelegate.currentUser.loginOriginValue = LoginOriginFacebook;
                }
                else
                {
                    DebugLog(@"ERROR: User not registered (User: %@)", _appDelegate.currentUser);
                    // TODO: handle user not being registered propery
                }
                    
                completionBlock(dictionary);
                                                                  
                                                                  
            } errorHandler:errorBlock];
        } errorHandler: errorBlock];
    }
    onFailure: ^(NSString* errorString)
     {
         errorBlock(errorString);
     }];
}


#pragma mark - Reachability change

- (void) reachabilityChanged: (NSNotification*) notification
{
    #ifdef PRINT_REACHABILITY
    NSString* reachabilityString;
    if ([self.reachability currentReachabilityStatus] == ReachableViaWiFi)
        reachabilityString = @"WiFi";
    else if([self.reachability currentReachabilityStatus] == ReachableViaWWAN)
        reachabilityString = @"WWAN";
    else if([self.reachability currentReachabilityStatus] == NotReachable)
        reachabilityString = @"None";
    
    //    DebugLog(@"Reachability == %@", reachabilityString);
#endif
    
    if ([self.reachability currentReachabilityStatus] == ReachableViaWiFi)
    {
        if (self.networkErrorView)
        {
            [self hideNetworkErrorView];
        }
    }
    else if([self.reachability currentReachabilityStatus] == ReachableViaWWAN)
    {
        if (self.networkErrorView)
        {
            [self hideNetworkErrorView];
        }
    }
    else if ([self.reachability currentReachabilityStatus] == NotReachable)
    {
        NSString* message = [SYNDeviceManager.sharedInstance isIPad] ? NSLocalizedString(@"No_Network_iPad", nil)
        : NSLocalizedString(@"No_Network_iPhone", nil);
        [self presentNetworkErrorViewWithMesssage: message];
    }
}

-(void)checkReachability
{
    if (!self.reachability)
    {
        self.reachability = [Reachability reachabilityWithHostname: _appDelegate.networkEngine.hostName];
    }
    [self reachabilityChanged:nil];
}

- (void) presentNetworkErrorViewWithMesssage: (NSString*) message
{
    if(self.networkErrorView)
    {
        [self.networkErrorView setText:message];
        return;
    }
    
    self.networkErrorView = [SYNNetworkErrorView errorView];
    [self.networkErrorView setCenterVerticalOffset:18.0f];
    self.networkErrorView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BarNetworkLogin"]];
    self.networkErrorView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin| UIViewAutoresizingFlexibleWidth;
    [self.networkErrorView setText:message];
    
    CGRect errorViewFrame = self.networkErrorView.frame;
    errorViewFrame.origin.y = -(self.networkErrorView.height);
    self.networkErrorView.frame = errorViewFrame;
    
    [self.view addSubview:self.networkErrorView];
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect endFrame = self.networkErrorView.frame;
        endFrame.origin.y = 0.0f;
        self.networkErrorView.frame = endFrame;
    }];
}

-(void)hideNetworkErrorView
{
    [UIView animateWithDuration:0.3
                          delay:0.1 options:UIViewAnimationCurveEaseInOut
                     animations:^{
        CGRect errorViewFrame = self.networkErrorView.frame;
        errorViewFrame.origin.y = -(self.networkErrorView.height);
        self.networkErrorView.frame = errorViewFrame;
    } completion:^(BOOL finished) {
        if(finished)
        {
            [self.networkErrorView removeFromSuperview];
            self.networkErrorView = nil;
        }
    }];
}

#pragma mark - check network before sending request
-(BOOL)isNetworkAccessibleOtherwiseShowErrorAlert
{
    BOOL isReachable = ![self.reachability currentReachabilityStatus] == NotReachable;
    if(! isReachable)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"login_screen_form_no_connection_dialog_title",nil) message:NSLocalizedString(@"login_screen_form_no_connection_dialog_message",nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
        [alert show];
    }
    return isReachable;
}

-(void)doFacebookLoginAnimation
{
    // to be implemented by subclass
}


#pragma mark - form validation

-(BOOL) registrationFormPartOneIsValidForUserName:(UITextField*)userNameInputField
{
    
    if (userNameInputField.text.length < 1)
    {
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_field_username_error_empty", nil)
                   nextToView: userNameInputField];
        
        [userNameInputField becomeFirstResponder];
        
        return NO;
    }
    
    return YES;
}

- (BOOL) registrationFormIsValidForEmail:(UITextField*)emailInputField userName:(UITextField*)userNameInputField password:(UITextField*)passwordInputField dd:(UITextField*)ddInputField mm:(UITextField*)mmInputField yyyy:(UITextField*)yyyyInputField
{
    if (emailInputField.text.length < 1)
    {
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_field_email_error_empty",nil)
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
    
    if (userNameInputField.text.length < 1)
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
    
    if (passwordInputField.text.length < 1)
    {
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_field_password_error_empty", nil)
                   nextToView: passwordInputField];
        
        [passwordInputField becomeFirstResponder];
        
        return NO;
    }
    
    return [self dateValidForDd:ddInputField mm:mmInputField yyyy:yyyyInputField];
}


-(BOOL)dateValidForDd:(UITextField*)ddInputField mm:(UITextField*)mmInputField yyyy:(UITextField*)yyyyInputField
{
    // == Check for date == //
    
    NSArray* dobTextFields = @[mmInputField, ddInputField, yyyyInputField];
    
    
    // == Check wether the DOB fields contain numbers == //
    
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    
    for (UITextField* dobField in dobTextFields)
    {
        if(dobField.text.length == 0)
        {
            [self placeErrorLabel: NSLocalizedString(@"register_screen_form_error_invalid_date", nil)
                       nextToView: yyyyInputField];
            
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
                       nextToView: yyyyInputField];
            
            [dobField becomeFirstResponder];
            
            return NO;
        }
    }
    if(yyyyInputField.text.length < 4)
    {
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_error_invalid_date", nil)
                   nextToView: yyyyInputField];
        return NO;
    }
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    NSDate* potentialDate = [dateFormatter dateFromString: [NSString stringWithFormat:@"%@-%@-%@", yyyyInputField.text, [self zeroPadIfOneCharacter:mmInputField.text], [self zeroPadIfOneCharacter:ddInputField.text]]];
    
    // == Not a real date == //
    
    if (!potentialDate)
    {
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_error_invalid_date", nil)
                   nextToView: yyyyInputField];
        
        return NO;
    }
    
    NSDate* nowDate = [NSDate date];
    
    // == In the future == //
    
    if ([nowDate compare:potentialDate] == NSOrderedAscending) {
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_error_future", nil)
                   nextToView: yyyyInputField];
        
        return NO;
    }
    
    // == Yonger than 13 == //
    
    NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* nowDateComponents = [gregorian components:(NSYearCalendarUnit) fromDate:nowDate];
    nowDateComponents.year -= 13;
    
    NSDate* tooYoungDate = [gregorian dateFromComponents:nowDateComponents];
    
    if ([tooYoungDate compare:potentialDate] == NSOrderedAscending) {
        
        [self placeErrorLabel: NSLocalizedString(@"register_screen_form_error_under_13", nil)
                   nextToView: yyyyInputField];
        
        return NO;
    }
    
    return YES;
}

- (BOOL) loginFormIsValidForUsername:(UITextField*)userNameInputField password:(UITextField*)passwordInputField
{
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

- (BOOL) resetPasswordFormIsValidForUsername:(UITextField*)userNameInputField
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

- (void) placeErrorLabel: (NSString*) errorText
              nextToView: (UIView*) view
{
    //Override in subclass
}

-(NSString*)zeroPadIfOneCharacter:(NSString*)inputString
{
    if([inputString length]==1)
    {
        return [NSString stringWithFormat:@"0%@",inputString];
    }
    
    return inputString;
}


@end
