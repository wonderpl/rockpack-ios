//
//  SYNNetworkOperationJsonObjectFetch.h
//  rockpack
//
//  Created by Michael Michailidis on 15/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "MKNetworkOperation.h"

@class SYNOAuth2Credential, User;

typedef void (^MKNKAutocompleteProcessBlock) (NSArray*);
typedef void (^MKNKLoginCompleteBlock) (SYNOAuth2Credential *);
typedef void (^MKNKUserCompleteBlock) (User*);
typedef void (^MKNKUserErrorBlock) (NSDictionary*);
typedef void (^MKNKUserSuccessBlock) (NSDictionary*);

#import "AppConstants.h"

@class SYNOAuth2Credential, User;

typedef void (^MKNKAutocompleteProcessBlock) (NSArray*);
typedef void (^MKNKLoginCompleteBlock) (SYNOAuth2Credential *);
typedef void (^MKNKUserCompleteBlock) (User*);
typedef void (^MKNKUserErrorBlock) (NSDictionary*);
typedef void (^MKNKUserSuccessBlock) (NSDictionary*);

@interface SYNNetworkOperationJsonObject : MKNetworkOperation

-(void)addJSONCompletionHandler:(JSONResponseBlock)responseBlock errorHandler:(MKNKErrorBlock)errorBlock;

@end
