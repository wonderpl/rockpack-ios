#import "User.h"
#import "NSDictionary+Validation.h"

@interface User ()

// Private interface goes here.

@end


@implementation User

#pragma mark - Object factory

+ (User*)instanceFromDictionary: (NSDictionary *) dictionary usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    NSError *error = nil;
    
    NSString *userid = [dictionary objectForKey: @"userid"]; // there must be a username
    if(!userid)
        return nil;
    
    NSEntityDescription* userEntity = [NSEntityDescription entityForName:@"User" inManagedObjectContext: managedObjectContext];
    
    NSFetchRequest *userFetchRequest = [[NSFetchRequest alloc] init];
    [userFetchRequest setEntity:userEntity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"userid == '%@'", userid];
    [userFetchRequest setPredicate: predicate];
    
    NSArray *matchingCategoryInstanceEntries = [managedObjectContext executeFetchRequest: userFetchRequest
                                                                                   error: &error];
    
    User *instance;
    
    if (matchingCategoryInstanceEntries.count > 0)
    {
        instance = matchingCategoryInstanceEntries[0];
        
        
        return instance;
    }
    else
    {
        instance = [User insertInManagedObjectContext: managedObjectContext];
        
        
        [instance setAttributesFromDictionary: dictionary
                    usingManagedObjectContext: managedObjectContext];
        
        
        return instance;
    }
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext {
    
    self.userid = [dictionary objectForKey:@"userid"];
    self.firstName = [dictionary objectForKey:@"first_name" withDefault:@""];
    self.lastName = [dictionary objectForKey:@"last_name" withDefault:@""];
    
    self.userName = [dictionary objectForKey:@"name"];
    self.thumbnailURL = [dictionary objectForKey:@"avatar_thumbnail_url" withDefault:@""];
    
}


- (NSString *) description
{
    NSMutableString* descriptioString = [[NSMutableString alloc] init];
    
    return descriptioString;
}

@end
