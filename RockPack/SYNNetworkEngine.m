//
//  SYNNetworkEngine.m
//  rockpack
//
//  Created by Nick Banks on 10/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "Category.h"
#import "SYNAppDelegate.h"
#import "Channel.h"
#import "NSString+Utils.h"
#import "SYNAppDelegate.h"
#import "SYNMainRegistry.h"
#import "SYNNetworkEngine.h"
#import "SYNNetworkOperationJsonObjectParse.h"
#import "SYNSearchRegistry.h"
#import "VideoInstance.h"

@interface SYNNetworkEngine ()

@end

@implementation SYNNetworkEngine

- (NSString *) hostName
{
    return hostName;
}

-(id)initWithDefaultSettings
{
    
    hostName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"APIHostName"];
    
    self = [super initWithDefaultSettings];
    
    if(self) {
        
        
        
    }
    
    
    return self;
}


#pragma mark - Engine API

- (void) coverArtWithWithStart: (unsigned int) start
                          size: (unsigned int) size
             completionHandler: (MKNKUserSuccessBlock) completionBlock
                  errorHandler: (MKNKUserErrorBlock) errorBlock
{
    // If size is 0, then don't include start and size in the call (i.e. just use default params), otherwise assume both params are valid
    NSDictionary *params = [self paramsAndLocaleForStart: start
                                                    size: size];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: kAPIGetCoverArt
                                                                                                       params: params
                                                                                                   httpMethod: @"GET"];
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueOperation: networkOperation];
}


- (void) updateCategoriesOnCompletion: (MKNKVoidBlock) completionBlock
                              onError: (MKNKErrorBlock) errorBlock
{
    
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject*)[self operationWithPath:kAPICategories params:[self getLocalParam]];
    
    
    [networkOperation addJSONCompletionHandler:^(NSDictionary *dictionary) {
        
        BOOL registryResultOk = [self.registry registerCategoriesFromDictionary:dictionary];
        if (!registryResultOk)
            return;
        
        completionBlock();
        
    } errorHandler:^(NSError* error) {
        DebugLog(@"API request failed");
    }];
    
    
    [self enqueueOperation: networkOperation];
    
    
}


- (void) updateVideosScreenForCategory:(NSString*)categoryId
{
    NSDictionary* parameters;
    if([categoryId isEqualToString:@"all"])
        parameters = [self getLocalParam];
    else
        parameters = [self getLocalParamWithParams:[NSDictionary dictionaryWithObject:categoryId forKey:@"category"]];
    
    DebugLog(@"Network Engine requesting Videos with locale: %@", self.localeString);
    
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject*)[self operationWithPath:kAPIPopularVideos params:parameters];
    
    [networkOperation addJSONCompletionHandler:^(NSDictionary *dictionary) {
        
        BOOL registryResultOk = [self.registry registerVideoInstancesFromDictionary:dictionary forViewId:@"Videos" byAppending:NO];
        if (!registryResultOk) {
            DebugLog(@"Update Videos Screens Request Failed");
            return;
        }
        
        
        
    } errorHandler:^(NSError* error) {
        DebugLog(@"Update Videos Screens Request Failed");
    }];
    
    
    [self enqueueOperation: networkOperation];
}




//- (void) updateChannel: (NSString *) resourceURL
//{
//    
//    SYNNetworkOperationJsonObject *networkOperation =
//    (SYNNetworkOperationJsonObject*)[self operationWithURLString:resourceURL params:[self getLocalParam]];
//    
//    [networkOperation addJSONCompletionHandler:^(NSDictionary *dictionary) {
//        
//        NSString* possibleError = dictionary[@"error"];
//        
//        if (possibleError)
//        {
//            DebugLog(@"Call for updateChannel failed with error");
//            return;
//        }
//        
//        BOOL registryResultOk = [self.registry registerChannelFromDictionary:dictionary];
//        if (!registryResultOk) {
//            DebugLog(@"Registration of Channel Failed at NetworkEngine");
//            return;
//        }
//        
//        
//        
//    } errorHandler:^(NSError* error) {
//        DebugLog(@"Update Channel Screens Request Failed");
//    }];
//    
//    [self enqueueOperation: networkOperation];
//    
//}

- (void) updateChannel: (NSString *) resourceURL
     completionHandler: (MKNKUserSuccessBlock) completionBlock
          errorHandler: (MKNKUserErrorBlock) errorBlock
{
    
    SYNNetworkOperationJsonObject *networkOperation =(SYNNetworkOperationJsonObject*)[self operationWithURLString: resourceURL
                                                                                                           params: nil];
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueOperation: networkOperation];
    
}

- (void) updateChannelsScreenForCategory:(NSString*)categoryId
                                forRange:(NSRange)range
                            onCompletion:(MKNKJSONCompleteBlock)completeBlock
                                 onError:(MKNKJSONErrorBlock)errorBlock {
    
    
    NSMutableDictionary* tempParameters = [NSMutableDictionary dictionary];
    [tempParameters setObject:[NSString stringWithFormat:@"%i", range.location] forKey:@"start"];
    [tempParameters setObject:[NSString stringWithFormat:@"%i", range.length] forKey:@"size"];
    
    if(![categoryId isEqualToString:@"all"]) {
        [tempParameters setObject:categoryId forKey:@"category"];
    }
        
    
    NSDictionary* parameters = [self getLocalParamWithParams:tempParameters];
    
    
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject*)[self operationWithPath:kAPIPopularChannels params: parameters];
    
    [networkOperation addJSONCompletionHandler:^(NSDictionary *dictionary) {
        
        completeBlock(dictionary);
        
    } errorHandler:^(NSError* error) {
        DebugLog(@"Update Channel Screens Request Failed");
        errorBlock(@{@"network_error":@"engine failed to load channels"});
    }];
    
    [self enqueueOperation: networkOperation];
    
}






#pragma mark - Search

- (void) searchVideosForTerm:(NSString*)searchTerm
{
    NSDictionary* parameters;
    
    if(searchTerm == nil || [searchTerm isEqualToString:@""])
        return;
    
    parameters = [self getLocalParamWithParams:[NSDictionary dictionaryWithObject:searchTerm forKey:@"q"]];
    
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject*)[self operationWithPath:kAPISearchVideos params:parameters];
    
    [networkOperation addJSONCompletionHandler:^(NSDictionary *dictionary) {
        
        BOOL registryResultOk = [self.searchRegistry registerVideosFromDictionary:dictionary];
        if (!registryResultOk)
            return;
        
        
    } errorHandler:^(NSError* error) {
        DebugLog(@"Update Videos Screens Request Failed");
    }];
    
    
    [self enqueueOperation: networkOperation];
}


- (void) searchChannelsForTerm:(NSString*)searchTerm
{
    
    
    if(!searchTerm) return;
    
    
    NSDictionary* parameters;
    
    
    parameters = [self getLocalParamWithParams:[NSDictionary dictionaryWithObject:searchTerm forKey:@"q"]];
    
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject*)[self operationWithPath:kAPISearchChannels params:parameters];
    
    [networkOperation addJSONCompletionHandler:^(NSDictionary *dictionary) {
        
        BOOL registryResultOk = [self.searchRegistry registerChannelFromDictionary:dictionary];
        if (!registryResultOk)
            return;
        
        
    } errorHandler:^(NSError* error) {
        DebugLog(@"Update Videos Screens Request Failed");
    }];
    
    
    [self enqueueOperation: networkOperation];
}

#pragma mark - Autocomplete

- (void) getAutocompleteForHint:(NSString*)hint
                    forResource:(EntityType)entityType
                   withComplete: (MKNKAutocompleteProcessBlock) completionBlock
                        andError: (MKNKErrorBlock) errorBlock
{
    
    if(!hint) return;
    
    
    // Register the class to be used for this operation only
    
    [self registerOperationSubclass:[SYNNetworkOperationJsonObjectParse class]];
    
    
    NSDictionary* parameters = [self getLocalParamWithParams:[NSDictionary dictionaryWithObject:hint forKey:@"q"]];
    
    NSString* apiForEntity;
    if(entityType == EntityTypeChannel)
        apiForEntity = kAPICompleteChannels;
    else if(entityType == EntityTypeVideo)
        apiForEntity = kAPICompleteVideos;
    else
        return; // do not accept any unknown type
    
    SYNNetworkOperationJsonObjectParse *networkOperation =
    (SYNNetworkOperationJsonObjectParse*)[self operationWithPath:apiForEntity params:parameters];
    
    [networkOperation addJSONCompletionHandler:^(NSArray *array) {
        
        completionBlock(array);
        
        
    } errorHandler:errorBlock];
    
    
    [self enqueueOperation: networkOperation];
    
    
    
    // Go back to the original operation class
    
    [self registerOperationSubclass:[SYNNetworkOperationJsonObject class]];
    
}

-(void)userPublicChannelsByOwner:(ChannelOwner*)channelOwner {
    
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : channelOwner.uniqueId};
    
    NSString *apiString = [kAPIGetUserDetails stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: @{@"locale" : self.localeString}
                                                                                                   httpMethod: @"GET"];
    
    [networkOperation addJSONCompletionHandler:^(NSDictionary *responseDictionary) {
         
         
         BOOL registryResultOk = [self.searchRegistry registerChannelFromDictionary:responseDictionary withViewId:@"UserChannels" andOwner:channelOwner];
         if (!registryResultOk)
             return;
         
         
     } errorHandler: ^(NSError* error) {
         
         DebugLog(@"API Call failed");
         
     }];
    
    
    [self enqueueOperation: networkOperation];
    
}

@end
