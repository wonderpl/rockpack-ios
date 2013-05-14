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

@end
