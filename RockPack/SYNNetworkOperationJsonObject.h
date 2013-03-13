//
//  SYNNetworkOperationJsonObjectFetch.h
//  rockpack
//
//  Created by Michael Michailidis on 15/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "MKNetworkOperation.h"

#import "AppConstants.h"

@interface SYNNetworkOperationJsonObject : MKNetworkOperation

-(void)addJSONCompletionHandler:(JSONResponseBlock)responseBlock errorHandler:(MKNKErrorBlock)errorBlock;
-(void)addJSONCompletionHandler:(JSONResponseBlock)responseBlock apiErrorHandler:(MKNKApiErrorBlock)apiErrorBlock;

@end
