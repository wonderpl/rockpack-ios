//
//  SYNUserInfoRegistry.m
//  rockpack
//
//  Created by Michael Michailidis on 12/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNUserInfoRegistry.h"
#import "SYNAppDelegate.h"


@interface SYNUserInfoRegistry ()



@end

@implementation SYNUserInfoRegistry

@synthesize lastReceivedAccessInfoObject;
@synthesize lastRegisteredUserObject;

#pragma mark - User

-(BOOL)registerUserFromDictionary:(NSDictionary *)dictionary
{
    
    if (!dictionary || ![dictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    lastRegisteredUserObject = [User instanceFromDictionary: dictionary
                                  usingManagedObjectContext: importManagedObjectContext];
    if(!lastRegisteredUserObject)
        return NO;
    
    BOOL saveResult = [self saveImportContext];
    if(!saveResult)
        return NO;
    
    
    [appDelegate saveContext: TRUE];
    
    
    return YES;
    
}

-(User*)retrieveCurrentUser
{
    NSError* error = nil;
    
    NSEntityDescription* accessInfoEntity = [NSEntityDescription entityForName: @"User"
                                                        inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    
    NSFetchRequest *userFetchRequest = [[NSFetchRequest alloc] init];
    [userFetchRequest setEntity: accessInfoEntity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"current == YES"];
    [userFetchRequest setPredicate: predicate];
    
    NSArray *matchingUserEntries = [appDelegate.mainManagedObjectContext executeFetchRequest: userFetchRequest
                                                                                          error: &error];
    if(error)
        return nil;
    
    if(!matchingUserEntries.count > 0)
        return nil;
    
    return (User*)(matchingUserEntries[0]);
}


#pragma mark - Access Info

-(BOOL)registerAccessInfoFromDictionary:(NSDictionary *)dictionary
{
    
    
    if (!dictionary || ![dictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    
    
    lastReceivedAccessInfoObject = [AccessInfo instanceFromDictionary: dictionary usingManagedObjectContext: importManagedObjectContext];
    if(!lastReceivedAccessInfoObject)
        return NO;
    
    BOOL saveResult = [self saveImportContext];
    if(!saveResult)
        return NO;
    
    
    [appDelegate saveContext: TRUE];
    
    
    
    return YES;
}

-(AccessInfo*)retrieveStoredAccessInfo
{
    NSError* error = nil;
    
    NSEntityDescription* accessInfoEntity = [NSEntityDescription entityForName: @"AccessInfo"
                                                        inManagedObjectContext: appDelegate.mainManagedObjectContext];


    NSFetchRequest *channelFetchRequest = [[NSFetchRequest alloc] init];
    [channelFetchRequest setEntity: accessInfoEntity];

    NSArray *matchingAccessInfoEntries = [appDelegate.mainManagedObjectContext executeFetchRequest: channelFetchRequest
                                                                                          error: &error];
    if(error)
        return nil;
    
    if(!matchingAccessInfoEntries.count > 0)
        return nil;
    
    return (AccessInfo*)(matchingAccessInfoEntries[0]);
        
}

@end
