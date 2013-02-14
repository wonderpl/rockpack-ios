//
//  SYNRegistry.m
//  rockpack
//
//  Created by Michael Michailidis on 14/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNRegistry.h"
#import <CoreData/CoreData.h>

#import "SYNAppDelegate.h"
#import "Category.h"
#import "Channel.h"
#import "VideoInstance.h"


@interface SYNRegistry ()

@property (nonatomic, strong) NSString *localeString;
@property (nonatomic, strong) NSEntityDescription *videoInstanceEntity;
@property (nonatomic, strong) NSEntityDescription *channelEntity;
@property (nonatomic, strong) NSManagedObjectContext *importManagedObjectContext;
@property (nonatomic, strong) SYNAppDelegate *appDelegate;

-(BOOL)saveImportContext;

@end

@implementation SYNRegistry

-(id)initWithManagedObjectContext:(NSManagedObjectContext*)moc
{
    if (self = [super init])
    {
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
        
    }
    
    return self;
}


#pragma mark - Update Data Methods

-(BOOL)registerCategoriesFromDictionary:(NSDictionary*)dictionary
{
    // Get Root Object
    NSDictionary *categoriesDictionary = [dictionary objectForKey: @"categories"];
    
    
    if (categoriesDictionary && [categoriesDictionary isKindOfClass:[NSDictionary class]])
    {
        
        NSArray *itemArray = [categoriesDictionary objectForKey: @"items"];
        
        if ([itemArray isKindOfClass: [NSArray class]])
        {
            
            // === Main Processing === //
            for (NSDictionary *categoryDictionary in itemArray)
            {
                if ([categoryDictionary isKindOfClass: [NSDictionary class]])
                {
                    
                    
                    Category* category = [Category instanceFromDictionary: categoryDictionary usingManagedObjectContext: self.importManagedObjectContext];
                    
                    DebugLog(@"Found Category: %@\n", category);
                }
            }
            
            // [[NSNotificationCenter defaultCenter] postNotificationName: kCategoriesUpdated object: nil];
            
        }
        else
        {
            AssertOrLog(@"Not a dictionary");
            return NO;
        }
        
        
        BOOL saveResult = [self saveImportContext];
        if(!saveResult)
            return NO;
        
        
        
        
    }
    else
    {
        AssertOrLog(@"Not a dictionary");
        return NO;
    }
    
    
    return YES;
}


-(BOOL)registerVideoInstancesFromDictionary:(NSDictionary *)dictionary forViewId:(NSString*)viewId
{
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
                    [VideoInstance instanceFromDictionary: itemDictionary
                                usingManagedObjectContext: self.importManagedObjectContext
                                      ignoringObjectTypes: kIgnoreNothing
                                                andViewId: viewId];
                }
            }
        }
        else
        {
            AssertOrLog(@"No itemArray for videos");
            return NO;
        }
        
        BOOL saveResult = [self saveImportContext];
        if(!saveResult)
            return NO;
    }
    else
    {
        AssertOrLog(@"Not videos in dictionary");
        return NO;
    }
    
    return YES;
}

-(BOOL)registerChannelFromDictionary:(NSDictionary*)dictionary
{
    [Channel instanceFromDictionary: dictionary
          usingManagedObjectContext: self.importManagedObjectContext
                ignoringObjectTypes: kIgnoreNothing
                          andViewId: @"Channels"];
    
    BOOL saveResult = [self saveImportContext];
    if(!saveResult)
        return NO;
    
    return YES;
}

-(BOOL)registerChannelScreensFromDictionary:(NSDictionary *)dictionary
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
        else
        {
            AssertOrLog(@"items array not an array");
            return NO;
        }
        
        BOOL saveResult = [self saveImportContext];
        if(!saveResult)
            return NO;
        
        
    }
    else
    {
        AssertOrLog(@"Not videos in dictionary");
        return NO;
    }
    
    
    return YES;
}

#pragma mark - Context Management

-(BOOL)saveImportContext
{
    NSError* error;
    if (![self.importManagedObjectContext save:&error])
    {
        NSArray* detailedErrors = [[error userInfo] objectForKey: NSDetailedErrorsKey];
        
        if ([detailedErrors count] > 0)
        {
            for(NSError* detailedError in detailedErrors)
            {
                DebugLog(@" DetailedError: %@", [detailedError userInfo]);
            }
        }
        return NO;
    }
    return YES;
}

@end
