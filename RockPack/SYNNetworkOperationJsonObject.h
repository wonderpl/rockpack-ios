//
//  SYNNetworkOperationJsonObjectFetch.h
//  rockpack
//
//  Created by Michael Michailidis on 15/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "MKNetworkOperation.h"

@interface SYNNetworkOperationJsonObject : MKNetworkOperation

-(void)addJSONCompletionHandler:(MKNKResponseBlock)responseBlock errorHandler:(MKNKErrorBlock)errorBlock;

@end
