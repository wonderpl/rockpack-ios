//
//  SYNRegistry.m
//  rockpack
//
//  Created by Michael Michailidis on 14/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "Category.h"
#import "Channel.h"
#import "NSDictionary+Validation.h"
#import "SYNAppDelegate.h"
#import "SYNRegistry.h"
#import "VideoInstance.h"
#import <CoreData/CoreData.h>

#define kChannelsViewId @"Channels"

@interface SYNRegistry ()

@property (nonatomic, strong) NSEntityDescription *channelEntity;
@property (nonatomic, strong) NSEntityDescription *videoInstanceEntity;
@property (nonatomic, strong) NSManagedObjectContext *importManagedObjectContext;
@property (nonatomic, strong) NSString *localeString;
@property (nonatomic, strong) SYNAppDelegate *appDelegate;

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
            // We need to mark all of our existing Category objects corresponding to this viewId, just in case they are no longer required
            // and should be removed in a post-import cleanup
            NSArray *existingObjectsInViewId = [self markManagedObjectForPossibleDeletionWithEntityName: @"Category"
                                                                                              andViewId: nil
                                                                                 inManagedObjectContext: self.importManagedObjectContext];
            
            // === Main Processing === //
            for (NSDictionary *categoryDictionary in itemArray)
            {
                if ([categoryDictionary isKindOfClass: [NSDictionary class]])
                {
                    Category* category = [Category instanceFromDictionary: categoryDictionary
                                                usingManagedObjectContext: self.importManagedObjectContext];
                    
                    DebugLog(@"Found Category: %@\n", category);
                }
            }
            
            // Now remove any Category objects that are no longer referenced in the import
            [self removeUnusedManagedObjects: existingObjectsInViewId
                      inManagedObjectContext: self.importManagedObjectContext];
            
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
            // We need to mark all of our existing VideoInstance objects corresponding to this viewId, just in case they are no longer required
            // and should be removed in a post-import cleanup
            NSArray *existingObjectsInViewId = [self markManagedObjectForPossibleDeletionWithEntityName: @"VideoInstance"
                                                                                              andViewId: viewId
                                                                                 inManagedObjectContext: self.importManagedObjectContext];
            
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
            
            // Now remove any VideoInstance objects that are no longer referenced in the import
            [self removeUnusedManagedObjects: existingObjectsInViewId
                      inManagedObjectContext: self.importManagedObjectContext];
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
            // We need to mark all of out existing objects corresponding to this viewId, just in case they are no longer required
            // and should be removed in a post-import cleanup
            NSArray *existingObjectsInViewId = [self markManagedObjectForPossibleDeletionWithEntityName: @"Channel"
                                                                                              andViewId: kChannelsViewId
                                                                                 inManagedObjectContext: self.importManagedObjectContext];
            
            for (NSDictionary *itemDictionary in itemArray)
            {
                if ([itemDictionary isKindOfClass: [NSDictionary class]])
                {
                    [Channel instanceFromDictionary: itemDictionary
                          usingManagedObjectContext: self.importManagedObjectContext
                                ignoringObjectTypes: kIgnoreNothing
                                          andViewId: kChannelsViewId];
                }
            }
            
            // Now remove any objects that are no longer referenced in the import
            [self removeUnusedManagedObjects: existingObjectsInViewId
                      inManagedObjectContext: self.importManagedObjectContext];
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


#pragma mark - Database garbage collection

// Before we start adding objects to the import context for a particular viewId, mark them all for possible deletion.
// We will unmark them if any of them are re-used by the import. All new objects are created with this marked for deletion flag already false
- (NSArray *) markManagedObjectForPossibleDeletionWithEntityName: (NSString *) entityName
                                                       andViewId: (NSString *) viewId
                                          inManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    // ARC based compiler now inits all local vars to nil by default
    NSError *error;
    
    // Create an entity description based on the name passed in
    NSEntityDescription *entityToMark = [NSEntityDescription entityForName: entityName
                                                    inManagedObjectContext: managedObjectContext];
    
    NSFetchRequest *entityFetchRequest = [[NSFetchRequest alloc] init];
    [entityFetchRequest setEntity: entityToMark];
    
    // Only use the viewId as a predicate if we actually have one (makes no sense for categories)
    if (viewId)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"viewId == %@", viewId];
        [entityFetchRequest setPredicate: predicate];
    }

    NSArray *matchingCategoryInstanceEntries = [managedObjectContext executeFetchRequest: entityFetchRequest
                                                                                   error: &error];
    
    [matchingCategoryInstanceEntries enumerateObjectsUsingBlock: ^(id managedObject, NSUInteger idx, BOOL *stop)
     {
         ((AbstractCommon *)managedObject).markedForDeletionValue = TRUE;
     }];
    
    // Return the array of pre-existing objects, so that we don't have to perform another fetch for cleanup
    return matchingCategoryInstanceEntries;
}


// Iterate through all previously existing NSManaged objects that corresponded to a viewId and delete them if necessary
- (void) removeUnusedManagedObjects: (NSArray *) managedObjects
             inManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    [managedObjects enumerateObjectsUsingBlock: ^(id managedObject, NSUInteger idx, BOOL *stop)
     {
         if (((AbstractCommon *)managedObject).markedForDeletionValue == TRUE)
         {
             [managedObjectContext deleteObject: (NSManagedObject *)managedObject];
             DebugLog (@"Deleted NSManagedObject that is no longer used after import");
         }
     }];
}

@end
