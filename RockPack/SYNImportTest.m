//
//  SYNImportTest.m
//  rockpack
//
//  Created by Nick Banks on 15/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "SYNAppDelegate.h"
#import "SYNImportTest.h"
#import "SYNNetworkEngine.h"
#import "VideoInstance.h"

//[SYNImportTest importTest];

static NSManagedObjectContext *importManagedObjectContext;
static SYNNetworkEngine *networkEngine;

@implementation SYNImportTest

+ (void) importTest
{
    networkEngine = [[SYNNetworkEngine alloc] initWithDefaultSettings];
    
    NSString *path = [NSString stringWithFormat: kAPIRecentlyAddedVideoInSubscribedChannelsForUser, @"USERID"];
    
    [networkEngine JSONObjectForPath: path
    completionBlock: ^(NSDictionary *dictionary)
    {
     // This is where the magic occurs
     // Create our own ManagedObjectContext with NSConfinementConcurrencyType as suggested in the WWDC2011 What's new in CoreData video
     SYNAppDelegate *appDelegate = UIApplication.sharedApplication.delegate;
     importManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSConfinementConcurrencyType];
     importManagedObjectContext.parentContext = appDelegate.mainManagedObjectContext;
     
     if (dictionary)
     {
         // Get Data dictionary
         NSDictionary *videosDictionary = [dictionary objectForKey: @"videos"];
         
         // Get Data, being cautious and checking to see that we do indeed have an 'Data' key and it does return a dictionary
         if (videosDictionary && [videosDictionary isKindOfClass: [NSDictionary class]])
         {
             // Template for reading values from model (numbers, strings, dates and bools are the data types that we currently have)
             NSArray *itemArray = [videosDictionary objectForKey: @"items"];
             
             if ([itemArray isKindOfClass: [NSArray class]])
             {
                 for (NSDictionary *itemDictionary in itemArray)
                 {
                     if ([itemDictionary isKindOfClass: [NSDictionary class]])
                     {
                         VideoInstance *videoInstance =  [VideoInstance instanceFromDictionary: itemDictionary
                                                                     usingManagedObjectContext: importManagedObjectContext];
                         
                         // If we seem to have a valid object, then save
                         if (videoInstance != nil)
                         {
                             NSError *error = nil;
                             
                             if (![importManagedObjectContext save: &error])
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

                         }
                     }
                 }  
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
     AssertOrLog(@"API request failed");
    }];
}

@end
