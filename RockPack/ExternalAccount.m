#import "ExternalAccount.h"


@interface ExternalAccount ()

// Private interface goes here.

@end


@implementation ExternalAccount

+ (ExternalAccount*)instanceFromDictionary:(NSDictionary*)dictionary
                 usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    
    
    if(![dictionary isKindOfClass:[NSDictionary class]])
        return nil;
    
    ExternalAccount* instance;
    
    if(!(instance = [ExternalAccount insertInManagedObjectContext:managedObjectContext]))
        return nil;
    
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
    if([dictionary[@"external_system"] isKindOfClass:[NSString class]])
        self.system = dictionary[@"external_system"];
    
    if([dictionary[@"external_uid"] isKindOfClass:[NSString class]])
        self.uid = dictionary[@"external_uid"];
    
    if([dictionary[@"external_token"] isKindOfClass:[NSString class]])
        self.token = dictionary[@"external_token"];
    
    if([dictionary[@"token_expires"] isKindOfClass:[NSDate class]])
        self.expiration = dictionary[@"token_expires"];
    
    if([dictionary[@"token_permissions"] isKindOfClass:[NSString class]])
        self.permissions = dictionary[@"token_permissions"];
    
    if(self.permissions)
    {
        // set flags
        
        NSArray* permissionsArray = [self.permissions componentsSeparatedByString:@","];
        for (NSString* permission in permissionsArray) {
            if([permission isEqualToString:@"read"])
                self.flagsValue |= ExternalAccountFlagRead;
            else if([permission isEqualToString:@"write"])
                self.flagsValue |= ExternalAccountFlagWrite;
        }
    }
    
}



@end
