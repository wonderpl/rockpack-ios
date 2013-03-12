//
//  SYNOAuthNetworkEngine.m
//  oauth2demo-iOS
//
//  Created by Nick Banks on 21/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"

#import "SYNOAuthNetworkEngine.h"
#import "SYNOAuth2Credential.h"




// Hostname
#define kHostName @"rockpack-oauth2-demo.herokuapp.com"


@interface SYNOAuthNetworkEngine ()

// OAuth2 and refresh tokens
@property (nonatomic, strong) SYNOAuth2Credential *oAuth2Credential;

// Used for authentication callbacks
@property (nonatomic, copy) SYNOAuth2CompletionBlock oAuthCompletionBlock;
@property (nonatomic, copy) SYNOAuth2RefreshCompletionBlock oAuthRefreshCompletionBlock;

@end

@implementation SYNOAuthNetworkEngine

- (BOOL) isAuthenticated
{
    if (self.oAuth2Credential == nil)
    {
        self.oAuth2Credential = [SYNOAuth2Credential credentialFromKeychainForService: kOAuth2ClientId
                                                                              account: kOAuth2ClientId];
    }
    
    // Check to see if wa have a credential and an access token
	return (self.oAuth2Credential.accessToken != nil);
}


// Enqueues the operation if already authenticated, and if not, tries to authentican and then re-queue if successful
- (void) enqueueSignedOperation: (MKNetworkOperation *) request
{
	// If we're not authenticated, and this is not part of the OAuth process,
	if (!self.isAuthenticated)
    {
		DebugLog(@"enqueueSignedOperation - Not authenticated");
		[self authenticateWithCompletionBlock: ^(NSError *error)
        {
			if (error)
            {
				// Auth failed, so call the MKNetworkOperation object's error blocks (if any) with our own custom NSError
				DebugLog(@"Auth error: %@", error);
                [request operationFailedWithError: [NSError errorWithDomain: NSURLErrorDomain
                                                                       code: NSURLErrorUserAuthenticationRequired
                                                                   userInfo: nil]];
			}
			else
            {
				// Auth succeeded, call this method again recursively
				[self enqueueSignedOperation: request];
			}
		}];
	}
	else
    {
		DLog(@"enqueueSignedOperation - Authenticated");
        
        [request setUsername: kOAuth2ClientId
                    password: kOAuth2ClientSecret];
        
        [request setAuthorizationHeaderValue: self.oAuth2Credential.accessToken
                                 forAuthType: @"Bearer"];
        
		[self enqueueOperation: request];
	}
}


- (void) authenticateWithCompletionBlock: (SYNOAuth2CompletionBlock) completionBlock
{
	// Store the Completion Block to call after authentication
	self.oAuthCompletionBlock = completionBlock;
    
    NSDictionary *headerFields = @{@"grant_type" : @"password",
                                   @"client_id" : kOAuth2ClientId,
                                   @"username" : @"ios",
                                   @"password" : @"password"};
    
    MKNetworkOperation *op = [self operationWithPath: @"oauth2/token"
                                              params: headerFields
                                          httpMethod: @"GET"];
    
    // Set Basic Authentication username and password
    [op setUsername: kOAuth2ClientId
           password: kOAuth2ClientSecret
          basicAuth: YES];
    
    [op addCompletionHandler: ^(MKNetworkOperation *completedOperation)
     {
         NSDictionary *response = [completedOperation responseJSON];
         
         self.oAuth2Credential = [SYNOAuth2Credential credentialWithAccessToken: response[@"access_token"]
                                                                   refreshToken: response[@"refresh_token"]
                                                                      tokenType: response[@"token_type"]
                                                                      expiresIn: response[@"expires_in"]];
         // We were successful, so save the credentials to the keychain
         [self.oAuth2Credential saveToKeychainForService: kOAuth2ClientId
                                                 account: kOAuth2ClientId];
         
         // Then, call our completion block (indicating that there were no errors)
         self.oAuthCompletionBlock(nil);
     }
     errorHandler: ^(MKNetworkOperation* completedOperation, NSError* error)
     {
         // Something went wrong, so return the error to the completion block
         self.oAuthCompletionBlock(error);
     }];
    
    // Queue the authentication operation
    [self enqueueOperation: op];
}


- (void) refreshAuthenticationWithCompletionBlock: (SYNOAuth2RefreshCompletionBlock) completionBlock
{
	// Store the Completion Block to call after authentication
	self.oAuthRefreshCompletionBlock = completionBlock;
    
    NSDictionary *headerFields = @{@"grant_type" : @"refresh_token",
                                   @"client_id" : kOAuth2ClientId,
                                   @"client_password" : kOAuth2ClientSecret,
                                   @"refresh_token" : self.oAuth2Credential.refreshToken};
    
    MKNetworkOperation *op = [self operationWithPath: @"oauth2/token"
                                              params: headerFields
                                          httpMethod: @"GET"];
    
    // Set Basic Authentication username and password
    [op setUsername: kOAuth2ClientId
           password: kOAuth2ClientSecret
          basicAuth: YES];
    
    [op addCompletionHandler: ^(MKNetworkOperation *completedOperation)
     {
         NSDictionary *response = [completedOperation responseJSON];
         
         // Create a new credential from the returned data
         self.oAuth2Credential = [SYNOAuth2Credential credentialWithAccessToken: response[@"access_token"]
                                                                   refreshToken: response[@"refresh_token"]
                                                                      tokenType: response[@"token_type"]
                                                                      expiresIn: response[@"expires_in"]];
         
         // Save the updated credentials to the keychain
         [self.oAuth2Credential saveToKeychainForService: kOAuth2ClientId
                                                 account: kOAuth2ClientId];
         
         // Then, call our completion block (indicating that there were no errors)
         self.oAuthCompletionBlock(nil);
     }
                errorHandler: ^(MKNetworkOperation* completedOperation, NSError* error)
     {
         // Something went wrong, so return the error to the completion block
         self.oAuthCompletionBlock(error);
     }];
    
    // Queue the authentication operation
    [self enqueueOperation: op];
}

@end
