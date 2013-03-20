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
#import "VideoInstance.h"

@interface SYNOAuthNetworkEngine ()

// OAuth2 and refresh tokens
@property (nonatomic, strong) SYNOAuth2Credential *oAuth2Credential;

// Used for authentication callbacks
@property (nonatomic, copy) SYNOAuth2CompletionBlock oAuthCompletionBlock;
@property (nonatomic, copy) SYNOAuth2RefreshCompletionBlock oAuthRefreshCompletionBlock;

@property (nonatomic, weak) SYNAppDelegate* appDelegate;

@end

@implementation SYNOAuthNetworkEngine

#pragma mark - OAuth2 Housekeeping functions

-(id)initWithDefaultSettings
{
    self = [super initWithDefaultSettings];
    
    self.appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    return self;
}



- (NSString *) hostName
{
    return kAPISecureHostName;
}



// Enqueues the operation if already authenticated, and if not, tries to authentican and then re-queue if successful
- (void) enqueueSignedOperation: (MKNetworkOperation *) request
{
	// If we're not authenticated, and this is not part of the OAuth process,
	if (!self.oAuth2Credential)
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
         
         SYNOAuth2Credential* newOAuth2Credentials = [SYNOAuth2Credential credentialWithAccessToken: responseDictionary[@"access_token"]
                                                                                          expiresIn: responseDictionary[@"expires_in"]
                                                                                       refreshToken: responseDictionary[@"refresh_token"]
                                                                                        resourceURL: responseDictionary[@"resource_url"]
                                                                                          tokenType: responseDictionary[@"token_type"]
                                                                                             userId: responseDictionary[@"user_id"]];
         
         if (newOAuth2Credentials == nil)
         {
             DebugLog(@"Invalid credential returned");
             errorBlock(@{@"parsing_error": @"credentialWithAccessToken: did not complete correctly"});
             return;
         }
         
         
         completionBlock(newOAuth2Credentials);
         
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


- (void) userInformationFromCredentials: (SYNOAuth2Credential *) credentials
                      completionHandler: (MKNKUserSuccessBlock) completionBlock
                           errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : credentials.userId};
    
    NSString *apiString = [kAPIGetUserDetails stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: nil
                                                                                                   httpMethod: @"GET"
                                                                                                          ssl: TRUE];    
    [self addCommonOAuthPropertiesToSignedNetworkOperation: networkOperation
                                         completionHandler: completionBlock
                                              errorHandler: errorBlock];
    
    [networkOperation addJSONCompletionHandler:^(NSDictionary *responseDictionary) {
        
        
        NSString* possibleError = responseDictionary[@"error"];
         
        if (possibleError)
        {
            errorBlock(responseDictionary);
            return;
        }
        
        // Register User
        
        [self.registry registerUserFromDictionary:responseDictionary];
        
        
        completionBlock(responseDictionary);
         
     } errorHandler: ^(NSError* error) {
         
         DebugLog(@"API Call failed");
         NSDictionary* customErrorDictionary = @{@"network_error" : [NSString stringWithFormat: @"%@, Server responded with %i", error.domain, error.code]};
         errorBlock(customErrorDictionary);
         
         
     }];
    
    [networkOperation setUsername: kOAuth2ClientId
                         password: kOAuth2ClientSecret];
    
    [networkOperation setAuthorizationHeaderValue: credentials.accessToken
                                      forAuthType: @"Bearer"];
    
    [self enqueueOperation: networkOperation];
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


#pragma mark - Channel management

- (void) channelDataForUserId: (NSString *) userId
                    channelId: (NSString *) channelId
                        start: (unsigned int) start
                         size: (unsigned int) size
            completionHandler: (MKNKUserSuccessBlock) completionBlock
                 errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId,
                                                @"CHANNELID" : channelId};
    
    // If size is 0, then don't include start and size in the call (i.e. just use default params), otherwise assume both params are valid
    NSDictionary *params = nil;
    if (size > 0)
    {
        params = @{@"start" : @(start), @"size" : @(size)};
    }
    
    NSString *apiString = [kAPIGetChannelDetails stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: params
                                                                                                   httpMethod: @"GET"
                                                                                                          ssl: TRUE];
    [self addCommonOAuthPropertiesToSignedNetworkOperation: networkOperation
                                         completionHandler: completionBlock
                                              errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}


// Wrapper functions for common
- (void) createChannelForUserId: (NSString *) userId
                          title: (NSString *) title
                    description: (NSString *) description
                       category: (NSString *) category
                          cover: (NSString *) cover
                       isPublic: (BOOL) isPublic
              completionHandler: (MKNKUserSuccessBlock) completionBlock
                   errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    NSString *apiString = [kAPICreateNewChannel stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    [self manageChannelForUserId: userId
                           title: title
                     description: description
                        category: category
                           cover: cover
                        isPublic: isPublic
                       apiString: apiString
                        httpVerb: @"POST"
               completionHandler: completionBlock
                    errorHandler: errorBlock];
}

- (void) updateChannelForUserId: (NSString *) userId
                      channelId: (NSString *) channelId
                          title: (NSString *) title
                    description: (NSString *) description
                       category: (NSString *) category
                          cover: (NSString *) cover
                       isPublic: (BOOL) isPublic
              completionHandler: (MKNKUserSuccessBlock) completionBlock
                   errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId,
                                                @"CHANNELID" : channelId};
    
    NSString *apiString = [kAPIUpdateExistingChannel stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    [self manageChannelForUserId: userId
                           title: title
                     description: description
                        category: category
                           cover: cover
                        isPublic: isPublic
                        apiString: apiString
                        httpVerb: @"PUT"
               completionHandler: completionBlock
                    errorHandler: errorBlock];
}

- (void) manageChannelForUserId: (NSString *) userId
                          title: (NSString *) title
                    description: (NSString *) description
                       category: (NSString *) category
                          cover: (NSString *) cover
                       isPublic: (BOOL) isPublic
                       apiString: apiString
                       httpVerb: (NSString *) httpVerb
              completionHandler: (MKNKUserSuccessBlock) completionBlock
                   errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *params = @{@"title" : title,
                             @"description" : description,
                             @"category" : category,
                             @"cover" : cover,
                             @"public" : @(isPublic)};

    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: params
                                                                                                   httpMethod: @"POST"
                                                                                                          ssl: TRUE];
   [networkOperation addHeaders: @{@"Content-Type" : @"application/json"}];
    networkOperation.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
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

- (void) updateVideosForChannelForUserId: (NSString *) userId
                               channelId: (NSString *) channelId
                            videoInstanceSet: (NSOrderedSet *) videoInstanceSet
                       completionHandler: (MKNKUserSuccessBlock) completionBlock
                            errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId,
                                                @"CHANNELID" : channelId};
    
    NSString *apiString = [kAPIUpdateVideosForChannel stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: nil
                                                                                                   httpMethod: @"PUT"
                                                                                                          ssl: TRUE];
    [networkOperation setCustomPostDataEncodingHandler: ^NSString * (NSDictionary *postDataDict)
     {
         NSError *error = nil;
         NSMutableArray *videoIdArray = [[NSMutableArray alloc] initWithCapacity: videoInstanceSet.count];
         
         for (VideoInstance *videoInstance in videoInstanceSet)
         {
             [videoIdArray addObject: videoInstance.uniqueId];
         }
         
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


-(SYNOAuth2Credential*)oAuth2Credential
{
    return self.appDelegate.currentOAuth2Credentials;
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
