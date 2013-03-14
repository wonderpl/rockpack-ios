//
//  SYNNetworkEngine.h
//  rockpack
//
//  Created by Nick Banks on 10/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "MKNetworkEngine.h"

#import "AppConstants.h"
#import "SYNNetworkOperationJsonObject.h"

@interface SYNNetworkEngine : MKNetworkEngine

- (id) initWithDefaultSettings;

- (void) updateHomeScreenOnCompletion: (MKNKVoidBlock) completionBlock
                              onError: (MKNKErrorBlock) errorBlock;

- (void) updateCategoriesOnCompletion: (MKNKVoidBlock) completionBlock
                              onError: (MKNKErrorBlock) errorBlock;

- (void) updateVideosScreenForCategory:(NSString*)categoryId;
- (void) updateChannel: (NSString *) resourceURL;
- (void) updateChannelsScreenForCategory:(NSString*)category;

- (void) searchVideosForTerm:(NSString*)searchTerm;
- (void) searchChannelsForTerm:(NSString*)searchTerm;

- (void) getAutocompleteForHint:(NSString*)hint
                    forResource:(EntityType)entityType
                   withComplete: (MKNKAutocompleteProcessBlock) completionBlock
                       andError: (MKNKErrorBlock) errorBlock;


-(void)doSimpleLoginForUsername:(NSString*)username
                    forPassword:(NSString*)password
                   withComplete: (MKNKLoginCompleteBlock) completionBlock
                       andError: (MKNKUserErrorBlock) errorBlock;

-(void)doFacebookLoginWithAccessToken:(NSString*)facebookAccessToken
                         withComplete: (MKNKLoginCompleteBlock) completionBlock
                             andError: (MKNKUserErrorBlock) errorBlock;

-(void)registerUserWithData:(NSDictionary*)userData
               withComplete:(MKNKLoginCompleteBlock)completionBlock
                   andError:(MKNKUserErrorBlock)errorBlock;

-(void)retrieveUserFromAccessInfo:(AccessInfo*)accessInfo
                     withComplete:(MKNKUserCompleteBlock)completionBlock
                         andError:(MKNKUserErrorBlock)errorBlock;


@end
