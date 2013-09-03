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
    
    Friend *instance = [Friend insertInManagedObjectContext: managedObjectContext];
    
    instance.uniqueId = [dictionary objectForKey:@"id"
                                     withDefault:@""]; // we can instantiate a Friend with no id since they are not always on rockpack
    
    
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
    
    self.lastShareDate = [dictionary dateFromISO6801StringForKey:@"last_shared_date"
                                                     withDefault:nil];
    
}

-(NSString*)firstName
{
    NSArray* dNameArray = [self.displayName componentsSeparatedByString:@" "];
    return (dNameArray.count > 0 ? dNameArray[0] : @"");
}

-(NSString*)lastName
{
    NSArray* dNameArray = [self.displayName componentsSeparatedByString:@" "];
    return (dNameArray.count > 1 ? dNameArray[dNameArray.count - 1] : @"");
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
