//
//  SYNNetworkEngine.h
//  rockpack
//
//  Created by Nick Banks on 10/01/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//



#import "AppConstants.h"
#import "SYNAbstractNetworkEngine.h"
#import "SYNNetworkOperationJsonObject.h"
#import "ChannelOwner.h"
#import "SYNNetworkOperationJsonObjectParse.h"

@interface SYNNetworkEngine : SYNAbstractNetworkEngine

@property (nonatomic) BOOL shouldFirstCheckCache;

- (void) updateCategoriesOnCompletion: (MKNKJSONCompleteBlock) completionBlock
                              onError: (MKNKErrorBlock) errorBlock;


- (MKNetworkOperation*) updateChannelsScreenForCategory: (NSString*) categoryId
                                               forRange: (NSRange) range
                                          ignoringCache: (BOOL) ignore
                                           onCompletion: (MKNKJSONCompleteBlock) completeBlock
                                                onError: (MKNKJSONErrorBlock) errorBlock;

- (MKNetworkOperation*) searchVideosForTerm:(NSString*)searchTerm
                                    inRange:(NSRange)range
                                 onComplete:(MKNKSearchSuccessBlock)completeBlock;

- (MKNetworkOperation*) searchChannelsForTerm:(NSString*)searchTerm
                                     andRange:(NSRange)range
                                   onComplete:(MKNKSearchSuccessBlock)completeBlock;

- (MKNetworkOperation*) searchUsersForTerm: (NSString*)searchTerm
                                  andRange: (NSRange)range
                                onComplete: (MKNKSearchSuccessBlock)completeBlock;

- (MKNetworkOperation*) getAutocompleteForHint: (NSString*)hint
                                   forResource: (EntityType)entityType
                                  withComplete: (MKNKAutocompleteProcessBlock) completionBlock
                                      andError: (MKNKErrorBlock) errorBlock;

- (void) updateCoverArtWithWithStart: (unsigned int) start
                                size: (unsigned int) size
                   completionHandler: (MKNKJSONCompleteBlock) completionBlock
                        errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) updateCoverArtOnCompletion: (MKNKJSONCompleteBlock) completionBlock
                            onError: (MKNKErrorBlock) errorBlock;

- (MKNetworkOperation*) updateChannel: (NSString *) resourceURL
                    completionHandler: (MKNKUserSuccessBlock) completionBlock
                         errorHandler: (MKNKUserErrorBlock) errorBlock;

-(void)channelOwnerDataForChannelOwner:(ChannelOwner*)channelOwner
                            onComplete:(MKNKUserSuccessBlock)completeBlock
                               onError:(MKNKUserErrorBlock)errorBlock;

- (void) channelOwnerSubscriptionsForOwner: (ChannelOwner*) channelOwner
                                  forRange: (NSRange)range
                         completionHandler: (MKNKUserSuccessBlock) completionBlock
                              errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) subscribersForUserId: (NSString*) userId
                    channelId: (NSString*)channelId
                     forRange: (NSRange)range
             ompletionHandler: (MKNKBasicSuccessBlock) completionBlock
                 errorHandler: (MKNKBasicFailureBlock) errorBlock;



- (void) videosForChannelForUserId: (NSString *) userId
                         channelId: (NSString *) channelId
                           inRange: (NSRange) range
                 completionHandler: (MKNKUserSuccessBlock) completionBlock
                      errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) updatePlayerSourceWithCompletionHandler: (MKNKUserErrorBlock) completionBlock
                                    errorHandler: (MKNKUserSuccessBlock) errorBlock;

@end
