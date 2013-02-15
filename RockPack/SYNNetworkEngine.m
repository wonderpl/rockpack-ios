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
#import "SYNNetworkOperationJsonObject.h"
#import "SYNRegistry.h"

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
    }

    return self;
}


#pragma mark - Utility Methods





- (void) JSONObjectForURLString: (NSString *) URLString
                 withParameters: (NSDictionary*)parameters
                completionBlock: (JSONResponseBlock) completionBlock
                     errorBlock: (MKNKErrorBlock) errorBlock {
    
    [self registerOperationSubclass:[SYNNetworkOperationJsonObject class]];
    SYNNetworkOperationJsonObject *networkOperation = (SYNNetworkOperationJsonObject*)[self operationWithURLString: URLString params:parameters];
    
    [networkOperation addJSONCompletionHandler:completionBlock errorHandler:errorBlock];
    
    
    [self enqueueOperation: networkOperation];
}







#pragma mark - Engine API

- (void) updateHomeScreenOnCompletion: (MKNKVoidBlock) completionBlock
                              onError: (MKNKErrorBlock) errorBlock
{
    // TODO: We need to replace USERID with actual userId ASAP
    // TODO: Figure out the reST parameters and format
    
    // Patch the USERID into the path
    NSString *apiURL = [NSString stringWithFormat: kAPIRecentlyAddedVideoInSubscribedChannelsForUser, @"USERID"];

    [self JSONObjectForURLString: [self getHostURLWithPath:apiURL]
             withParameters:@{}
            completionBlock: ^(NSDictionary *dictionary) {
         BOOL registryResultOk = [self.registry registerVideoInstancesFromDictionary:dictionary forViewId:@"Home"];
         if (registryResultOk)
         {
             if(errorBlock)
             {
                 NSError* notParsedError = [NSError errorWithDomain:@"Object not Parsed in Registry" code:1 userInfo:nil];
                 errorBlock(notParsedError);
             }
         }
         
         [self.appDelegate saveContext: TRUE];
         
         if (completionBlock)
         {
             completionBlock();
         }
         
         
     } errorBlock:errorBlock];
}


- (void) updateCategories
{

    
    [self JSONObjectForURLString:[self getHostURLWithPath:@"ws/categories/"]
            withParameters:@{}
            completionBlock: ^(NSDictionary *dictionary) {
        
        if (dictionary)
        {
            [self.registry registerCategoriesFromDictionary:dictionary];
        }
    } errorBlock:^(NSError* error) {
        AssertOrLog(@"API request failed");
    }];
}

- (void) updateVideosScreen
{
    
    
    [self JSONObjectForURLString:[self getHostURLWithPath: kAPIPopularVideos]
             withParameters:@{}
            completionBlock: ^(NSDictionary *dictionary)
     {
         BOOL registryResultOk = [self.registry registerVideoInstancesFromDictionary:dictionary forViewId:@"Videos"];
         if (!registryResultOk)
             return;
         
         [self.appDelegate saveContext: TRUE];
         
         
     } errorBlock:nil];
}


- (void) updateChannel: (NSString *) resourceURL
{
    
    
    [self JSONObjectForURLString:[self getHostURLWithPath:resourceURL]
                  withParameters: @{}
                 completionBlock: ^(NSDictionary *dictionary)
     {
         
         if (dictionary && [dictionary isKindOfClass: [NSDictionary class]])
         {
             
             BOOL registryResultOk = [self.registry registerChannelFromDictionary:dictionary];
             if (registryResultOk)
             {
                 
             }
             
             // TODO: I think that we need to work out how to save asynchronously
             [self.appDelegate saveContext: TRUE];
             
//             [[NSNotificationCenter defaultCenter] postNotificationName: kDataUpdated
//                                                                 object: nil];
         }
         else
         {
             AssertOrLog(@"Not a dictionary");
         }
     }
                 errorBlock: ^(NSError* error)
     {
         NSLog(@"API request failed");
     }];
}

- (void) updateChannelsScreen
{
    // TODO: Replace category with something sensible
    // Now add on the locale and category as query parameters
    //    NSString *path = [NSString stringWithFormat: @"%@?locale=%@&category=%@", kAPIPopularChannels, self.localeString, @"CATID"];
    NSString *path = kAPIPopularChannels;
    
    [self JSONObjectForURLString:[self getHostURLWithPath:path]
            withParameters: @{}
            completionBlock: ^(NSDictionary *dictionary)
     {
         
         
         NSError *error;
         
         // Now we need to see if this object already exists, and if so return it and if not create it
         NSFetchRequest *channelInstanceFetchRequest = [[NSFetchRequest alloc] init];
         [channelInstanceFetchRequest setEntity: self.channelEntity];
         
         NSArray *matchingChannelEntries = [self.importManagedObjectContext executeFetchRequest: channelInstanceFetchRequest
                                                                                     error: &error];
         NSLog (@"channel instances %@", matchingChannelEntries);
         
         
         
         if (dictionary)
         {
             BOOL registryResultOk = [self.registry registerChannelScreensFromDictionary:dictionary];
             if (registryResultOk)
             {
                 [self.appDelegate saveContext:TRUE];
                 
                 //                 [[NSNotificationCenter defaultCenter] postNotificationName: kDataUpdated
                 //                                                                     object: nil];
             }
             
         }
     } errorBlock: ^(NSError* error)
     {
         NSLog(@"API request failed");
     }];
}


#pragma mark - Utility Methods

-(NSString*)getHostURLWithPath:(NSString*)path
{
    return [NSString stringWithFormat:@"http://%@/%@", kAPIHostName, path];
}

-(NSDictionary*)getParametersWithLocaleFrom:(NSDictionary*)parameters
{
    
    NSMutableDictionary* dictionaryWithLocale = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    [dictionaryWithLocale setValue:self.localeString forKey:@"locale"];
    return dictionaryWithLocale;
}

@end
