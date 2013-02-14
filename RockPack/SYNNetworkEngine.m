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
        
        
        
        // This is where the magic occurs
        // Create our own ManagedObjectContext with NSConfinementConcurrencyType as suggested in the WWDC2011 What's new in CoreData video
        self.appDelegate = UIApplication.sharedApplication.delegate;
        self.importManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSConfinementConcurrencyType];
        self.importManagedObjectContext.parentContext = self.appDelegate.mainManagedObjectContext;
        
        // Cache frequently used vars
        self.videoInstanceEntity = [NSEntityDescription entityForName: @"VideoInstance"
                                               inManagedObjectContext: self.importManagedObjectContext];
        
        self.channelEntity = [NSEntityDescription entityForName: @"Channel"
                                         inManagedObjectContext: self.importManagedObjectContext];
        
        self.registry = [[SYNRegistry alloc] initWithManagedObjectContext:nil];
    }

    return self;
}


#pragma mark - Utility Methods


- (void) JSONObjectForPath: (NSString *) path
           completionBlock: (JSONResponseBlock) completionBlock
                errorBlock: (MKNKErrorBlock) errorBlock
{
    // Append additional parameters
    path = [NSString stringWithFormat: @"%@?locale=%@", path, self.localeString];
    
    MKNetworkOperation *networkOperation = [self operationWithPath: path];
    
    [networkOperation addCompletionHandler: ^(MKNetworkOperation *completedOperation)
    {
        [completedOperation responseJSONWithCompletionHandler: ^(id jsonObject)
        {
          completionBlock(jsonObject);
        }];
    }
    errorHandler: ^(MKNetworkOperation *errorOp, NSError* error)
    {
        errorBlock(error);
    }];
    
    [self enqueueOperation: networkOperation];
}






- (void) JSONObjectForURLString: (NSString *) URLString
                completionBlock: (JSONResponseBlock) completionBlock
                     errorBlock: (MKNKErrorBlock) errorBlock
{
    MKNetworkOperation *networkOperation = [self operationWithURLString: URLString];
    
    [networkOperation addCompletionHandler: ^(MKNetworkOperation *completedOperation)
     {
         [completedOperation responseJSONWithCompletionHandler: ^(id jsonObject)
          {
              completionBlock(jsonObject);
          }];
     }
     errorHandler: ^(MKNetworkOperation *errorOp, NSError* error)
     {
         errorBlock(error);
     }];
    
    [self enqueueOperation: networkOperation];
}




#pragma mark - Main Update Calls


- (void) updateCategories
{
    
    NSString *path = @"ws/categories/";
    
    [self JSONObjectForPath:path completionBlock: ^(NSDictionary *dictionary) {
        
         if (dictionary)
         {
             [self.registry registerCategoriesFromDictionary:dictionary];
         }
     }
                 errorBlock:^(NSError* error)
     {
         AssertOrLog(@"API request failed");
     }];
}







- (void) updateVideoInstancesWithURL: (NSString *) apiURL
                           andViewId: (NSString *) viewId
                        onCompletion: (MKNKVoidBlock) completionBlock
                             onError: (MKNKErrorBlock) errorBlock
{

    [self JSONObjectForPath: apiURL
            completionBlock: ^(NSDictionary *dictionary)
     {
         if (dictionary)
         {
             BOOL registryResultOk = [self.registry registerVideoInstancesFromDictionary:dictionary forViewId:viewId];
             if (registryResultOk)
             {
                 [self.appDelegate saveContext: TRUE];
                 
                 if (completionBlock)
                 {
                     completionBlock();
                 }
             }
                
             else
             {
                 AssertOrLog(@"Not a dictionary");
             }
         }
     }
                 errorBlock: ^(NSError* error)
     {
         if (errorBlock)
         {
             errorBlock(error);
         }
         AssertOrLog(@"API request failed");
     }];
}


- (void) updateHomeScreenOnCompletion: (MKNKVoidBlock) completionBlock
                              onError: (MKNKErrorBlock) errorBlock
{
    // TODO: We need to replace USERID with actual userId ASAP
    
    // Patch the USERID into the path
    NSString *apiURL = [NSString stringWithFormat: kAPIRecentlyAddedVideoInSubscribedChannelsForUser, @"USERID"];

    [self updateVideoInstancesWithURL: apiURL
                            andViewId: @"Home"
                         onCompletion: completionBlock
                              onError: errorBlock];
}

- (void) updateVideosScreen
{
    [self updateVideoInstancesWithURL: kAPIPopularVideos
                            andViewId: @"Videos"
                         onCompletion: nil
                              onError: nil];
}


- (void) updateChannel: (NSString *) resourceURL
{
    [self JSONObjectForURLString: resourceURL
                 completionBlock: ^(NSDictionary *dictionary)
     {
         
         if (dictionary && [dictionary isKindOfClass: [NSDictionary class]])
         {
             [Channel instanceFromDictionary: dictionary
                   usingManagedObjectContext: self.importManagedObjectContext
                           ignoringObjectTypes: kIgnoreNothing
                                   andViewId: @"Channels"];

             NSError *error = nil;
             
             // Merge local context into main context
             if (![self.importManagedObjectContext save: &error])
             {
                 NSArray* detailedErrors = [[error userInfo] objectForKey: NSDetailedErrorsKey];
                 
                 if ([detailedErrors count] > 0)
                 {
                     for(NSError* detailedError in detailedErrors)
                     {
                         DebugLog(@" DetailedError: %@", [detailedError userInfo]);
                     }
                 }
             }
             
             // Save main context and save asynchronously into persistent database
             
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
    
    [self JSONObjectForPath: path
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
             // Get Data dictionary
             NSDictionary *channelsDictionary = [dictionary objectForKey: @"channels"];
             
             // Get Data, being cautious and checking to see that we do indeed have an 'Data' key and it does return a dictionary
             if (channelsDictionary && [channelsDictionary isKindOfClass: [NSDictionary class]])
             {
                 // Template for reading values from model (numbers, strings, dates and bools are the data types that we currently have)
                 NSArray *itemArray = [channelsDictionary objectForKey: @"items"];
                 
                 if ([itemArray isKindOfClass: [NSArray class]])
                 {
                     for (NSDictionary *itemDictionary in itemArray)
                     {
                         if ([itemDictionary isKindOfClass: [NSDictionary class]])
                         {
                             [Channel instanceFromDictionary: itemDictionary
                                   usingManagedObjectContext: self.importManagedObjectContext
                                         ignoringObjectTypes: kIgnoreNothing
                                                   andViewId: @"Channels"];
                         }
                     }
                 }
                 
                 NSError *error = nil;
                 
                 if (![self.importManagedObjectContext save: &error])
                 {
                     NSArray* detailedErrors = [[error userInfo] objectForKey: NSDetailedErrorsKey];
                     
                     if ([detailedErrors count] > 0)
                     {
                         for(NSError* detailedError in detailedErrors)
                         {
                             DebugLog(@" DetailedError: %@", [detailedError userInfo]);
                         }
                     }
                 }
                 
                 [self.appDelegate saveContext: TRUE];
                 
//                 [[NSNotificationCenter defaultCenter] postNotificationName: kDataUpdated
//                                                                     object: nil];
             }
             else
             {
                 AssertOrLog(@"Not a dictionary");
             }
         }
     }
                 errorBlock: ^(NSError* error)
     {
         NSLog(@"API request failed");
     }];
}

@end
