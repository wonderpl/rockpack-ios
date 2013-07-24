#import "AppConstants.h"
#import "Channel.h"
#import "NSDictionary+Validation.h"
#import "User.h"

@implementation User

@synthesize facebookToken;

#pragma mark - Object factory


+ (User *) instanceFromUser: (User *) oldUser
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
{
    User *instance = [User insertInManagedObjectContext: managedObjectContext];
    
    instance.uniqueId = oldUser.uniqueId;
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


+ (User *) instanceFromDictionary: (NSDictionary *) dictionary
        usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
              ignoringObjectTypes: (IgnoringObjects) ignoringObjects
{
    NSString *uniqueId = dictionary[@"id"];
    
    if (!uniqueId)
    {
        return nil;
    }
    
    User *instance = [User insertInManagedObjectContext: managedObjectContext];
    
    instance.uniqueId = uniqueId;
    
    [instance setAttributesFromDictionary: dictionary
                usingManagedObjectContext: managedObjectContext
                      ignoringObjectTypes: ignoringObjects];
    
    return instance;
}


- (void) setAttributesFromDictionary: (NSDictionary *) dictionary
           usingManagedObjectContext: (NSManagedObjectContext *) managedObjectContext
                 ignoringObjectTypes: (IgnoringObjects) ignoringObjects
{
    // Sets attributes for ChannelOwner (superclass) AND adds Channels
    [super setAttributesFromDictionary: dictionary
                   ignoringObjectTypes: ignoringObjects];
    
    // Then set the rest
    NSString *n_username = dictionary[@"username"];
    self.username = n_username ? n_username : self.username;
    
    NSString *n_emailAddress = dictionary[@"email"];
    self.emailAddress = n_emailAddress ? n_emailAddress : self.emailAddress;
    
    NSString *n_firstName = dictionary[@"first_name"];
    self.firstName = n_firstName ? n_firstName : self.firstName;
    
    NSString *n_lastName = dictionary[@"last_name"];
    self.lastName = n_lastName ? n_lastName : self.lastName;
    
    NSNumber *n_display_fullName = dictionary[@"display_fullname"];
    self.fullNameIsPublicValue = n_display_fullName ? [n_display_fullName boolValue] : NO;
    
    NSDictionary* n_external_accounts = dictionary[@"external_accounts"];
    if(n_external_accounts)
    {
        
        
        NSArray* n_external_account_items = n_external_accounts[@"items"];
        NSDictionary* n_facebook_account = n_external_account_items ? n_external_account_items[0] : nil;
        if(n_facebook_account)
        {
            NSString* n_external_system = n_facebook_account[@"external_system"];
            if([n_external_system isEqualToString:@"facebook"])
            {
                self.facebookAccountUrl = n_external_accounts[@"resource_url"];
                self.facebookToken = n_facebook_account[@"external_token"];
            }
            
        }
    }
    
    
    
    
    
    NSDictionary *activity_url_dict = dictionary[@"activity"];
    
    if (activity_url_dict)
    {
        self.activityUrl = activity_url_dict[@"resource_url"];
    }
    
    NSDictionary *coverart_url_dict = dictionary[@"cover_art"];
    
    if (coverart_url_dict)
    {
        self.coverartUrl = coverart_url_dict[@"resource_url"];
    }
    
    NSDictionary *subscriptions_url_dict = dictionary[@"subscriptions"];
    
    if (subscriptions_url_dict)
    {
        self.subscriptionsUrl = coverart_url_dict[@"resource_url"];
    }
    
    // == Gender == //
    NSString *genderString = dictionary[@"gender"];
    
    if (!genderString || [genderString isEqual: [NSNull null]])
    {
        self.genderValue = GenderUndecided;
    }
    else if ([[genderString uppercaseString] isEqual: @"M"])
    {
        self.genderValue = GenderMale;
    }
    else if ([[genderString uppercaseString] isEqual: @"F"])
    {
        self.genderValue = GenderFemale;
    }
    
    // == Date of Birth == //
    
    NSString *dateOfBirthString = dictionary[@"date_of_birth"];
    
    if ([dateOfBirthString isKindOfClass: [NSNull class]])
    {
        self.dateOfBirth = nil;
    }
    else
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"yyyy-MM-dd"];
        NSDate *dateOfBirthDate = [dateFormatter dateFromString: dateOfBirthString];
        
        self.dateOfBirth = dateOfBirthDate;
    }
    
    // == Locale == //
    NSString *localeFromDict = [dictionary objectForKey: @"locale"
                                            withDefault: @""];

    NSString *localeFromDevice = [(NSString *) CFBridgingRelease(CFLocaleCreateCanonicalLanguageIdentifierFromString(NULL, (CFStringRef)[NSLocale.autoupdatingCurrentLocale objectForKey: NSLocaleIdentifier])) lowercaseString];
    
    if ([localeFromDict isEqualToString: @""])
    {
        self.locale = localeFromDevice;
    }
    else
    {
        self.locale = localeFromDict;
    }
}


#pragma mark - Accessors

- (void) addSubscriptionsObject: (Channel *) value_
{
    [self.subscriptionsSet addObject: value_];
    value_.subscribedByUserValue = YES;
    value_.subscribersCountValue++;
}


- (void) removeSubscriptionsObject: (Channel *) value_
{
    value_.subscribedByUserValue = NO;
    value_.subscribersCountValue--;
    [self.subscriptionsSet removeObject: value_];
}


- (NSString *) fullName
{
    NSMutableString *fullNameString = [[NSMutableString alloc] initWithCapacity: (self.firstName.length + 1 + self.lastName.length)];
    
    if (![self.firstName isEqualToString: @""])
    {
        [fullNameString appendString: self.firstName];
    }
    
    if (![self.lastName isEqualToString: @""])
    {
        [fullNameString appendFormat: @" %@", self.lastName];
    }
    
    return [NSString stringWithString: (NSString *) fullNameString];
}


- (NSString *) description
{
    NSMutableString *userDescription = [NSMutableString stringWithFormat: @"User (%i) - username: '%@'", [self.uniqueId intValue], self.username];
    
    [userDescription appendFormat: @"\nUser Channels (%i)", self.channels.count];
    
    [userDescription appendString: @":"];
    
    for (Channel *channel in self.channels)
    {
        [userDescription appendFormat: @"\n - %@ (%@)", channel.title, [channel.subscribedByUser boolValue] ? @"Subscribed": @"-"];
    }
    
    [userDescription appendFormat: @"\nUser Subscriptions (%i)", self.subscriptions.count];
    
    [userDescription appendString: @":"];
    
    for (Channel *channel in self.subscriptions)
    {
        [userDescription appendFormat: @"\n - %@ (%@)", channel.title, [channel.subscribedByUser boolValue] ? @"Subscribed": @"-"];
    }
    
    return userDescription;
}


@end
