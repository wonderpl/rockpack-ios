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

#pragma mark - OAuth2 Housekeeping functions

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


#pragma mark - Sign-up & Sign-in (inc. Facebook)

// This code block is common to all of the signup/signin methods
- (void) addCommonOAuthPropertiesToUnsignedNetworkOperation: (SYNNetworkOperationJsonObject *) networkOperation
                                          completionHandler: (MKNKLoginCompleteBlock) completionBlock
                                               errorHandler: (MKNKUserErrorBlock) errorBlock
{
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
         
         completionBlock(self.oAuth2Credential);
         
     }
                                  errorHandler: ^(NSError* error)
     {
         DebugLog(@"Register Facebook Token with Server Failed");
         NSDictionary* customErrorDictionary = @{@"network_error": [NSString stringWithFormat: @"%@, Server responded with %i", error.domain, error.code]};
         errorBlock(customErrorDictionary);
     }];

}


// Get authentication token, by passing facebook access token to the API, and getting the authentication token in return
- (void) doFacebookLoginWithAccessToken: (NSString*) facebookAccessToken
                      completionHandler: (MKNKLoginCompleteBlock) completionBlock
                           errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary* postLoginParams = @{@"external_system" : @"facebook",
                                      @"external_token" : facebookAccessToken};
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*) [self operationWithPath: kAPISecureExternalLogin
                                                                                                        params: postLoginParams
                                                                                                    httpMethod: @"POST"
                                                                                                           ssl: TRUE];
    [self addCommonOAuthPropertiesToUnsignedNetworkOperation: networkOperation
                                           completionHandler: completionBlock
                                                errorHandler: errorBlock];
    
    [self enqueueOperation: networkOperation];
}


// Get authentication token by using exisiting username and password
- (void) doSimpleLoginForUsername: (NSString*) username
                      forPassword: (NSString*) password
                completionHandler: (MKNKLoginCompleteBlock) completionBlock
                     errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary* postLoginParams = @{@"grant_type" : @"password",
                                      @"username" : username,
                                      @"password" : password};
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*) [self operationWithPath: kAPISecureLogin
                                                                                                        params: postLoginParams
                                                                                                    httpMethod: @"POST"
                                                                                                           ssl: TRUE];
    [self addCommonOAuthPropertiesToUnsignedNetworkOperation: networkOperation
                                           completionHandler: completionBlock
                                                errorHandler: errorBlock];
    
    [self enqueueOperation: networkOperation];
}




// Get authentication token by registering details with server
- (void) registerUserWithData: (NSDictionary*) userData
            completionHandler: (MKNKLoginCompleteBlock) completionBlock
                 errorHandler: (MKNKUserErrorBlock) errorBlock
{
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: kAPISecureRegister
                                                                                                       params: userData
                                                                                                   httpMethod: @"POST"
                                                                                                          ssl: TRUE];
    [networkOperation addHeaders: @{@"Content-Type" : @"application/json"}];
    networkOperation.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    [self addCommonOAuthPropertiesToUnsignedNetworkOperation: networkOperation
                                           completionHandler: completionBlock
                                                errorHandler: errorBlock];
    
    [self enqueueOperation: networkOperation];
}

#pragma mark - Common functionality

// This code block is common to all of the signup/signin methods
- (void) addCommonOAuthPropertiesToSignedNetworkOperation: (SYNNetworkOperationJsonObject *) networkOperation
                                        completionHandler: (MKNKUserSuccessBlock) completionBlock
                                             errorHandler: (MKNKUserErrorBlock) errorBlock
{
    [networkOperation addJSONCompletionHandler: ^(NSDictionary *responseDictionary)
     {
         NSString* possibleError = responseDictionary[@"error"];
         
         if (possibleError)
         {
             errorBlock(responseDictionary);
             return;
         }
         
         completionBlock(responseDictionary);
         
     }
     errorHandler: ^(NSError* error)
     {
         DebugLog(@"API Call failed");
         NSDictionary* customErrorDictionary = @{@"network_error" : [NSString stringWithFormat: @"%@, Server responded with %i", error.domain, error.code]};
         errorBlock(customErrorDictionary);
     }];
    
}

#pragma mark - User management

- (void) userInformationForUserId: (NSString *) userId
                 completionHandler: (MKNKUserSuccessBlock) completionBlock
                      errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSString *apiString = [kAPIGetUserDetails stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: nil
                                                                                                   httpMethod: @"GET"
                                                                                                          ssl: TRUE];    
    [self addCommonOAuthPropertiesToSignedNetworkOperation: networkOperation
                                         completionHandler: completionBlock
                                              errorHandler: errorBlock];
    
    [networkOperation addJSONCompletionHandler: ^(NSDictionary *responseDictionary) {
        
        
        NSString* possibleError = responseDictionary[@"error"];
         
        if (possibleError)
        {
            errorBlock(responseDictionary);
            return;
        }
        
        // Register User
        
        [self.registry registerUserFromDictionary:responseDictionary];
        
        // Test if new User is in Core Data
        
        
        
        completionBlock(responseDictionary);
         
     } errorHandler: ^(NSError* error) {
         
         DebugLog(@"API Call failed");
         NSDictionary* customErrorDictionary = @{@"network_error" : [NSString stringWithFormat: @"%@, Server responded with %i", error.domain, error.code]};
         errorBlock(customErrorDictionary);
         
     }];
    
    [self enqueueSignedOperation: networkOperation];
}


- (void) changeUsernameForUserId: (NSString *) userId
                        password: (NSString *) password
                completionHandler: (MKNKUserSuccessBlock) completionBlock
                     errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSString *apiString = [kAPIChangeUserName stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: nil
                                                                                                   httpMethod: @"PUT"
                                                                                                          ssl: TRUE];
    [networkOperation setCustomPostDataEncodingHandler: ^NSString * (NSDictionary *postDataDict)
     {
         // Wrap it in quotes to make it valid JSON
         NSString *JSONFormattedPassword = [NSString stringWithFormat: @"\"%@\"", password];
         return JSONFormattedPassword;
     }
                                               forType: @"application/json"];
    [self addCommonOAuthPropertiesToSignedNetworkOperation: networkOperation
                                         completionHandler: completionBlock
                                              errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}


#pragma mark - Avatars

- (void) updateAvatarForUserId: (NSString *) userId
                         image: (UIImage *) image
             completionHandler: (MKNKUserSuccessBlock) completionBlock
                  errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSString *apiString = [kAPIUpdateAvatar stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: nil
                                                                                                   httpMethod: @"PUT"
                                                                                                          ssl: TRUE];
    // We have to perform the image upload with an input stream
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *lengthString = [NSString stringWithFormat: @"%@", [NSNumber numberWithUnsignedLong: imageData.length]];
    NSInputStream *inputStream = [NSInputStream inputStreamWithData: imageData];
    networkOperation.uploadStream = inputStream;
    
    [networkOperation addHeaders: @{@"Content-Type" : @"image/png", @"Content-Length" : lengthString}];

    [self addCommonOAuthPropertiesToSignedNetworkOperation: networkOperation
                                         completionHandler: completionBlock
                                              errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}


#pragma mark - Channel creation

- (void) createChannelWithData: (NSDictionary*) userData
             completionHandler: (MKNKUserSuccessBlock) completionBlock
                  errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : self.oAuth2Credential.userId};

    NSString *apiString = [kAPICreateNewChannel stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: userData
                                                                                                   httpMethod: @"POST"
                                                                                                          ssl: TRUE];
   [networkOperation addHeaders: @{@"Content-Type" : @"application/json"}];
    networkOperation.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    [self addCommonOAuthPropertiesToSignedNetworkOperation: networkOperation
                                         completionHandler: completionBlock
                                              errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}


// /ws/USERID/channels/CHANNELID/  /* PUT */

- (void) updateChannelWithChannelId: (NSString *) channelId
                               data: (NSDictionary*) userData
                  completionHandler: (MKNKUserSuccessBlock) completionBlock
                       errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : self.oAuth2Credential.userId,
                                                @"CHANNELID" : channelId};

    NSString *apiString = [kAPIUpdateExistingChannel stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: userData
                                                                                                   httpMethod: @"PUT"
                                                                                                          ssl: TRUE];
    
    [networkOperation addHeaders: @{@"Content-Type" : @"application/json"}];
    
    [self addCommonOAuthPropertiesToSignedNetworkOperation: networkOperation
                                         completionHandler: completionBlock
                                              errorHandler: errorBlock];

    [self enqueueSignedOperation: networkOperation];

}


// /ws/USERID/channels/CHANNELID/videos/    /* PUT */

//    [self updateVideosForChannelWithChannelId: @"abc"
//                                 videoIdArray: @[@"aaa", @"bbb", @"ccc"]
//                            completionHandler: nil
//                                 errorHandler: nil];

- (void) updateVideosForChannelWithChannelId: (NSString *) channelId
                                videoIdArray: (NSArray *) videoIdArray
                           completionHandler: (MKNKUserSuccessBlock) completionBlock
                                errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : self.oAuth2Credential.userId,
                                                @"CHANNELID" : channelId};
    
    NSString *apiString = [kAPIUpdateVideosForChannel stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: nil
                                                                                                   httpMethod: @"PUT"
                                                                                                          ssl: TRUE];
    [networkOperation setCustomPostDataEncodingHandler: ^NSString * (NSDictionary *postDataDict)
     {
         NSError *error = nil;
         
         NSData *jsonData = [NSJSONSerialization dataWithJSONObject: videoIdArray
                                                            options: 0
                                                              error: &error];
         
         NSString *jsonString = [[NSString alloc] initWithData: jsonData
                                                      encoding: NSUTF8StringEncoding];
         
         return jsonString;
     }
     forType: @"application/json"];
    
    [self addCommonOAuthPropertiesToSignedNetworkOperation: networkOperation
                                         completionHandler: completionBlock
                                              errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}

// Test code template

//[self userInformationForUserId: self.oAuth2Credential.userId
//             completionHandler: ^(NSDictionary* errorDictionary)
// {
//     DebugLog(@"User data %@", errorDictionary);
//     // If we successfuly created a channel, then upload the videos for that channel
//     //             [self uploadVideosForChannel];
// }
//                  errorHandler: ^(NSDictionary* errorDictionary)
// {
//     DebugLog(@"Channel creation failed");
//     NSDictionary* formErrors = errorDictionary[@"form_errors"];
//     
//     if (formErrors)
//     {
//         // TODO: Show errors in channel creation
//         //           [self showRegistrationError:formErrors];
//     }
// }];

@end
