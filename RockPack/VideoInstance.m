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

+(VideoInstance*) instanceFromVideoInstance:(VideoInstance*)existingInstance
                  usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext {
    
    VideoInstance* instance = [VideoInstance insertInManagedObjectContext: managedObjectContext];
    
    instance.uniqueId = existingInstance.uniqueId;
    instance.viewId = existingInstance.viewId;
    
    instance.position = existingInstance.position;
    
    instance.dateAdded = existingInstance.dateAdded;
    
    instance.title = existingInstance.title;
    
    
    instance.video = [Video instanceFromVideo:existingInstance.video
                    usingManagedObjectContext:managedObjectContext];
    
    
    
    return instance;
    
}

#pragma mark - Object factory

+ (VideoInstance *) instanceFromDictionary: (NSDictionary *) dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                        ignoringObjectTypes: (IgnoringObjects) ignoringObjects
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %@ AND viewId == %@", uniqueId, viewId];
    [videoInstanceFetchRequest setPredicate: predicate];
    
    NSArray *matchingVideoInstanceEntries = [managedObjectContext executeFetchRequest: videoInstanceFetchRequest
                                                                                error: &error];
    
    VideoInstance *instance;
    
    if (matchingVideoInstanceEntries.count > 0)
    {
        instance = matchingVideoInstanceEntries[0];
        // NSLog(@"Using existing VideoInstance instance with id %@ in view %@", instance.uniqueId, instance.viewId);
        
        // Mark this object so that it is not deleted in the post-import step
        instance.markedForDeletionValue = FALSE;
        
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
                          ignoringObjectTypes: (ignoringObjects == kIgnoreChannelObjects) ? kIgnoreChannelObjects : kIgnoreVideoInstanceObjects
                                    andViewId: viewId];
        
        // NSLog(@"Created VideoInstance instance with id %@ in view %@", instance.uniqueId, instance.viewId);
        
        return instance;
    }
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                              withId: (NSString *) uniqueId
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects
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
    self.viewId = viewId;
    
    self.position = [dictionary objectForKey: @"position"
                                 withDefault: [NSNumber numberWithInt: 0]];
    
    self.dateAdded = [dictionary dateFromISO6801StringForKey: @"date_added"
                                                 withDefault: [NSDate date]];
    
    self.title = [dictionary upperCaseStringForKey: @"title"
                                       withDefault: @""];
    
    // NSManagedObjects
    self.video = [Video instanceFromDictionary: [dictionary objectForKey: @"video"]
                     usingManagedObjectContext: managedObjectContext
                           ignoringObjectTypes: ignoringObjects
                                     andViewId: viewId];
    
    if (!(ignoringObjects & kIgnoreChannelObjects))
    {
        self.channel = [Channel instanceFromDictionary: [dictionary objectForKey: @"channel"]
                         usingManagedObjectContext: managedObjectContext
                               ignoringObjectTypes: ignoringObjects
                                         andViewId: viewId];
    }
}


#pragma mark - Object reference counting

// This is very important, we need to set the delete rule to 'Nullify' and then custom delete our connected NSManagedObjects
// dependent on whether they are only referenced by us
- (void) prepareForDeletion
{
    if (self.video.videoInstances.count == 1)
    {
        [self.managedObjectContext deleteObject: self.video];
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
    return [NSString stringWithFormat: @"VideoInstance: uniqueId(%@), viewId(%@), dateAdded (%@), title(%@)", self.uniqueId, self.viewId, self.dateAdded, self.title];
}

@end
