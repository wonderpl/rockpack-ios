//
//  SYNNetworkEngine.m
//  rockpack
//
//  Created by Nick Banks on 10/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "Genre.h"
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

@synthesize shouldFirstCheckCache;

- (NSString *) hostName
{
    return hostName;
}


- (id) initWithDefaultSettings
{
    hostName = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"APIHostName"];
    
    if ((self = [super initWithDefaultSettings]))
    {
        // Custom init goes here
    }
    
    return self;
}


#pragma mark - Engine API


- (void) updateCategoriesOnCompletion: (MKNKJSONCompleteBlock) completionBlock
                              onError: (MKNKErrorBlock) errorBlock
{
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject*)[self operationWithPath: kAPICategories
                                                     params: [self getLocalParam]];

    [networkOperation addJSONCompletionHandler:^(NSDictionary *dictionary) {
        
        
        completionBlock(dictionary);
        
    } errorHandler:^(NSError* error) {
        
        DebugLog(@"API request failed");
        
    }];

    [self enqueueOperation: networkOperation]; 
}


- (void) updateCoverArtWithWithStart: (unsigned int) start
                                size: (unsigned int) size
                   completionHandler: (MKNKJSONCompleteBlock) completionBlock
                        errorHandler: (MKNKUserErrorBlock) errorBlock
{
    // If size is 0, then don't include start and size in the call (i.e. just use default params), otherwise assume both params are valid
    NSDictionary *params = [self paramsAndLocaleForStart: start
                                                    size: size];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: kAPIGetCoverArt
                                                                                                       params: params
                                                                                                   httpMethod: @"GET"];
    
    [networkOperation addJSONCompletionHandler: ^(NSDictionary *dictionary)
     {
         BOOL registryResultOk = [self.registry registerCoverArtFromDictionary: dictionary
                                                                 forUserUpload: NO];
         
         if (!registryResultOk)
             return;
         
         completionBlock(dictionary);
         
     } errorHandler: ^(NSError* error) {
         
         DebugLog(@"API request failed");
         
     }];
    
    [self enqueueOperation: networkOperation];
}


- (void) updateCoverArtOnCompletion: (MKNKJSONCompleteBlock) completionBlock
                            onError: (MKNKErrorBlock) errorBlock
{
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: kAPIGetCoverArt
                                                                                                       params: [self getLocalParam]];
    
    [networkOperation addJSONCompletionHandler: ^(NSDictionary *dictionary)
    {
        BOOL registryResultOk = [self.registry registerCoverArtFromDictionary: dictionary
                                                                forUserUpload: NO];
        
        if (!registryResultOk)
            return;
        
        completionBlock(dictionary);
        
    } errorHandler: ^(NSError* error) {
        
        DebugLog(@"API request failed");
    }];
    
    [self enqueueOperation: networkOperation];
}




- (void) updateChannel: (NSString *) resourceURL
     completionHandler: (MKNKUserSuccessBlock) completionBlock
          errorHandler: (MKNKUserErrorBlock) errorBlock
{
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithURLString: resourceURL
                                                                                                           params: nil];
    
    [self addCommonHandlerToNetworkOperation: networkOperation
                           completionHandler: completionBlock
                                errorHandler: errorBlock];
    
    [self enqueueOperation: networkOperation];
    
}


- (void) updateChannelsScreenForCategory: (NSString*) categoryId
                                forRange: (NSRange) range
                           ignoringCache: (BOOL) ignore
                            onCompletion: (MKNKJSONCompleteBlock) completeBlock
                                 onError: (MKNKJSONErrorBlock) errorBlock
{
    NSMutableDictionary* tempParameters = [NSMutableDictionary dictionary];
    
    [tempParameters setObject: [NSString stringWithFormat: @"%i", range.location - 1]
                       forKey: @"start"]; // compensate for 0 indexed
    
    [tempParameters setObject: [NSString stringWithFormat: @"%i", range.length]
                       forKey: @"size"];
    
    if (![categoryId isEqualToString: @"all"])
    {
        [tempParameters setObject: categoryId
                           forKey: @"category"];
    }

    NSDictionary* parameters = [self getLocalParamWithParams: tempParameters];

    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject*)[self operationWithPath: kAPIPopularChannels
                                                     params: parameters];
    
    networkOperation.ignoreCachedResponse = ignore;
    
    [networkOperation addJSONCompletionHandler: ^(NSDictionary *dictionary){
        completeBlock(dictionary);
    } errorHandler: ^(NSError* error) {
        errorBlock(@{@"network_error":@"Engine Failed to Load Channels"});
    }];
    
    [self enqueueOperation: networkOperation];
}


#pragma mark - Search

- (void) searchVideosForTerm: (NSString*)searchTerm
                     inRange: (NSRange)range
                  onComplete: (MKNKSearchSuccessBlock)completeBlock
{
    if (searchTerm == nil || [searchTerm isEqualToString:@""])
        return;
    
    NSMutableDictionary* tempParameters = [NSMutableDictionary dictionary];
    
    [tempParameters setObject:searchTerm forKey: @"q"];
    
    [tempParameters setObject: [NSString stringWithFormat: @"%i", range.location]
                       forKey: @"start"];
    
    [tempParameters setObject: [NSString stringWithFormat: @"%i", range.length]
                       forKey: @"size"];
    
    [tempParameters addEntriesFromDictionary: [self getLocalParam]];
    
    NSDictionary* parameters = [NSDictionary dictionaryWithDictionary: tempParameters];
    
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject*)[self operationWithPath: kAPISearchVideos
                                                     params: parameters];
    
    [networkOperation addJSONCompletionHandler: ^(NSDictionary *dictionary) {
        
        int itemsCount = 0;
        
        if(!dictionary)
            return;
        
        NSNumber *totalNumber = (NSNumber*)[[dictionary objectForKey: @"videos"] objectForKey:@"total"];
        if (totalNumber && [totalNumber isKindOfClass: [NSNumber class]])
            itemsCount = totalNumber.intValue;
        
        BOOL registryResultOk = [self.searchRegistry registerVideosFromDictionary:dictionary];
        if (!registryResultOk)
            return;
        
        completeBlock(itemsCount);
        
    } errorHandler:^(NSError* error) {
        DebugLog(@"Update Videos Screens Request Failed");
    }];
    
    
    [self enqueueOperation: networkOperation];
}


- (void) searchChannelsForTerm: (NSString*)searchTerm
                      andRange: (NSRange)range
                    onComplete: (MKNKSearchSuccessBlock)completeBlock
{
    if (searchTerm == nil || [searchTerm isEqualToString:@""])
        return;

    NSMutableDictionary* tempParameters = [NSMutableDictionary dictionary];
    
    [tempParameters setObject:searchTerm forKey:@"q"];
    
    [tempParameters setObject: [NSString stringWithFormat: @"%i", range.location]
                       forKey:@"start"];
    
    [tempParameters setObject: [NSString stringWithFormat: @"%i", range.length]
                       forKey: @"size"];
    
    [tempParameters addEntriesFromDictionary: [self getLocalParam]];
    
    
    NSDictionary* parameters = [NSDictionary dictionaryWithDictionary: tempParameters];
    
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject*)[self operationWithPath:kAPISearchChannels params:parameters];
    
    [networkOperation addJSONCompletionHandler: ^(NSDictionary *dictionary) {
        
        
        int itemsCount = 0;
        
        if (!dictionary)
            return;
        
        NSNumber *totalNumber = (NSNumber*)dictionary[@"channels"][@"total"];
        
        if (totalNumber && [totalNumber isKindOfClass: [NSNumber class]])
        {
            itemsCount = totalNumber.intValue;
        }
        
        BOOL registryResultOk = [self.searchRegistry registerChannelsFromDictionary: dictionary];
        
        if (!registryResultOk)
            return;
        
        completeBlock(itemsCount);
        
        
    } errorHandler:^(NSError* error) {
        DebugLog(@"Update Videos Screens Request Failed");
    }];
    
    
    [self enqueueOperation: networkOperation];
}


#pragma mark - Autocomplete

- (void) getAutocompleteForHint: (NSString*)hint
                    forResource: (EntityType)entityType
                   withComplete: (MKNKAutocompleteProcessBlock) completionBlock
                       andError: (MKNKErrorBlock) errorBlock
{
    if (!hint) return;
    
    // Register the class to be used for this operation only
    
    [self registerOperationSubclass: [SYNNetworkOperationJsonObjectParse class]];
    
    NSDictionary* parameters = [self getLocalParamWithParams: [NSDictionary dictionaryWithObject: hint
                                                                                          forKey: @"q"]];
    
    NSString* apiForEntity;
    if(entityType == EntityTypeChannel)
        apiForEntity = kAPICompleteChannels;
    else if(entityType == EntityTypeVideo)
        apiForEntity = kAPICompleteVideos;
    else
        return; // do not accept any unknown type
    
    SYNNetworkOperationJsonObjectParse *networkOperation =
    (SYNNetworkOperationJsonObjectParse*)[self operationWithPath: apiForEntity
                                                          params: parameters];
    
    [networkOperation addJSONCompletionHandler: ^(NSArray *array) {
        completionBlock(array);
    } errorHandler: errorBlock];
    
    [self enqueueOperation: networkOperation];
    
    // Go back to the original operation class
    
    [self registerOperationSubclass:[SYNNetworkOperationJsonObject class]];
    
}


#pragma User Data


- (void) channelOwnerDataForChannelOwner: (ChannelOwner*) channelOwner
                              onComplete: (MKNKUserSuccessBlock) completeBlock
                                 onError: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : channelOwner.uniqueId};
    
    // same as for User
    NSString *apiString = [kAPIGetUserDetails stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: [self getLocalParam]];
    
    [networkOperation addJSONCompletionHandler: ^(id dictionary) {
        
        NSString* possibleError = dictionary[@"error"];
        if(possibleError)
        {
            errorBlock(@{@"error":possibleError});
            return;
        }

        completeBlock(dictionary);

     } errorHandler: ^(NSError* error) {
         errorBlock(error);
     }];
    
    [self enqueueOperation: networkOperation];
}


- (void) channelOwnerSubscriptionsForOwner: (ChannelOwner*) channelOwner
                                  forRange: (NSRange)range
                         completionHandler: (MKNKUserSuccessBlock) completionBlock
                              errorHandler: (MKNKUserErrorBlock) errorBlock
{
    NSDictionary *apiSubstitutionDictionary = @{@"USERID" : channelOwner.uniqueId};
    
    NSDictionary *params = [self paramsForStart: range.location
                                           size: range.length];
    
    
    
    // we are not using the subscriptions_url returned from user info data but using a std one.
    NSString *apiString = [kAPIGetUserSubscriptions stringByReplacingOccurrencesOfStrings: apiSubstitutionDictionary];
    
    
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithPath: apiString
                                                                                                       params: params];
    
    [networkOperation addJSONCompletionHandler: ^(id dictionary) {
        
        if(!dictionary)
        {
            errorBlock(dictionary);
            return;
        }
        
        completionBlock(dictionary);
        
    } errorHandler:^(NSError *error) {
        errorBlock(error);
    }];

    [self enqueueOperation: networkOperation];
}

@end
