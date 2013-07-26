//
//  SYNNetworkOperationJsonObjectAutocomplete.m
//  rockpack
//
//  Created by Michael Michailidis on 06/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNNetworkOperationJsonObjectParse.h"

@implementation SYNNetworkOperationJsonObjectParse

- (void) responseJSONWithOptions: (NSJSONReadingOptions) options
               completionHandler: (void (^)(id jsonObject)) jsonDecompressionHandler
{
    if ([self responseData] == nil)
    {
        jsonDecompressionHandler(nil);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData *parsedData = [self.responseData subdataWithRange: NSMakeRange(19, self.responseData.length - 19 - 1)];
        
        NSError *error = nil;
        id returnValue = [NSJSONSerialization JSONObjectWithData: parsedData
                                                         options: options
                                                           error: &error];
        
        if (error)
        {
            jsonDecompressionHandler(nil);
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            jsonDecompressionHandler(returnValue);
        });
    });
}


@end
