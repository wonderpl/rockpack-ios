#import "Friend.h"
#import "NSDictionary+Validation.h"

@interface Friend ()

// Private interface goes here.

@end


@implementation Friend

@synthesize isOnRockpack;

+ (Friend *) instanceFromDictionary: (NSDictionary *) dictionary
                usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    if (!dictionary || ![dictionary isKindOfClass: [NSDictionary class]])
    {
        return nil;
    }
    
    NSString *uniqueId = dictionary[@"id"];
    
    if ([uniqueId isKindOfClass: [NSNull class]])
    {
        return nil;
    }
    
    Friend *instance = [Friend insertInManagedObjectContext: managedObjectContext];
    
    instance.uniqueId = uniqueId;
    
    
    [instance setAttributesFromDictionary: dictionary];
    
    
    return instance;
}

- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
{
    // call to ChannelOwner
    [super setAttributesFromDictionary:dictionary
                   ignoringObjectTypes:kIgnoreChannelObjects];
    
    self.externalSystem = [dictionary objectForKey: @"external_system"];
    
    if(self.externalSystem)
        self.externalUID = [dictionary objectForKey: @"external_uid"];
    
    
    self.resourceURL = [dictionary objectForKey: @"resource_url"];
    
    self.hasIOSDevice = [dictionary objectForKey: @"has_ios_device"
                                     withDefault: @(NO)];
    
}

-(BOOL)isIsOnRockpack
{
    return (self.resourceURL != nil);
}

@end
