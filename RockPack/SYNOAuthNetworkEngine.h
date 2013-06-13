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

-(void) doRequestPasswordResetForUsername:(NSString*) username
                        completionHandler:(MKNKJSONCompleteBlock) completionBlock
                            errorHandler: (MKNKErrorBlock) errorBlock;
// User information

- (void) retrieveAndRegisterUserFromCredentials: (SYNOAuth2Credential *) credentials
                      completionHandler: (MKNKUserSuccessBlock) completionBlock
                           errorHandler: (MKNKUserErrorBlock) errorBlock;

// Avatars

- (void) updateAvatarForUserId: (NSString *) userId
                         image: (UIImage *) image
             completionHandler: (MKNKUserSuccessBlock) completionBlock
                  errorHandler: (MKNKUserErrorBlock) errorBlock;

// Channel creation


- (void) channelCreatedForUserId: (NSString *) userId
                       channelId: (NSString *) channelId
               completionHandler: (MKNKUserSuccessBlock) completionBlock
                    errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) channelDataForUserId: (NSString *) userId
                    channelId: (NSString *) channelId
                        start: (unsigned int) start
                         size: (unsigned int) size
            completionHandler: (MKNKUserSuccessBlock) completionBlock
                 errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) createChannelForUserId: (NSString *) userId
                          title: (NSString *) title
                    description: (NSString *) description
                       category: (NSString *) category
                          cover: (NSString *) cover
                       isPublic: (BOOL) isPublic
              completionHandler: (MKNKUserSuccessBlock) completionBlock
                   errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) updateChannelForUserId: (NSString *) userId
                      channelId: (NSString *) channelId
                          title: (NSString *) title
                    description: (NSString *) description
                       category: (NSString *) category
                          cover: (NSString *) cover
                       isPublic: (BOOL) isPublic
              completionHandler: (MKNKUserSuccessBlock) completionBlock
                   errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) updatePrivacyForChannelForUserId: (NSString *) userId
                                channelId: (NSString *) channelId
                                 isPublic: (BOOL) isPublic
                        completionHandler: (MKNKUserSuccessBlock) completionBlock
                             errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) deleteChannelForUserId: (NSString *) userId
                      channelId: (NSString *) channelId
              completionHandler: (MKNKUserSuccessBlock) completionBlock
                   errorHandler: (MKNKUserErrorBlock) errorBlock;


- (void) videosForChannelForUserId: (NSString *) userId
                         channelId: (NSString *) channelId
                 completionHandler: (MKNKUserSuccessBlock) completionBlock
                      errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) updateVideosForChannelForUserId: (NSString *) userId
                               channelId: (NSString *) channelId
                        videoInstanceSet: (NSOrderedSet *) videoInstanceSet
                           clearPrevious: (BOOL) clearPrevious
                       completionHandler: (MKNKUserSuccessBlock) completionBlock
                            errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) userDataForUser: (User*) user
            onCompletion: (MKNKUserSuccessBlock) completionBlock
                 onError: (MKNKUserErrorBlock) errorBlock;

- (void) userSubscriptionsForUser: (User*)user
                     onCompletion: (MKNKUserSuccessBlock) completionBlock
                          onError: (MKNKUserErrorBlock) errorBlock;

// User activity

- (void) recordActivityForUserId: (NSString *) userId
                          action: (NSString *) action
                 videoInstanceId: (NSString *) videoInstanceId
               completionHandler: (MKNKUserSuccessBlock) completionBlock
                    errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) activityForUserId: (NSString *) userId
         completionHandler: (MKNKUserSuccessBlock) completionBlock
              errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) notificationsFromUserId: (NSString *) userId
               completionHandler: (MKNKUserErrorBlock) completionBlock
                    errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) markAdReadForNotificationIndexes: (NSArray*) indexes
                               fromUserId: (NSString*)userId
                        completionHandler: (MKNKUserErrorBlock) completionBlock
                             errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) changeUserField: (NSString*) userField
                 forUser: (User *) user
            withNewValue: (id)newValue
       completionHandler: (MKNKUserSuccessBlock) completionBlock
            errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) changeUserPasswordWithOldValue: (NSString*) oldPassword
                            andNewValue: (NSString*)newValue
                              forUserId: (NSString *) userid
                      completionHandler: (MKNKUserSuccessBlock) successBlock
                           errorHandler: (MKNKUserErrorBlock) errorBlock;

// Cover art

- (void) coverArtForUserId: (NSString *) userId
                     start: (unsigned int) start
                      size: (unsigned int) size
         completionHandler: (MKNKUserSuccessBlock) completionBlock
              errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) updateCoverArtForUserId: (NSString *) userId
                    onCompletion: (MKNKVoidBlock) completionBlock
                         onError: (MKNKErrorBlock) errorBlock;

- (void) uploadCoverArtForUserId: (NSString *) userId
                           image: (UIImage *) image
               completionHandler: (MKNKUserSuccessBlock) completionBlock
                    errorHandler: (MKNKUserErrorBlock) errorBlock;


- (void) deleteCoverArtForUserId: (NSString *) userId
                         coverId: (NSString *) coverId
               completionHandler: (MKNKUserSuccessBlock) completionBlock
                    errorHandler: (MKNKUserErrorBlock) errorBlock;

// Sunscriptions

- (void) channelSubscriptionsForUserId: (NSString *) userId
                            credential: (SYNOAuth2Credential*)credential
                                 start: (unsigned int) start
                                  size: (unsigned int) size
                     completionHandler: (MKNKUserSuccessBlock) completionBlock
                          errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) channelSubscribeForUserId: (NSString *) userId
                        channelURL: (NSString *) channelURL
                 completionHandler: (MKNKUserSuccessBlock) completionBlock
                      errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) channelUnsubscribeForUserId: (NSString *) userId
                           channelId: (NSString *) channelId
                   completionHandler: (MKNKUserSuccessBlock) completionBlock
                        errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) subscriptionsUpdatesForUserId: (NSString *) userId
                                 start: (unsigned int) start
                                  size: (unsigned int) size
                     completionHandler: (MKNKUserSuccessBlock) completionBlock
                          errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) shareLinkWithObjectType: (NSString *) objectType
                        objectId: (NSString *) objectId
               completionHandler: (MKNKUserSuccessBlock) completionBlock
                    errorHandler: (MKNKUserErrorBlock) errorBlock;

- (MKNetworkOperation*) updateChannel: (NSString *) resourceURL
                    completionHandler: (MKNKUserSuccessBlock) completionBlock
                         errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) reportConcernForUserId: (NSString *) userId
                     objectType: (NSString *) objectType
                       objectId: (NSString *) objectId
                         reason: (NSString *) reason
              completionHandler: (MKNKUserSuccessBlock) completionBlock
                   errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) reportPlayerErrorForVideoInstanceId: (NSString *) videoInstanceId
                            errorDescription: (NSString *) errorDescription
                           completionHandler: (MKNKUserSuccessBlock) completionBlock
                                errorHandler: (MKNKUserErrorBlock) errorBlock;

@end
