//
//  SYNUserInfoRegistry.h
//  rockpack
//
//  Created by Michael Michailidis on 12/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNRegistry.h"
#import "AccessInfo.h"

@interface SYNUserInfoRegistry : SYNRegistry

@property (readonly, nonatomic, strong) AccessInfo* lastReceivedAccessInfoObject;

-(BOOL)registerAccessInfoFromDictionary:(NSDictionary *)dictionary;
-(AccessInfo*)retrieveStoredAccessInfo;

@end
