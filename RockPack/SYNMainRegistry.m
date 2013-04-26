//
//  SYNRegistry.m
//  rockpack
//
//  Created by Michael Michailidis on 14/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "Category.h"
#import "Channel.h"
#import "ChannelCover.h"
#import "NSDictionary+Validation.h"
#import "SYNAppDelegate.h"
#import "SYNMainRegistry.h"
#import "VideoInstance.h"
#import "AppConstants.h"
#import <CoreData/CoreData.h>


@interface SYNMainRegistry ()

@property (nonatomic, strong) NSEntityDescription *channelEntity;
@property (nonatomic, strong) NSEntityDescription *videoInstanceEntity;
@property (nonatomic, strong) NSString *localeString;

@end

@implementation SYNMainRegistry

#pragma mark - Update Data Methods

- (BOOL) registerUserFromDictionary: (NSDictionary*) dictionary
{
    // == Check for Validity == //
    if (!dictionary || ![dictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    User* newUser = [User instanceFromDictionary: dictionary
                       usingManagedObjectContext: importManagedObjectContext];
    
    if(!newUser)
        return NO;
    
    newUser.current = @(YES);
    
    BOOL saveResult = [self saveImportContext];
    if(!saveResult)
        return NO;
    
    [appDelegate saveContext: TRUE];
    
    
    return YES;
}


- (BOOL) registerSubscriptionsForCurrentUserFromDictionary: (NSDictionary*) dictionary
{
    // == Check for Validity == //
    if (!dictionary || ![dictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    User* currentUser = appDelegate.currentUser;
    
    if(!currentUser)
        return NO;
    
    NSDictionary* channeslDictionary = [dictionary objectForKey: @"channels"];
    if(!channeslDictionary)
        return NO;
    
    NSArray* itemsArray = [channeslDictionary objectForKey: @"items"];
    if(!itemsArray)
        return NO;
    
    for (NSDictionary* subscriptionChannel in itemsArray)
    {
        Channel* channel = [Channel subscriberInstanceFromDictionary: subscriptionChannel
                                           usingManagedObjectContext: appDelegate.mainManagedObjectContext
                                                           andViewId: kProfileViewId];
        
        if (!channel) continue;
        
        [currentUser addSubscriptionsObject: channel];
        
    }
    
    BOOL saveResult = [self saveImportContext];
    if(!saveResult)
        return NO;
    
    [appDelegate saveContext: TRUE];
    
    return YES;
}


- (BOOL) registerCategoriesFromDictionary: (NSDictionary*) dictionary
{
    // == Check for Validity == //
    NSDictionary *categoriesDictionary = [dictionary objectForKey: @"categories"];
    if (!categoriesDictionary || ![categoriesDictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    NSArray *itemArray = [categoriesDictionary objectForKey: @"items"];
    
    if (![itemArray isKindOfClass: [NSArray class]])
        return NO;
    
    // We need to mark all of our existing Category objects corresponding to this viewId, just in case they are no longer required
    // and should be removed in a post-import cleanup
    NSArray *existingObjectsInViewId = [self markManagedObjectForPossibleDeletionWithEntityName: @"Category"
                                                                                      andViewId: nil
                                                                         inManagedObjectContext: importManagedObjectContext];
    
    // === Main Processing === //
    for (NSDictionary *categoryDictionary in itemArray)
        if ([categoryDictionary isKindOfClass: [NSDictionary class]])
            [Category instanceFromDictionary: categoryDictionary
                   usingManagedObjectContext: importManagedObjectContext];
    
    // == =============== == //
    
    // Now remove any Category objects that are no longer referenced in the import
    [self removeUnusedManagedObjects: existingObjectsInViewId
              inManagedObjectContext: importManagedObjectContext];
    
    // [[NSNotificationCenter defaultCenter] postNotificationName: kCategoriesUpdated object: nil];
    
    BOOL saveResult = [self saveImportContext];
    if(!saveResult)
        return NO;
    
    [appDelegate saveContext: TRUE];
    
    return YES;
}


- (BOOL) registerCoverArtFromDictionary: (NSDictionary*) dictionary
                             forViewId: (NSString *) viewId
{
    // == Check for Validity == //
    NSDictionary *channelCoverDictionary = [dictionary objectForKey: @"cover_art"];
    if (!channelCoverDictionary || ![channelCoverDictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    NSArray *itemArray = [channelCoverDictionary objectForKey: @"items"];
    
    if (![itemArray isKindOfClass: [NSArray class]])
        return NO;
    
    // We need to mark all of our existing Category objects corresponding to this viewId, just in case they are no longer required
    // and should be removed in a post-import cleanup
    NSArray *existingObjectsInViewId = [self markManagedObjectForPossibleDeletionWithEntityName: @"ChannelCover"
                                                                                      andViewId: viewId
                                                                         inManagedObjectContext: importManagedObjectContext];
    
    for (NSDictionary *individualChannelCoverDictionary in itemArray)
    {
        if ([individualChannelCoverDictionary isKindOfClass: [NSDictionary class]])
        {
            [ChannelCover instanceFromDictionary: individualChannelCoverDictionary
                       usingManagedObjectContext: importManagedObjectContext
                                       andViewId: viewId];
        }
    }
    
    // Now remove any Category objects that are no longer referenced in the import
    [self removeUnusedManagedObjects: existingObjectsInViewId
              inManagedObjectContext: importManagedObjectContext];

    BOOL saveResult = [self saveImportContext];
    
    if (!saveResult)
        return NO;
    
    [appDelegate saveContext: TRUE];
    
    return YES;
}


- (BOOL) registerVideoInstancesFromDictionary: (NSDictionary *) dictionary
                                    forViewId: (NSString*) viewId
                                  byAppending: (BOOL) append
{
    
    // == Check for Validity == //
    
    NSDictionary *videosDictionary = [dictionary objectForKey: @"videos"];
    if (!videosDictionary || ![videosDictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    
    NSArray *itemArray = [videosDictionary objectForKey: @"items"];
    if (![itemArray isKindOfClass: [NSArray class]])
        return NO;
    
    // == =============== == //
    
    // We need to mark all of our existing VideoInstance objects corresponding to this viewId, just in case they are no longer required
    // and should be removed in a post-import cleanup
    NSArray *existingObjectsInViewId = [self markManagedObjectForPossibleDeletionWithEntityName: @"VideoInstance"
                                                                                      andViewId: viewId
                                                                         inManagedObjectContext: importManagedObjectContext];
    
    // === Main Processing === //
    
    for (NSDictionary *itemDictionary in itemArray)
        if ([itemDictionary isKindOfClass: [NSDictionary class]])
            [VideoInstance instanceFromDictionary: itemDictionary
                        usingManagedObjectContext: importManagedObjectContext
                              ignoringObjectTypes: kIgnoreNothing
                                        andViewId: viewId];
    
    // == =============== == //
    
    // Now remove any VideoInstance objects that are no longer referenced in the import
    [self removeUnusedManagedObjects: existingObjectsInViewId
              inManagedObjectContext: importManagedObjectContext];
    
    BOOL saveResult = [self saveImportContext];
    if(!saveResult)
        return NO;
    
    [appDelegate saveContext: TRUE];
    
    return YES;
}

-(BOOL)registerChannelFromDictionary:(NSDictionary*)dictionary
{
    
    // == Check for Validity == //
    
    if (!dictionary || ![dictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    // == =============== == //
    
    [Channel instanceFromDictionary: dictionary
          usingManagedObjectContext: importManagedObjectContext
                ignoringObjectTypes: kIgnoreNothing
                          andViewId: kChannelDetailsViewId];
    
    BOOL saveResult = [self saveImportContext];
    if(!saveResult)
        return NO;
    
    
    [appDelegate saveContext: TRUE];
    
    return YES;
}



- (BOOL) registerNewChannelScreensFromDictionary: (NSDictionary *) dictionary
                                   byAppending: (BOOL) append {
    
    
    // == Check for Validity == //
    
    NSDictionary *channelsDictionary = [dictionary objectForKey: @"channels"];
    if (!channelsDictionary || ![channelsDictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    NSArray *itemArray = [channelsDictionary objectForKey: @"items"];
    if (![itemArray isKindOfClass: [NSArray class]])
        return NO;
    
    if(itemArray.count == 0)
        return YES;
    
    
    
    // Query for existing objects
    
    NSFetchRequest *channelFetchRequest = [[NSFetchRequest alloc] init];
    [channelFetchRequest setEntity: [NSEntityDescription entityForName: @"Channel"
                                                inManagedObjectContext: importManagedObjectContext]];
    
    
    //NSDictionary *firstItem = [itemArray objectAtIndex:0];
    
    //NSString* heuristicCategoryId = [firstItem objectForKey:@"category"];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat: @"viewId == %@", kChannelsViewId];
    
    [channelFetchRequest setPredicate: predicate];
    
    
    NSError* error;
    NSArray *matchingChannelEntries = [importManagedObjectContext executeFetchRequest: channelFetchRequest
                                                                                error: &error];
    
    
    NSMutableDictionary* existingChannelsByIndex = [NSMutableDictionary dictionaryWithCapacity:matchingChannelEntries.count];
    
    for (Channel* existingChannel in matchingChannelEntries)
    {
        
        NSLog(@" - Channel: %@ (%@)", existingChannel.title, existingChannel.categoryId);
        [existingChannelsByIndex setObject:existingChannel forKey:existingChannel.uniqueId];
        ((AbstractCommon *)existingChannel).markedForDeletionValue = YES;
    }
    
    Channel* existingChannelMatch;
    for (NSDictionary *itemDictionary in itemArray)
    {
        
        NSString *uniqueId = [itemDictionary objectForKey: @"id"];
        if(!uniqueId)
            continue;
        
        if((existingChannelMatch = [existingChannelsByIndex objectForKey:uniqueId]))
        {
            //NSLog(@"Found (title:%@)", existingChannelMatch.title);
            ((AbstractCommon *)existingChannelMatch).markedForDeletionValue = NO;
            continue;
        }
            
        
        if ([itemDictionary isKindOfClass: [NSDictionary class]])
        {
            
            [Channel instanceFromDictionary: itemDictionary
                  usingManagedObjectContext: importManagedObjectContext
                        ignoringObjectTypes: kIgnoreStoredObjects
                                  andViewId: kChannelsViewId];
        }
            
    }
        
    


    if(!append)
    {
        
        [self removeUnusedManagedObjects: matchingChannelEntries
                  inManagedObjectContext: importManagedObjectContext];
        
    }
    
    
    BOOL saveResult = [self saveImportContext];
    if(!saveResult)
        return NO;
    
    [appDelegate saveContext: TRUE];
    
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
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"viewId == \"%@\"", viewId];
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
    if(!managedObjects)
        return;
    
    [managedObjects enumerateObjectsUsingBlock: ^(id managedObject, NSUInteger idx, BOOL *stop)
     {
         if (((AbstractCommon *)managedObject).markedForDeletionValue == TRUE)
         {
             [managedObjectContext deleteObject: (NSManagedObject *)managedObject];
             // DebugLog (@"Deleted NSManagedObject that is no longer used after import");
         }
     }];
}

@end
