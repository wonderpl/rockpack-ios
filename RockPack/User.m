#import "User.h"
#import "NSDictionary+Validation.h"
#import "AppConstants.h"

@interface User ()

// Private interface goes here.

@end


@implementation User

#pragma mark - Object factory

+ (User*) instanceFromDictionary: (NSDictionary *) dictionary usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    NSError *error = nil;
    
    NSString *uniqueId = [dictionary objectForKey: @"id"]; 
    
    if(!uniqueId)
        return nil;
    
    NSEntityDescription* userEntity = [NSEntityDescription entityForName:@"User" inManagedObjectContext: managedObjectContext];
    
    NSFetchRequest *userFetchRequest = [[NSFetchRequest alloc] init];
    [userFetchRequest setEntity:userEntity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == '%@'", uniqueId];
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
                                       withId: uniqueId
                    usingManagedObjectContext: managedObjectContext
                          ignoringObjectTypes: kIgnoreNothing
                                    andViewId: @"Users"];
        
        return instance;
    }
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
                              withId: (NSString *) uniqueId
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects
                           andViewId: (NSString *) viewId {
    
    // As we are a subclass of ChannelOwner, set its attributes as well
    [super setAttributesFromDictionary: dictionary
                                withId: uniqueId
             usingManagedObjectContext: managedObjectContext
                   ignoringObjectTypes: ignoringObjects
                             andViewId: viewId];

    self.emailAddress = [dictionary objectForKey: @"email_address"];
    if(self.emailAddress || [self.emailAddress isEqualToString:@""])
        self.emailAddress = @"(Email Address)";
    
    self.firstName = [dictionary objectForKey: @"first_name"];
    if(self.firstName || [self.firstName isEqualToString:@""])
        self.firstName = @"(First Name)";

    
    self.lastName = [dictionary objectForKey: @"last_name"];
    if(self.lastName || [self.firstName isEqualToString:@""])
        self.lastName = @"(Last Name)";
    
    
    self.gender = @(GenderMale);
    
    self.dateOfBirth = [dictionary dateFromISO6801StringForKey: @"birthday"
                                                   withDefault: [NSDate date]];
}


- (NSString *) description
{
    return [NSString stringWithFormat:
            @"username:%@, firstName:%@, lastName:%@, emailAddress:%@",
            self.username, self.firstName, self.lastName, self.emailAddress];
}

@end
