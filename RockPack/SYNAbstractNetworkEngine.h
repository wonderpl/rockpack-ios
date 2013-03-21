//
//  SYNAbstractNetworkEngine.h
//  rockpack
//
//  Created by Nick Banks on 18/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "MKNetworkEngine.h"
#import "SYNMainRegistry.h"
#import "SYNNetworkOperationJsonObject.h"
#import "SYNSearchRegistry.h"

@class SYNNetworkOperationJsonObject;

@interface SYNAbstractNetworkEngine : MKNetworkEngine

@property (nonatomic, strong) NSString *localeString;
@property (nonatomic, strong) SYNMainRegistry* registry;
@property (nonatomic, strong) SYNSearchRegistry* searchRegistry;

- (id) initWithDefaultSettings;

- (NSString *) hostName;

- (void) addCommonHandlerToNetworkOperation: (SYNNetworkOperationJsonObject *) networkOperation
                          completionHandler: (MKNKUserSuccessBlock) completionBlock
                               errorHandler: (MKNKUserErrorBlock) errorBlock;

- (NSDictionary *) paramsForStart: (int) start
                             size: (int) size;

@end
