//
//  SYNNetworkOperationPostJson.m
//  rockpack
//
//  Created by Michael Michailidis on 12/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNNetworkOperationPostJson.h"

@implementation SYNNetworkOperationPostJson

@synthesize jsonObjectToPost;

-(NSData*) bodyData {
    
    if(!self.jsonObjectToPost) {
        return nil;
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.jsonObjectToPost
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];

    if(!jsonData) {
        return nil;
    }
    
    
        
    return jsonData;
}

@end
