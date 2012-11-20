//
//  SYNVideoDownloadEngine.h
//  rockpack
//
//  Created by Nick Banks on 20/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "MKNetworkEngine.h"

@interface SYNVideoDownloadEngine : MKNetworkEngine

- (MKNetworkOperation*) downloadFileFrom: (NSString*) path
                                  toFile: (NSString*) filePath;

@end
