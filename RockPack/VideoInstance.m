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
    
    NSString *uniqueId = [dictionary objectForKey: @"id"
                                      withDefault: @"Uninitialized Id"];
    
    
    if (videoInstanceEntity == nil)
    {
        
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            
            videoInstanceEntity = [NSEntityDescription entityForName: @"VideoInstance"
                                              inManagedObjectContext: managedObjectContext];
          
        });
    }
    
    VideoInstance *instance;
    
    if(!(ignoringObjects & kIgnoreStoredObjects))
    {
        NSFetchRequest *videoInstanceFetchRequest = [[NSFetchRequest alloc] init];
        [videoInstanceFetchRequest setEntity: videoInstanceEntity];
        
        // Search on the unique Id
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %@ AND viewId == %@", uniqueId, viewId];
        [videoInstanceFetchRequest setPredicate: predicate];
        
        NSArray *matchingVideoInstanceEntries = [managedObjectContext executeFetchRequest: videoInstanceFetchRequest
                                                                                    error: &error];
        
        if (matchingVideoInstanceEntries.count > 0)
        {
            instance = matchingVideoInstanceEntries[0];
            
            instance.markedForDeletionValue = NO;
            
            
        }
        
    }
    
    
    
    if(!instance)
    {
        instance = [VideoInstance insertInManagedObjectContext: managedObjectContext];
    }
    
    
    
    [instance setAttributesFromDictionary: dictionary
                                   withId: uniqueId
                usingManagedObjectContext: managedObjectContext
                      ignoringObjectTypes: ignoringObjects
                                andViewId: viewId];
    
    return instance;
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
