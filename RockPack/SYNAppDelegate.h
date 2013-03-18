//
//  SYNAppDelegate.h
//  RockPack
//
//  Created by Nick Banks on 12/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SYNMainRegistry.h"
#import "SYNSearchRegistry.h"
#import "SYNRegistry.h"
#import "AccessInfo.h"
#import "SYNUserInfoRegistry.h"
#import "User.h"

// Something new!

@class SYNBottomTabViewController, ChannelOwner, SYNNetworkEngine, SYNOAuthNetworkEngine;

@interface SYNAppDelegate : UIResponder <UIApplicationDelegate>

// Main app window
@property (strong, nonatomic) UIWindow *window;

// Support for Core Data
@property (nonatomic, readonly) NSManagedObjectContext *mainManagedObjectContext;

@property (nonatomic, readonly) NSManagedObjectContext *searchManagedObjectContext;

// Comms support
@property (readonly, nonatomic, strong) SYNNetworkEngine *networkEngine;
@property (readonly, nonatomic, strong) SYNOAuthNetworkEngine *oAuthNetworkEngine;

@property (readonly, nonatomic, strong) User* currentUser;
@property (readonly, nonatomic, strong) AccessInfo* currentAccessInfo;


// Root view controller
@property (strong, nonatomic) UIViewController *viewController;

// Bit of a hack to represent the current user
@property (weak, nonatomic) ChannelOwner *channelOwnerMe;

@property (readonly, nonatomic, strong) SYNMainRegistry* mainRegistry;
@property (readonly, nonatomic, strong) SYNSearchRegistry* searchRegistry;
@property (readonly, nonatomic, strong) SYNUserInfoRegistry* userRegistry;

- (void) saveContext: (BOOL) wait;
-(void) saveSearchContext;
- (void) resetCoreDataStack;

@end
