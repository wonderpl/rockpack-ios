//
//  SYNRegistry.m
//  rockpack
//
//  Created by Michael Michailidis on 14/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
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
#import "FeedItem.h"
#import "Video.h"


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
    
    // Pass viewId s.
    
    for (Channel* ch in newUser.channels)
        ch.viewId = kProfileViewId;
    
    newUser.viewId = kProfileViewId;
    
    [appDelegate saveContext: TRUE];
    
    return YES;
}



- (BOOL) registerSubscriptionsForCurrentUserFromDictionary: (NSDictionary*) dictionary
{
    
    // sets the view id
    
    [appDelegate.currentUser setSubscriptionsDictionary:dictionary];
    
    [appDelegate saveContext:YES];
    
    return YES;
    
}




- (BOOL) registerCategoriesFromDictionary: (NSDictionary*) dictionary
{
    // == Check for Validity == //
    NSDictionary *categoriesDictionary = dictionary[@"categories"];
    if (!categoriesDictionary || ![categoriesDictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    NSArray *itemArray = categoriesDictionary[@"items"];
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
        
        existingCategoriesByIndex[existingCategory.uniqueId] = existingCategory;
        
        existingCategory.markedForDeletionValue = YES; // if a real genre is passed - delete the old objects
    }
    

    for (NSDictionary *categoryDictionary in itemArray)
    {
        
        
        NSString *uniqueId = categoryDictionary[@"id"];
        if (!uniqueId)
            continue;
        
        Genre* genre;
        
        genre = existingCategoriesByIndex[uniqueId];
        
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
                                              withDefault: @0];
        
        
        
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
    NSDictionary *channelCoverDictionary = dictionary[@"cover_art"];
    if (!channelCoverDictionary || ![channelCoverDictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    NSArray *itemArray = channelCoverDictionary[@"items"];
    
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

//    BOOL saveResult = [self saveImportContext];
//    
//    if (!saveResult)
//        return NO;
    
    [appDelegate saveContext:NO];
    
    return YES;
}

#pragma mark - VideoInstances

- (BOOL) registerDataForSocialFeedFromItemsDictionary: (NSDictionary *) dictionary
                                          byAppending: (BOOL) append
{
    
    // == Check for Validity == //
    
    NSArray *itemsArray = dictionary[@"items"];
    if (!itemsArray || ![itemsArray isKindOfClass: [NSArray class]])
        return NO;
    
    NSDictionary *aggregationsDictionary = dictionary[@"aggregations"];
    if (!aggregationsDictionary || ![aggregationsDictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    FeedItem* aggregationFeedItem;
    
    NSMutableDictionary *aggregationItems = [NSMutableDictionary dictionaryWithCapacity:aggregationsDictionary.allKeys.count];
    
    
    
    // == Parse Items == //
    
    FeedItem* leafFeedItem;
    AbstractCommon* object;
    
    ChannelOwner* co;
    for (NSDictionary* itemDictionary in itemsArray)
    {
        // define type
        
        if(itemDictionary[@"video"]) // videoInstance object
        {
            object = [VideoInstance instanceFromDictionary:itemDictionary
                                 usingManagedObjectContext:importManagedObjectContext];
            
            if(!object)
                continue;
            
            co = ((VideoInstance*)object).channel.channelOwner;
            
            
        }
        else if (itemDictionary[@"cover"]) // channel object
        {
            object = [Channel instanceFromDictionary:itemDictionary
                           usingManagedObjectContext:importManagedObjectContext];
            
            if(!object)
                continue;
            
            co = ((Channel*)object).channelOwner;
        }
        
        
        
        object.viewId = kFeedViewId;
        
        leafFeedItem = [FeedItem instanceFromResource:object];
        
        if(!leafFeedItem)
            continue;
        
        // DebugLog(@"%@", leafFeedItem);
        
        // object has been created, see if it belongs to an aggregation
        
        NSString* aggregationIndex = itemDictionary[@"aggregation"] ? itemDictionary[@"aggregation"] : nil;
        if(!aggregationIndex || ![aggregationIndex isKindOfClass:[NSString class]]) // the item IS part of an aggregation
            continue;
        
        
        // if we have already created the FeedItem, use it
        aggregationFeedItem = aggregationItems[aggregationIndex];
        
        // else, create a new one
        if(!aggregationFeedItem)
        {
            NSDictionary* aggregationItemDictionary = aggregationsDictionary[aggregationIndex];
            aggregationFeedItem = [FeedItem instanceFromDictionary:aggregationItemDictionary
                                                            withId:aggregationIndex
                                         usingManagedObjectContext:importManagedObjectContext];
            
            
            if(!aggregationFeedItem)
                continue;
            
            aggregationFeedItem.viewId = kFeedViewId;
            
            
            [aggregationItems setObject:aggregationFeedItem forKey:aggregationIndex];
            
            // parse covers
            
            NSArray* coversArray = (NSArray*)(aggregationItemDictionary[@"covers"]);
            
            
            
            if(![coversArray isKindOfClass:[NSArray class]] || coversArray.count == 0)
                continue;
            
            NSMutableString* coverReferencesString = [[NSMutableString alloc] init];
            
            aggregationFeedItem.positionValue = ((NSNumber*)coversArray[0]).integerValue; // heuristically create position
            
            for (NSNumber* coverIndex in coversArray)
            {
                NSDictionary* itemDictionaryReference = itemsArray[coverIndex.integerValue];
                NSString* itemReferenceIdentifier = itemDictionaryReference[@"id"];
                if(!itemReferenceIdentifier)
                    continue;
                
                [coverReferencesString appendFormat:@"%@:", itemReferenceIdentifier];
            }
                
                
            [coverReferencesString deleteCharactersInRange:NSMakeRange(coverReferencesString.length - 1, 1)]; // delete last ':'
            
            aggregationFeedItem.coverIndexes = [NSString stringWithString:coverReferencesString];
            
            // DebugLog(@"*** %@", aggregationFeedItem.coverIndexes);
            
        }
        
        [aggregationFeedItem.feedItemsSet addObject:leafFeedItem];
        
    }
    
//    for (NSDictionary* d in aggregationItems) // traces keys
//    {
//        NSLog(@"%@", d);
//    }
    
    return YES;
}

// legacy parsing

- (BOOL) registerDataForFeedFromDictionary: (NSDictionary *) dictionary
                               byAppending: (BOOL) append
{
    // == Check for Validity == //
    NSDictionary *videosDictionary = dictionary[@"videos"];
    if (!videosDictionary || ![videosDictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    
    NSArray *itemArray = videosDictionary[@"items"];
    if (!itemArray || ![itemArray isKindOfClass: [NSArray class]])
        return NO;
    
    
    NSMutableDictionary* existingVideoInstancesByIndex = nil;
    NSArray *existingFeedVideoInstances = nil;
    
    NSError* error = nil;
    
    if(!append)
    {
        
        NSFetchRequest *videoInstanceFetchRequest = [[NSFetchRequest alloc] init];
        [videoInstanceFetchRequest setEntity: [NSEntityDescription entityForName: @"VideoInstance"
                                                          inManagedObjectContext: importManagedObjectContext]];
        
        NSPredicate* viewIdPredicate = [NSPredicate predicateWithFormat:@"viewId == %@ AND fresh == YES", kFeedViewId];
        
        
        videoInstanceFetchRequest.predicate = viewIdPredicate;
        
        existingFeedVideoInstances = [importManagedObjectContext executeFetchRequest: videoInstanceFetchRequest
                                                                                        error: &error];
        
        existingVideoInstancesByIndex = [NSMutableDictionary dictionaryWithCapacity:existingFeedVideoInstances.count];
        
        // Organise videos by Id
        for (VideoInstance* existingVideoInstance in existingFeedVideoInstances)
        {
            existingVideoInstancesByIndex[existingVideoInstance.uniqueId] = existingVideoInstance;
                
                
                existingVideoInstance.markedForDeletionValue = YES;
                existingVideoInstance.freshValue = NO;
                
                existingVideoInstance.channel.markedForDeletionValue = YES;
                existingVideoInstance.channel.freshValue = NO;
                
                existingVideoInstance.channel.channelOwner.markedForDeletionValue = YES;
            
        }
    }
    
    
    NSFetchRequest *videoFetchRequest = [[NSFetchRequest alloc] init];
    [videoFetchRequest setEntity: [NSEntityDescription entityForName: @"Video"
                                                      inManagedObjectContext: importManagedObjectContext]];

    NSMutableArray* videoIds = [NSMutableArray array];
    for (NSDictionary *itemDictionary in itemArray)
    {
        id uniqueId = [itemDictionary[@"video"] objectForKey:@"id"];
        if(uniqueId)
        {
            [videoIds addObject:uniqueId];
        }
    }
    
    NSPredicate* videoPredicate = [NSPredicate predicateWithFormat:@"uniqueId IN %@", videoIds];
    
    videoFetchRequest.predicate = videoPredicate;

    NSArray *existingVideos = [importManagedObjectContext executeFetchRequest: videoFetchRequest
                                                                        error: &error];
    
    
    
    for (NSDictionary *itemDictionary in itemArray)
    {
        NSString *uniqueId = itemDictionary[@"id"];
        if(!uniqueId)
            continue; 
        
        VideoInstance* videoInstance;
        videoInstance = existingVideoInstancesByIndex[uniqueId];
        
        if (!videoInstance)
        {
            // The video is not in the dictionary of existing videos
            // Create a new video object. kIgnoreStoredObjects makes sure no attempt is made to query first
            videoInstance = [VideoInstance instanceFromDictionary: itemDictionary
                                        usingManagedObjectContext: importManagedObjectContext existingVideos:existingVideos];
            
        }
        
        
        videoInstance.markedForDeletionValue = NO; // This video is in the dictionary and should not be deleted.
        
        
        
        videoInstance.position = [itemDictionary objectForKey: @"position"
                                                  withDefault: @(0)];
        
        videoInstance.viewId = kFeedViewId;
        videoInstance.freshValue = YES;
        
        videoInstance.channel.viewId = kFeedViewId;
        videoInstance.channel.freshValue = YES;
        
        videoInstance.channel.channelOwner.viewId = kFeedViewId;
        videoInstance.channel.channelOwner.freshValue = YES;
        
    }    
    
    int d = 0;
    
    if(!append)
    {
        for (VideoInstance* oldVideoInstance in existingFeedVideoInstances)
        {
            if(!oldVideoInstance.markedForDeletionValue)
                continue;
            
            // delete channels owners that are not used in the feed anymore
            if(!oldVideoInstance.channel.channelOwner.freshValue && oldVideoInstance.channel.channelOwner.markedForDeletionValue)
                [oldVideoInstance.channel.channelOwner.managedObjectContext deleteObject:oldVideoInstance.channel];
            
            // delete channels that are not used in the feed anymore
            if(!oldVideoInstance.channel.freshValue && oldVideoInstance.channel.markedForDeletionValue)
                [oldVideoInstance.channel.managedObjectContext deleteObject:oldVideoInstance.channel];
            
            [oldVideoInstance.managedObjectContext deleteObject:oldVideoInstance];
            
            d++;
        }
    }
    
    DebugLog(@"deleted feed objects: %i", d);
    
    
    
//    if(![self saveImportContext])
//        return NO;
    
    [appDelegate saveContext: NO];
    
    return YES;
}

#pragma mark - Channels




// Called by Main Channel page

- (BOOL) registerChannelsFromDictionary: (NSDictionary *) dictionary
                               forGenre: (Genre*) genre
                            byAppending: (BOOL) append
{
    // == Check for Validity == //
    NSDictionary *channelsDictionary = dictionary[@"channels"];
    if (!channelsDictionary || ![channelsDictionary isKindOfClass: [NSDictionary class]])
    {
        AssertOrLog(@"registerChannelsFromDictionary: unexpected JSON format");
        return NO;
    }
    
    NSArray *itemArray = channelsDictionary[@"items"];
    if (![itemArray isKindOfClass: [NSArray class]])
    {
        AssertOrLog(@"registerChannelsFromDictionary: unexpected JSON format");
        return NO;
    }

    // Query for existing objects
    NSFetchRequest *channelFetchRequest = [[NSFetchRequest alloc] init];
    [channelFetchRequest setEntity: [NSEntityDescription entityForName: @"Channel"
                                                inManagedObjectContext: importManagedObjectContext]];
    
    NSMutableArray* predicates = [[NSMutableArray alloc] initWithCapacity:2];
    
    
    [predicates addObject: [NSPredicate predicateWithFormat: @"viewId == %@", kChannelsViewId]];
    
    // get all channels that are in the DB, any of them can belong to the new "popular" list
    
    if (genre)
    {
        if ([genre isMemberOfClass: [Genre class]])
        {
            [predicates addObject: [NSPredicate predicateWithFormat: @"categoryId IN %@", [genre getSubGenreIdArray]]];
        }
        else
        {
            [predicates addObject: [NSPredicate predicateWithFormat: @"categoryId == %@", genre.uniqueId]];
        }
        
        [channelFetchRequest setPredicate: [NSCompoundPredicate andPredicateWithSubpredicates: predicates]];
    }
    else // if nil was passed (@"all") then only the first predicate is valid
    {
        [channelFetchRequest setPredicate: (NSPredicate*)predicates[0]];
    }
    

    
    // Get a list of existing channels in in a dictionary
    
    NSError* error;
    NSArray *existingChannels = [importManagedObjectContext executeFetchRequest: channelFetchRequest
                                                                          error: &error];
    
    NSMutableDictionary* existingChannelsByIndex = [NSMutableDictionary dictionaryWithCapacity: existingChannels.count];
    
    for (Channel* existingChannel in existingChannels)
    {
        
        existingChannelsByIndex[existingChannel.uniqueId] = existingChannel;
        
        if(!append)
            existingChannel.popularValue = NO; // set all to NO
        
        // if we do not append and the channel is not owned by the user then delete //
        
        if(!append)
            existingChannel.markedForDeletionValue = YES;
        
        
        // set the old channels to not fresh and refresh on demand //
        if(!append)
            existingChannel.freshValue = NO;
           
    }


    
    
    // Loop through the fresh data from the server
    
//    DebugLog(@"Logging %i items", itemArray.count);
    
    NSInteger items = 0;
    
    for (NSDictionary *itemDictionary in itemArray)
    {
        items++;
        NSString *uniqueId = itemDictionary[@"id"];
        if(!uniqueId)
            continue;
        
        Channel* channel;
        
        channel = existingChannelsByIndex[uniqueId];
        
        if (!channel)
        {
            channel = [Channel instanceFromDictionary: itemDictionary
                            usingManagedObjectContext: importManagedObjectContext
                                  ignoringObjectTypes: kIgnoreVideoInstanceObjects];
            
           
        }
        else
        {
            [existingChannelsByIndex removeObjectForKey: uniqueId];
        }

        channel.markedForDeletionValue = NO;
        
        channel.freshValue = YES;
        
        NSNumber* remotePosition = [itemDictionary objectForKey: @"position" withDefault: @0];
        if([remotePosition intValue] != channel.positionValue)
        {
            channel.position = remotePosition;
        }
        
        
        // nil is passed in case of the @"all" category which is popular
        
        if (!genre) 
            channel.popularValue = YES;
        
        channel.viewId = kChannelsViewId;
    }
    
    // delete old objects //
    
    for (id key in existingChannelsByIndex)
    {
        Channel* deleteCandidate = (Channel*)existingChannelsByIndex[key];
        
        if(deleteCandidate && deleteCandidate.markedForDeletionValue)
            [deleteCandidate.managedObjectContext deleteObject:deleteCandidate];
    }

    
    
//    BOOL saveResult = [self saveImportContext];
//    if(!saveResult)
//        return NO;
    
    [appDelegate saveContext:NO];
    
    
    
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
             
         }
     }];
}

@end
