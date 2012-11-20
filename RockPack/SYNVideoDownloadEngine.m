//
//  SYNVideoDownloadEngine.m
//  rockpack
//
//  Created by Nick Banks on 20/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNVideoDownloadEngine.h"

@implementation SYNVideoDownloadEngine

- (MKNetworkOperation*) downloadFileFrom: (NSString*) path
                                  toFile: (NSString*) filePath
{
    MKNetworkOperation *op = [self operationWithPath: path
                                              params: nil
                                          httpMethod: @"GET"];
    
    [op addDownloadStream: [NSOutputStream outputStreamToFileAtPath: filePath
                                                             append: YES]];
    
    // Continue after network lost, then recovery
    [op setFreezable: YES];
    
    [self enqueueOperation: op];
    
    return op;
}

@end
