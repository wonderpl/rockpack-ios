//
//  SYNRegistry.m
//  rockpack
//
//  Created by Michael Michailidis on 14/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "Channel.h"
#import "CoverArt.h"
#import "NSDictionary+Validation.h"
#import "SYNAppDelegate.h"
#import "SYNMainRegistry.h"
#import "VideoInstance.h"
#import "Genre.h"
#import "AppConstants.h"
#import <CoreData/CoreData.h>
#import "VideoInstance.h"


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
                       usingManagedObjectContext: appDelegate.mainManagedObjectContext
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


- (BOOL) registerChannelOwnerFromDictionary: (NSDictionary*) dictionary
{
    // == Check for Validity == //
    if (!dictionary || ![dictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    // dictionary also contains the set of user channels
    
    ChannelOwner* channelOwner = [ChannelOwner instanceFromDictionary: dictionary
                                            usingManagedObjectContext: appDelegate.mainManagedObjectContext
                                                  ignoringObjectTypes: kIgnoreNothing];
    
    if (!channelOwner)
        return NO;
    
    
    [appDelegate saveContext: YES];
    
    
    return YES;
}


- (BOOL) registerSubscriptionsForCurrentUserFromDictionary: (NSDictionary*) dictionary
{
    // == Check for Validity == //
    if (!dictionary || ![dictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    User* currentUser = appDelegate.currentUser;
    
    if (!currentUser)
        return NO;
    
    NSDictionary* channeslDictionary = [dictionary objectForKey: @"channels"];
    if (!channeslDictionary)
        return NO;
    
    NSArray* itemsArray = [channeslDictionary objectForKey: @"items"];
    if (!itemsArray)
        return NO;
    
    
    for (NSDictionary* subscriptionChannel in itemsArray)
    {
        
        // must use the main context so as to be able to link it with the channel owner
        
        Channel* channel = [Channel instanceFromDictionary:subscriptionChannel
                                 usingManagedObjectContext:currentUser.managedObjectContext
                                       ignoringObjectTypes:kIgnoreNothing];
        
        if (!channel)
            continue;
        
        
        [currentUser addSubscriptionsObject:channel];
        
        
        
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
    
    if (itemArray.count == 0)
        return YES;
    
    
    // Query for existing objects
    NSFetchRequest *categoriesFetchRequest = [[NSFetchRequest alloc] init];
    [categoriesFetchRequest setEntity: [NSEntityDescription entityForName: @"Genre"
                                                   inManagedObjectContext: appDelegate.mainManagedObjectContext]];
    
    
    // must not fetch SubGenres
    categoriesFetchRequest.includesSubentities = NO;
    
    
    NSError* error;
    NSArray *existingCategories = [appDelegate.mainManagedObjectContext executeFetchRequest: categoriesFetchRequest
                                                                                          error: &error];
    
    NSMutableDictionary* existingCategoriesByIndex = [NSMutableDictionary dictionaryWithCapacity:existingCategories.count];
    
    for (Genre* existingCategory in existingCategories)
    {
        
        [existingCategoriesByIndex setObject:existingCategory forKey:existingCategory.uniqueId];
        
        existingCategory.markedForDeletionValue = YES; // if a real genre is passed - delete the old objects
    }
    

    for (NSDictionary *categoryDictionary in itemArray)
    {
        
        
        NSString *uniqueId = [categoryDictionary objectForKey: @"id"];
        if (!uniqueId)
            continue;
        
        Genre* genre;
        
        genre = [existingCategoriesByIndex objectForKey:uniqueId];
        
        if(!genre)
        {
            genre = [Genre instanceFromDictionary: categoryDictionary
                        usingManagedObjectContext: appDelegate.mainManagedObjectContext];
        }
        else
        {
            [genre setAttributesFromDictionary:categoryDictionary withId:uniqueId usingManagedObjectContext:appDelegate.mainManagedObjectContext];
        }
        
        genre.markedForDeletionValue = NO;
        
        genre.priority = [categoryDictionary objectForKey: @"priority"
                                              withDefault: [NSNumber numberWithInt: 0]];
        
        
        
    }
        
    
   
    
    [self removeUnusedManagedObjects: existingCategories
              inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    
    
    [appDelegate saveContext: TRUE];
    
    return YES;
}


- (BOOL) registerCoverArtFromDictionary: (NSDictionary*) dictionary
                          forUserUpload: (BOOL) userUpload
{
    // == Check for Validity == //
    NSDictionary *channelCoverDictionary = [dictionary objectForKey: @"cover_art"];
    if (!channelCoverDictionary || ![channelCoverDictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    NSArray *itemArray = [channelCoverDictionary objectForKey: @"items"];
    
    if (![itemArray isKindOfClass: [NSArray class]])
        return NO;
    
    for (NSDictionary *individualChannelCoverDictionary in itemArray)
    {
        if (![individualChannelCoverDictionary isKindOfClass: [NSDictionary class]])
            continue;
        
        [CoverArt instanceFromDictionary: individualChannelCoverDictionary
               usingManagedObjectContext: importManagedObjectContext
                           forUserUpload: userUpload]; 
    }

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
    
    if (itemArray.count == 0)
        return YES;
    
    
    NSFetchRequest *videoInstanceFetchRequest = [[NSFetchRequest alloc] init];
    [videoInstanceFetchRequest setEntity: [NSEntityDescription entityForName: @"VideoInstance"
                                                      inManagedObjectContext: appDelegate.mainManagedObjectContext]];
    
    NSError* error = nil;
    NSArray *matchingVideoInstanceEntries = [appDelegate.mainManagedObjectContext executeFetchRequest: videoInstanceFetchRequest
                                                                                                error: &error];
    
    NSMutableDictionary* existingVideosByIndex = [NSMutableDictionary dictionaryWithCapacity:matchingVideoInstanceEntries.count];
    
    // Organise videos by Id
    for (VideoInstance* existingVideo in matchingVideoInstanceEntries)
    {
        [existingVideosByIndex setObject:existingVideo forKey:existingVideo.uniqueId];
        
        // We need to mark all of our existing VideoInstance objects corresponding to this viewId, just in case they are no longer required
        // and should be removed in a post-import cleanup
        
        existingVideo.markedForDeletionValue = YES;
        
        existingVideo.freshValue = NO;
    }
    
    
    for (NSDictionary *itemDictionary in itemArray)
    {
        
        NSString *uniqueId = [itemDictionary objectForKey: @"id"];
        if(!uniqueId)
            continue;
        
        VideoInstance* video = [existingVideosByIndex objectForKey:uniqueId];
        
        if (!video)
        {
            // The video is not in the dictionary of existing videos
            // Create a new video object. kIgnoreStoredObjects makes sure no attempt is made to query first
            video = [VideoInstance instanceFromDictionary: itemDictionary
                                usingManagedObjectContext: appDelegate.mainManagedObjectContext
                                      ignoringObjectTypes: kIgnoreStoredObjects];
            
        }
        
        video.markedForDeletionValue = NO; // This video is in the dictionary and should not be deleted.
        
        video.freshValue = YES;
        
        video.position = [itemDictionary objectForKey: @"position"
                                          withDefault: [NSNumber numberWithInt: 0]];
    }    
    
    
    
    // Now remove any VideoInstance objects that are no longer referenced in the import
    [self removeUnusedManagedObjects: matchingVideoInstanceEntries
              inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    BOOL saveResult = [self saveImportContext];
    if(!saveResult)
        return NO;
    
    [appDelegate saveContext: TRUE];
    
    return YES;
}


- (BOOL) registerChannelFromDictionary: (NSDictionary*) dictionary
{
    // == Check for Validity == //
    if (!dictionary || ![dictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    // == =============== == //
    
    [Channel instanceFromDictionary: dictionary
          usingManagedObjectContext: appDelegate.mainManagedObjectContext
                ignoringObjectTypes: kIgnoreNothing];
    
    
    [appDelegate saveContext: TRUE];
    
    return YES;
}


- (BOOL) registerChannelsFromDictionary: (NSDictionary *) dictionary
                        forChannelOwner: (ChannelOwner*) channelOwner
                            byAppending: (BOOL) append
{
    // == Check for Validity == //
    if(!channelOwner)
        return NO;
    
    NSDictionary *channelsDictionary = [dictionary objectForKey: @"channels"];
    if (!channelsDictionary || ![channelsDictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    NSArray *itemArray = [channelsDictionary objectForKey: @"items"];
    if (![itemArray isKindOfClass: [NSArray class]])
        return NO;
    
    if (itemArray.count == 0)
        return YES;
    
    // Query for existing objects
    NSFetchRequest *channelFetchRequest = [[NSFetchRequest alloc] init];
    [channelFetchRequest setEntity: [NSEntityDescription entityForName: @"Channel"
                                                inManagedObjectContext: channelOwner.managedObjectContext]];
    
    NSPredicate* ownedByUserPredicate = [NSPredicate predicateWithFormat:@"channelOwner.uniqueId == %@", channelOwner.uniqueId];
    
    [channelFetchRequest setPredicate: ownedByUserPredicate];
    
    NSError* error;
    NSArray *matchingChannelEntries = [channelOwner.managedObjectContext executeFetchRequest: channelFetchRequest
                                                                                       error: &error];
    
    NSMutableDictionary* existingChannelsByIndex = [NSMutableDictionary dictionaryWithCapacity:matchingChannelEntries.count];
    
    for (Channel* existingChannel in matchingChannelEntries)
    {
        // NSLog(@" - Channel: %@ (%@)", existingChannel.title, existingChannel.categoryId);
        [existingChannelsByIndex setObject:existingChannel forKey:existingChannel.uniqueId];
        
        if (!append)
            existingChannel.markedForDeletionValue = YES; // if a real genre is passed - delete the old objects
    }
    
    for (NSDictionary *itemDictionary in itemArray)
    {
        
        NSString *uniqueId = [itemDictionary objectForKey: @"id"];
        if (!uniqueId)
            continue;
        
        Channel* channel;
        
        channel = [existingChannelsByIndex objectForKey:uniqueId];
        
        if (!channel)
        {
            channel = [Channel instanceFromDictionary: itemDictionary
                            usingManagedObjectContext: channelOwner.managedObjectContext
                                  ignoringObjectTypes: (kIgnoreStoredObjects | kIgnoreChannelOwnerObject)];
        }
        
        
        channel.markedForDeletionValue = NO;
        
        channel.position = [itemDictionary objectForKey: @"position"
                                            withDefault: [NSNumber numberWithInt: 0]];
        
        [channelOwner addChannelsObject:channel];
    }
    
    
    [self removeUnusedManagedObjects: matchingChannelEntries
              inManagedObjectContext: channelOwner.managedObjectContext];
    
    
    BOOL saveResult = [self saveImportContext];
    if (!saveResult)
        return NO;
    
    [appDelegate saveContext: TRUE];
    
    return YES;
}



- (BOOL) registerChannelsFromDictionary: (NSDictionary *) dictionary
                               forGenre: (Genre*) genre
                            byAppending: (BOOL) append
{
    // == Check for Validity == //
    NSDictionary *channelsDictionary = [dictionary objectForKey: @"channels"];
    if (!channelsDictionary || ![channelsDictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    NSArray *itemArray = [channelsDictionary objectForKey: @"items"];
    if (![itemArray isKindOfClass: [NSArray class]])
        return NO;
    
    // Query for existing objects
    NSFetchRequest *channelFetchRequest = [[NSFetchRequest alloc] init];
    [channelFetchRequest setEntity: [NSEntityDescription entityForName: @"Channel"
                                                inManagedObjectContext: appDelegate.mainManagedObjectContext]];
    
    NSPredicate* genrePredicate;
    
    if(genre)
    {
        if ([genre isMemberOfClass: [Genre class]])
        {
            genrePredicate = [NSPredicate predicateWithFormat: @"categoryId IN %@", [genre getSubGenreIdArray]];
        }
        else
        {
            genrePredicate = [NSPredicate predicateWithFormat: @"categoryId == %@", genre.uniqueId];
        }
    }

    [channelFetchRequest setPredicate: genrePredicate];
    
    
    NSError* error;
    NSArray *existingChannels = [appDelegate.mainManagedObjectContext executeFetchRequest: channelFetchRequest
                                                                                          error: &error];
    
    
    NSMutableDictionary* existingChannelsByIndex = [NSMutableDictionary dictionaryWithCapacity: existingChannels.count];
    
    for (Channel* existingChannel in existingChannels)
    {
        
        [existingChannelsByIndex setObject:existingChannel forKey:existingChannel.uniqueId];
        
        if(!append)
            existingChannel.popularValue = NO; // set all to NO
        
        // if we do not append and the channel is not owned by the user then delete //
        
        if(!append)
            existingChannel.markedForDeletionValue = YES;
        
        
        // set the old channels to not fresh and refresh on demand //
        if(!append)
            existingChannel.freshValue = NO;
           
    }
    
    
    
    // protect owned and subscribed channels from deletion //
    
    for (Channel* subscribedChannel in appDelegate.currentUser.subscriptions)
    {
        subscribedChannel.markedForDeletionValue = NO;
    }
    
    for (Channel* ownedChannels in appDelegate.currentUser.channels)
    {
        ownedChannels.markedForDeletionValue = NO;
    }
    
    

    for (NSDictionary *itemDictionary in itemArray)
    {
        NSString *uniqueId = [itemDictionary objectForKey: @"id"];
        if(!uniqueId)
            continue;
        
        Channel* channel;
        
        channel = [existingChannelsByIndex objectForKey: uniqueId];
        
        if (!channel)
        {
            channel = [Channel instanceFromDictionary: itemDictionary
                            usingManagedObjectContext: appDelegate.mainManagedObjectContext
                                  ignoringObjectTypes: kIgnoreStoredObjects];
        }

        channel.markedForDeletionValue = NO;
        
        channel.freshValue = YES;
        
        channel.position = [itemDictionary objectForKey: @"position"
                                            withDefault: [NSNumber numberWithInt: 0]];
        
        if (!genre) // nil is passed in case of the @"all" category which is popular
            channel.popularValue = YES;
    }
    
    [self removeUnusedManagedObjects: existingChannels
              inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
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
    
    [managedObjects enumerateObjectsUsingBlock: ^(AbstractCommon* managedObject, NSUInteger idx, BOOL *stop)
    {
         if (managedObject.markedForDeletionValue)
         {
             [managedObjectContext deleteObject:managedObject];
             // DebugLog (@"Deleted NSManagedObject that is no longer used after import");
         }
     }];
}

@end
