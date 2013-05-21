//
//  SYNLoginBaseViewController.m
//  rockpack
//
//  Created by Mats Trovik on 14/05/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNLoginBaseViewController.h"
#import "User.h"
#import "SYNActivityManager.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNFacebookManager.h"
#import "SYNAppDelegate.h"
#import "SYNNetworkEngine.h"
#import "SYNDeviceManager.h"
#import <FacebookSDK/FacebookSDK.h>

@interface SYNLoginBaseViewController ()

@end

@implementation SYNLoginBaseViewController

-(id)init
{
    self = [super init];
    if(self)
    {
        [self commonInit];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self commonInit];
    }
    return self;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        [self commonInit];
    }
    return self;
}

-(void)commonInit
{
    _appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    self.reachability = [Reachability reachabilityWithHostname:_appDelegate.networkEngine.hostName];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self performSelector:@selector(reachabilityChanged:) withObject:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void) setUpInitialState;
{
    
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

-(void) loginForUsername: (NSString*) username
             forPassword: (NSString*) password
       completionHandler: (MKNKUserSuccessBlock) completionBlock
            errorHandler: (MKNKUserErrorBlock) errorBlock
{
    [self.appDelegate.oAuthNetworkEngine doSimpleLoginForUsername: username forPassword: password completionHandler: ^(SYNOAuth2Credential* credential) {
        
        
        // Case where the user is a member of Rockpack but has not signing in this device
        
        [self.appDelegate.oAuthNetworkEngine userInformationFromCredentials: credential completionHandler: ^(NSDictionary* dictionary) {
            
            
            // the dictionary contains a User dictionary //
            
            NSString* username = [dictionary objectForKey: @"username"];
            DebugLog(@"User Registerd: %@", username);
            
            // by this time the currentUser is set in the DB //
            
            [self checkAndSaveRegisteredUser: credential];
            completionBlock(dictionary);
            
            
        } errorHandler:errorBlock];
        
    } errorHandler:errorBlock];
    
}

#pragma mark - reset password

- (void) doRequestPasswordResetForUsername: (NSString*) username
                         completionHandler: (MKNKJSONCompleteBlock) completionBlock
                              errorHandler: (MKNKErrorBlock) errorBlock
{
    [self.appDelegate.oAuthNetworkEngine doRequestPasswordResetForUsername: username
                                                         completionHandler: completionBlock errorHandler:errorBlock];
}

#pragma mark - register user

- (void) registerUserWithData: (NSDictionary*) userData
            completionHandler: (MKNKUserSuccessBlock) completionBlock
                 errorHandler: (MKNKUserErrorBlock) errorBlock
{
    [self.appDelegate.oAuthNetworkEngine registerUserWithData:userData completionHandler: ^(SYNOAuth2Credential* credential) {
        
        // Case where the user registers
        [self.appDelegate.oAuthNetworkEngine userInformationFromCredentials: credential completionHandler: ^(NSDictionary* dictionary) {
            [self checkAndSaveRegisteredUser: credential];
            completionBlock(dictionary);
        } errorHandler:errorBlock];
    } errorHandler: errorBlock];
}

#pragma mark - upload Avatar

- (void) uploadAvatarImage: (UIImage *) image
          completionHandler: (MKNKUserSuccessBlock) completionBlock
               errorHandler: (MKNKUserErrorBlock) errorBlock
{
    [self.appDelegate.oAuthNetworkEngine updateAvatarForUserId: self.appDelegate.currentOAuth2Credentials.userId image:image completionHandler:completionBlock errorHandler:errorBlock];
}

#pragma mark - login facebook

-(void) loginThroughFacebookWithCompletionHandler:(MKNKJSONCompleteBlock) completionBlock
                                     errorHandler: (MKNKUserErrorBlock) errorBlock
{
    SYNFacebookManager* facebookManager = [SYNFacebookManager sharedFBManager];
    
    [facebookManager loginOnSuccess:^(NSDictionary<FBGraphUser> *dictionary) {
        
        FBAccessTokenData* accessTokenData = [[FBSession activeSession] accessTokenData];
        
        [self.appDelegate.oAuthNetworkEngine doFacebookLoginWithAccessToken:accessTokenData.accessToken completionHandler: ^(SYNOAuth2Credential* credential) {
            [self.appDelegate.oAuthNetworkEngine userInformationFromCredentials: credential completionHandler: ^(NSDictionary* dictionary) {
                [self checkAndSaveRegisteredUser:credential];
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
        NSString* message = [[SYNDeviceManager sharedInstance] isIPad] ? NSLocalizedString(@"NO NETWORK, PLEASE CHECK YOUR INTERNET CONNECTION.", nil)
        : NSLocalizedString(@"NO NETWORK", nil);
        [self presentNetworkErrorViewWithMesssage: message];
    }
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
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Internet connection",nil) message:NSLocalizedString(@"You need an Internet connection to log in, register or request your password.",nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
        [alert show];
    }
    return isReachable;
}

@end
