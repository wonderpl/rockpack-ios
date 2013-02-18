//
//  SYNNetworkOperationJsonObjectFetch.h
//  rockpack
//
//  Created by Michael Michailidis on 15/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "MKNetworkOperation.h"


typedef void (^JSONResponseBlock)(id jsonObject);

@interface SYNNetworkOperationJsonObject : MKNetworkOperation

-(void)addJSONCompletionHandler:(JSONResponseBlock)responseBlock errorHandler:(MKNKErrorBlock)errorBlock;

@end
