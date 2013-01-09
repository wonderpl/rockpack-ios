//
//  SYNAbstractUpdater.m
//  rockpack
//
//  Created by Nick Banks on 09/01/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "AbstractCommon.h"
#import "AppConstants.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "NSDictionary+Validation.h"
#import "SYNAbstractUpdater.h"
#import "SYNAppDelegate.h"
#import "Video.h"
#import "VideoInstance.h"

#define kUpdaterCancelled TRUE
#define kUpdaterNotCancelled FALSE

@interface SYNAbstractUpdater()

#pragma mark -
#pragma mark Private Properties

@property (nonatomic, copy) SYNUpdaterResponseBlock completionBlock;

@property (nonatomic, assign) BOOL firstTime;
@property (nonatomic, assign) int batchSize;
@property (nonatomic, assign) int numItemsTotal;
@property (nonatomic, assign) int offset;
@property (nonatomic, retain) NSException *cancelledException;
@property (nonatomic, retain) NSException *communicationsException;
@property (nonatomic, retain) NSManagedObjectContext *importManagedObjectContext;
@property (nonatomic, retain) NSString *uniqueViewId;
@property (nonatomic, retain) id responseJSON;

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
        if (completionBlock)
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


- (NSURL *) queryURL
{
    return nil;
    //return [NSURL URLWithString: @"http://www.synchromation.com"];
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
    SYNAppDelegate *appDelegate = UIApplication.sharedApplication.delegate;
    
    // Set up a default exception
    self.cancelledException = [NSException exceptionWithName: @"CancelledException"
                                                      reason: @"Operation cancelled"
                                                    userInfo: nil];
    
    self.communicationsException = [NSException exceptionWithName: @"CommunicationsException"
                                                           reason: @"Error talking to server"
                                                         userInfo: nil];
	
    // This is where the magic occurs
    // Create our own ManagedObjectContext with NSConfinementConcurrencyType as suggested in the WWDC2011 What's new in CoreData video
    self.importManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSConfinementConcurrencyType];
    self.importManagedObjectContext.parentContext = appDelegate.mainManagedObjectContext;
    
	@try
	{
		// Register ourselves as an observer of the NSManagedObjectContextDidSaveNotification event that gets sent
		// when a managedObjectContext is saved to the persistent sotre
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(contextDidSave:)
													 name: NSManagedObjectContextDidSaveNotification
												   object: self.importManagedObjectContext];
        
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
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: self.queryURL]
                                                                   cachePolicy: NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                               timeoutInterval: kAPIDefaultTimout];
            
            // Set up a synchronouse connection to send the GET
            NSData *responseData = [NSURLConnection sendSynchronousRequest: request
                                                         returningResponse: &response
                                                                     error: &error];
            // Abort if cancelled
            if (self.isCancelled)
            {
                DebugLog (@"Cancel in loop %@", self);
                @throw self.cancelledException;
            }
            
            // Did we succeed?  If so then update the venue list stored in the database, otherwise log a suitable error
            if ([error code])
            {
                // Log the error
                DebugLog(@"AbstractUpdate, sendSynchronoutRequest: Unresolved error %@, %@", error, [error userInfo]);
                @throw self.communicationsException;
            }
            else
            {
                // No? What about a nil pointer?
                if (!responseData)
                {
                    DebugLog(@"AbstractnUpdate: NSURLConnection sendSynchronousRequest: Response = nil");
                    error = [NSError errorWithDomain: NSURLErrorDomain
                                                code: NSURLErrorZeroByteResource
                                            userInfo: nil];
                    
                    @throw self.communicationsException;
                }
                else
                {
                    // Turn the incoming JSON into an NSDictionary or NSArray
                    self.responseJSON = [NSJSONSerialization JSONObjectWithData: responseData
                                                                        options: 0
                                                                          error: &error];
                    // If not successful, then call our completion block
                    if ((self.responseJSON == nil) && error)
                    {
                        self.completionBlock(self, error, kUpdaterNotCancelled);
                        return;
                    }
                }
                
                // Only do something if we were successful in getting our information i.e. we were returned a dictionalry
                if (self.responseJSON)
                {
                    [self createManagedObjectsFromDictionary: self.responseJSON
                                                shouldDelete: self.firstTime];
                    
                    // Paging support
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
            if (![self.importManagedObjectContext save: &error])
            {
                NSArray* detailedErrors = [[error userInfo] objectForKey: NSDetailedErrorsKey];
                if(detailedErrors != nil && [detailedErrors count] > 0)
                {
                    for(NSError* detailedError in detailedErrors)
                    {
                        DebugLog(@" DetailedError: %@", [detailedError userInfo]);
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
                                                      object: self.importManagedObjectContext];
        // Clean up
        [self.importManagedObjectContext reset];
    }
    
    // Report back if anything that actually returned an error code (as opposed to a user or programmatic cancellation)
    if (error)
    {
        if ([error code] == NSURLErrorCancelled)
        {
            self.completionBlock(self, nil, kUpdaterCancelled);
        }
        else
        {
            self.completionBlock(self, error, kUpdaterNotCancelled);
        }
    }
}


// This is the notification that we receive when the saving our our managed object context (managedObjectContext) to the persistent store is complete.
// I.e. we can call a method in our main thread to update its own managedObjectContext
- (void) contextDidSave: (NSNotification*) notification
{
    self.completionBlock(self, nil, kUpdaterNotCancelled);
}


- (void) createManagedObjectsFromDictionary: (NSDictionary *) responseDictionary
                               shouldDelete: (BOOL) shouldDelete
{
    NSError	*error = nil;
    
    // Only delete the first time on a batched update
    if (shouldDelete == TRUE)
    {
        NSEntityDescription *genericEntity = [NSEntityDescription entityForName: @"GenericTableEntry"
                                                         inManagedObjectContext: self.importManagedObjectContext];
        
        // Delete all entities that correspond to this unique view id
        // We should delete them here as if we hit a problem, then we just rollback the update
        NSFetchRequest *deletionFetchRequest = [[NSFetchRequest alloc] init];
        [deletionFetchRequest setEntity: genericEntity];
        
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:  @"(uniqueViewId ==  %@)", self.uniqueViewId];
        [deletionFetchRequest setPredicate: predicate];
        
        NSArray *entriesForDeletion = [self.importManagedObjectContext executeFetchRequest: deletionFetchRequest
                                                                          error: &error];
        
        // Fast enumerate through the existing song database, deleting them
        for (AbstractCommon *entryToDelete in entriesForDeletion)
        {
            [self.importManagedObjectContext deleteObject: entryToDelete];
        }
    }
    
    // Rest of parsing goes here
}


- (void) createChannelObjectsFromItemArray: (NSArray *) itemArray
{
    for (NSDictionary *newsItem in itemArray)
    {
        NSString *uniqueId;
        
        // Get Data dictionary
        NSDictionary *dataDictionary = [newsItem objectForKey: @"Data"];
        
        // Get Data, being cautious and checking to see that we do indeed have an 'Data' key and it does return a dictionary
        if (dataDictionary && [dataDictionary isKindOfClass: [NSDictionary class]])
        {
            // Template for reading values from model (numbers, strings, dates and bools are the data types that we currently have)
            NSNumber *number  = [dataDictionary objectForKey: dataDictionary
                                                     withDefault: @0];
            
            NSString *string  = [dataDictionary objectForKey: dataDictionary
                                                 withDefault: @""];
            
            NSDate *date  = [dataDictionary objectForKey: dataDictionary
                                                 withDefault: @0];
            
            NSNumber *boolean  = [dataDictionary objectForKey: dataDictionary
                                                 withDefault: @FALSE];
        
            
        }
        
        VideoInstance *videoInstance = [VideoInstance insertInManagedObjectContext: self.importManagedObjectContext];
        
        // Get common properties
//        [self getCommonObjectAttributesFromDictionary: newsItem
//                                             uniqueId: &uniqueId];
    }
}
    
    
@end
    
