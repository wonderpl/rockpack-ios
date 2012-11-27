//
//  SYNOAuthNetworkEngine.h
//  oauth2demo-iOS
//
//  Created by Nick Banks on 21/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "MKNetworkEngine.h"

typedef void (^SYNOAuth2CompletionBlock)(NSError *error);
typedef void (^SYNOAuth2RefreshCompletionBlock)(NSError *error);

@interface SYNOAuthNetworkEngine : MKNetworkEngine

- (void) enqueueSignedOperation: (MKNetworkOperation *) request;

@end
