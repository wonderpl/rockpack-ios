//
//  SYNAbstractNetworkEngine.h
//  rockpack
//
//  Created by Nick Banks on 18/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
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
@property (nonatomic, strong) NSString *locationString;
@property (nonatomic, strong) SYNMainRegistry* registry;
@property (nonatomic, strong) SYNSearchRegistry* searchRegistry;
@property (nonatomic, readonly) NSString* hostName;

- (id) initWithDefaultSettings;


- (void) addCommonHandlerToNetworkOperation: (SYNNetworkOperationJsonObject *) networkOperation
                          completionHandler: (MKNKUserSuccessBlock) completionBlock
                               errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) addCommonHandlerToNetworkOperation:  (SYNNetworkOperationJsonObject *) networkOperation
                          completionHandler: (MKNKUserSuccessBlock) completionBlock
                               errorHandler: (MKNKUserErrorBlock) errorBlock
                           retryInputStream: (NSInputStream*) retryInputStream;

- (IBAction) refreshOAuthTokenWithCompletionHandler: (MKNKUserErrorBlock) completionBlock
                                       errorHandler: (MKNKUserSuccessBlock) errorBlock;


- (NSDictionary *) paramsForStart: (int) start
                             size: (int) size;

- (NSDictionary *) paramsAndLocaleForStart: (int) start
                                      size: (int) size;

-(NSDictionary*) getLocaleParam;

-(NSDictionary*) getLocaleParamWithParams: (NSDictionary*) parameters;

// common operations for both engines

- (MKNetworkOperation *) updateChannel: (NSString *) resourceURL
                       forVideosLength: (NSInteger) length
                     completionHandler: (MKNKUserSuccessBlock) completionBlock
                          errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) enqueueSignedOperation: (MKNetworkOperation *) request;

#pragma mark - HTTP status 5xx errors
-(void)showErrorPopUpForError:(NSError*)error;

-(void)trackSessionWithMessage:(NSString*)message;

@end
