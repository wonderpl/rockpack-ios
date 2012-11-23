//
//  SYNOAuthNetworkEngine.m
//  oauth2demo-iOS
//
//  Created by Nick Banks on 21/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNOAuthNetworkEngine.h"
#import "SYNOAuth2Credential.h"


// OAuth username and password
#define kOAuth2ClientId @"a637c4294064e8003139412d4a1acf"
#define kOAuth2ClientSecret @"7d6a1956c0207ed9d0bbc22ddf9d95"

// Hostname
#define kHostName @"rockpack-oauth2-demo.herokuapp.com"


@interface SYNOAuthNetworkEngine ()

// OAuth2 and refresh tokens
@property (nonatomic, strong) SYNOAuth2Credential *oAuth2Credential;

// Used for authentication callback
@property (nonatomic, copy) SYNOAuth2CompletionBlock oAuthCompletionBlock;

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
		NSLog(@"enqueueSignedOperation - Not authenticated");
		[self authenticateWithCompletionBlock: ^(NSError *error)
        {
			if (error)
            {
				// Auth failed, so call the MKNetworkOperation object's error blocks (if any) with our own custom NSError
				NSLog(@"Auth error: %@", error);
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

@end
