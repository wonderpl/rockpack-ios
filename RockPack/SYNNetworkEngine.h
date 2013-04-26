//
//  SYNNetworkEngine.h
//  rockpack
//
//  Created by Nick Banks on 10/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//



#import "AppConstants.h"
#import "SYNAbstractNetworkEngine.h"
#import "SYNNetworkOperationJsonObject.h"
#import "ChannelOwner.h"

@interface SYNNetworkEngine : SYNAbstractNetworkEngine

@property (nonatomic) BOOL shouldFirstCheckCache;

- (void) updateCategoriesOnCompletion: (MKNKVoidBlock) completionBlock
                              onError: (MKNKErrorBlock) errorBlock;

- (void) updateVideosScreenForCategory: (NSString*) categoryId;


- (void) updateChannelsScreenForCategory:(NSString*)categoryId
                                forRange:(NSRange)range
                           ignoringCache:(BOOL)ingore
                            onCompletion:(MKNKJSONCompleteBlock)completeBlock
                                 onError:(MKNKJSONErrorBlock)errorBlock;

- (void) searchVideosForTerm: (NSString*) searchTerm;
- (void) searchChannelsForTerm: (NSString*) searchTerm;

- (void) getAutocompleteForHint: (NSString*) hint
                    forResource: (EntityType) entityType
                   withComplete: (MKNKAutocompleteProcessBlock) completionBlock
                       andError: (MKNKErrorBlock) errorBlock;

-(void) userPublicChannelsByOwner: (ChannelOwner*) channelOwner;

- (void) coverArtWithWithStart: (unsigned int) start
                          size: (unsigned int) size
             completionHandler: (MKNKUserSuccessBlock) completionBlock
                  errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) updateCoverArtOnCompletion: (MKNKVoidBlock) completionBlock
                            onError: (MKNKErrorBlock) errorBlock;

- (void) updateChannel: (NSString *) resourceURL
     completionHandler: (MKNKUserSuccessBlock) completionBlock
          errorHandler: (MKNKUserErrorBlock) errorBlock;

@end
