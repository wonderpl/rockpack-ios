//
//  SYNNetworkEngine.h
//  rockpack
//
//  Created by Nick Banks on 10/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "MKNetworkEngine.h"
#import "SYNNetworkOperationJsonObject.h"

@interface SYNNetworkEngine : MKNetworkEngine

-(id) initWithDefaultSettings;

- (void) updateHomeScreenOnCompletion: (MKNKVoidBlock) completionBlock
                              onError: (MKNKErrorBlock) errorBlock;

- (void) updateVideosScreen;
- (void) updateChannelsScreen;
- (void) updateCategories;
- (void) updateChannel: (NSString *) resourceURL;

@end
