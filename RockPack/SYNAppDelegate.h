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
#import "User.h"
#import "SYNOAuth2Credential.h"
#import "SYNVideoQueue.h"
#import "SYNChannelManager.h"

#define kShowLoginPhase YES
#define kUsingProductionAPI YES

// Something new!

@class SYNContainerViewController, ChannelOwner, SYNNetworkEngine, SYNOAuthNetworkEngine;

@interface SYNAppDelegate : UIResponder <UIApplicationDelegate>

// Main app window
@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, readonly) SYNVideoQueue* videoQueue;

// Support for Core Data
@property (nonatomic, readonly) NSManagedObjectContext *mainManagedObjectContext;

@property (nonatomic, readonly) SYNChannelManager* channelManager;

@property (nonatomic, readonly) NSManagedObjectContext *searchManagedObjectContext;

@property (nonatomic, readonly) NSManagedObjectContext *channelsManagedObjectContext;

// Comms support
@property (readonly, nonatomic, strong) SYNNetworkEngine *networkEngine;
@property (readonly, nonatomic, strong) SYNOAuthNetworkEngine *oAuthNetworkEngine;
@property (readonly, nonatomic, strong) NSString *userAgentString;

@property (readonly, nonatomic, strong) User* currentUser;

@property (nonatomic, strong) SYNOAuth2Credential* currentOAuth2Credentials;

// Root view controller
@property (strong, nonatomic) UIViewController *masterViewController;


@property (readonly, nonatomic, strong) SYNMainRegistry* mainRegistry;
@property (readonly, nonatomic, strong) SYNSearchRegistry* searchRegistry;

@property (nonatomic, assign) BOOL searchRefreshDisabled;

- (void) deleteDataObject:(NSManagedObject*)managedObject;
- (void) saveContext: (BOOL) wait;
- (void) saveSearchContext;
- (void) saveChannelsContext;
- (void) clearCoreDataMainEntities:(BOOL)userBound;
- (void) logout;
- (void) resetCurrentOAuth2Credentials;


@end
