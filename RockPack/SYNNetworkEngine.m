//
//  SYNNetworkEngine.m
//  rockpack
//
//  Created by Nick Banks on 10/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNNetworkEngine.h"
#import "Channel.h"
#import "SYNNetworkEngine.h"
#import "VideoInstance.h"
#import "Category.h"
#import "SYNMainRegistry.h"
#import "SYNSearchRegistry.h"
#import "SYNAppDelegate.h"
#import "AccessInfo.h"
#import "SYNNetworkOperationJsonObjectParse.h"
#import "SYNUserInfoRegistry.h"

#define kJSONParseError 110
#define kNetworkError   112

@interface SYNNetworkEngine ()

@property (nonatomic, strong) NSString *localeString;
@property (nonatomic, strong) NSEntityDescription *videoInstanceEntity;
@property (nonatomic, strong) NSEntityDescription *channelEntity;
@property (nonatomic, strong) NSManagedObjectContext *importManagedObjectContext;
@property (nonatomic, strong) SYNMainRegistry* registry;
@property (nonatomic, strong) SYNSearchRegistry* searchRegistry;
@property (nonatomic, strong) SYNUserInfoRegistry* userInfoRegistry;

@end

@implementation SYNNetworkEngine

- (id) initWithDefaultSettings
{
    
    if ((self = [super initWithHostName: kAPIHostName
                     customHeaderFields: @{@"x-client-identifier" : @"Rockpack iPad client"}]))
    {
        // Set our local string (i.e. en_GB, en_US or fr_FR)
        self.localeString = [(NSString*)CFBridgingRelease(CFLocaleCreateCanonicalLanguageIdentifierFromString(NULL, (CFStringRef)[NSLocale.autoupdatingCurrentLocale objectForKey: NSLocaleIdentifier])) lowercaseString];
        
        SYNAppDelegate* appDelegate = UIApplication.sharedApplication.delegate;
        
        self.registry = appDelegate.mainRegistry;
        
        self.searchRegistry = appDelegate.searchRegistry;
        
        self.userInfoRegistry = appDelegate.userRegistry;
        
        // This engine is about requesting JSON objects and uses the appropriate operation type
        [self registerOperationSubclass:[SYNNetworkOperationJsonObject class]];
        
        
        // We should register here for locale changes
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(localeDidChange)
                                                     name: NSCurrentLocaleDidChangeNotification
                                                   object: nil];
    }
    
    return self;
}


- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: NSCurrentLocaleDidChangeNotification
                                                  object: nil];
}

// If the locale changes, then we need to reset the CoreData DB
- (void) localeDidChange
{
    //SYNAppDelegate* appDelegate = UIApplication.sharedApplication.delegate;
//    [appDelegate resetCoreDataStack];
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
        if (!registryResultOk) {
            DebugLog(@"Update Videos Screens Request Failed");
            return;
        }
        
        
        
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
        if (!registryResultOk) {
            DebugLog(@"Update Channel Screens Request Failed");
            return;
        }
        
        
        
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
        if (!registryResultOk) {
            DebugLog(@"Update Channel Screens Request Failed");
            return;
        }
        
        
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


#pragma mark - Login Stuff

-(void)doSimpleLoginForUsername:(NSString*)username
                    forPassword:(NSString*)password
                   withComplete: (MKNKLoginCompleteBlock) completionBlock
                       andError: (MKNKUserErrorBlock) errorBlock
{
    
    NSDictionary* postLoginParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                                @"password", @"grant_type",
                                                username, @"username",
                                                password, @"password", nil];
    
    //NSDictionary* parameters = [self getLocalParamWithParams:postLoginParams];
    
    
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject*)[self operationWithURLString:kAPISecureLogin params:postLoginParams httpMethod:@"POST"];
    
    [networkOperation setUsername:kOAuth2ClientId password:@"" basicAuth:YES];
    
    [networkOperation addJSONCompletionHandler:^(NSDictionary *dictionary) {
        
        NSString* possibleError = [dictionary objectForKey:@"error"];
        if(possibleError) {
            errorBlock(dictionary);
            return;
        }
        
        
        BOOL registryResultOk = [self.userInfoRegistry registerAccessInfoFromDictionary:dictionary];
        if (!registryResultOk) {
            DebugLog(@"Access Token Info returned is wrong");
            errorBlock([NSError errorWithDomain:@"Call completed but token dictionary could not be read." code:0 userInfo:nil]);
            return;
        }
        
        AccessInfo* recentlyFetchedAccessInfo = self.userInfoRegistry.lastReceivedAccessInfoObject;
        
        completionBlock(recentlyFetchedAccessInfo);
        
    } errorHandler:^(NSError* error) {
        DebugLog(@"Update Access Info Request Failed");
        errorBlock(@{@"network_error": [NSString stringWithFormat:@"%@, Server responded with %i", error.domain, error.code]});
    }];
    
    [self enqueueOperation: networkOperation];
}

-(void)doFacebookLoginWithAccessToken:(NSString*)facebookAccessToken
                         withComplete: (MKNKLoginCompleteBlock) completionBlock
                             andError: (MKNKUserErrorBlock) errorBlock {
    
    NSDictionary* postLoginParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"facebook", @"external_system",
                                     facebookAccessToken, @"external_token",
                                     nil];
    
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject*)[self operationWithURLString:kAPISecureExternalLogin params:postLoginParams httpMethod:@"POST"];
    
    [networkOperation setUsername:kOAuth2ClientId password:@"" basicAuth:YES];
    
    [networkOperation addJSONCompletionHandler:^(NSDictionary *dictionary) {
        
        NSString* possibleError = [dictionary objectForKey:@"error"];
        if(possibleError) {
            errorBlock(dictionary);
            return;
        }
        
        
        BOOL registryResultOk = [self.userInfoRegistry registerAccessInfoFromDictionary:dictionary];
        if (!registryResultOk) {
            DebugLog(@"Access Token Info Could Not Be Registered in CoreData");
            errorBlock(@{@"parsing_error": @"registerAccessInfoFromDictionary: did not complete correctly"});
            return;
        }
        
        AccessInfo* recentlyFetchedAccessInfo = self.userInfoRegistry.lastReceivedAccessInfoObject;
        
        completionBlock(recentlyFetchedAccessInfo);
        
    } errorHandler:^(NSError* error) {
        DebugLog(@"Register Facebook Token with Server Failed");
        NSDictionary* customErrorDictionary = @{@"network_error": [NSString stringWithFormat:@"%@, Server responded with %i", error.domain, error.code]};
        errorBlock(customErrorDictionary);
    }];
    
    [self enqueueOperation: networkOperation];
}

-(void)registerUserWithData:(NSDictionary*)userData
               withComplete:(MKNKLoginCompleteBlock)completionBlock
                   andError:(MKNKUserErrorBlock)errorBlock {
    
    
    
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject*)[self operationWithURLString:kAPISecureRegister params:userData httpMethod:@"POST"];
    
    [networkOperation setUsername:kOAuth2ClientId password:@"" basicAuth:YES];
    [networkOperation addHeaders:@{@"Content-Type": @"application/json"}];
    networkOperation.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    
    
    [networkOperation addJSONCompletionHandler:^(NSDictionary *dictionary) {
        
        NSString* possibleError = [dictionary objectForKey:@"error"];
        if(possibleError) {
            errorBlock(dictionary);
            return;
        }
        
        BOOL registryResultOk = [self.userInfoRegistry registerAccessInfoFromDictionary:dictionary];
        if (!registryResultOk) {
            errorBlock(@{@"parsing_error": @"registerAccessInfoFromDictionary: did not complete correctly"});
            return;
        }
        
        AccessInfo* recentlyFetchedAccessInfo = self.userInfoRegistry.lastReceivedAccessInfoObject;
        
        completionBlock(recentlyFetchedAccessInfo);
        
        
    } errorHandler:^(NSError* error) {
        NSDictionary* customErrorDictionary = @{@"network_error": [NSString stringWithFormat:@"%@, Server responded with %i", error.domain, error.code]};
        errorBlock(customErrorDictionary);
    }];
    
    [self enqueueOperation: networkOperation];
    
    
    
}


-(void)retrieveUserFromAccessInfo:(AccessInfo*)accessInfo
               withComplete:(MKNKUserCompleteBlock)completionBlock
                   andError:(MKNKUserErrorBlock)errorBlock {
    
    
    
    SYNNetworkOperationJsonObject *networkOperation =
    (SYNNetworkOperationJsonObject*)[self operationWithURLString:accessInfo.resourceUrl];
    
    
    [networkOperation addHeaders:@{@"Authorization": [NSString stringWithFormat:@"Bearer %@", accessInfo.accessToken]}];
    
    
    
    [networkOperation addJSONCompletionHandler:^(NSDictionary *dictionary) {
        
        NSString* possibleError = [dictionary objectForKey:@"error"];
        if(possibleError)
        {
            
            errorBlock([dictionary objectForKey:@"form_errors"]);
            return;
        }
        
        BOOL registryResultOk = [self.userInfoRegistry registerAccessInfoFromDictionary:dictionary];
        if (!registryResultOk) {
            DebugLog(@"Access Token Info returned is wrong");
            errorBlock([NSError errorWithDomain:@"Call completed but token dictionary could not be read." code:0 userInfo:nil]);
            return;
        }
        
        User* recentylRegisteredUser = self.userInfoRegistry.lastRegisteredUserObject;
        
        completionBlock(recentylRegisteredUser);
        
        
    } errorHandler:^(NSError* error) {
        DebugLog(@"Update Access Info Request Failed");
        NSDictionary* customErrorDictionary = @{@"network_error": error};
        errorBlock(customErrorDictionary);
    }];
    
    [self enqueueOperation: networkOperation];
    
    
    
}

@end
