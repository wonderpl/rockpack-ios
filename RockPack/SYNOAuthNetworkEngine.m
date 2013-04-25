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
#import "Video.h"
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
    
    // read host from plist
    
    hostName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SecureAPIHostName"];

    
    return self;
}


- (NSString *) hostName
{
    return hostName;
}


-(SYNOAuth2Credential*)oAuth2Credential
{
    return self.appDelegate.currentOAuth2Credentials;
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
//		DLog(@"enqueueSignedOperation - Authenticated");
        
        // We need to make a copy of the request first, so that we can re-submit on authentication error
//        [request addCommonHandlerToNetworkOperation: networkOperation
//                               completionHandler: completionBlock
//                                    errorHandler: errorBlock];
        
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
    // Add locale to every request
    NSDictionary* localeParam = @{@"locale" : self.localeString};
    [networkOperation addParams: localeParam];
    
    [networkOperation setUsername: kOAuth2ClientId
                         password: @""
                        basicAuth: YES];

    [networkOperation addJSONCompletionHandler: ^(id response)
     {
         if ([response isKindOfClass: [NSDictionary class]])
         {
             NSDictionary *responseDictionary = (NSDictionary *) response;
             
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
         else
         {
             // We were expecing a dictionary back, so call error block
             errorBlock(response);
         }
     }
      errorHandler: ^(NSError* error)
     {
         DebugLog(@"Server Failed");
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


- (IBAction) refreshOAuthTokenWithCompletionHandler: (MKNKUserErrorBlock) completionBlock
                                       errorHandler: (MKNKUserSuccessBlock) errorBlock
{
    NSDictionary *refreshParams = @{@"grant_type" : @"refresh_token",
                                    @"refresh_token" : self.oAuth2Credential.refreshToken};
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*) [self operationWithPath: kAPIRefreshToken
                                                                                                        params: refreshParams
                                                                                                    httpMethod: @"POST"
                                                                                                           ssl: TRUE];  
    // Set Basic Authentication username and password
    [networkOperation setUsername: kOAuth2ClientId
                         password: @""
                        basicAuth: YES];
    
    [networkOperation addHeaders: @{@"Content-Type" : @"application/x-www-form-urlencoded"}];
    
    
    [networkOperation addCompletionHandler: ^(MKNetworkOperation *completedOperation)
     {
         NSDictionary *responseDictionary = [completedOperation responseJSON];
         
         // Parse the new OAuth details, creating a new credential object
         SYNOAuth2Credential* newOAuth2Credentials = [SYNOAuth2Credential credentialWithAccessToken: responseDictionary[@"access_token"]
                                                                                          expiresIn: responseDictionary[@"expires_in"]
                                                                                       refreshToken: responseDictionary[@"refresh_token"]
                                                                                        resourceURL: responseDictionary[@"resource_url"]
                                                                                          tokenType: responseDictionary[@"token_type"]
                                                                                             userId: responseDictionary[@"user_id"]];
         
         // Save the new credential object in the keychain
         // The user passed back is assumed to be the current user
         [newOAuth2Credentials saveToKeychainForService: kOAuth2Service
                                                account: responseDictionary[@"user_id"]];
         
         completionBlock(responseDictionary);
     }
     errorHandler: ^(MKNetworkOperation* completedOperation, NSError* error)
     {
         NSDictionary *responseDictionary = [completedOperation responseJSON];
         errorBlock(responseDictionary);
         DebugLog (@"failed");
     }];
    
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


#pragma mark - User Data



- (void) userInformationFromCredentials: (SYNOAuth2Credential *) credentials
                      completionHandler: (MKNKUserSuccessBlock) completionBlock
                           errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : credentials.userId};
    
    NSString *apiString = [kAPIGetUserDetails stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: @{@"locale" : self.localeString}
                                                                                                   httpMethod: @"GET"
                                                                                                          ssl: TRUE];
    
    [networkOperation addJSONCompletionHandler:^(NSDictionary *responseDictionary)
    {
        NSString* possibleError = responseDictionary[@"error"];
         
        if (possibleError)
        {
            errorBlock(responseDictionary);
            return;
        }
        
        // Register User
        
        BOOL userRegistered = [self.registry registerUserFromDictionary:responseDictionary];
        if(!userRegistered)
            return;
        
        // Get subscriptions
        
        NSString* userId = [responseDictionary objectForKey:@"id"];
        
        [self channelSubscriptionsForUserId:userId
                                 credential:credentials
                                      start:0
                                       size:50
                          completionHandler:^(id subscriptionsDictionary) {
                              
                              
                              NSString* possibleError = responseDictionary[@"error"];
                              
                              if (possibleError)
                              {
                                  errorBlock(responseDictionary);
                                  return;
                              }
                              
                              BOOL userRegistered = [self.registry registerSubscriptionsForCurrentUserFromDictionary:subscriptionsDictionary];
                              if(!userRegistered)
                                  return;
                              
                              completionBlock(responseDictionary);
                              
        
                            } errorHandler:^(NSError* error) {
                                
                                DebugLog(@"API Call failed");
                                NSDictionary* customErrorDictionary = @{@"network_error" : [NSString stringWithFormat: @"%@, Server responded with %i", error.domain, error.code]};
                                errorBlock(customErrorDictionary);
        
                            }];
        
        
        
     }
     errorHandler: ^(NSError* error)
     {
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



- (void) changeUserField: (NSString*) userField
                 forUser: (User *) user
            withNewValue: (NSString*)newValue
       completionHandler: (MKNKBasicSuccessBlock) successBlock
            errorHandler: (MKNKUserErrorBlock) errorBlock {
    
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : user.uniqueId, @"ATTRIBUTE" : userField};
    
    NSString *apiString = [kAPIChangeUserFields stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: nil
                                                                                                   httpMethod: @"PUT"
                                                                                                          ssl: TRUE];
    [networkOperation setCustomPostDataEncodingHandler: ^NSString * (NSDictionary *postDataDict)
     {
         // Wrap it in quotes to make it valid JSON
         NSString *JSONFormattedPassword = [NSString stringWithFormat: @"\"%@\"", newValue];
         return JSONFormattedPassword;
     } forType: @"application/json"];
    
    [networkOperation addCompletionHandler:^(MKNetworkOperation* operation) {
        
        if(operation.HTTPStatusCode == 204) {
            
            successBlock();
            
        } else {
            
            errorBlock(@{@"http_error":[NSString stringWithFormat:@"%i", operation.HTTPStatusCode]});
            
        }
    
    
    } errorHandler:^(MKNetworkOperation* operation, NSError* error) {
        
        id responseJSON = [operation responseJSON];
        
        if(!responseJSON) {
            errorBlock(@{@"responce_error" : @"malformed response"});
            return;
        }
        
        errorBlock(responseJSON);
        
    }];
    
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

    [self addCommonHandlerToNetworkOperation: networkOperation
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
    NSDictionary *params = [self paramsAndLocaleForStart: start
                                                    size: size];
    
    NSString *apiString = [kAPIGetChannelDetails stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: params
                                                                                                   httpMethod: @"GET"
                                                                                                          ssl: TRUE];
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
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
                                                                                                   httpMethod: httpVerb
                                                                                                          ssl: TRUE];
    [networkOperation addHeaders: @{@"Content-Type" : @"application/json"}];
    networkOperation.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}


// Wrapper function for channel creation
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


// Wrapper function for channel update
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


- (void) updatePrivacyForChannelForUserId: (NSString *) userId
                                channelId: (NSString *) channelId
                                isPublic: (BOOL) isPublic
                        completionHandler: (MKNKUserSuccessBlock) completionBlock
                             errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId,
                                                @"CHANNELID" : channelId};
    
    NSString *apiString = [kAPIUpdateChannelPrivacy stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: nil
                                                                                                   httpMethod: @"PUT"
                                                                                                          ssl: TRUE];
    [networkOperation setCustomPostDataEncodingHandler: ^NSString * (NSDictionary *postDataDict)
     {
         // Wrap it in quotes to make it valid JSON
         NSString *privacyValueString = [NSString stringWithFormat: @"%@", isPublic ? @"true" : @"false"];
         return privacyValueString;
     }
     forType: @"application/json"];
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}


- (void) deleteChannelForUserId: (NSString *) userId
                      channelId: (NSString *) channelId
              completionHandler: (MKNKUserSuccessBlock) completionBlock
                   errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId,
                                                @"CHANNELID" : channelId};
    
    NSString *apiString = [kAPIDeleteChannel stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: nil
                                                                                                   httpMethod: @"DELETE"
                                                                                                          ssl: TRUE];
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}


- (void) videosForChannelForUserId: (NSString *) userId
                         channelId: (NSString *) channelId
                 completionHandler: (MKNKUserSuccessBlock) completionBlock
                      errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId,
                                                @"CHANNELID" : channelId};
    
    NSString *apiString = [kAPIUpdateVideosForChannel stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: nil
                                                                                                   httpMethod: @"GET"
                                                                                                          ssl: TRUE];
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}


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
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}


- (void) updateChannel: (NSString *) resourceURL
     completionHandler: (MKNKUserSuccessBlock) completionBlock
          errorHandler: (MKNKUserErrorBlock) errorBlock
{
    
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject*)[self operationWithURLString: resourceURL
                                                          params: nil];
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
    
}


// User activity

- (void) recordActivityForUserId: (NSString *) userId
                          action: (NSString *) action
                 videoInstanceId: (NSString *) videoInstanceId
               completionHandler: (MKNKUserSuccessBlock) completionBlock
                    errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSString *apiString = [kAPIRecordUserActivity stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    
    // We need to handle locale differently (so add the locale to the URL) as opposed to the other parameters which are in the POST body
    apiString = [NSString stringWithFormat: @"%@?locale=%@", apiString, self.localeString];
    
    NSDictionary *params = @{@"action" : action,
                             @"video_instance" : videoInstanceId};

    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: params
                                                                                                   httpMethod: @"POST"
                                                                                                          ssl: TRUE];
    [networkOperation addHeaders: @{@"Content-Type" : @"application/json"}];
    networkOperation.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}


- (void) activityForUserId: (NSString *) userId
         completionHandler: (MKNKUserSuccessBlock) completionBlock
              errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSString *apiString = [kAPIGetUserActivity stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: nil
                                                                                                   httpMethod: @"GET"
                                                                                                          ssl: TRUE];
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}

// Cover art

- (void) updateCoverArtForUserId: (NSString *) userId
                    onCompletion: (MKNKVoidBlock) completionBlock
                            onError: (MKNKErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSString *apiString = [kAPIGetUserCoverArt stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: [self getLocalParam]];
    
    
    [networkOperation addJSONCompletionHandler: ^(NSDictionary *dictionary)
     {
         BOOL registryResultOk = [self.registry registerCoverArtFromDictionary: dictionary
                                                                     forViewId: kUserCoverArtViewId];
         if (!registryResultOk)
             return;
         
         completionBlock();
     }
                                  errorHandler: ^(NSError* error) {
                                      DebugLog(@"API request failed");
                                  }];
    
    [self enqueueSignedOperation: networkOperation];
}

- (void) coverArtForUserId: (NSString *) userId
                     start: (unsigned int) start
                      size: (unsigned int) size
         completionHandler: (MKNKUserSuccessBlock) completionBlock
              errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSDictionary *params = [self paramsForStart: start
                                           size: size];
    
    NSString *apiString = [kAPIGetUserCoverArt stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: params
                                                                                                   httpMethod: @"GET"
                                                                                                          ssl: TRUE];
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}

- (void) uploadCoverArtForUserId: (NSString *) userId
                           image: (UIImage *) image
               completionHandler: (MKNKUserSuccessBlock) completionBlock
                    errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSString *apiString = [kAPIUploadUserCoverArt stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: nil
                                                                                                   httpMethod: @"POST"
                                                                                                          ssl: TRUE];
    // We have to perform the image upload with an input stream
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *lengthString = [NSString stringWithFormat: @"%@", [NSNumber numberWithUnsignedLong: imageData.length]];
    NSInputStream *inputStream = [NSInputStream inputStreamWithData: imageData];
    networkOperation.uploadStream = inputStream;
    
    [networkOperation addHeaders: @{@"Content-Type" : @"image/png", @"Content-Length" : lengthString}];
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}


- (void) deleteCoverArtForUserId: (NSString *) userId
                         coverId: (NSString *) coverId
               completionHandler: (MKNKUserSuccessBlock) completionBlock
                    errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId,
                                                @"COVERID" : coverId};
    
    NSString *apiString = [kAPIDeleteUserCoverArt stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: nil
                                                                                                   httpMethod: @"DELETE"
                                                                                                          ssl: TRUE];
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}


#pragma mark - Subscriptions

- (void) channelSubscriptionsForUserId: (NSString *) userId
                            credential: (SYNOAuth2Credential*)credential
                                 start: (unsigned int) start
                                  size: (unsigned int) size
                     completionHandler: (MKNKUserSuccessBlock) completionBlock
                          errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSDictionary *params = [self paramsForStart: start
                                           size: size];
    
    NSString *apiString = [kAPIGetUserSubscriptions stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: params
                                                                                                   httpMethod: @"GET"
                                                                                                          ssl: TRUE];
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [networkOperation setUsername: kOAuth2ClientId
                         password: kOAuth2ClientSecret];
    
    [networkOperation setAuthorizationHeaderValue: credential.accessToken
                                      forAuthType: @"Bearer"];
    
    [self enqueueOperation: networkOperation];
}

- (void) channelSubscribeForUserId: (NSString *) userId
                        channelURL: (NSString *) channelURL
                 completionHandler: (MKNKUserSuccessBlock) completionBlock
                      errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSString *apiString = [kAPICreateUserSubscription stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: nil
                                                                                                   httpMethod: @"POST"
                                                                                                          ssl: TRUE];
    
    
    [networkOperation setCustomPostDataEncodingHandler: ^NSString * (NSDictionary *postDataDict)
     {
         // Wrap it in quotes to make it valid JSON
         NSString *channelURLJSONString = [NSString stringWithFormat: @"\"%@\"", channelURL];
         return channelURLJSONString;
     }
     forType: @"application/json"];
    
    [networkOperation addHeaders: @{@"Content-Type" : @"application/json"}];
    networkOperation.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}

- (void) channelUnsubscribeForUserId: (NSString *) userId
                           channelId: (NSString *) channelId
                   completionHandler: (MKNKUserSuccessBlock) completionBlock
                        errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId,
                                                @"SUBSCRIPTION" : channelId};
    
    NSString *apiString = [kAPIDeleteUserSubscription stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: nil
                                                                                                   httpMethod: @"DELETE"];
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueSignedOperation: networkOperation];
}

// Subscription updates

// New way of getting updates to the user's subscriptions

- (void) subscriptionsUpdatesForUserId: (NSString *) userId
                                 start: (unsigned int) start
                                  size: (unsigned int) size
                     completionHandler: (MKNKUserSuccessBlock) completionBlock
                          errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : userId};
    
    NSString *apiString = [kAPIUserSubscriptionUpdates stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    NSDictionary *params = [self paramsAndLocaleForStart: start
                                                    size: size];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: params
                                                                                                   httpMethod: @"GET"];
    
    __weak SYNOAuthNetworkEngine *weakSelf = self;
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: ^(id response) {
                               
         if(!weakSelf) return;
         
         BOOL registryResultOk = [weakSelf.registry registerVideoInstancesFromDictionary: (NSDictionary *) response
                                                                               forViewId: @"Home"
                                                                             byAppending: NO];
         
         if (!registryResultOk)
         {
             NSError* error = [NSError errorWithDomain: @""
                                                  code: kJSONParseError
                                              userInfo: nil];
             errorBlock(error);
             return;
         }
         else
         {
             completionBlock(response);
         }
     }
     errorHandler: errorBlock];
    
    
    
    [self enqueueSignedOperation: networkOperation];
    

    
    
    
    
    
}




@end
