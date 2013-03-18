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

- (void) doFacebookLoginWithAccessToken: (NSString*) facebookAccessToken
                           withComplete: (MKNKLoginCompleteBlock) completionBlock
                               andError: (MKNKUserErrorBlock) errorBlock;

- (void) createChannelWithData: (NSDictionary*) userData
                  withComplete: (MKNKVoidBlock) completionBlock
                      andError: (MKNKUserErrorBlock) errorBlock;

- (void) updateChannelWithChannelId: (NSString *) channelId
                               data: (NSDictionary*) userData
                       withComplete: (MKNKVoidBlock) completionBlock
                           andError: (MKNKUserErrorBlock) errorBlock;

- (void) updateVideosForChannelWithChannelId: (NSString *) channelId
                             videoIdArray: (NSArray *) videoIdArray
                             withComplete: (MKNKVoidBlock) completionBlock
                                 andError: (MKNKUserErrorBlock) errorBlock;

@end
