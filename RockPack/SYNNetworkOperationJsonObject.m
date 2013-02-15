//
//  SYNNetworkOperationJsonObjectFetch.m
//  rockpack
//
//  Created by Michael Michailidis on 15/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNNetworkOperationJsonObject.h"

@implementation SYNNetworkOperationJsonObject

-(void)addJSONCompletionHandler:(MKNKResponseBlock)responseBlock errorHandler:(MKNKErrorBlock)errorBlock
{
    [self addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        
         [completedOperation responseJSONWithCompletionHandler: ^(id jsonObject) {
             
             if(!jsonObject) { // check whether an object is returned before calling the completeBlock
                 NSError* noObjectParsedError = [NSError errorWithDomain:@"JSON Object Not Parsed" code:0 userInfo:nil];
                 errorBlock(noObjectParsedError);
                 return;
             }
             responseBlock(jsonObject);
         }];
        
     } errorHandler: ^(MKNetworkOperation *errorOp, NSError* error) {
         errorBlock(error);
     }];
}
@end
