//
//  SYNRegistry.h
//  rockpack
//
//  Created by Michael Michailidis on 14/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYNRegistry.h"
#import "Genre.h"
#import "ChannelOwner.h"

@interface SYNMainRegistry : SYNRegistry

- (BOOL) registerCategoriesFromDictionary: (NSDictionary *) dictionary;

- (BOOL) registerDataForFeedFromDictionary: (NSDictionary *) dictionary
                               byAppending: (BOOL) append;


- (BOOL) registerChannelsFromDictionary: (NSDictionary *) dictionary
                               forGenre: (Genre *) genre
                            byAppending: (BOOL) append;


- (BOOL) registerUserFromDictionary: (NSDictionary *) dictionary;

- (BOOL) registerSubscriptionsForCurrentUserFromDictionary: (NSDictionary *) dictionary;

- (BOOL) registerCoverArtFromDictionary: (NSDictionary *) dictionary
                          forUserUpload: (BOOL) userUpload;


@end
