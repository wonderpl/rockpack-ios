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

-(BOOL)registerAccessInfoFromDictionary:(NSDictionary *)dictionary
{
    
    
    if (!dictionary || ![dictionary isKindOfClass: [NSDictionary class]])
        return NO;
    
    
    
    lastReceivedAccessInfoObject = [AccessInfo instanceFromDictionary: dictionary
                                            usingManagedObjectContext: importManagedObjectContext];
    
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

    NSArray *matchingChannelEntries = [appDelegate.mainManagedObjectContext executeFetchRequest: channelFetchRequest
                                                                                          error: &error];
    
    if(error || !(matchingChannelEntries.count > 0))
        return nil;
    
    return matchingChannelEntries[0];
        
}

@end
