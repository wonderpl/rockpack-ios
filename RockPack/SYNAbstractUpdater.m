//
//  SYNAbstractUpdater.m
//  rockpack
//
//  Created by Nick Banks on 09/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAbstractUpdater.h"
#import "AppConstants.h"
#import "DictionaryHelper.h"
#import "Channel.h"
#import "Video.h"
#import "VideoInstance.h"
#import "ChannelOwner.h"

@interface SYNAbstractUpdater()

#pragma mark -
#pragma mark Private Properties

@property (nonatomic, copy) SYNUpdaterResponseBlock completionBlock;

@property (nonatomic, retain) NSException *cancelledException;
@property (nonatomic, retain) NSException *communicationsException;
@property (nonatomic, retain) NSString *uniqueViewId;
@property (nonatomic, assign) int numItemsTotal;
@property (nonatomic, assign) int offset;
@property (nonatomic, assign) int batchSize;
@property (nonatomic, assign) BOOL firstTime;


@end

@implementation SYNAbstractUpdater

#pragma mark -
#pragma mark Object lifecycle

- (void) cancel
{
    DebugLog (@"__________Cancel called on operation %@", self);
    [super cancel];
}


// This is the initialisation method that sets the callback delegate and Twitter username and password and tweet
- (id) initWithCompletionBlock: (SYNUpdaterResponseBlock) completionBlock
                 uniqueViewId: (NSString *) uniqueViewId;
{
    if ((self = [super init]))
    {
        // Perform initialisation here
        if (response)
        {
            self.completionBlock = completionBlock;
        }
        
        self.uniqueViewId = uniqueViewId;
    }

    return self;
}


// This is the main entry point for the NSOperation
- (void) main
{
	[self updateObjectList: @"ACommonProperties"];
}


- (NSString *) queryURL
{
    return @"";
}


// No batching by default
- (int) defaultBatchSize
{
    return kDefaultBatchSize;
}



// Get the playlist for the venue

- (void) updateObjectList: (NSString *) entityName
{
	// Several functions use this to report errors
	NSError	*error = nil;
	NSURLResponse *response = nil;

    // Set up a default exception
    self.cancelledException = [NSException exceptionWithName: @"CancelledException"
                                                      reason: @"Operation cancelled"
                                                    userInfo: nil];
    
    self.communicationsException = [NSException exceptionWithName: @"CommunicationsException"
                                                           reason: @"Error talking to server"
                                                         userInfo: nil];
	
    // Set up a new managed object context with our existing persistent store (as created by our app delegate)
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
    
    // No undo manager
    [managedObjectContext setUndoManager: nil];
    
	@try
	{
		[managedObjectContext setPersistentStoreCoordinator: [(SecretDJAppDelegate *)[[UIApplication sharedApplication] delegate] persistentStoreCoordinator]];
		
		// Register ourselves as an observer of the NSManagedObjectContextDidSaveNotification event that gets sent
		// when a managedObjectContext is saved to the persistent sotre
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(contextDidSave:)
													 name: NSManagedObjectContextDidSaveNotification
												   object: managedObjectContext];
        // Abort if cancelled
        if (self.isCancelled)
        {
            //            NSBLog (@"__________Cancel on entry %@", self);
            @throw self.cancelledException;
        }
        
        
        // batch size is a static int set to kBatchSize on init, after the fist call, the control
        // of batch size is entirely server size
        self.numItemsTotal = [self defaultBatchSize];
        
        //        self.indexOffset = 0;
        // If we were interrupted then don't set the firsttime flag
        if (0 == self.indexOffset)
        {
            self.firstTime = TRUE;
        }
        
        self.batchSize = [self defaultBatchSize];
        int numItemsRemaining = [self defaultBatchSize];
        
		while (numItemsRemaining > 0)
        {
            self.currentBatchSize = (numItemsRemaining < self.batchSize) ? numItemsRemaining : self.batchSize;
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: [self queryURL]]
                                                                   cachePolicy: NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                               timeoutInterval: kAPI2VenuesUpdateTimeout];
            
            // Set up a synchronouse connection to send the GET
            NSData *responseData = [NSURLConnection sendSignedSynchronousRequest: request
                                                               returningResponse: &response
                                                                           error: &error];
            // Abort if cancelled
            if (self.isCancelled)
            {
                //                NSBLog (@"__________Cancel in loop %@", self);
                @throw self.cancelledException;
            }
            else
            {
                //                NSBLog (@"==========Running in loop %@", self);
            }
            
            // Did we succeed?  If so then update the venue list stored in the database, otherwise log a suitable error
            if ([error code])
            {
                // Log the error
                NSBLog(@"AbstractUpdate, sendSynchronoutRequest: Unresolved error %@, %@", error, [error userInfo]);
                @throw self.communicationsException;
            }
            else
            {
                // No? What about a nil pointer?
                if (!responseData)
                {
                    NSBLog(@"AbstractnUpdate: NSURLConnection sendSynchronousRequest: Response = nil");
                    error = [NSError errorWithDomain: NSURLErrorDomain
                                                code: NSURLErrorZeroByteResource
                                            userInfo: nil];
                    
                    @throw self.communicationsException;
                }
                else
                {
                    // All seems well, so construct a String around the Data from the response
                    NSString *responseString = [[[NSString alloc] initWithData: responseData
                                                                      encoding: NSUTF8StringEncoding] autorelease];
                    
                    // Check so see if response is null string or empty array or list
                    if (!([responseString isEqualToString:@""] || [responseString isEqualToString:@"{}"]))
                    {
                        // Create a new JSON parser object
                        SBJSON *jsonParser = [[SBJSON new] autorelease];
                        
                        // Parse string into a (mutable)dictionary object
                        self.responseDictionary =  (NSDictionary *) [jsonParser objectWithString: responseString
                                                                                           error: NULL];
                    }
                    
                    // Only do something if we were successful in getting our information i.e. we were returned a dictionalry
                    if (self.responseDictionary)
                    {
                        [self createManagedObjectsFromDictionary: self.responseDictionary
                                          inManagedObjectContext: managedObjectContext
                                                    shouldDelete: self.firstTime];
                        
                        // Paging support
                        if ((self.firstTime  == TRUE) && ![self.jukeboxHash isEqualToString: @""] && [self.jukeboxHash isEqualToString: self.lastJukeboxHash])
                        {
                            // Same as last time so act as if cancelled
                            NSBLog (@"__________Cancel on same hash %@", self);
                            @throw self.cancelledException;
                        }
                        else
                        {
                            self.lastJukeboxHash = self.jukeboxHash;
                        }
                        
                        self.firstTime = FALSE;
                        self.indexOffset += self.currentBatchSize;
                        
                        numItemsRemaining = (self.batchSize == kDefaultBatchSize) ? 0 : self.numItemsTotal - self.indexOffset;
                    }
                    else
                    {
                        // Really should have our own error domain for this
                        error = [NSError errorWithDomain: NSURLErrorDomain
                                                    code: NSURLErrorCannotParseResponse
                                                userInfo: nil];
                        
                        @throw self.communicationsException;
                    }
                }
            }
            
            // Only save if we weren't cancelled
            if (!self.isCancelled && !error)
            {
                if (![managedObjectContext save: &error])
                {
                    NSArray* detailedErrors = [[error userInfo] objectForKey: NSDetailedErrorsKey];
                    if(detailedErrors != nil && [detailedErrors count] > 0)
                    {
                        for(NSError* detailedError in detailedErrors)
                        {
                            NSBLog(@" DetailedError: %@", [detailedError userInfo]);
                        }
                    }
                    
                    // Bail out if save failed
                    error = [NSError errorWithDomain: NSURLErrorDomain
                                                code: NSURLErrorCannotDecodeContentData
                                            userInfo: nil];
                    
                    @throw self.communicationsException;
                }
            }
        }
	}
	@catch (NSException * e)
	{
        if (nil == error)
        {
            error = [NSError errorWithDomain: NSURLErrorDomain
                                        code: NSURLErrorCancelled
                                    userInfo: [NSDictionary dictionaryWithObject: [NSNumber numberWithInt: self.indexOffset]
                                                                          forKey: @"Index"]];
        }
	}
    @finally
    {
		// Remove ourself as an observer of the NSManagedObjectContextDidSaveNotification event (as this task is about to dissappear)
		[[NSNotificationCenter defaultCenter] removeObserver: self
														name: NSManagedObjectContextDidSaveNotification
													  object: managedObjectContext];
        // Clean up
        [managedObjectContext reset];
        [managedObjectContext release];
    }
	
	// Report back if anything that actually returned an error code (as opposed to a user or programmatic cancellation)
	if (error)
	{
        if ([error code] == NSURLErrorCancelled)
        {
            //            NSBLog (@"__________Cancel callback %@", self);
            [self.delegate performSelectorOnMainThread: self.cancelledSelector
                                            withObject: error
                                         waitUntilDone: YES];
        }
        else
        {
            [self.delegate performSelectorOnMainThread: self.errorSelector
                                            withObject: error
                                         waitUntilDone: YES];
        }
	}
}


// This is the notification that we receive when the saving our our managed object context (managedObjectContext) to the persistent store is complete.
// I.e. we can call a method in our main thread to update its own managedObjectContext
- (void) contextDidSave: (NSNotification*) notification
{
    NSMutableDictionary	*response = [[NSMutableDictionary alloc] initWithCapacity: 2];
	
	[response setObject: notification
				 forKey: @"Notification"];
	
	if (self.responseDictionary)
	{
		[response setObject: self.responseDictionary
					 forKey: @"ResponseDictionary"];
	}
	
    [self.delegate performSelectorOnMainThread: self.updateSelector
                                    withObject: response
                                 waitUntilDone: YES];
	
	[response release];
}


- (void) createManagedObjectsFromDictionary: (NSDictionary *) responseDictionary
                               shouldDelete: (BOOL) shouldDelete
{
    NSError	*error = nil;
    
    // Only delete the first time on a batched update
    if (shouldDelete == TRUE)
    {
        NSEntityDescription *genericEntity = [NSEntityDescription entityForName: @"GenericTableEntry"
                                                         inManagedObjectContext: managedObjectContext];
        
        // Delete all entities that correspond to this unique view id
        // We should delete them here as if we hit a problem, then we just rollback the update
        NSFetchRequest *deletionFetchRequest = [[[NSFetchRequest alloc] init] autorelease];
        [deletionFetchRequest setEntity: genericEntity];
        
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(uniqueViewId ==  %@)", self.uniqueViewId];
        [deletionFetchRequest setPredicate: predicate];
        
        NSArray *entriesForDeletion = [managedObjectContext executeFetchRequest: deletionFetchRequest
                                                                          error: &error];
        
        // Fast enumerate through the existing song database, deleting them
        for (GenericTableEntry *entryToDelete in entriesForDeletion)
        {
            [managedObjectContext deleteObject: entryToDelete];
        }
    }
    
    // Rest of parsing goes here
}


- (void) createChannelObjectsFromItemArray: (NSArray *) itemArray
{   
    for (NSDictionary *newsItem in itemArray)
    {
        NSNumber *newsItemId = [NSNumber numberWithInt: 0];
        NSString *newsItemURL = @"";
        
        // Get Data dictionary
        NSDictionary *dataDictionary = [newsItem objectForKey: @"Data"];
        
        // Get Data, being cautious and checking to see that we do indeed have an 'Data' key and it does return a dictionary
        if (dataDictionary && [dataDictionary isKindOfClass: [NSDictionary class]])
        {
            newsItemId = [DictionaryHelper validIntForDictionary: dataDictionary
                                                          andKey: @"Id"
                                                  withDefaultInt: 0];
            
            newsItemURL = [DictionaryHelper validStringForDictionary: dataDictionary
                                                              andKey: @"Url"
                                                   withDefaultString: @""];
            
        }
        
        VideoInstance *videoInstance = [VideoInstance insertInManagedObjectContext: self.mainManagedObjectContext]; 
        
        // Set to defaults so that we don't crash on save if something goes wrong in parsing
        NSString *imageURI = @"";

        
        // Get common properties
        [self getCommonObjectAttributesFromDictionary: newsItem
                                             uniqueId: &uniqueId];
}


// All objects share certain attributes, so parse them here, start with the unique ID, but add more as more common items fount
- (void) getCommonObjectAttributesFromDictionary: (NSDictionary *) dictionary
                                        uniqueId: (NSString **) uniqueId

{
    // Get common attributes
    *uniqueId = [DictionaryHelper validStringForDictionary: dictionary
                                                andKey: @"id"
                                     withDefaultString: @""];
}


@end

