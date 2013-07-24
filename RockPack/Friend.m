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
    
    
    self.externalUID = [dictionary objectForKey: @"external_uid"];
    
    
    
    self.resourceURL = [dictionary objectForKey: @"resource_url"];
    
    
    self.hasIOSDevice = [dictionary objectForKey: @"has_ios_device"
                                     withDefault: @(NO)];
    
}

-(BOOL)isOnRockpack
{
    return (self.resourceURL != nil);
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"[Friend (id:%@, name:%@)]", self.externalUID, self.displayName];
}

@end
