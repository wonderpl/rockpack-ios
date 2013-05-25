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

@synthesize selectedForVideoQueue;

+(VideoInstance*) instanceFromVideoInstance:(VideoInstance*)existingInstance
                  usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext {
    
    VideoInstance* instance = [VideoInstance insertInManagedObjectContext: managedObjectContext];
    
    instance.uniqueId = existingInstance.uniqueId;
    
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
{
    NSError *error = nil;
    
    if (![dictionary isKindOfClass: [NSDictionary class]])
        return nil;
    
    NSString *uniqueId = [dictionary objectForKey: @"id"];
    
    if(!uniqueId || ![uniqueId isKindOfClass:[NSString class]])
        return nil;
    
    
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
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %@", uniqueId];
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
                      ignoringObjectTypes: (ignoringObjects == kIgnoreChannelObjects) ? kIgnoreChannelObjects : kIgnoreVideoInstanceObjects];
    
    return instance;
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                              withId: (NSString *) uniqueId
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects
{
    
    
    
    
    self.uniqueId = uniqueId;
    
    
    self.position = [dictionary objectForKey: @"position"
                                 withDefault: [NSNumber numberWithInt: 0]];
    
    self.dateAdded = [dictionary dateFromISO6801StringForKey: @"date_added"
                                                 withDefault: [NSDate date]];
    
    self.title = [dictionary upperCaseStringForKey: @"title"
                                       withDefault: @""];
    
    // NSManagedObjects
    self.video = [Video instanceFromDictionary: [dictionary objectForKey: @"video"]
                     usingManagedObjectContext: managedObjectContext
                           ignoringObjectTypes: ignoringObjects];
    
    if (!(ignoringObjects & kIgnoreChannelObjects))
    {
        self.channel = [Channel instanceFromDictionary: [dictionary objectForKey: @"channel"]
                             usingManagedObjectContext: managedObjectContext
                                   ignoringObjectTypes: ignoringObjects];
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
    return [NSString stringWithFormat: @"VideoInstance: uniqueId(%@), dateAdded (%@), title(%@)", self.uniqueId, self.dateAdded, self.title];
}

@end
