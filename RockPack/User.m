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
    
    
    NSArray *matchingCategoryInstanceEntries = [managedObjectContext executeFetchRequest: userFetchRequest error: &error];
    User *instance;
    
    if (matchingCategoryInstanceEntries.count > 0)
    {
        instance = matchingCategoryInstanceEntries[0];
        
        [instance updateAttributesFromDictionary:dictionary
                                          withId:uniqueId
                       usingManagedObjectContext:managedObjectContext];
        
        return instance;
    }
    else
    {
        instance = [User insertInManagedObjectContext: managedObjectContext];
        
        instance.uniqueId = uniqueId;
        
        [instance setAttributesFromDictionary: dictionary
                                       withId: uniqueId
                    usingManagedObjectContext: managedObjectContext
                          ignoringObjectTypes: kIgnoreNothing
                                    andViewId: @"Users"];
        
        return instance;
    }
}

-(void)updateAttributesFromDictionary: (NSDictionary*) dictionary
                               withId: (NSString*)uniqueId
            usingManagedObjectContext: (NSManagedObjectContext*)managedObjectContext {
    
    
    
    if (![dictionary isKindOfClass: [NSDictionary class]])
    {
        AssertOrLog (@"setAttributesFromDictionary: not a dictionary, unable to construct object");
        return;
    }
    
    if(self.uniqueId != uniqueId)
    {
        DebugLog(@"The 'User' you're trying to update does not match the data");
        return;
    }
    
    self.thumbnailURL = [dictionary objectForKey: @"avatar_thumbnail_url"
                                     withDefault: @"http://"];
    
    self.displayName = [dictionary upperCaseStringForKey: @"display_name"
                                             withDefault: @""];
    
    NSDictionary* channelsDictionary = [self channelsDictionary];
    
    NSDictionary* channelsArray = [dictionary objectForKey:@"channels"];
    NSArray* channelItemsArray = [channelsArray objectForKey:@"items"];
    
    
    
    for (NSDictionary* channelDictionary in channelItemsArray)
    {
        
        NSString* channelId = [dictionary objectForKey:@"id"];
        if(!channelId || [channelId isEqualToString:@""])
            continue;
        
        NSString* existingChannel = [channelsDictionary objectForKey:channelId];
        if(existingChannel)
            continue;
        
        
        
        Channel* channel = [Channel instanceFromDictionary:channelDictionary
                                 usingManagedObjectContext:managedObjectContext
                                       ignoringObjectTypes:(kIgnoreChannelOwnerObject)
                                                 andViewId:kProfileViewId];
        
        channel.channelOwner = self;
        
        [self addChannelsObject:channel];
        
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
    
    self.username = [dictionary objectForKey: @"username" withDefault:@""];

    self.emailAddress = [dictionary objectForKey: @"email" withDefault:@""];
    
    self.firstName = [dictionary objectForKey: @"first_name" withDefault:@""];
    
    self.lastName = [dictionary objectForKey: @"last_name" withDefault:@""];
    
    
    
    
    
    
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
    
    self.genderValue = GenderUndecided;
    
    
    
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

-(NSString*)fullName
{
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

- (NSString *) description
{
    NSMutableString* userDescription = [NSMutableString stringWithFormat:@"User (%i) - username: '%@'", [self.uniqueId intValue], self.username];
    
    [userDescription appendFormat:@"\nUser Channels (%i)", self.channels.count];
    
    if(self.channels.count == 0) {
        [userDescription appendString:@"."];
    } else {
        [userDescription appendString:@":"];
        for (Channel* channel in self.channels) {
            [userDescription appendFormat:@"\n - %@ (%@)", channel.title, [channel.subscribedByUser boolValue] ? @"Subscribed" : @"-"];
        }
    }
    
    
    return userDescription;
}

@end
