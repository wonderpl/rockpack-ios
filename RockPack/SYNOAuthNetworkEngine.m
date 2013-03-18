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

- (void) doFacebookLoginWithAccessToken: (NSString*) facebookAccessToken
                           withComplete: (MKNKLoginCompleteBlock) completionBlock
                               andError: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary* postLoginParams = @{@"external_system" : @"facebook",
                                      @"external_token" : facebookAccessToken};
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*) [self operationWithURLString: kAPISecureExternalLogin
                                                                                                             params: postLoginParams
                                                                                                         httpMethod: @"POST"];
    
    [networkOperation setUsername: kOAuth2ClientId
                         password: @""
                        basicAuth: YES];
    
    [networkOperation addJSONCompletionHandler: ^(NSDictionary *responseDictionary)
    {
        NSString* possibleError = responseDictionary[@"error"];
        
        if(possibleError)
        {
            errorBlock(responseDictionary);
            return;
        }
        
        self.oAuth2Credential = [SYNOAuth2Credential credentialWithAccessToken: responseDictionary[@"access_token"]
                                                                     expiresIn: responseDictionary[@"expires_in"]
                                                                  refreshToken: responseDictionary[@"refresh_token"]
                                                                   resourceURL: responseDictionary[@"resource_url"]
                                                                     tokenType: responseDictionary[@"token_type"]
                                                                        userId: responseDictionary[@"user_id"]];
        
        if (self.oAuth2Credential == nil)
        {
            DebugLog(@"Invalid credential returned");
            errorBlock(@{@"parsing_error": @"credentialWithAccessToken: did not complete correctly"});
            return;
        }
        
        // We were successful, so save the credentials to the keychain
        [self.oAuth2Credential saveToKeychainForService: kOAuth2ClientId
                                                account: kOAuth2ClientId];
        
//        AccessInfo* recentlyFetchedAccessInfo = self.userInfoRegistry.lastReceivedAccessInfoObject;
        
        completionBlock(self.oAuth2Credential);
        
    }
    errorHandler: ^(NSError* error)
    {
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
		AssertOrLog(@"enqueueSignedOperation - Not authenticated");
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


- (void) createChannelWithData: (NSDictionary*) userData
                    withComplete: (MKNKVoidBlock) completionBlock
                        andError: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : self.oAuth2Credential.userId};
    
    NSString *apiString = [kAPICreateNewChannel stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: userData
                                                                                                   httpMethod: @"POST"
                                                                                                          ssl: TRUE];
    
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

// /ws/USERID/channels/CHANNELID/  /* PUT */
- (void) updateChannelWithChannelId: (NSString *) channelId
                               data: (NSDictionary*) userData
                       withComplete: (MKNKVoidBlock) completionBlock
                           andError: (MKNKUserErrorBlock) errorBlock
{
//    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId,
//                                                @"CHANNELID" : channelId};
//
//    SYNNetworkOperationJsonObject *networkOperation =
//    (SYNNetworkOperationJsonObject*)[self operationWithPath: [kAPIUpdateExistingChannel stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary]
//                                                          params: userData
//                                                      httpMethod: @"PUT"];
//
//    [networkOperation setUsername: kOAuth2ClientId
//                         password: @""
//                        basicAuth: YES];
//
//    [networkOperation addHeaders: @{@"Content-Type": @"application/json"}];
//    networkOperation.postDataEncoding = MKNKPostDataEncodingTypeJSON;
//
//
//    [networkOperation addJSONCompletionHandler: ^(NSDictionary *dictionary)
//     {
//         NSString* possibleError = [dictionary objectForKey: @"error"];
//
//         if(possibleError)
//         {
//             errorBlock(dictionary);
//             return;
//         }
//
//         completionBlock();
//     }
//                                  errorHandler: ^(NSError* error)
//     {
//         NSDictionary* customErrorDictionary = @{@"network_error": [NSString stringWithFormat: @"%@, Server responded with %i", error.domain, error.code]};
//         errorBlock(customErrorDictionary);
//     }];
//
//    [self enqueueOperation: networkOperation];
//
}
//
// /ws/USERID/channels/CHANNELID/videos/    /* PUT */


- (void) updateVideosForChannelWithChannelId: (NSString *) channelId
                             videoIdArray: (NSArray *) videoIdArray
                             withComplete: (MKNKVoidBlock) completionBlock
                                 andError: (MKNKUserErrorBlock) errorBlock
{
//
//    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId,
//                                                @"CHANNELID" : channelId};
//
//    SYNNetworkOperationJsonObject *networkOperation =
//    (SYNNetworkOperationJsonObject*)[self operationWithPath: [kAPIUpdateVideosForChannel stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary]
//                                                          params: nil
//                                                      httpMethod: @"PUT"];
//
//    [networkOperation setUsername: kOAuth2ClientId
//                         password: @""
//                        basicAuth: YES];
//
//    [networkOperation addHeaders: @{@"Content-Type": @"application/json"}];
//    networkOperation.postDataEncoding = MKNKPostDataEncodingTypeJSON;
//
//
//    [networkOperation addJSONCompletionHandler: ^(NSDictionary *dictionary)
//     {
//         NSString* possibleError = [dictionary objectForKey: @"error"];
//
//         if (possibleError)
//         {
//             errorBlock(dictionary);
//             return;
//         }
//
//         completionBlock();
//     }
//     errorHandler: ^(NSError* error)
//     {
//         NSDictionary* customErrorDictionary = @{@"network_error": [NSString stringWithFormat: @"%@, Server responded with %i", error.domain, error.code]};
//         errorBlock(customErrorDictionary);
//     }];
//
//    [self enqueueOperation: networkOperation];
//
}

@end
