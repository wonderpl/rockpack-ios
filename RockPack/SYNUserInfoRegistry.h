//
//  SYNUserInfoRegistry.h
//  rockpack
//
//  Created by Michael Michailidis on 12/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNRegistry.h"
#import "AccessInfo.h"
#import "User.h"

@interface SYNUserInfoRegistry : SYNRegistry

@property (readonly, nonatomic, strong) AccessInfo* lastReceivedAccessInfoObject;
@property (readonly, nonatomic, strong) User* lastRegisteredUserObject;

-(BOOL)registerAccessInfoFromDictionary:(NSDictionary *)dictionary;
-(AccessInfo*)retrieveStoredAccessInfo;

-(BOOL)registerUserFromDictionary:(NSDictionary *)dictionary;

@end
