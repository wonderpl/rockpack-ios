#import "AccessInfo.h"
#import "NSDictionary+Validation.h"


@interface AccessInfo ()

// Private interface goes here.

@end


@implementation AccessInfo


+ (AccessInfo *) instanceFromDictionary: (NSDictionary *) dictionary
         usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext {
    
    
    NSEntityDescription* accessInfoEntity = [NSEntityDescription entityForName: @"AccessInfo"
                                                        inManagedObjectContext: managedObjectContext];
    
    
    NSFetchRequest *channelFetchRequest = [[NSFetchRequest alloc] init];
    [channelFetchRequest setEntity: accessInfoEntity];
    
    
    AccessInfo* instance = [AccessInfo insertInManagedObjectContext: managedObjectContext];
    
    [instance setAttributesFromDictionary: dictionary
                usingManagedObjectContext: managedObjectContext];
    
    return instance;
}




- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext {
    
    
    
    self.tokenType = [dictionary objectForKey: @"token_type" withDefault: @"Bearer"];
    
    self.userId = [dictionary objectForKey: @"user_id" withDefault:@""];
    
    self.accessToken = [dictionary objectForKey:@"access_token" withDefault:@""];
    
    self.resourceUrl = [dictionary objectForKey: @"resource_url" withDefault: @""];
    
    self.expiryTime = [dictionary objectForKey: @"expires_in" withDefault:@(0)];
    
    self.refreshToken = [dictionary objectForKey: @"refresh_token" withDefault:@""];
    
    
}

@end
