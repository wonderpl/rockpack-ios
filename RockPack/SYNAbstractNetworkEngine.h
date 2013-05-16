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
#import "User.h"

#define kJSONParseError 110
#define kNetworkError   112

@class SYNNetworkOperationJsonObject;

@interface SYNAbstractNetworkEngine : MKNetworkEngine {
    NSString* hostName;
}

@property (nonatomic, strong) NSString *localeString;
@property (nonatomic, strong) SYNMainRegistry* registry;
@property (nonatomic, strong) SYNSearchRegistry* searchRegistry;
@property (nonatomic, readonly) NSString* hostName;

- (id) initWithDefaultSettings;


- (void) addCommonHandlerToNetworkOperation: (SYNNetworkOperationJsonObject *) networkOperation
                          completionHandler: (MKNKUserSuccessBlock) completionBlock
                               errorHandler: (MKNKUserErrorBlock) errorBlock;

- (IBAction) refreshOAuthTokenWithCompletionHandler: (MKNKUserErrorBlock) completionBlock
                                       errorHandler: (MKNKUserSuccessBlock) errorBlock;


- (NSDictionary *) paramsForStart: (int) start
                             size: (int) size;

- (NSDictionary *) paramsAndLocaleForStart: (int) start
                                      size: (int) size;

-(NSDictionary*) getLocalParam;

-(NSDictionary*) getLocalParamWithParams:(NSDictionary*)parameters;

- (void) enqueueSignedOperation: (MKNetworkOperation *) request;

@end
