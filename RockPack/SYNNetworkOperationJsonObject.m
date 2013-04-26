//
//  SYNNetworkOperationJsonObjectFetch.m
//  rockpack
//
//  Created by Michael Michailidis on 15/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNNetworkOperationJsonObject.h"

@implementation SYNNetworkOperationJsonObject

@synthesize ignoreCachedResponse;

-(void)addJSONCompletionHandler:(JSONResponseBlock)responseBlock errorHandler:(MKNKErrorBlock)errorBlock
{
    BOOL ignore = self.ignoreCachedResponse;
    
    [self addCompletionHandler:^(MKNetworkOperation *completedOperation)
    {
         
        if(ignore && completedOperation.isCachedResponse)
            return;
         
         [completedOperation responseJSONWithOptions: NSJSONReadingAllowFragments
                                   completionHandler: ^(id jsonObject) {
                                       
            // We need to check to see if the response is signalled as blank
             if(!jsonObject && (completedOperation.HTTPStatusCode != 204))
             {
                 // check whether an object is returned before calling the completeBlock
                 NSLog(@"The JSON Object could not be parsed!");
                 NSError* noObjectParsedError = [NSError errorWithDomain: @"JSON Object Not Parsed"
                                                                    code: 0
                                                                userInfo: nil];
                 errorBlock(noObjectParsedError);
                 return;
             }
            
             responseBlock(jsonObject);
         }];
     }
     errorHandler: ^(MKNetworkOperation *errorOp, NSError* error)
     { 
         if(error.code == 400) { // api error, response has Json Data
             
             [errorOp responseJSONWithOptions: NSJSONReadingAllowFragments
                            completionHandler: ^(id jsonObject)
             {
                 if (!jsonObject)
                 {
                     errorBlock(error);
                     return;
                 }
                 
                 responseBlock(jsonObject);
             }];
         }
         else if(error.code == 401)
         {
             // Invalid or expired token
             [errorOp responseJSONWithOptions: NSJSONReadingAllowFragments
                            completionHandler: ^(id jsonObject)
              {
                  if (!jsonObject)
                  {
                      errorBlock(error);
                      return;
                  }
                  
                  responseBlock(jsonObject);
              }];
         }
         else
         {
             errorBlock(error);
         }
      }];
}



@end
