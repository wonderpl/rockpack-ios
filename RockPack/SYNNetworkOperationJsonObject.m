//
//  SYNNetworkOperationJsonObjectFetch.m
//  rockpack
//
//  Created by Michael Michailidis on 15/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNNetworkOperationJsonObject.h"

@implementation SYNNetworkOperationJsonObject

-(void)addJSONCompletionHandler:(JSONResponseBlock)responseBlock errorHandler:(MKNKErrorBlock)errorBlock
{
    [self addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        
         [completedOperation responseJSONWithCompletionHandler: ^(id jsonObject) {
             
             if(!jsonObject) { // check whether an object is returned before calling the completeBlock
                 
                 NSLog(@"The JSON Object could not be parsed!");
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


-(void)addJSONCompletionHandler:(JSONResponseBlock)responseBlock apiErrorHandler:(MKNKApiErrorBlock)apiErrorBlock
{
    [self addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        
        [completedOperation responseJSONWithCompletionHandler: ^(id jsonObject) {
            
            if(!jsonObject) { // check whether an object is returned before calling the completeBlock
                
                NSLog(@"The JSON Object could not be parsed!");
                NSError* noObjectParsedError = [NSError errorWithDomain:@"JSON Object Not Parsed" code:0 userInfo:nil];
                apiErrorBlock(noObjectParsedError, @{});
                return;
                
            }
            responseBlock(jsonObject);
        }];
        
    } errorHandler: ^(MKNetworkOperation *errorOp, NSError* error) {
        
        if(error.code == 400) { // api error, has Json Data
            
            [errorOp responseJSONWithCompletionHandler: ^(id jsonObject) {
                
                if(!jsonObject) { 
                    
                    apiErrorBlock(error, jsonObject);
                    return;
                    
                }
                responseBlock(jsonObject);
            }];
        } else {
            apiErrorBlock(error, @{});
        }
        
    }];
}


@end
