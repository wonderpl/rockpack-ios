#import "User.h"
#import "NSDictionary+Validation.h"
#import "AppConstants.h"
#import "Channel.h"

@interface User ()

// Private interface goes here.

@end


@implementation User

@synthesize fullName;

#pragma mark - Object factory


+ (User*) instanceFromUser:(User*)oldUser
 usingManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
{
    
    User* instance = [User insertInManagedObjectContext: managedObjectContext];
    
    instance.username = oldUser.username;
    
    instance.emailAddress = oldUser.emailAddress;
    
    instance.firstName = oldUser.firstName;
    
    instance.lastName = oldUser.lastName;
    
    instance.activityUrl = oldUser.activityUrl;
    
    instance.coverartUrl = oldUser.coverartUrl;
    
    instance.subscriptionsUrl = oldUser.subscriptionsUrl;
    
    instance.genderValue = oldUser.genderValue;
    
    instance.dateOfBirth = oldUser.dateOfBirth;
    
    instance.locale = oldUser.locale;
    
    
    return instance;
    
    
}

+ (User*) instanceFromDictionary: (NSDictionary *) dictionary
       usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
             ignoringObjectTypes: (IgnoringObjects) ignoringObjects
{
    NSError *error = nil;
    
    NSString *uniqueId = [dictionary objectForKey: @"id"]; 
    
    if(!uniqueId)
        return nil;
    
    NSEntityDescription* userEntity = [NSEntityDescription entityForName: @"User"
                                                  inManagedObjectContext: managedObjectContext];
    
    NSFetchRequest *userFetchRequest = [[NSFetchRequest alloc] init];
    [userFetchRequest setEntity:userEntity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %@", uniqueId];
    [userFetchRequest setPredicate: predicate];
    
    
    NSArray *matchingCategoryInstanceEntries = [managedObjectContext executeFetchRequest: userFetchRequest error: &error];
    User *instance;
    
    if (matchingCategoryInstanceEntries.count > 0)
    {
        instance = matchingCategoryInstanceEntries[0];
        
    }
    else
    {
        instance = [User insertInManagedObjectContext: managedObjectContext];
        
        
        
        
    }
    
    instance.uniqueId = uniqueId;
    
    [instance setAttributesFromDictionary: dictionary
                usingManagedObjectContext: managedObjectContext
                      ignoringObjectTypes: ignoringObjects];
    
    return instance;
}




- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects {
    
    
    // Sets attributes for ChannelOwner (superclass) AND adds Channels
    
    [super setAttributesFromDictionary: dictionary
                   ignoringObjectTypes: ignoringObjects];
    
    // Then set the rest
    
    NSString* n_username = [dictionary objectForKey: @"username"];
    self.username = n_username ? n_username : self.username;

    NSString* n_emailAddress = [dictionary objectForKey:@"email"];
    self.emailAddress = n_emailAddress ? n_emailAddress : self.emailAddress;
    
    NSString* n_firstName = [dictionary objectForKey:@"first_name" ];
    self.firstName = n_firstName ? n_firstName : self.firstName;
    
    NSString* n_lastName = [dictionary objectForKey: @"last_name"];
    self.lastName = n_lastName ? n_lastName : self.lastName;
    
    
    NSDictionary* activity_url_dict = [dictionary objectForKey: @"activity"];
    if(activity_url_dict)
        self.activityUrl = [activity_url_dict objectForKey:@"resource_url"];
    
    NSDictionary* coverart_url_dict = [dictionary objectForKey: @"cover_art"];
    if(coverart_url_dict) 
        self.coverartUrl = [coverart_url_dict objectForKey:@"resource_url"];
    
    NSDictionary* subscriptions_url_dict = [dictionary objectForKey: @"subscriptions"];
    if(subscriptions_url_dict) 
        self.subscriptionsUrl = [coverart_url_dict objectForKey:@"resource_url"];
    
    
    // == Gender == //
    NSString* genderString = [dictionary objectForKey:@"gender"];
    
    if(!genderString || [genderString isEqual:[NSNull null]])
    {
        self.genderValue = GenderUndecided;
    }
    else if([[genderString uppercaseString] isEqual:@"M"])
    {
        self.genderValue = GenderMale;
    }
    else if([[genderString uppercaseString] isEqual:@"F"])
    {
        self.genderValue = GenderFemale;
    }
    
    
    
    // == Date of Birth == //
    
    NSString* dateOfBirthString = [dictionary objectForKey:@"date_of_birth"];
    if([dateOfBirthString isKindOfClass:[NSNull class]]) {
        
        self.dateOfBirth = nil;
        
    } else {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *dateOfBirthDate = [dateFormatter dateFromString:dateOfBirthString];
        
        self.dateOfBirth = dateOfBirthDate;
        
    }
    
    
    // == Locale == //
    
    
    NSString* localeFromDict = [dictionary objectForKey:@"locale" withDefault:@""];
    
    
    NSString* localeFromDevice = [(NSString*)CFBridgingRelease(CFLocaleCreateCanonicalLanguageIdentifierFromString(NULL, (CFStringRef)[NSLocale.autoupdatingCurrentLocale objectForKey: NSLocaleIdentifier])) lowercaseString];
    
    if([localeFromDict isEqualToString:@""]) {
        
        self.locale = localeFromDevice;
        
    } else {
        
        self.locale = localeFromDict;
    }
    
                        
}

#pragma mark - Accessors

-(void)addSubscriptionsObject:(Channel *)value_
{

    [self.subscriptionsSet addObject:value_];
    value_.subscribedByUserValue = YES;
    value_.subscribersCountValue++;
}
-(void)removeSubscriptionsObject:(Channel *)value_
{
    value_.subscribedByUserValue = NO;
    value_.subscribersCountValue--;
    [self.subscriptionsSet removeObject:value_];
    
}

-(NSString*) fullName
{
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

- (NSString *) description
{
    NSMutableString* userDescription = [NSMutableString stringWithFormat:@"User (%i) - username: '%@'", [self.uniqueId intValue], self.username];
    
    [userDescription appendFormat:@"\nUser Channels (%i)", self.channels.count];
    
    [userDescription appendString:@":"];
    for (Channel* channel in self.channels) {
        [userDescription appendFormat:@"\n - %@ (%@)", channel.title, [channel.subscribedByUser boolValue] ? @"Subscribed" : @"-"];
    }
    
    [userDescription appendFormat:@"\nUser Subscriptions (%i)", self.subscriptions.count];
    
    [userDescription appendString:@":"];
    for (Channel* channel in self.subscriptions) {
        [userDescription appendFormat:@"\n - %@ (%@)", channel.title, [channel.subscribedByUser boolValue] ? @"Subscribed" : @"-"];
    }
    
    
    return userDescription;
}

@end
