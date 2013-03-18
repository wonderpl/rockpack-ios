//
//  SYNOAuthNetworkEngine.m
//  oauth2demo-iOS
//
//  Created by Nick Banks on 21/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "NSString+Utils.h"
#import "SYNAppDelegate.h"
#import "SYNNetworkOperationJsonObject.h"
#import "SYNOAuth2Credential.h"
#import "SYNOAuthNetworkEngine.h"

@interface SYNOAuthNetworkEngine ()

// OAuth2 and refresh tokens
@property (nonatomic, strong) SYNOAuth2Credential *oAuth2Credential;

// Used for authentication callbacks
@property (nonatomic, copy) SYNOAuth2CompletionBlock oAuthCompletionBlock;
@property (nonatomic, copy) SYNOAuth2RefreshCompletionBlock oAuthRefreshCompletionBlock;

@end

@implementation SYNOAuthNetworkEngine

- (NSString *) hostName
{
    return kAPISecureHostName;
}

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

-(void)doFacebookLoginWithAccessToken:(NSString*)facebookAccessToken
                         withComplete: (MKNKLoginCompleteBlock) completionBlock
                             andError: (MKNKUserErrorBlock) errorBlock {
    
    NSDictionary* postLoginParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"facebook", @"external_system",
                                     facebookAccessToken, @"external_token",
                                     nil];
    
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject*)[self operationWithURLString:kAPISecureExternalLogin params:postLoginParams httpMethod:@"POST"];
    
    [networkOperation setUsername:kOAuth2ClientId password:@"" basicAuth:YES];
    
    [networkOperation addJSONCompletionHandler:^(NSDictionary *dictionary) {
        
        NSString* possibleError = [dictionary objectForKey:@"error"];
        if(possibleError) {
            errorBlock(dictionary);
            return;
        }
        
        
        BOOL registryResultOk = [self.userInfoRegistry registerAccessInfoFromDictionary:dictionary];
        if (!registryResultOk) {
            DebugLog(@"Access Token Info Could Not Be Registered in CoreData");
            errorBlock(@{@"parsing_error": @"registerAccessInfoFromDictionary: did not complete correctly"});
            return;
        }
        
        AccessInfo* recentlyFetchedAccessInfo = self.userInfoRegistry.lastReceivedAccessInfoObject;
        
        completionBlock(recentlyFetchedAccessInfo);
        
    } errorHandler:^(NSError* error) {
        DebugLog(@"Register Facebook Token with Server Failed");
        NSDictionary* customErrorDictionary = @{@"network_error": [NSString stringWithFormat:@"%@, Server responded with %i", error.domain, error.code]};
        errorBlock(customErrorDictionary);
    }];
    
    [self enqueueOperation: networkOperation];
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


- (void) createChannelWithUserId: (NSString *) userId
                            data: (NSDictionary*) userData
                    withComplete: (MKNKVoidBlock) completionBlock
                        andError: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    NSString *apiString = [kAPICreateNewChannel stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithURLString: apiString
                                                                                                            params: userData
                                                                                                        httpMethod: @"POST"];
    
    [networkOperation addHeaders: @{@"Content-Type": @"application/json"}];
    networkOperation.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    
    [networkOperation addJSONCompletionHandler: ^(NSDictionary *dictionary)
     {
         NSString* possibleError = [dictionary objectForKey: @"error"];
         
         if(possibleError)
         {
             errorBlock(dictionary);
             return;
         }
         
         completionBlock();
     }
     errorHandler: ^(NSError* error)
     {
         NSDictionary* customErrorDictionary = @{@"network_error": [NSString stringWithFormat: @"%@, Server responded with %i", error.domain, error.code]};
         errorBlock(customErrorDictionary);
     }];
    
    [self enqueueSignedOperation: networkOperation];
    
}


@end
