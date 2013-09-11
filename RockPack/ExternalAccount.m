#import "ExternalAccount.h"
#import "NSDictionary+Validation.h"

@interface ExternalAccount ()

// Private interface goes here.

@end


@implementation ExternalAccount

@synthesize permissionFlagsString;

+ (ExternalAccount*)instanceFromDictionary:(NSDictionary*)dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    
    
    if(![dictionary isKindOfClass:[NSDictionary class]])
        return nil;
    
    ExternalAccount* instance;
    
    if(!(instance = [ExternalAccount insertInManagedObjectContext:managedObjectContext]))
        return nil;
    
    if([dictionary[@"external_system"] isKindOfClass:[NSString class]])
        instance.system = dictionary[@"external_system"];
    
    instance.noautopostValue = NO; // allow auto posting unless expilictely denied
    
    [instance setAttributesFromDictionary:dictionary];
    
    return instance;
    
}

/*
 {
 "resource_url": "http: //resource/url/for/connection/",
 "external_system": "SYSTEM LABEL",
 "external_uid": "123",
 "external_token": "xxx",
 "token_expires": "2013-01-01T00:00:00",
 "token_permissions": "read,write",
 "meta": null
 }
 */


-(void)setAttributesFromDictionary:(NSDictionary*)dictionary
{
    
    
    if([dictionary[@"external_uid"] isKindOfClass:[NSString class]])
        self.uid = dictionary[@"external_uid"];
    
    if([dictionary[@"external_token"] isKindOfClass:[NSString class]])
        self.token = dictionary[@"external_token"];
    
    if([dictionary[@"resource_url"] isKindOfClass:[NSString class]])
        self.url = dictionary[@"resource_url"];
    
    if([dictionary[@"token_expires"] isKindOfClass:[NSString class]])
        self.expiration = [dictionary dateFromISO6801StringForKey:@"token_expires"
                                                      withDefault:[NSDate distantPast]];
    
    if([dictionary[@"token_permissions"] isKindOfClass:[NSString class]])
        self.permissions = dictionary[@"token_permissions"];
    
    if(self.permissions)
    {
        // set flags
        // just for FB fo now
        NSArray* permissionsArray = [self.permissions componentsSeparatedByString:@","];
        for (NSString* permission in permissionsArray) {
            if([permission isEqualToString:@"read"])
                self.flagsValue |= ExternalAccountFlagRead;
            else if([permission isEqualToString:@"write"])
                self.flagsValue |= ExternalAccountFlagWrite;
        }
    }
    
}

// if the autopost value is set to TRUE from anywhere, revert the noautopost flag if it was set
-(void)setFlagsValue:(int32_t)value_
{
    self.flags = @(value_);
    if(value_ & ExternalAccountFlagAutopostStar)
        self.noautopostValue = NO;
}

-(NSString*)permissionFlagsString
{
    NSMutableString* permissionsString = [[NSMutableString alloc] init];
    if(self.flagsValue & ExternalAccountFlagRead)
        [permissionsString appendString:@"-R"];
    
    if (self.flagsValue & ExternalAccountFlagWrite)
        [permissionsString appendString:@"-W"];
    
    if (self.flagsValue & ExternalAccountFlagAutopostStar)
        [permissionsString appendString:@"-aSt"];
    
    if (self.flagsValue & ExternalAccountFlagAutopostAdd)
        [permissionsString appendString:@"-aAd"];
    
    return [NSString stringWithString:permissionsString];
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"[ExternalAccount(system:'%@', flags:'%@')]", self.system, self.permissionFlagsString];
}

@end
