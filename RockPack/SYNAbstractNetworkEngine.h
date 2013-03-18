//
//  SYNAbstractNetworkEngine.h
//  rockpack
//
//  Created by Nick Banks on 18/03/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "MKNetworkEngine.h"
#import "SYNMainRegistry.h"
#import "SYNSearchRegistry.h"
#import "SYNUserInfoRegistry.h"

@interface SYNAbstractNetworkEngine : MKNetworkEngine

@property (nonatomic, strong) NSString *localeString;
@property (nonatomic, strong) SYNMainRegistry* registry;
@property (nonatomic, strong) SYNSearchRegistry* searchRegistry;
@property (nonatomic, strong) SYNUserInfoRegistry* userInfoRegistry;

- (id) initWithDefaultSettings;

- (NSString *) hostName;

@end
