//
//  SYNOAuthNetworkEngine.h
//  oauth2demo-iOS
//
//  Created by Nick Banks on 21/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "MKNetworkEngine.h"
#import "SYNAbstractNetworkEngine.h"

typedef void (^SYNOAuth2CompletionBlock)(NSError *error);
typedef void (^SYNOAuth2RefreshCompletionBlock)(NSError *error);

@interface SYNOAuthNetworkEngine : SYNAbstractNetworkEngine

- (void) enqueueSignedOperation: (MKNetworkOperation *) request;

- (void) registerUserWithData: (NSDictionary*) userData
            completionHandler: (MKNKLoginCompleteBlock) completionBlock
                 errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) doSimpleLoginForUsername: (NSString*) username
                      forPassword: (NSString*) password
                completionHandler: (MKNKLoginCompleteBlock) completionBlock
                     errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) doFacebookLoginWithAccessToken: (NSString*) facebookAccessToken
                      completionHandler: (MKNKLoginCompleteBlock) completionBlock
                           errorHandler: (MKNKUserErrorBlock) errorBlock;


// User information

- (void) userInformationFromCredentials: (SYNOAuth2Credential *) credentials
                      completionHandler: (MKNKUserSuccessBlock) completionBlock
                           errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) changeUsernameForUserId: (NSString *) userId
                        password: (NSString *) password
               completionHandler: (MKNKUserSuccessBlock) completionBlock
                    errorHandler: (MKNKUserErrorBlock) errorBlock;

// Avatars

- (void) updateAvatarForUserId: (NSString *) userId
                         image: (UIImage *) image
             completionHandler: (MKNKUserSuccessBlock) completionBlock
                  errorHandler: (MKNKUserErrorBlock) errorBlock;

// Channel creation

- (void) createChannelWithData: (NSDictionary*) userData
             completionHandler: (MKNKUserSuccessBlock) completionBlock
                  errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) updateChannelWithChannelId: (NSString *) channelId
                               data: (NSDictionary*) userData
                  completionHandler: (MKNKUserSuccessBlock) completionBlock
                       errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) updateVideosForChannelWithChannelId: (NSString *) channelId
                                videoIdArray: (NSArray *) videoIdArray
                           completionHandler: (MKNKUserSuccessBlock) completionBlock
                                errorHandler: (MKNKUserErrorBlock) errorBlock;



@end
