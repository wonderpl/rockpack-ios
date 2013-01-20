#import "Channel.h"
#import "NSDate-Utilities.h"
#import "NSDictionary+Validation.h"
#import "Video.h"
#import "VideoInstance.h"


static NSEntityDescription *videoInstanceEntity = nil;

@interface VideoInstance ()

// Private interface goes here.

@end


@implementation VideoInstance


#pragma mark - Object factory

+ (VideoInstance *) instanceFromDictionary: (NSDictionary *) dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                        withRootObjectType: (RootObject) rootObject
                                 andViewId: (NSString *) viewId
{
    NSError *error = nil;
    
    // Get the unique id of this object from the dictionary that has been passed in
    NSString *uniqueId = [dictionary objectForKey: @"id"
                                      withDefault: @"Uninitialized Id"];
    
    // Only create an entity description once, should increase performance
    if (videoInstanceEntity == nil)
    {
        // Do once, and only once
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^
        {
            // Not entirely sure I shouldn't 'copy' this object before assigning it to the static variable
            videoInstanceEntity = [NSEntityDescription entityForName: @"VideoInstance"
                                              inManagedObjectContext: managedObjectContext];
          
        });
    }
    
    // Now we need to see if this object already exists, and if so return it and if not create it
    NSFetchRequest *videoInstanceFetchRequest = [[NSFetchRequest alloc] init];
    [videoInstanceFetchRequest setEntity: videoInstanceEntity];
    
    // Search on the unique Id
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %@", uniqueId];
    [videoInstanceFetchRequest setPredicate: predicate];
    
    NSArray *matchingVideoInstanceEntries = [managedObjectContext executeFetchRequest: videoInstanceFetchRequest
                                                                                error: &error];
    
    VideoInstance *instance;
    
    if (matchingVideoInstanceEntries.count > 0)
    {
        instance = matchingVideoInstanceEntries[0];
        NSLog(@"Using existing VideoInstance instance with id %@", instance.uniqueId);
        
        // Check to see if we need to fill in the viewId
        if (rootObject == kVideoInstanceRootObject)
        {
            instance.viewId = viewId;
        }
        else
        {
            instance.viewId = @"";
        }
        
        return instance;
    }
    else
    {
        instance = [VideoInstance insertInManagedObjectContext: managedObjectContext];
        
        // As we have a new object, we need to set all the attributes (from the dictionary passed in)
        // We have already obtained the uniqueId, so pass it in as an optimisation
        [instance setAttributesFromDictionary: dictionary
                                       withId: uniqueId
                    usingManagedObjectContext: managedObjectContext
                           withRootObjectType: rootObject
                                    andViewId: viewId];
        
        NSLog(@"Created VideoInstance instance with id %@", instance.uniqueId);
        
        return instance;
    }
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                              withId: (NSString *) uniqueId
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                  withRootObjectType: (RootObject) rootObject
                           andViewId: (NSString *) viewId
{
    // Is we are not actually a dictionary, then bail
    if (![dictionary isKindOfClass: [NSDictionary class]])
    {
        AssertOrLog (@"setAttributesFromDictionary: not a dictionary, unable to construct object");
        return;
    }
    
    // Simple objects
    self.uniqueId = uniqueId;
    
    // If we are initially creating Channel objects, then set our viewId of the appropriate vide name
    // otherwise just set to blank
    if (rootObject == kVideoInstanceRootObject)
    {
        self.viewId = viewId;
    }
    else
    {
        self.viewId = @"";
    }
    
    self.dateAdded = [dictionary dateFromISO6801StringForKey: @"date_added"
                                                 withDefault: [NSDate date]];
    
    self.title = [dictionary upperCaseStringForKey: @"title"
                                       withDefault: @""];
    
    // NSManagedObjects
    self.video = [Video instanceFromDictionary: [dictionary objectForKey: @"video"]
                     usingManagedObjectContext: managedObjectContext
                            withRootObjectType: rootObject
                                     andViewId: viewId];
    
    self.channel = [Channel instanceFromDictionary: [dictionary objectForKey: @"channel"]
                     usingManagedObjectContext: managedObjectContext
                            withRootObjectType: rootObject
                                         andViewId: viewId];
}


#pragma mark - Object reference counting

// This is very important, we need to set the delete rule to 'Nullify' and then custom delete our connected NSManagedObjects
// dependent on whether they are only referenced by us
- (void) prepareForDeletion
{
    if (self.video.videoInstances.count == 1)
    {
        DebugLog(@"Single reference to Video, will be deleted");
        [self.managedObjectContext deleteObject: self.video];
    }
    else
    {
        DebugLog(@"Multiple references to Video object, not deleted");
    }
}


#pragma mark - Helper methods

- (NSNumber *) daysAgo
{
    NSTimeInterval timeIntervalSeconds = [NSDate.date timeIntervalSinceDate: self.dateAdded];
    
    return [NSNumber numberWithInt: timeIntervalSeconds/86400];
}


- (NSDate *) dateAddedIgnoringTime
{
    return self.dateAdded.dateIgnoringTime;
}


- (NSString *) description
{
    return [NSString stringWithFormat: @"VideoInstance(%@) dateAdded: %@, title: %@", self.uniqueId, self.dateAdded, self.title];
}

@end
