#import "Channel.h"
#import "NSDate-Utilities.h"
#import "NSDictionary+Validation.h"
#import "Video.h"
#import "VideoInstance.h"
#import "ChannelOwner.h"

@implementation VideoInstance

@synthesize selectedForVideoQueue;

// Store our date formatter as a static for optimization purposes
static NSDateFormatter *dateFormatter = nil;

+ (VideoInstance *) instanceFromVideoInstance: (VideoInstance *) existingInstance
                    usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                          ignoringObjectTypes: (IgnoringObjects) ignoringObjects
{
    VideoInstance *instance = [VideoInstance insertInManagedObjectContext: managedObjectContext];
    
    instance.uniqueId = existingInstance.uniqueId;
    instance.position = existingInstance.position;
    instance.dateAdded = existingInstance.dateAdded;
    instance.dateOfDayAdded = existingInstance.dateOfDayAdded;
    instance.title = existingInstance.title;
    
    instance.video = [Video	instanceFromVideo: existingInstance.video
                             usingManagedObjectContext: managedObjectContext];
    
    if (!(ignoringObjects & kIgnoreChannelObjects))
    {
        instance.channel = [Channel	instanceFromChannel: existingInstance.channel
                                              andViewId: instance.viewId
                              usingManagedObjectContext: managedObjectContext
                                    ignoringObjectTypes: ignoringObjects | kIgnoreChannelOwnerObject | kIgnoreVideoInstanceObjects];
    }
    
    return instance;
}


#pragma mark - Object factory

+ (VideoInstance *) instanceFromDictionary: (NSDictionary *) dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    return [VideoInstance instanceFromDictionary: dictionary
                       usingManagedObjectContext: managedObjectContext
                                  existingVideos: nil];
}

+ (VideoInstance *) instanceFromDictionary: (NSDictionary *) dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                            existingVideos: (NSArray *) existingVideos
{
    return [VideoInstance instanceFromDictionary: dictionary
                       usingManagedObjectContext: managedObjectContext
                             ignoringObjectTypes: kIgnoreNothing
                                  existingVideos: existingVideos];
}


+ (VideoInstance *) instanceFromDictionary: (NSDictionary *) dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                       ignoringObjectTypes: (IgnoringObjects) ignoringObjects
                            existingVideos: (NSArray *) existingVideos
{
    if (![dictionary isKindOfClass: [NSDictionary class]])
    {
        return nil;
    }
    
    NSString *uniqueId = dictionary[@"id"];
    
    if (!uniqueId || ![uniqueId isKindOfClass: [NSString class]])
    {
        return nil;
    }
    
    VideoInstance *instance = [VideoInstance insertInManagedObjectContext: managedObjectContext];
    
    instance.uniqueId = uniqueId;
    
    [instance setAttributesFromDictionary: dictionary
                usingManagedObjectContext: managedObjectContext
                      ignoringObjectTypes: ignoringObjects
                           existingVideos: existingVideos];
    
    return instance;
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects
                      existingVideos: (NSArray *) existingVideos
{
    self.position = [dictionary objectForKey: @"position"
                                 withDefault: @0];
    
    self.dateAdded = [dictionary dateFromISO6801StringForKey: @"date_added"
                                                 withDefault: [NSDate date]];
    
    NSString *dateAdded = dictionary[@"date_added"];
    NSString *dayAdded = [dateAdded substringToIndex: [dateAdded rangeOfString: @"T"].location];
    self.dateOfDayAdded = [[VideoInstance DayOfDateFormatter] dateFromString: dayAdded];
    
    self.title = [dictionary objectForKey: @"title"
                              withDefault: @""];
    
    NSArray *filteredVideos;
    if(existingVideos)
    {
        NSString *videoId = (dictionary[@"video"])[@"id"];
        filteredVideos = [existingVideos filteredArrayUsingPredicate: [NSPredicate predicateWithFormat: @"uniqueId = %@", videoId]];
    }
    
    
    
    if (filteredVideos && [filteredVideos count] > 0)
    {
        self.video = filteredVideos[0];
    }
    else
    {
        self.video = [Video instanceFromDictionary: dictionary[@"video"]
                         usingManagedObjectContext: managedObjectContext
                               ignoringObjectTypes: ignoringObjects];
    }
    
    if (!(ignoringObjects & kIgnoreChannelObjects))
    {
        self.channel = [Channel instanceFromDictionary: dictionary[@"channel"]
                             usingManagedObjectContext: managedObjectContext
                                   ignoringObjectTypes: ignoringObjects | kIgnoreVideoInstanceObjects];
    }
    
    // kIgnoreStarringObjects
    
    
    NSArray* starrersArray = dictionary[@"starring_users"];
    if (!(ignoringObjects & kIgnoreStarringObjects) && [starrersArray isKindOfClass:[NSArray class]])
    {
        ChannelOwner* starringChannelOwner;
        for (NSDictionary* starringDictionary in starrersArray)
        {
            starringChannelOwner = [ChannelOwner instanceFromDictionary:starringDictionary
                                              usingManagedObjectContext:self.managedObjectContext
                                                    ignoringObjectTypes:kIgnoreChannelObjects];
            
            // the method addStarrersObject has been overriden so as to copy the CO, do not use unless in need of a copy
            // ex. when passing the currentUser to the video instance
            [self.starrersSet addObject:starringChannelOwner];
            
        }
        
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
    
    return @((int) (timeIntervalSeconds / 86400.0f));
}


- (NSDate *) dateAddedIgnoringTime
{
    if (!self.dateOfDayAdded)
    {
        self.dateOfDayAdded = self.dateAdded.dateIgnoringTime;
    }
    
    return self.dateOfDayAdded;
}


// Used for dates in the following format "2012-12-14T09:59:46.000Z"
// 2013-01-30T15:43:18.806454+00:00
+ (NSDateFormatter *) DayOfDateFormatter
{
    if (dateFormatter == nil)
    {
        // Do once, and only once
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^
                      {
                          dateFormatter = [[NSDateFormatter alloc] init];
                          [dateFormatter setTimeZone: [NSTimeZone timeZoneWithName: @"UTC"]];
                          [dateFormatter setDateFormat: @"yyyy-MM-dd"];
                      });
    }
    
    return dateFormatter;
}

#pragma mark - Starrers

-(void)addStarrersObject:(ChannelOwner *)value_
{
    ChannelOwner* copyOfChannelOwner = [ChannelOwner instanceFromChannelOwner:value_
                                                                    andViewId:self.viewId
                                                    usingManagedObjectContext:self.managedObjectContext
                                                          ignoringObjectTypes:kIgnoreAll];
    
    if(!copyOfChannelOwner)
        return;
    
    [self.starrersSet addObject:copyOfChannelOwner];
}

-(void)removeStarrersObject:(ChannelOwner *)value_
{
    if(!value_)
        return;
    
    for (ChannelOwner* starrer in self.starrers)
    {
        if([starrer.uniqueId isEqualToString:value_.uniqueId])
        {
            [self.starrersSet removeObject:starrer];
            [starrer.managedObjectContext deleteObject:starrer];
            
            break;
        }
            
        
    }
}



-(void)setMarkedForDeletionValue:(BOOL)value_
{
    self.markedForDeletion = @(value_);
    self.channel.markedForDeletionValue = value_;
    self.channel.channelOwner.markedForDeletionValue = value_;
}

@end
