#import "Channel.h"
#import "NSDate-Utilities.h"
#import "NSDictionary+Validation.h"
#import "Video.h"
#import "VideoInstance.h"


@interface VideoInstance ()

// Private interface goes here.

@end


@implementation VideoInstance

@synthesize selectedForVideoQueue;

+(VideoInstance*) instanceFromVideoInstance:(VideoInstance*)existingInstance
                  usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                        ignoringObjectTypes: (IgnoringObjects) ignoringObjects {
    
    VideoInstance* instance = [VideoInstance insertInManagedObjectContext: managedObjectContext];
    
    instance.uniqueId = existingInstance.uniqueId;
    
    instance.position = existingInstance.position;
    
    instance.dateAdded = existingInstance.dateAdded;
    
    instance.title = existingInstance.title;
    
    instance.video = [Video instanceFromVideo:existingInstance.video
                    usingManagedObjectContext:managedObjectContext];
    
    if (!(ignoringObjects & kIgnoreChannelObjects))
    {
        instance.channel = [Channel instanceFromChannel:existingInstance.channel
                                              andViewId:instance.viewId
                              usingManagedObjectContext:managedObjectContext
                                    ignoringObjectTypes:ignoringObjects | kIgnoreChannelOwnerObject | kIgnoreVideoInstanceObjects];
    }
    
    
    
    return instance;
    
}

#pragma mark - Object factory

+ (VideoInstance *) instanceFromDictionary: (NSDictionary *) dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    return [VideoInstance instanceFromDictionary:dictionary
                       usingManagedObjectContext:managedObjectContext
                             ignoringObjectTypes:kIgnoreNothing];
}

+ (VideoInstance *) instanceFromDictionary: (NSDictionary *) dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                        ignoringObjectTypes: (IgnoringObjects) ignoringObjects
{
    
    if (![dictionary isKindOfClass: [NSDictionary class]])
        return nil;
    
    NSString *uniqueId = [dictionary objectForKey: @"id"];
    if(!uniqueId || ![uniqueId isKindOfClass:[NSString class]])
        return nil;
    
    
    VideoInstance *instance = [VideoInstance insertInManagedObjectContext: managedObjectContext];
    
    instance.uniqueId = uniqueId;
    
    
    [instance setAttributesFromDictionary: dictionary
                usingManagedObjectContext: managedObjectContext
                      ignoringObjectTypes: ignoringObjects];
    
    return instance;
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects
{
    
    
    
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
                                   ignoringObjectTypes: ignoringObjects | kIgnoreVideoInstanceObjects];
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
