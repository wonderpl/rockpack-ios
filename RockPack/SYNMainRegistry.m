//
//  SYNRegistry.m
//  rockpack
//
//  Created by Michael Michailidis on 14/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "Channel.h"
#import "ChannelCover.h"
#import "NSDictionary+Validation.h"
#import "SYNAppDelegate.h"
#import "SYNMainRegistry.h"
#import "VideoInstance.h"
#import "Genre.h"
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
    
    // dictionary also contains the set of user channels
    
    User* newUser = [User instanceFromDictionary: dictionary
                       usingManagedObjectContext: importManagedObjectContext
                             ignoringObjectTypes: kIgnoreNothing];
    
    if(!newUser)
        return NO;
    
    newUser.currentValue = YES;
    
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
        
        // must use the main context so as to be able to link it with the channel owner
        
        Channel* channel = [Channel instanceFromDictionary:subscriptionChannel
                                 usingManagedObjectContext:currentUser.managedObjectContext
                                       ignoringObjectTypes:kIgnoreNothing
                                                 andViewId:kProfileViewId];
        
        if (!channel)
            continue;
        
        channel.subscribedByUserValue = YES;
        
        [currentUser.subscriptionsSet addObject:channel];
        
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
    NSArray *existingObjectsInViewId = [self markManagedObjectForPossibleDeletionWithEntityName: @"Genre"
                                                                                      andViewId: nil
                                                                         inManagedObjectContext: importManagedObjectContext];
    
    // === Main Processing === //
    for (NSDictionary *categoryDictionary in itemArray)
        if ([categoryDictionary isKindOfClass: [NSDictionary class]])
            [Genre instanceFromDictionary: categoryDictionary
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
                                        forGenre: (Genre*) genre
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
    
    
    NSPredicate* notOwnedByUserPredicate = [NSPredicate predicateWithFormat:@"channelOwner.uniqueId != '%@'", appDelegate.currentUser.uniqueId];
    NSPredicate* genrePredicate;
    NSPredicate* finalPredicate;
    
    if(!genre)
    {
        finalPredicate = notOwnedByUserPredicate;
    }
    else
    {
        if([genre isKindOfClass:[Genre class]])
        {
            genrePredicate = [NSPredicate predicateWithFormat:@"categoryId IN %@", [genre getSubGenreIdArray]];
        }
        else
        {
            genrePredicate = [NSPredicate predicateWithFormat:@"categoryId == '%@'", genre.uniqueId];
        }
        
        finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[genrePredicate, notOwnedByUserPredicate]];
    
        
    }

    [channelFetchRequest setPredicate: finalPredicate];
    
    
    NSError* error;
    NSArray *matchingChannelEntries = [importManagedObjectContext executeFetchRequest: channelFetchRequest
                                                                                error: &error];
    
    
    NSMutableDictionary* existingChannelsByIndex = [NSMutableDictionary dictionaryWithCapacity:matchingChannelEntries.count];
    
    for (Channel* existingChannel in matchingChannelEntries)
    {
        
        // NSLog(@" - Channel: %@ (%@)", existingChannel.title, existingChannel.categoryId);
        [existingChannelsByIndex setObject:existingChannel forKey:existingChannel.uniqueId];
        existingChannel.markedForDeletionValue = YES;
        existingChannel.popularValue = NO;
    }
    
    
    for (NSDictionary *itemDictionary in itemArray)
    {
        
        NSString *uniqueId = [itemDictionary objectForKey: @"id"];
        if(!uniqueId)
            continue;
        
        Channel* channel;
        
        channel = [existingChannelsByIndex objectForKey:uniqueId];
        
        if(!channel)
        {
            channel = [Channel instanceFromDictionary: itemDictionary
                            usingManagedObjectContext: importManagedObjectContext
                                  ignoringObjectTypes: kIgnoreStoredObjects
                                            andViewId: kChannelsViewId];
            
            
        }
       
        
        channel.markedForDeletionValue = NO;
        
        if(!genre)
            channel.popularValue = YES;
        
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
