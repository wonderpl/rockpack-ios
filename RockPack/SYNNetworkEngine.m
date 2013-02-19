//
//  SYNNetworkEngine.m
//  rockpack
//
//  Created by Nick Banks on 10/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNNetworkEngine.h"
#import "AppConstants.h"
#import "Channel.h"
#import "SYNAppDelegate.h"
#import "SYNNetworkEngine.h"
#import "VideoInstance.h"
#import "Category.h"
#import "SYNRegistry.h"

#define kJSONParseError 110
#define kNetworkError   112

@interface SYNNetworkEngine ()

@property (nonatomic, strong) NSString *localeString;
@property (nonatomic, strong) NSEntityDescription *videoInstanceEntity;
@property (nonatomic, strong) NSEntityDescription *channelEntity;
@property (nonatomic, strong) NSManagedObjectContext *importManagedObjectContext;
@property (nonatomic, strong) SYNAppDelegate *appDelegate;
@property (nonatomic, strong) SYNRegistry* registry;

@end

@implementation SYNNetworkEngine

- (id) initWithDefaultSettings
{
    
    if ((self = [super initWithHostName: kAPIHostName
                     customHeaderFields: @{@"x-client-identifier" : @"Rockpack iPad client"}]))
    {
        // Set our local string (i.e. en_GB, en_US or fr_FR)
        self.localeString =   [NSLocale.autoupdatingCurrentLocale objectForKey: NSLocaleIdentifier];
        
        
        self.appDelegate = UIApplication.sharedApplication.delegate;
        
        
        self.registry = [[SYNRegistry alloc] initWithManagedObjectContext:nil];
        
        // This engine is about requesting JSON objects and uses the appropriate operation type
        [self registerOperationSubclass:[SYNNetworkOperationJsonObject class]];
    }

    return self;
}





#pragma mark - Engine API

- (void) updateHomeScreenOnCompletion: (MKNKVoidBlock) completionBlock
                              onError: (MKNKErrorBlock) errorBlock
{
 
    
    
    // TODO: We need to replace USERID with actual userId ASAP
    // TODO: Figure out the REST parameters and format
    
    NSString *apiURL = [NSString stringWithFormat:kAPIRecentlyAddedVideoInSubscribedChannelsForUser, @"USERID"];
    
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject*)[self operationWithPath:apiURL params:[self getLocalParam]];
    
    
    [networkOperation addJSONCompletionHandler:^(NSDictionary *dictionary) {
        
        BOOL registryResultOk = [self.registry registerVideoInstancesFromDictionary:dictionary forViewId:@"Home"];
        if (!registryResultOk) {
            NSError* error = [NSError errorWithDomain:@"" code:kJSONParseError userInfo:nil];
            errorBlock(error);
            return;
        }
            
        completionBlock();
        
        [self.appDelegate saveContext: TRUE];
        
        
    } errorHandler:errorBlock];
    
    
    [self enqueueOperation:networkOperation];
    

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
    
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject*)[self operationWithPath:kAPIPopularVideos params:parameters];
    
    [networkOperation addJSONCompletionHandler:^(NSDictionary *dictionary) {
        
        BOOL registryResultOk = [self.registry registerVideoInstancesFromDictionary:dictionary forViewId:@"Videos"];
        if (!registryResultOk)
            return;
        
        [self.appDelegate saveContext: TRUE];
        
    } errorHandler:^(NSError* error) {
        DebugLog(@"Update Videos Screens Request Failed");
    }];
    
    
    [self enqueueOperation: networkOperation];
}


- (void) updateChannel: (NSString *) resourceURL
{
    
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject*)[self operationWithURLString:resourceURL params:[self getLocalParam]];
    
    [networkOperation addJSONCompletionHandler:^(NSDictionary *dictionary) {
        
        BOOL registryResultOk = [self.registry registerChannelFromDictionary:dictionary];
        if (!registryResultOk)
            return;
        
        // TODO: I think that we need to work out how to save asynchronously
        [self.appDelegate saveContext: TRUE];
        
    } errorHandler:^(NSError* error) {
        DebugLog(@"Update Channel Screens Request Failed");
    }];
    
    [self enqueueOperation: networkOperation];
    
}

- (void) updateChannelsScreenForCategory:(NSString*)categoryId
{
    
    
    NSDictionary* parameters;
    if([categoryId isEqualToString:@"all"]) 
        parameters = [self getLocalParam];
    else
        parameters = [self getLocalParamWithParams:[NSDictionary dictionaryWithObject:categoryId forKey:@"category"]];
    
    
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject*)[self operationWithPath:kAPIPopularChannels params: parameters];
    
    [networkOperation addJSONCompletionHandler:^(NSDictionary *dictionary) {

        
    BOOL registryResultOk = [self.registry registerChannelScreensFromDictionary:dictionary];
    if (!registryResultOk)
        return;
        
    [self.appDelegate saveContext:TRUE];
        
        
    } errorHandler:^(NSError* error) {
        DebugLog(@"Update Channel Screens Request Failed");
    }];
    
    [self enqueueOperation: networkOperation];
    
    
    
    
}


#pragma mark - Utility Methods

-(NSDictionary*)getLocalParam
{
    return [NSDictionary dictionaryWithObject:self.localeString forKey:@"locale"];
}

-(NSDictionary*)getLocalParamWithParams:(NSDictionary*)parameters
{
    
    NSMutableDictionary* dictionaryWithLocale = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [dictionaryWithLocale addEntriesFromDictionary:[self getLocalParam]];
    return dictionaryWithLocale;
}

@end
