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
    
    
    NSMutableData* body = [[NSMutableData alloc] init];
    
    //[body appendData:thisDataObject[@"data"]];
    
        
    return body;
}

@end
